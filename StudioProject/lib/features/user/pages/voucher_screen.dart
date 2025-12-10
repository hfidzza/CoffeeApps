import 'package:coffee_shop_app/features/user/pages/home_screen.dart';
import 'package:coffee_shop_app/features/user/pages/order_screen.dart';
import 'package:coffee_shop_app/features/user/pages/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:simple_ticket_widget/simple_ticket_widget.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  final supabase = Supabase.instance.client;

  List vouchers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchVouchers();
  }

  Future<void> fetchVouchers() async {
    setState(() => loading = true);
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() => loading = false);
      return;
    }

    final res = await supabase
        .from('user_vouchers')
        .select('id, is_used, vouchers(*)')
        .eq('user_id', user.id)
        .eq('is_used', false)
        .order('created_at', ascending: false);

    setState(() {
      vouchers = List.from(res ?? []);
      loading = false;
    });
  }

  String formatPrice(dynamic value) {
    final number = double.tryParse(value?.toString() ?? '0') ?? 0;
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  String formatDate(dynamic dateValue) {
    try {
      if (dateValue == null) return '-';
      // support String or DateTime
      DateTime parsed;
      if (dateValue is String) {
        parsed = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        parsed = dateValue;
      } else {
        return '-';
      }
      // gunakan locale id_ID (pastikan sudah inisialisasi di main.dart)
      return DateFormat('dd MMM yyyy', 'id_ID').format(parsed);
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black..withOpacity(0.20),
                blurRadius: 30,
                offset: const Offset(0, -20),
              ),
            ],
          ),

          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "VOUCHER",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          currentIndex: 1,
          selectedItemColor: Colors.brown,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            if (index == 0) {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const HomeScreen(),
                  transitionsBuilder: (_, __, ___, child) => child,
                ),
              );
            }

            if (index == 2) {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const OrderScreen(),
                  transitionsBuilder: (_, __, ___, child) => child,
                ),
              );
            }

            if (index == 3) {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const ProfileScreen(),
                  transitionsBuilder: (_, __, ___, child) => child,
                ),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.tickets),
              label: 'Voucher',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.shopping_cart),
              label: 'Order',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.profile_circled),
              label: 'Profile',
            ),
          ],
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : vouchers.isEmpty
          ? const Center(
        child: Text(
          "Belum ada voucher",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Voucher Dine-In",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "${vouchers.length} item",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          ...vouchers.map((data) {
            final voucher = data['vouchers'] ?? {};
            final userVoucherId = data['id'];
            return _voucherCard(userVoucherId, voucher);
          }).toList()
        ],
      ),
    );
  }

  // VOUCHER CARD
  Widget _voucherCard(int userVoucherId, Map voucher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),

        child: SimpleTicketWidget(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: const BoxDecoration(
              color: Color(0xFF6F4E37),
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- LAYER ATAS ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      alignment: Alignment.center,
                      child: const RotatedBox(
                        quarterTurns: -1,
                        child: Text(
                          "VOUCHER",
                          style: TextStyle(
                            color: Colors.white70,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voucher['title'] ?? 'Voucher',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 10),

                          Text(
                            voucher['description']
                                ?? "Maksimum ${formatPrice(voucher['max_discount'])}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // --- GARIS PUTUS ---
                Row(
                  children: List.generate(
                    32,
                      (index) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          height: 1,
                          color: index.isEven
                            ? Colors.white.withOpacity(0.9)
                              : Colors.transparent,
                        ),
                      ),
                  ),
                ),

                const SizedBox(height: 14),

                // --- LAYER BAWAH ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    _infoCol(
                      "Berlaku Hingga",
                      formatDate(voucher['valid_until']),
                      color: Colors.white,
                    ),

                    ElevatedButton(
                      onPressed: () => useVoucher(userVoucherId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD7B899),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        "Pakai",
                        style: TextStyle(
                          color: Color(0xFF4E342E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCol(String title, String value, {Color color = Colors.black}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: color,
          ),
        ),
      ],
    );
  }


  Future<void> useVoucher(int userVoucherId) async {
    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      await supabase.from('user_vouchers').update({
        'is_used': true,
        'used_at': DateTime.now().toIso8601String(),
      }).eq('id', userVoucherId);

      Navigator.pop(context);
      await fetchVouchers();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Voucher berhasil dipakai")));
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    }
  }
}
