import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'produk.dart';
import 'user.dart';
import 'pelanggan.dart';
import 'penjualan.dart';
import 'riwayat.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<Widget> _pages = [
    ProdukPage(),
    UsersPage(),
    CustomersPage(),
    TransaksiScreen(),
    RiwayatPenjualan(),
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
        title: Text("CoffeShop"),
        backgroundColor: Color.fromRGBO(226, 216, 193, 1),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final supabase = Supabase.instance.client;
              await supabase.auth.signOut();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
          )
        ],
      ),
      body: Column(
        children: [
          if (_selectedIndex == 0 || _selectedIndex == 2) // Hanya tampil di Produk & Pelanggan
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Produk'),
          BottomNavigationBarItem(icon: Icon(Icons.app_registration), label: 'Registrasi'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Pelanggan'),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'Penjualan'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        backgroundColor: Color.fromARGB(255, 163, 129, 35),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
