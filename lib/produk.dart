import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  _ProdukPageState createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  List<dynamic> produkList = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  int? selectedId;

  @override
  void initState() {
    super.initState();
    fetchProduk();
  }

  Future<void> fetchProduk() async {
    final response = await supabase.from('produk').select();
    setState(() {
      produkList = response;
    });
  }

  Future<void> addProduk() async {
    await supabase.from('produk').insert({
      'nama_produk': nameController.text,
      'harga': int.parse(priceController.text),
      'stok': int.parse(stockController.text),
    });
    clearFields();
    fetchProduk();
  }

  Future<void> editProduk(int id) async {
    await supabase.from('produk').update({
      'nama_produk': nameController.text,
      'harga': int.parse(priceController.text),
      'stok': int.parse(stockController.text),
    }).eq('produk_id', id);
    clearFields();
    fetchProduk();
  }

  Future<void> deleteProduk(int id) async {
    await supabase.from('produk').delete().eq('produk_id', id);
    fetchProduk();
  }

  void clearFields() {
    nameController.clear();
    priceController.clear();
    stockController.clear();
    setState(() => selectedId = null);
  }

  void showForm({int? id, String? nama, int? harga, int? stok}) {
    if (id != null) {
      selectedId = id;
      nameController.text = nama!;
      priceController.text = harga.toString();
      stockController.text = stok.toString();
    } else {
      clearFields();
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Produk')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number),
            TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                if (selectedId == null) {
                  addProduk();
                } else {
                  editProduk(selectedId!);
                }
                Navigator.pop(context);
              },
              icon: const Icon(Icons.save),
              label: Text(selectedId == null ? 'Tambah Produk' : 'Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Produk")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: produkList.length,
          itemBuilder: (context, index) {
            final produk = produkList[index];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                title: Text(produk['nama_produk'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                subtitle: Text("Harga: Rp ${produk['harga']} | Stok: ${produk['stok']}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                trailing: Wrap(
                  spacing: 6,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => showForm(
                        id: produk['produk_id'],
                        nama: produk['nama_produk'],
                        harga: produk['harga'],
                        stok: produk['stok'],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteProduk(produk['produk_id']),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
