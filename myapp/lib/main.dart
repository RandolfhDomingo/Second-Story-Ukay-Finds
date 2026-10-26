import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

const _ink = Color(0xFF17241E);
const _paper = Color(0xFFF7F5EF);
const _accent = Color(0xFFE36B4B);
const _muted = Color(0xFF777D73);
const _green = Color(0xFF667E64);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Second Story Ukay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _green, surface: _paper),
        scaffoldBackgroundColor: _paper,
        useMaterial3: true,
      ),
      home: const Storefront(),
    );
  }
}

class ShopItem {
  const ShopItem({
    required this.name,
    required this.category,
    required this.price,
    required this.size,
    required this.condition,
    required this.imageUrl,
    required this.tint,
  });

  final String name;
  final String category;
  final int price;
  final String size;
  final String condition;
  final String imageUrl;
  final Color tint;
}

const _items = [
  ShopItem(
    name: 'Sunday denim jacket',
    category: 'Tops',
    price: 450,
    size: 'M',
    condition: 'Like new',
    imageUrl:
        'https://images.unsplash.com/photo-1543076447-215ad9ba6923?auto=format&fit=crop&w=900&q=85',
    tint: Color(0xFFE5E1D6),
  ),
  ShopItem(
    name: 'Soft knit cardigan',
    category: 'Tops',
    price: 380,
    size: 'S',
    condition: 'Great',
    imageUrl:
        'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?auto=format&fit=crop&w=900&q=85',
    tint: Color(0xFFE8DDD1),
  ),
  ShopItem(
    name: 'Everyday straight jeans',
    category: 'Bottoms',
    price: 520,
    size: '28',
    condition: 'Like new',
    imageUrl:
        'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&w=900&q=85',
    tint: Color(0xFFDDE3E1),
  ),
  ShopItem(
    name: 'Little black dress',
    category: 'Dresses',
    price: 490,
    size: 'S',
    condition: 'Great',
    imageUrl:
        'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=900&q=85',
    tint: Color(0xFFE9DCD5),
  ),
  ShopItem(
    name: 'Weekend linen shirt',
    category: 'Tops',
    price: 320,
    size: 'L',
    condition: 'Great',
    imageUrl:
        'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?auto=format&fit=crop&w=900&q=85',
    tint: Color(0xFFE8E5D8),
  ),
  ShopItem(
    name: 'Classic pleated skirt',
    category: 'Bottoms',
    price: 350,
    size: 'M',
    condition: 'Like new',
    imageUrl:
        'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?auto=format&fit=crop&w=900&q=85',
    tint: Color(0xFFE5DCE0),
  ),
  ShopItem(
    name: 'Floral day dress',
    category: 'Dresses',
    price: 420,
    size: 'M',
    condition: 'Great',
    imageUrl:
        'https://images.unsplash.com/photo-1612336307429-8a898d10e223?auto=format&fit=crop&w=900&q=85',
    tint: Color(0xFFE7DED1),
  ),
  ShopItem(
    name: 'Canvas market tote',
    category: 'Accessories',
    price: 180,
    size: 'One size',
    condition: 'Great',
    imageUrl:
        'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=900&q=85',
    tint: Color(0xFFDFE3D8),
  ),
];

class Storefront extends StatefulWidget {
  const Storefront({super.key});

  @override
  State<Storefront> createState() => _StorefrontState();
}

class _StorefrontState extends State<Storefront> {
  final _searchController = TextEditingController();
  final _catalogKey = GlobalKey();
  String _category = 'All finds';
  String _query = '';
  String _paymentMethod = 'Cash';
  final Set<String> _saved = {};
  final Map<String, int> _bag = {};

  int get _bagCount => _bag.values.fold(0, (total, count) => total + count);

  int get _bagTotal => _bag.entries.fold(0, (total, entry) {
    final item = _items.firstWhere((item) => item.name == entry.key);
    return total + item.price * entry.value;
  });

  List<ShopItem> get _visibleItems => _items.where((item) {
    final matchesCategory =
        _category == 'All finds' || item.category == _category;
    final matchesQuery = item.name.toLowerCase().contains(_query.toLowerCase());
    return matchesCategory && matchesQuery;
  }).toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToBag(ShopItem item) {
    setState(
      () => _bag.update(item.name, (count) => count + 1, ifAbsent: () => 1),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${item.name} added to your bag'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _scrollToCatalog() {
    final context = _catalogKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showBag() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => _BagSheet(
          bag: _bag,
          total: _bagTotal,
          paymentMethod: _paymentMethod,
          onPaymentChanged: (method) {
            setState(() => _paymentMethod = method);
            setSheetState(() {});
          },
          onQuantityChanged: (name, change) {
            setState(() {
              final quantity = (_bag[name] ?? 0) + change;
              if (quantity <= 0) {
                _bag.remove(name);
              } else {
                _bag[name] = quantity;
              }
            });
            setSheetState(() {});
          },
          onCheckout: (name, phone) {
            final orderTotal = _bagTotal;
            final itemCount = _bagCount;
            final paymentMethod = _paymentMethod;
            setState(_bag.clear);
            Navigator.pop(context);
            showDialog<void>(
              context: this.context,
              builder: (context) => AlertDialog(
                backgroundColor: _paper,
                icon: const Icon(
                  Icons.check_circle_outline,
                  color: _green,
                  size: 34,
                ),
                title: const Text('Reservation received'),
                content: Text(
                  'Thanks, $name! We reserved $itemCount ${itemCount == 1 ? 'piece' : 'pieces'} for ₱$orderTotal.\n\n'
                  'Payment: $paymentMethod\nContact: $phone\n\n'
                  '${paymentMethod == 'Cash' ? 'Pay when you pick up your finds.' : 'The shop will contact you with transfer details.'}',
                ),
                actions: [
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLocation() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _paper,
        icon: const Icon(Icons.location_on_outlined, color: _accent, size: 30),
        title: const Text('Visit Second Story'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'San Juan, Metro Manila',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text('Tuesday to Sunday, 10 AM–6 PM'),
            SizedBox(height: 12),
            Text(
              'This is a sample location. Update it with your shop address before publishing.',
              style: TextStyle(color: _muted, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final columns = constraints.maxWidth >= 1100
                ? 4
                : constraints.maxWidth >= 760
                ? 3
                : 2;
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: wide ? 48 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(wide),
                        const SizedBox(height: 26),
                        _buildHero(wide),
                        const SizedBox(height: 48),
                        _buildCatalogHeader(wide),
                        const SizedBox(height: 18),
                        _buildCategories(),
                        const SizedBox(height: 22),
                        if (_visibleItems.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 48),
                            child: Center(
                              child: Text('No finds match that search.'),
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _visibleItems.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: wide ? 20 : 12,
                                  mainAxisSpacing: 28,
                                  childAspectRatio: wide ? 0.68 : 0.62,
                                ),
                            itemBuilder: (context, index) => _ProductTile(
                              item: _visibleItems[index],
                              isSaved: _saved.contains(
                                _visibleItems[index].name,
                              ),
                              onSave: () => setState(() {
                                final name = _visibleItems[index].name;
                                _saved.contains(name)
                                    ? _saved.remove(name)
                                    : _saved.add(name);
                              }),
                              onAdd: () => _addToBag(_visibleItems[index]),
                            ),
                          ),
                        const SizedBox(height: 54),
                        _buildVisitSection(wide),
                        const SizedBox(height: 24),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool wide) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _ink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.change_history_rounded,
              color: _paper,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SECOND STORY',
                style: TextStyle(
                  color: _ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                'UKAY FINDS',
                style: TextStyle(
                  color: _muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.1,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (wide) ...[
            TextButton(
              onPressed: _scrollToCatalog,
              child: const Text('Shop all'),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: _showLocation,
              icon: const Icon(Icons.location_on_outlined, size: 15),
              label: const Text('San Juan, Manila'),
              style: TextButton.styleFrom(
                foregroundColor: _muted,
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(width: 20),
          ],
          SizedBox(
            width: wide ? 220 : 40,
            height: 40,
            child: wide
                ? TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Find something lovely',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  )
                : IconButton(
                    tooltip: 'Search items',
                    onPressed: () => _showSearch(context),
                    icon: const Icon(Icons.search),
                  ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Open bag',
            onPressed: _showBag,
            icon: Badge(
              isLabelVisible: _bagCount > 0,
              label: Text('$_bagCount'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _paper,
        title: const Text('Find a piece'),
        content: TextField(
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: (value) => setState(() => _query = value),
          decoration: const InputDecoration(hintText: 'Try “denim” or “dress”'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(bool wide) {
    final photo = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=1400&q=90',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFFD8DED2),
              child: const Icon(Icons.checkroom, size: 72, color: _green),
            ),
          ),
          const Positioned(
            right: 18,
            top: 18,
            child: CircleAvatar(
              radius: 36,
              backgroundColor: _paper,
              child: Text(
                'GOOD\nAS NEW',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ink,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8E9DF),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: wide
          ? SizedBox(
              height: 370,
              child: Row(
                children: [
                  Expanded(flex: 5, child: _heroCopy()),
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox.expand(child: photo),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 18),
                  child: _heroCopy(),
                ),
                SizedBox(
                  height: 225,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: photo,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _heroCopy() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Text(
              'PRELOVED, NOT PRE-LOVED',
              style: TextStyle(
                fontSize: 9,
                color: _green,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Fresh finds.\nSecond lives.',
            style: TextStyle(
              fontFamily: 'Georgia',
              color: _ink,
              fontSize: 42,
              height: 1.02,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'One-of-a-kind pieces, picked with care and ready for their next story.',
            style: TextStyle(color: _muted, height: 1.5, fontSize: 13),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _scrollToCatalog,
            icon: const Icon(Icons.arrow_downward_rounded, size: 17),
            label: const Text('Explore the rack'),
            style: FilledButton.styleFrom(
              backgroundColor: _ink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogHeader(bool wide) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            key: _catalogKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'THE LATEST RACK',
                style: TextStyle(
                  color: _accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.7,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Good clothes, good finds',
                style: TextStyle(
                  color: _ink,
                  fontFamily: 'Georgia',
                  fontSize: wide ? 30 : 25,
                ),
              ),
            ],
          ),
        ),
        if (wide)
          Text(
            '${_visibleItems.length} handpicked pieces',
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
      ],
    );
  }

  Widget _buildCategories() {
    const categories = [
      'All finds',
      'Tops',
      'Bottoms',
      'Dresses',
      'Accessories',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final selected = _category == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: selected,
              onSelected: (_) => setState(() => _category = category),
              showCheckmark: false,
              labelStyle: TextStyle(
                color: selected ? Colors.white : _ink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              selectedColor: _ink,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected ? _ink : const Color(0xFFE6E3DB),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVisitSection(bool wide) {
    return Container(
      padding: EdgeInsets.all(wide ? 26 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E9DF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: wide
          ? Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: _accent,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(child: _VisitCopy()),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _showLocation,
                  icon: const Icon(Icons.info_outline, size: 17),
                  label: const Text('Shop details'),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: _accent,
                  size: 26,
                ),
                const SizedBox(height: 10),
                const _VisitCopy(),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _showLocation,
                  icon: const Icon(Icons.info_outline, size: 17),
                  label: const Text('Shop details'),
                ),
              ],
            ),
    );
  }

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 30, top: 6),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 12,
        children: [
          Text(
            'SECOND STORY  /  UKAY FINDS',
            style: TextStyle(
              color: _ink,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          Text(
            'Cash  ·  GCash  ·  Bank transfer',
            style: TextStyle(color: _muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _VisitCopy extends StatelessWidget {
  const _VisitCopy();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Come browse in person',
          style: TextStyle(color: _ink, fontFamily: 'Georgia', fontSize: 21),
        ),
        SizedBox(height: 5),
        Text(
          'San Juan, Metro Manila  ·  Tue–Sun, 10 AM–6 PM',
          style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
        ),
        Text(
          'Sample shop location. Replace with your address.',
          style: TextStyle(color: _muted, fontSize: 10),
        ),
      ],
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.item,
    required this.isSaved,
    required this.onSave,
    required this.onAdd,
  });

  final ShopItem item;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: item.tint,
                    child: const Center(
                      child: Icon(Icons.checkroom, color: _green, size: 42),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 9,
                top: 9,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _paper.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.condition.toUpperCase(),
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: IconButton.filledTonal(
                  tooltip: isSaved ? 'Remove saved item' : 'Save item',
                  onPressed: onSave,
                  icon: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: isSaved ? _accent : _ink,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: _paper.withValues(alpha: 0.92),
                    minimumSize: const Size(34, 34),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '₱${item.price}',
              style: const TextStyle(
                color: _ink,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          '${item.category}  ·  Size ${item.size}',
          style: const TextStyle(color: _muted, fontSize: 10),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 34,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 15),
            label: const Text('Add to bag', style: TextStyle(fontSize: 11)),
            style: OutlinedButton.styleFrom(
              foregroundColor: _ink,
              side: const BorderSide(color: Color(0xFFD7D5CC)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BagSheet extends StatefulWidget {
  const _BagSheet({
    required this.bag,
    required this.total,
    required this.paymentMethod,
    required this.onPaymentChanged,
    required this.onQuantityChanged,
    required this.onCheckout,
  });

  final Map<String, int> bag;
  final int total;
  final String paymentMethod;
  final ValueChanged<String> onPaymentChanged;
  final void Function(String name, int change) onQuantityChanged;
  final void Function(String name, String phone) onCheckout;

  @override
  State<_BagSheet> createState() => _BagSheetState();
}

class _BagSheetState extends State<_BagSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bag = widget.bag;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(22, 12, 22, 20 + bottomInset),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7D5CC),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Your bag  ·  ${bag.values.fold(0, (a, b) => a + b)}',
                style: const TextStyle(
                  color: _ink,
                  fontFamily: 'Georgia',
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 12),
              if (bag.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Text(
                    'Your bag is waiting for a good find.',
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: bag.entries.map((entry) {
                      final item = _items.firstWhere(
                        (item) => item.name == entry.key,
                      );
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text('₱${item.price} each'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () =>
                                  widget.onQuantityChanged(item.name, -1),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('${entry.value}'),
                            IconButton(
                              onPressed: () =>
                                  widget.onQuantityChanged(item.name, 1),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              const Divider(height: 24),
              const Text(
                'PAYMENT METHOD',
                style: TextStyle(
                  color: _muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Cash', 'GCash', 'Bank transfer'].map((method) {
                  final selected = widget.paymentMethod == method;
                  return ChoiceChip(
                    label: Text(method),
                    selected: selected,
                    onSelected: (_) => widget.onPaymentChanged(method),
                    showCheckmark: false,
                    selectedColor: _ink,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : _ink,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Your name',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Enter your name'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Mobile number',
                        hintText: '09xx xxx xxxx',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value == null || value.trim().length < 7
                          ? 'Enter a valid contact number'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 17),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Total',
                      style: TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '₱${widget.total}',
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: bag.isEmpty
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          widget.onCheckout(
                            _nameController.text.trim(),
                            _phoneController.text.trim(),
                          );
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: _ink,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Place reservation'),
              ),
              const SizedBox(height: 5),
              Text(
                widget.paymentMethod == 'Cash'
                    ? 'Pay in cash when you pick up your order.'
                    : 'The shop will send ${widget.paymentMethod} payment details after reservation.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: _muted, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
