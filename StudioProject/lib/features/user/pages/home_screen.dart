import 'dart:async';
import 'package:coffee_shop_app/features/user/pages/order_screen.dart';
import 'package:coffee_shop_app/features/user/pages/profile_screen.dart';
import 'package:coffee_shop_app/features/user/pages/voucher_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'qr_scan_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  final List<String> _ads = [
    "assets/images/banner1.jpg",
    "assets/images/banner2.jpg",
    "assets/images/banner3.jpg",
  ];

  String displayName = 'User';

  List<Map<String, dynamic>> bestSeller = [];
  List<Map<String, dynamic>> bestCoffee = [];
  List<Map<String, dynamic>> spesialMenu = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
    _getUserName();
    _loadProducts();
  }

  void _getUserName() {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '';

    setState(() {
      displayName = email.contains('@')
          ? email.split('@')[0]
          : 'User';
    });
  }

  Future<void> _loadProducts() async {
    final seller = await _getProductsByCategory('best_seller');
    final coffe = await _getProductsByCategory('best_coffee');
    final special = await _getProductsByCategory('special_menu');

    setState(() {
      bestSeller = seller;
      bestCoffee = coffe;
      spesialMenu = special;
      isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> _getProductsByCategory(
      String category) async {
    final res = await Supabase.instance.client
        .from('products')
        .select()
        .eq('category', category)
        .limit(8);
    return List<Map<String, dynamic>>.from(res);
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentIndex < _ads.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }

      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spotlight =
        spesialMenu.isNotEmpty ? spesialMenu.first : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // --- HEADER ---
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    height: 250,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _ads.length,
                      onPageChanged: (index) {
                        setState(() => _currentIndex = index);
                      },
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                          child: Image.asset(
                            _ads[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        );
                      },
                    ),
                  ),

                  Positioned(
                    bottom: 15,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _ads.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentIndex == index ? 18 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                      ),
                    ),
                  ),

                  // USER BOX
                  Positioned(
                    bottom: -45,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Halo $displayName",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                    FontWeight.bold)),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const QrScanScreen(),
                                    )
                                  );
                                },
                                child: const Icon(
                                  CupertinoIcons.qrcode_viewfinder,
                                  size: 25,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 28),
                          const Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Mau Ngopi?, Pesan Disini",
                                style: TextStyle(
                                  fontWeight:
                                    FontWeight.w600),
                              ),
                              Icon(
                                CupertinoIcons.arrow_right,
                                size: 20),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 70),

              // --- SPECIAL MENU ---
              if (spotlight != null)
                Padding(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 16),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(25),
                        child: Image.network(
                          spotlight['image_url'] ?? '',
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) {
                            return Container(
                              height: 160,
                              color:
                              Colors.grey.shade300,
                             );
                            },
                        ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: 20,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton
                            .styleFrom(
                            backgroundColor:
                              const Color(
                                  0xFFCBB59A),
                            shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                  BorderRadius
                                    .circular(
                                    25),
                              ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets
                                .symmetric(
                                horizontal: 20,
                                vertical: 12),
                            child: Text(
                              "Order Now",
                              style: TextStyle(
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),

              const SizedBox(height: 30),

              _buildSection("Best Seller",
                  bestSeller),
              _buildSection("Best Coffee",
                  bestCoffee),
            ],
          ),
        ),
      ),

      // --- BOTTOM NAV ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color:
                Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          currentIndex: 0,
          selectedItemColor: Colors.brown,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            if (index == 1) {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const VoucherScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return child;
                  },
                ),
              );
            }

            if (index == 2) {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                  const OrderScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return child;
                  },
                ),
              );
            }

            if (index == 3) {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                  const ProfileScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return child;
                  },
                ),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon:
              Icon(CupertinoIcons.home),
              label: 'Home'),
            BottomNavigationBarItem(
                icon:
                Icon(CupertinoIcons.tickets),
                label: 'Voucher'),
            BottomNavigationBarItem(
                icon:
                Icon(CupertinoIcons.shopping_cart),
                label: 'Order'),
            BottomNavigationBarItem(
                icon:
                Icon(CupertinoIcons.profile_circled),
                label: 'Profile'),
          ],
        ),
      ),
    );
  }

  // --- PRODUCT SECTION ---
  Widget _buildSection(
      String title, List products) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: isLoading
              ? const Center(
              child:
              CircularProgressIndicator())
                : ListView.builder(
              scrollDirection:
              Axis.horizontal,
              itemCount:
              products.length,
              itemBuilder:
                  (context, index) {
                final item =
                    products[
                      index];

                return Container(
                  width: 150,
                  margin: const EdgeInsets
                      .only(
                      right:
                      12),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      ClipRRect(
                        borderRadius:
                        BorderRadius
                            .circular(
                            18),
                        child:
                        Image.network(
                          item['image_url'] ??
                            '',
                          height:
                          120,
                          width:
                          150,
                          fit:
                          BoxFit
                              .cover,
                          errorBuilder: (_,
                          __,
                          ___) {
                            return Container(
                              height:
                              120,
                              color:
                              Colors.grey.shade300,
                              child: const Icon(
                                  Icons.broken_image),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                          height:
                          6),
                      const Text(
                          "Coffee",
                          style:
                          TextStyle(
                              color:
                              Colors.grey,
                              fontSize:
                              12)),
                      Text(
                        item['name'],
                        style: const TextStyle(
                            fontWeight:
                            FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Rp ${item['price']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              print("Tambah ${item['name']}");
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
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
