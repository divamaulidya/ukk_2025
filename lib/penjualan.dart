import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PenjualanScreen extends StatefulWidget {
  const PenjualanScreen({super.key});

  @override
  State<PenjualanScreen> createState() => _PenjualanScreenState();
}

class _PenjualanScreenState extends State<PenjualanScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> pelanggan = [];
  List<Map<String, dynamic>> produk = [];
  List<Map<String, dynamic>> keranjang = [];
  int? selectedPelanggan;
  double totalHarga = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final pelangganResponse = await supabase.from('pelanggan').select('pelanggan_id, nama_pelanggan');
      final produkResponse = await supabase.from('produk').select('produk_id, nama_produk, harga');
      
      setState(() {
        pelanggan = List<Map<String, dynamic>>.from(pelangganResponse);
        produk = List<Map<String, dynamic>>.from(produkResponse);
        isLoading = false;
      });
    } catch (e) {
      _showError('Gagal mengambil data: $e');
    }
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      keranjang.add(product);
      totalHarga += product['harga'];
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      totalHarga -= keranjang[index]['harga'];
      keranjang.removeAt(index);
    });
  }

  Future<void> _checkout() async {
    if (selectedPelanggan == null || keranjang.isEmpty) {
      _showError('Pilih pelanggan dan tambahkan produk terlebih dahulu.');
      return;
    }

    try {
      await supabase.from('penjualan').insert({
        'pelanggan_id': selectedPelanggan,
        'produk': keranjang.map((e) => e['produk_id']).toList(),
        'total_harga': totalHarga,
        'tanggal': DateTime.now().toIso8601String(),
      });

      setState(() {
        keranjang.clear();
        totalHarga = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembelian berhasil!')),
      );
    } catch (e) {
      _showError('Gagal melakukan checkout: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Penjualan'),
        backgroundColor: const Color.fromARGB(255, 255, 227, 68),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Pilih Pelanggan'),
                    items: pelanggan.map((pel) {
                      return DropdownMenuItem<int>(
                        value: pel['pelanggan_id'],
                        child: Text(pel['nama_pelanggan']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPelanggan = value;
                      });
                    },
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: produk.length,
                    itemBuilder: (context, index) {
                      final item = produk[index];
                      return ListTile(
                        title: Text(item['nama_produk']),
                        subtitle: Text('Harga: Rp ${item['harga']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.red),
                              onPressed: () {
                                if (keranjang.contains(item)) {
                                  _removeFromCart(keranjang.indexOf(item));
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => _addToCart(item),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.grey[200],
                  child: Column(
                    children: [
                      const Text('Keranjang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ...keranjang.map((item) {
                        int index = keranjang.indexOf(item);
                        return ListTile(
                          title: Text(item['nama_produk']),
                          subtitle: Text('Harga: Rp ${item['harga']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeFromCart(index),
                          ),
                        );
                      }).toList(),
                      Text('Total Harga: Rp $totalHarga', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: (selectedPelanggan != null && keranjang.isNotEmpty) ? _checkout : null,
                        child: const Text('Bayar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
