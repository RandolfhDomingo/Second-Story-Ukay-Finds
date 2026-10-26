// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myapp/main.dart';
import 'package:myapp/shop_repository.dart';

const _testItems = [
  ShopItem(
    id: 'sunday-denim-jacket',
    name: 'Sunday denim jacket',
    category: 'Tops',
    price: 450,
    size: 'M',
    condition: 'Like new',
    imageUrl: '',
    tint: Color(0xFFE5E1D6),
    sortOrder: 0,
  ),
];

void main() {
  test('Firestore product documents map to shop items', () {
    final item = ShopItem.fromFirestore('denim-jacket', {
      'name': 'Denim jacket',
      'category': 'Tops',
      'price': 450,
      'size': 'M',
      'condition': 'Like new',
      'imageUrl': 'https://example.com/jacket.jpg',
      'tint': 'E5E1D6',
      'sortOrder': 0,
    });

    expect(item.id, 'denim-jacket');
    expect(item.price, 450);
    expect(item.tint, const Color(0xFFE5E1D6));
  });

  testWidgets('storefront fits tablet and phone widths', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 600);
    await tester.pumpWidget(MyApp(repository: _FakeShopRepository()));
    await tester.pumpAndSettle();

    expect(find.text('SECOND STORY'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(390, 844);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('reservation opens checkout with order details', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpWidget(MyApp(repository: _FakeShopRepository()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Add to bag').first);
    await tester.tap(find.text('Add to bag').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Open bag'));
    await tester.tap(find.byTooltip('Open bag'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Ari Santos');
    await tester.enterText(find.byType(TextFormField).at(1), '09123456789');
    await tester.ensureVisible(find.text('Place reservation'));
    await tester.tap(find.text('Place reservation'));
    await tester.pumpAndSettle();

    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Reservation received'), findsOneWidget);
    expect(find.text('Pay with Xendit'), findsNothing);
    expect(find.text('CONTACT & PAYMENT'), findsNothing);
    expect(find.text('Xendit secure checkout'), findsNothing);
    expect(find.text('Ari Santos'), findsOneWidget);
    expect(find.text('₱450'), findsWidgets);
    expect(find.text('Reservation received'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeShopRepository implements ShopRepository {
  @override
  Stream<List<ShopItem>> watchCatalog() => Stream.value(_testItems);

  @override
  Future<ReservationReceipt> createReservation({
    required String name,
    required String phone,
    required List<ReservationItem> items,
  }) async {
    return ReservationReceipt(
      id: 'test-reservation',
      total: items.fold(
        0,
        (total, line) => total + line.item.price * line.quantity,
      ),
      items: items,
    );
  }
}
