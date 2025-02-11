import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RiwayatPenjualan extends StatefulWidget {
  @override
  _RiwayatPenjualanState createState() => _RiwayatPenjualanState();
}

class _RiwayatPenjualanState extends State<RiwayatPenjualan> {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchRiwayatPenjualan() async {
    try {
      //  Ambil data `penjualan` dan gabungkan dengan `detail_penjualan` serta `produk`
      final response = await supabase
          .from('penjualan')
          .select('id, total_harga, tanggal, pelanggan:pelanggan_id(nama_pelanggan), detail_penjualan (produk:produk_id(nama_produk, harga), jumlah, subtotal)')
          .order('tanggal', ascending: false);

      print("Data Riwayat: $response"); // Debug untuk cek data
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Penjualan'),
        backgroundColor: Color.fromARGB(255, 255, 211, 68),
        automaticallyImplyLeading: false, // Menghilangkan tombol back
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchRiwayatPenjualan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data penjualan'));
          }

          final penjualanList = snapshot.data!;
          return ListView.builder(
            itemCount: penjualanList.length,
            itemBuilder: (context, index) {
              final penjualan = penjualanList[index];
              final pelanggan = penjualan['pelanggan']?['nama_pelanggan'] ?? 'Tanpa Nama';
              final tanggal = penjualan['tanggal'];
              final totalHarga = penjualan['total_harga'];
              final detailProduk = List<Map<String, dynamic>>.from(penjualan['detail_penjualan'] ?? []);

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pelanggan: $pelanggan',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text('Tanggal: $tanggal'),
                      const SizedBox(height: 8),
                      const Divider(),

                      // Menampilkan Daftar Produk
                      Column(
                        children: detailProduk.map((produk) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(produk['produk']['nama_produk'] ?? 'Produk Tidak Diketahui')),
                                Text('x${produk['jumlah']}'),
                                Text('Rp ${produk['subtotal']}'),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const Divider(),
                      Text(
                        'Total Harga: Rp $totalHarga',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
