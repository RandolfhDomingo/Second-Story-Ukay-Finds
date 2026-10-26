const {applicationDefault, initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

const projectArgument = process.argv.find((argument) =>
  argument.startsWith("--project="));
const projectId = projectArgument?.slice("--project=".length);
if (!projectId) {
  throw new Error("Pass the Firebase project with --project=PROJECT_ID.");
}

initializeApp({
  credential: applicationDefault(),
  projectId,
});

const products = [
  {
    id: "sunday-denim-jacket",
    name: "Sunday denim jacket",
    category: "Tops",
    price: 450,
    size: "M",
    condition: "Like new",
    imageUrl:
      "https://images.unsplash.com/photo-1543076447-215ad9ba6923?auto=format&fit=crop&w=900&q=85",
    tint: "E5E1D6",
  },
  {
    id: "soft-knit-cardigan",
    name: "Soft knit cardigan",
    category: "Tops",
    price: 380,
    size: "S",
    condition: "Great",
    imageUrl:
      "https://images.unsplash.com/photo-1434389677669-e08b4cac3105?auto=format&fit=crop&w=900&q=85",
    tint: "E8DDD1",
  },
  {
    id: "everyday-straight-jeans",
    name: "Everyday straight jeans",
    category: "Bottoms",
    price: 520,
    size: "28",
    condition: "Like new",
    imageUrl:
      "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&w=900&q=85",
    tint: "DDE3E1",
  },
  {
    id: "little-red-dress",
    name: "Little red dress",
    category: "Dresses",
    price: 490,
    size: "S",
    condition: "Great",
    imageUrl:
      "https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=900&q=85",
    tint: "E9DCD5",
  },
  {
    id: "weekend-linen-shirt",
    name: "Weekend linen shirt",
    category: "Tops",
    price: 320,
    size: "L",
    condition: "Great",
    imageUrl:
      "https://images.unsplash.com/photo-1598033129183-c4f50c736f10?auto=format&fit=crop&w=900&q=85",
    tint: "E8E5D8",
  },
  {
    id: "classic-pleated-skirt",
    name: "Classic pleated skirt",
    category: "Bottoms",
    price: 350,
    size: "M",
    condition: "Like new",
    imageUrl:
      "https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?auto=format&fit=crop&w=900&q=85",
    tint: "E5DCE0",
  },
  {
    id: "floral-day-dress",
    name: "Floral day dress",
    category: "Dresses",
    price: 420,
    size: "M",
    condition: "Great",
    imageUrl:
      "https://images.unsplash.com/photo-1612336307429-8a898d10e223?auto=format&fit=crop&w=900&q=85",
    tint: "E7DED1",
  },
  {
    id: "canvas-market-tote",
    name: "Canvas market tote",
    category: "Accessories",
    price: 180,
    size: "One size",
    condition: "Great",
    imageUrl:
      "https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=900&q=85",
    tint: "DFE3D8",
  },
].map(({id, ...product}, sortOrder) => ({
  id,
  data: {
    ...product,
    sortOrder,
    active: true,
  },
}));

async function seedCatalog() {
  const db = getFirestore();
  const batch = db.batch();
  for (const product of products) {
    batch.set(db.collection("products").doc(product.id), product.data, {
      merge: true,
    });
  }
  await batch.commit();
  console.log(`Seeded ${products.length} products in ${projectId}.`);
}

seedCatalog().catch((error) => {
  console.error("Could not seed Firestore catalog.", error);
  process.exitCode = 1;
});
