import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'produk.dart';
import 'user.dart';
import 'pelanggan.dart'; // Tambahkan import ini

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    ProductsPage(),
    UsersPage(),
    CustomersPage(), // 🔹 Tambahkan halaman pelanggan di sini
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${widget.username}"),
        backgroundColor: Color.fromARGB(255, 143, 101, 11),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final supabase = Supabase.instance.client;
              await supabase.auth.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
          )
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Produk'),
          BottomNavigationBarItem(icon: Icon(Icons.app_registration), label: 'Registrasi'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Pelanggan'), // Tambah icon pelanggan
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 163, 129, 35),
        onTap: _onItemTapped,
      ),
    );
  }
}
