import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// --- IMPORT IYONG LOGIN PAGE FILE ---
import 'login_page.dart';

void main() {
  runApp(
    MaterialApp(
      // Inalis ang 'const' dito dahil ang LoginPage constructor ay maaaring hindi const
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$name added to cart!")));
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(onOrderPressed: addToCart),
      OrderScreen(orders: cartItems),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("My First Mobile App"),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => _onItemTapped(1),
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
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

// --- 1. HOME SCREEN ---
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
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  Future<List<dynamic>> getMenu() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost/flutter_api/get_menu.php"),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: getMenu(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No menu items found."));
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var item = snapshot.data![index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(
                        item['food_name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("P${item['price']}.00"),
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
        if (_isVisible)
          Container(
            width: double.infinity,
            color: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: const Text(
              "Login Successful!",
              style: TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }
}

// --- 2. ORDER SCREEN ---
class OrderScreen extends StatelessWidget {
  final List<Map<String, String>> orders;
  const OrderScreen({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            leading: Icon(Icons.shopping_basket_outlined, color: Colors.blue),
            title: Text(
              "Cart Items",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Your cart is empty",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(orders[index]['food_name']!),
                          subtitle: Text("Price: P${orders[index]['price']}"),
                          trailing: const Icon(
                            Icons.receipt_long,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// --- 3. PROFILE SCREEN ---
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(40),
              ),
            ),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 60, color: Colors.blue),
                ),
                SizedBox(height: 15),
                Text(
                  "RENZO PANOPIO",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "zorenpo@gmail.com",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const ProfileInfoTile(
            icon: Icons.phone,
            label: "Contact Number",
            value: "1234567890",
          ),
          const ProfileInfoTile(
            icon: Icons.location_on,
            label: "Address",
            value: "General Trias, Cavite",
          ),
          const ProfileInfoTile(
            icon: Icons.badge,
            label: "Username",
            value: "zoren_01",
          ),
          const Divider(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Profile"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      // Inalis ang 'const' dito para maayos ang diagnostic error
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }
}
