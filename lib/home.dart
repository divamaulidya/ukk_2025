import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart'; // Mengimpor halaman login

class HomeScreen extends StatefulWidget {
  // Menerima parameter username dari halaman sebelumnya
  final String username;

  const HomeScreen({required this.username});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Membuat instance SupabaseClient untuk mengakses database
  final SupabaseClient _supabase = Supabase.instance.client;

  // Menyimpan index halaman yang aktif (0: Produk, 1: Transaksi, 2: Profil)
  int _currentIndex = 0;

  // Fungsi untuk mengambil data produk dari Supabase
  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    try {
      // Mengambil data produk dari tabel 'produk' di Supabase
      final response = await _supabase
          .from('produk')
          .select()
          .order('id_produk', ascending: true); // Mengurutkan produk berdasarkan id_produk
      return List<Map<String, dynamic>>.from(response); // Mengonversi hasil response menjadi list
    } catch (e) {
      // Menampilkan pesan error jika gagal mengambil data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat produk: $e')),
      );
      return []; // Mengembalikan list kosong jika gagal
    }
  }

  // Widget untuk menampilkan daftar produk dalam bentuk ListView
  Widget _buildProductList() {
    return FutureBuilder<List<Map<String, dynamic>>>( // Menggunakan FutureBuilder untuk menunggu hasil fetch produk
      future: _fetchProducts(), // Memanggil fungsi _fetchProducts untuk mengambil data produk
      builder: (context, snapshot) {
        // Menampilkan loading indicator saat data sedang diambil
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } 
        // Menampilkan error jika terjadi kesalahan
        else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } 
        // Menampilkan pesan jika tidak ada produk
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada produk.'));
        }

        final products = snapshot.data!; // Mengambil data produk

        // Menampilkan produk dalam bentuk ListView
        return ListView.builder(
          itemCount: products.length, // Jumlah item sesuai dengan banyaknya produk
          itemBuilder: (context, index) {
            final product = products[index]; // Mengambil data produk per index
            return Card(
              elevation: 5, // Memberikan efek bayangan pada kartu
              margin: const EdgeInsets.symmetric(vertical: 5), // Margin antar item
              child: ListTile(
                title: Text(product['namaproduk']), // Menampilkan nama produk
                subtitle: Text('Harga: ${product['harga']} | Stok: ${product['stok']}'), // Menampilkan harga dan stok produk
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tombol untuk mengedit produk
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditDialog(product); // Memanggil fungsi untuk menampilkan dialog edit produk
                      },
                    ),
                    // Tombol untuk menghapus produk
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: const Color.fromARGB(255, 255, 137, 82),
                      onPressed: () {
                        _showDeleteConfirmation(product['id_produk']); // Memanggil fungsi konfirmasi hapus produk
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  // Fungsi untuk menampilkan dialog edit produk
  void _showEditDialog(Map<String, dynamic> product) {
    final TextEditingController _namaProdukController = TextEditingController(text: product['namaproduk']);
    final TextEditingController _hargaController = TextEditingController(text: product['harga'].toString());
    final TextEditingController _stokController = TextEditingController(text: product['stok'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _namaProdukController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _hargaController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number, // Menggunakan keyboard angka
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _stokController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number, // Menggunakan keyboard angka
              ),
            ],
          ),
          actions: [
            // Tombol untuk membatalkan perubahan
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            // Tombol untuk menyimpan perubahan
            ElevatedButton(
              onPressed: () {
                _updateProduct(product['id_produk'], _namaProdukController.text, _hargaController.text, _stokController.text);
                Navigator.pop(context);
              },
              child: const Text('Perbarui Data'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk memperbarui produk di database
  Future<void> _updateProduct(int productId, String namaProduk, String harga, String stok) async {
    final hargaParsed = double.tryParse(harga);
    final stokParsed = int.tryParse(stok);

    // Validasi input pengguna
    if (namaProduk.isEmpty || hargaParsed == null || stokParsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi semua data dengan benar!')),
      );
      return;
    }

    try {
      // Melakukan update data produk di database
      await _supabase.from('produk').update({
        'namaproduk': namaProduk,
        'harga': hargaParsed,
        'stok': stokParsed,
      }).eq('id_produk', productId); // Menentukan produk yang akan diperbarui berdasarkan id_produk

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil diperbarui!')),
      );
      setState(() {}); // Memperbarui tampilan
    } catch (e) {
      // Menampilkan pesan error jika gagal update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui produk: $e')),
      );
    }
  }

  // Fungsi untuk menampilkan konfirmasi penghapusan produk
  void _showDeleteConfirmation(int productId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Membatalkan penghapusan
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _deleteProduct(productId); // Memanggil fungsi untuk menghapus produk
                Navigator.pop(context); // Menutup dialog
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menghapus produk dari database
  Future<void> _deleteProduct(int productId) async {
    try {
      await _supabase.from('produk').delete().eq('id_produk', productId); // Menghapus produk berdasarkan id_produk
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil dihapus!')),
      );
      setState(() {}); // Memperbarui tampilan
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus produk: $e')),
      );
    }
  }

  // Fungsi untuk menampilkan dialog menambah produk
  void _showAddProductDialog() {
    final TextEditingController _namaProdukController = TextEditingController();
    final TextEditingController _hargaController = TextEditingController();
    final TextEditingController _stokController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _namaProdukController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _hargaController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number, // Menggunakan keyboard angka
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _stokController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number, // Menggunakan keyboard angka
              ),
            ],
          ),
          actions: [
            // Tombol untuk membatalkan penambahan produk
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            // Tombol untuk menyimpan produk baru
            ElevatedButton(
              onPressed: () {
                _addProduct(_namaProdukController.text, _hargaController.text, _stokController.text);
                Navigator.pop(context);
              },
              child: const Text('Tambah Produk'),
            ),
          ],
        );
      },
    );
  }
