const {initializeApp} = require("firebase-admin/app");
const {FieldValue, getFirestore} =
  require("firebase-admin/firestore");
const {HttpsError, onCall} = require("firebase-functions/v2/https");

initializeApp();
const db = getFirestore();

function validateCustomer(name, phone) {
  if (typeof name !== "string" || name.trim().length < 1 ||
      name.trim().length > 100) {
    throw new HttpsError("invalid-argument", "Enter a valid name.");
  }
  if (typeof phone !== "string" ||
      phone.trim().replace(/[^\d]/g, "").length < 7 ||
      phone.trim().length > 30) {
    throw new HttpsError("invalid-argument", "Enter a valid phone number.");
  }

  const phoneDigits = phone.trim().replace(/[^\d]/g, "");
  let mobileNumber;
  if (phone.trim().startsWith("+") && phoneDigits.length <= 15) {
    mobileNumber = `+${phoneDigits}`;
  } else if (phoneDigits.startsWith("0") && phoneDigits.length >= 10) {
    mobileNumber = `+63${phoneDigits.slice(1)}`;
  } else if (phoneDigits.startsWith("63") && phoneDigits.length <= 15) {
    mobileNumber = `+${phoneDigits}`;
  } else {
    throw new HttpsError(
        "invalid-argument",
        "Enter a phone number with a country code or a Philippine mobile number.",
    );
  }
  return {name: name.trim(), mobileNumber};
}

function validateItems(items) {
  if (!Array.isArray(items) || items.length < 1 || items.length > 8) {
    throw new HttpsError("invalid-argument", "Your bag is empty or invalid.");
  }
  const seenIds = new Set();
  for (const item of items) {
    if (typeof item?.productId !== "string" ||
        !/^[A-Za-z0-9_-]{1,128}$/.test(item.productId) ||
        seenIds.has(item.productId) ||
        !Number.isSafeInteger(item.quantity) ||
        item.quantity < 1 || item.quantity > 10) {
      throw new HttpsError("invalid-argument", "An item in your bag is invalid.");
    }
    seenIds.add(item.productId);
  }
}

exports.createReservation = onCall(
    {
      region: "us-central1",
      maxInstances: 5,
    },
    async (request) => {
      const customer = validateCustomer(
          request.data?.name,
          request.data?.phone,
      );
      const {items} = request.data ?? {};
      validateItems(items);

      const reservationRef = db.collection("reservations").doc();
      const productRefs = items.map(({productId}) =>
        db.collection("products").doc(productId));
      let reservation;
      await db.runTransaction(async (transaction) => {
        const productDocs = [];
        for (const productRef of productRefs) {
          productDocs.push(await transaction.get(productRef));
        }
        const reservationItems = [];
        let total = 0;
        for (let index = 0; index < productDocs.length; index++) {
          const productDoc = productDocs[index];
          const quantity = items[index].quantity;
          const product = productDoc.data();
          if (!productDoc.exists || product.active !== true ||
              typeof product.name !== "string" ||
              !Number.isSafeInteger(product.price) || product.price <= 0) {
            throw new HttpsError(
                "failed-precondition",
                "A product is no longer available. Refresh the catalog and try again.",
            );
          }
          const lineTotal = product.price * quantity;
          total += lineTotal;
          reservationItems.push({
            productId: productDoc.id,
            name: product.name,
            quantity,
            unitPrice: product.price,
            lineTotal,
          });
        }
        if (!Number.isSafeInteger(total) || total <= 0) {
          throw new HttpsError("invalid-argument", "The order total is invalid.");
        }

        reservation = {
          name: customer.name,
          phone: customer.mobileNumber,
          items: reservationItems,
          total,
          currency: "PHP",
          status: "reserved",
          paymentStatus: "pending",
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        };
        transaction.create(reservationRef, reservation);
      });

      return {
        reservationId: reservationRef.id,
        total: reservation.total,
        items: reservation.items.map((item) => ({
          productId: item.productId,
          name: item.name,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
        })),
      };
    },
);
