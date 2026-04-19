import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'login_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _selectedIndex = 0;
  List<Map<String, String>> cartItems = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void addToCart(String name, String price) {
    setState(() {
      cartItems.add({"food_name": name, "price": price});
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blueAccent,
        content: Text("$name added to cart!"),
      ),
    );
  }

  double getTotalPrice() {
    double total = 0;
    for (var item in cartItems) {
      total += double.tryParse(item["price"] ?? "0") ?? 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onOrderPressed: addToCart),
      OrderScreen(orders: cartItems, totalPrice: getTotalPrice()),
      const ProfileScreen(),
    ];

    return Scaffold(
      // Set a dark background for the whole app to match your theme
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Canteen App"),
        centerTitle: true,
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0F172A),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Order',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ================= HOME SCREEN =================
class HomeScreen extends StatefulWidget {
  final Function(String, String) onOrderPressed;
  const HomeScreen({super.key, required this.onOrderPressed});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isVisible = false);
    });
  }

  Future<List<dynamic>> getMenu() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost/flutter_api/get_menu.php"),
      );
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) {
      debugPrint("API Error: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isVisible)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            color: Colors.greenAccent,
            child: const Center(
              child: Text(
                "Login Successful!",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: getMenu(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              final menu = snapshot.data!;
              return ListView.builder(
                itemCount: menu.length,
                itemBuilder: (context, index) {
                  final item = menu[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        item['food_name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "₱${item['price']}",
                        style: const TextStyle(color: Colors.blueAccent),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => widget.onOrderPressed(
                          item['food_name'],
                          item['price'].toString(),
                        ),
                        child: const Text("Order"),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ================= ORDER SCREEN =================
class OrderScreen extends StatelessWidget {
  final List<Map<String, String>> orders;
  final double totalPrice;
  const OrderScreen({
    super.key,
    required this.orders,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: orders.isEmpty
              ? const Center(
                  child: Text(
                    "Your cart is empty",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.fastfood,
                          color: Colors.blueAccent,
                        ),
                        title: Text(
                          orders[index]['food_name']!,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: Text(
                          "₱${orders[index]['price']}",
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TOTAL:",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                "₱${totalPrice.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ================= UPDATED VISIBLE PROFILE =================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40, bottom: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 52,
                    backgroundColor: Color(0xFF0F172A),
                    child: Icon(Icons.person, size: 65, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "KURT ATIENZA",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "BSIT Student • Canteen App User",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Info Tiles
          const ProfileInfoTile(
            icon: Icons.person_outline,
            label: "Full Name",
            value: "Kurt Rainier Atienza",
          ),
          const ProfileInfoTile(
            icon: Icons.school_outlined,
            label: "Course",
            value: "BS Computer Science",
          ),
          const ProfileInfoTile(
            icon: Icons.email_outlined,
            label: "Email",
            value: "kurt.atienza@student.ph",
          ),
          const ProfileInfoTile(
            icon: Icons.phone_android_outlined,
            label: "Contact",
            value: "0917-555-8899",
          ),
          const ProfileInfoTile(
            icon: Icons.location_on_outlined,
            label: "Address",
            value: "Parian Calamba",
          ),

          const SizedBox(height: 30),

          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Edit Profile",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Logout",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blueAccent),
        ),
        title: Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
