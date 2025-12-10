import 'package:coffee_shop_app/features/user/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/cupertino.dart';

class MenuPage extends StatefulWidget {
  final int tableNumber;

  const MenuPage({super.key, required this.tableNumber});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final supabase = Supabase.instance.client;
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> products = [];
  List<String> categories = ['All'];
  String selectedCategory = 'All';

  final Map<String, GlobalKey> _categoryKeys = {};

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_handleScroll);
  }

  // --- LOAD PRODUCTS ---
  Future<void> _loadProducts() async {
    final response = await supabase
        .from('menu_products')
        .select()
        .order('category', ascending: true);

    final data = List<Map<String, dynamic>>.from(response);

    final uniqueCategories = data
        .map((e) => e['category'].toString())
        .toSet()
        .toList();

    for (var cat in uniqueCategories) {
      _categoryKeys[cat] = GlobalKey();
    }

    setState(() {
      products = data;
      categories = ['All', ...uniqueCategories];
    });
  }

  // --- SCROLL LISTENER ---
  void _handleScroll() {
    for (String cat in _categoryKeys.keys) {
      final key = _categoryKeys[cat];
      if (key == null) continue;

      final context = key.currentContext;
      if (context == null) continue;

      final box = context.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero).dy;

      if (position < 200 && position > 0) {
        if (selectedCategory != cat) {
          setState(() => selectedCategory = cat);
        }
      }
    }
  }

  // --- FILTER ---
  List<Map<String, dynamic>> get specialProducts {
    return products.take(6).toList();
  }

  List<String> get realCategories {
    return categories.where((e) => e != 'All').toList();
  }

  List<Map<String, dynamic>> productsByCategory(String cat) {
    return products.where((e) => e['category'] == cat).toList();
  }

  void scrollToCategory(String category) {
    final key = _categoryKeys[category];
    if (key == null) return;

    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // --- HEADER AND CATEGORY ---
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            )
                          );
                        },
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 35),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Dine-In",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 35),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "No. Meja ${widget.tableNumber}",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Helvetica"),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),
                      const Icon(CupertinoIcons.search, size: 22),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                const Padding(
                  padding: EdgeInsets.only(left: 70),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Jika pindah meja konfirmasi ke kasir",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // CATEGORY BAR
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isActive = cat == selectedCategory;

                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isActive,
                          backgroundColor: Colors.white,
                          selectedColor: Colors.black87,
                          labelStyle: TextStyle(
                            color: isActive
                                ? Colors.white
                                : Colors.black),
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: isActive
                                  ? Colors.black
                                  : Colors.grey),
                          ),
                          onSelected: (_) {
                            setState(() => selectedCategory = cat);
                            if (cat != "All") {
                              scrollToCategory(cat);
                            } else {
                              _scrollController.animateTo(0,
                                  duration:
                                      const Duration(milliseconds: 400),
                                  curve: Curves.easeOut);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- CONTENT ---
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Special For You!",
                      style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text("${specialProducts.length} item"),
                  ],
                ),

                const SizedBox(height: 0),

                GridView.builder(
                  itemCount: specialProducts.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      mainAxisExtent: 280,
                  ),
                  itemBuilder: (context, index) {
                    return _gridItem(specialProducts[index]);
                  },
                ),

                const SizedBox(height: 5),

                // CATEGORY LISTVIEW
                ...realCategories.map((cat) {
                  final list = productsByCategory(cat);

                  if (list.isEmpty) return const SizedBox();

                  return Column(
                    key: _categoryKeys[cat],
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cat,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                          ),
                          Text("${list.length} item"),
                        ],
                      ),

                      const Divider(),

                      const SizedBox(height: 0),

                      ListView.separated(
                        shrinkWrap: true,
                        physics:
                          const NeverScrollableScrollPhysics(),
                        itemCount: list.length,
                        separatorBuilder: (c, i) =>
                            const Divider(height: 30),
                        itemBuilder: (context, index) {
                          return _listItem(list[index]);
                        },
                      ),

                      const SizedBox(height: 0),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- GRID ITEM ---
  Widget _gridItem(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(
                data['image_url']
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(data['category'] ?? "",
            style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          data['name'],
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Rp ${data['price']}",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            GestureDetector(
              onTap: () {
                print("Tambah ${data['name']}");
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFCBB59A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.add_circled,
                  size: 25,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- LIST ITEM ---
  Widget _listItem(Map<String, dynamic> data) {
    return Row(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(
                data['image_url']
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                  const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "⭐ Most Favorite",
                  style: TextStyle(fontSize: 11),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                data['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold),
              ),
              Text(
                data['description'] ?? "",
                style: const TextStyle(
                    fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Rp ${data['price']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print("Tambah ${data['name']}");
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFCBB59A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.add_circled,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
