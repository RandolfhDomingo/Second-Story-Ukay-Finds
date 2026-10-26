import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShopItem {
  const ShopItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.size,
    required this.condition,
    required this.imageUrl,
    required this.tint,
    required this.sortOrder,
  });

  factory ShopItem.fromFirestore(String id, Map<String, dynamic> data) {
    final name = data['name'];
    final category = data['category'];
    final price = data['price'];
    final size = data['size'];
    final condition = data['condition'];
    final imageUrl = data['imageUrl'];
    final tintHex = data['tint'];
    final sortOrder = data['sortOrder'];

    if (name is! String ||
        category is! String ||
        price is! int ||
        price <= 0 ||
        size is! String ||
        condition is! String ||
        imageUrl is! String ||
        tintHex is! String ||
        !RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(tintHex) ||
        sortOrder is! int) {
      throw FormatException('Product "$id" has invalid or incomplete data.');
    }

    return ShopItem(
      id: id,
      name: name,
      category: category,
      price: price,
      size: size,
      condition: condition,
      imageUrl: imageUrl,
      tint: Color(int.parse('FF$tintHex', radix: 16)),
      sortOrder: sortOrder,
    );
  }

  final String id;
  final String name;
  final String category;
  final int price;
  final String size;
  final String condition;
  final String imageUrl;
  final Color tint;
  final int sortOrder;
}

class ReservationItem {
  const ReservationItem({
    required this.item,
    required this.quantity,
    this.unitPrice,
  });

  final ShopItem item;
  final int quantity;
  final int? unitPrice;
}

class ReservationReceipt {
  const ReservationReceipt({
    required this.id,
    required this.total,
    required this.items,
  });

  final String id;
  final int total;
  final List<ReservationItem> items;
}

abstract interface class ShopRepository {
  Stream<List<ShopItem>> watchCatalog();

  Future<ReservationReceipt> createReservation({
    required String name,
    required String phone,
    required List<ReservationItem> items,
  });
}

class FirebaseShopRepository implements ShopRepository {
  FirebaseShopRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<ShopItem>> watchCatalog() {
    return _firestore
        .collection('products')
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final products =
              snapshot.docs
                  .map(
                    (document) =>
                        ShopItem.fromFirestore(document.id, document.data()),
                  )
                  .toList()
                ..sort(
                  (left, right) => left.sortOrder.compareTo(right.sortOrder),
                );
          return products;
        });
  }

  @override
  Future<ReservationReceipt> createReservation({
    required String name,
    required String phone,
    required List<ReservationItem> items,
  }) async {
    if (items.isEmpty || items.length > 8) {
      throw ArgumentError.value(
        items.length,
        'items',
        'Must contain 1–8 lines.',
      );
    }
    final reservationItems = items.map((line) {
      if (line.quantity < 1 || line.quantity > 10) {
        throw ArgumentError.value(
          line.quantity,
          'quantity',
          'Must be between 1 and 10.',
        );
      }
      return ReservationItem(
        item: line.item,
        quantity: line.quantity,
        unitPrice: line.item.price,
      );
    }).toList();
    final total = reservationItems.fold<int>(
      0,
      (total, line) => total + line.item.price * line.quantity,
    );
    final phoneDigits = phone.trim().replaceAll(RegExp(r'\D'), '');
    final normalizedPhone = phone.trim().startsWith('+')
        ? '+$phoneDigits'
        : phoneDigits.startsWith('0')
        ? '+63${phoneDigits.substring(1)}'
        : '+$phoneDigits';
    final reservationRef = _firestore.collection('reservations').doc();
    await reservationRef.set({
      'name': name.trim(),
      'phone': normalizedPhone,
      'items': reservationItems
          .map(
            (line) => {
              'productId': line.item.id,
              'name': line.item.name,
              'quantity': line.quantity,
              'unitPrice': line.unitPrice,
              'lineTotal': line.item.price * line.quantity,
            },
          )
          .toList(),
      'total': total,
      'currency': 'PHP',
      'status': 'reserved',
      'paymentStatus': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ReservationReceipt(
      id: reservationRef.id,
      total: total,
      items: reservationItems,
    );
  }
}
