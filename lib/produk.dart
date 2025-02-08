import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home.dart';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await supabase.from('produk').select();
      print("✅ Data produk: $response");

      setState(() {
        products = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetch data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> addProduct() async {
    TextEditingController nameController = TextEditingController();
    TextEditingController stockController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tambah Produk"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Nama Produk")),
              TextField(controller: stockController, decoration: InputDecoration(labelText: "Stok"), keyboardType: TextInputType.number),
              TextField(controller: priceController, decoration: InputDecoration(labelText: "Harga"), keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal")),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && stockController.text.isNotEmpty && priceController.text.isNotEmpty) {
                  try {
                    await supabase.from('produk').insert({
                      'nama_produk': nameController.text,
                      'stok': int.parse(stockController.text),
                      'harga': int.parse(priceController.text),
                    });
                    print("✅ Produk berhasil ditambahkan!");
                    fetchProducts();
                    Navigator.pop(context);
                  } catch (e) {
                    print("❌ Error menambah produk: $e");
                  }
                }
              },
              child: Text("Tambah"),
            ),
          ],
        );
      },
    );
  }

  Future<void> editProduct(int id, String currentName, int currentStock, int currentPrice) async {
    TextEditingController nameController = TextEditingController(text: currentName);
    TextEditingController stockController = TextEditingController(text: currentStock.toString());
    TextEditingController priceController = TextEditingController(text: currentPrice.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Produk"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Nama Produk")),
              TextField(controller: stockController, decoration: InputDecoration(labelText: "Stok"), keyboardType: TextInputType.number),
              TextField(controller: priceController, decoration: InputDecoration(labelText: "Harga"), keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal")),
            ElevatedButton(
              onPressed: () async {
                try {
                  await supabase.from('produk').update({
                    'nama_produk': nameController.text,
                    'stok': int.parse(stockController.text),
                    'harga': int.parse(priceController.text),
                  }).eq('id', id);
                  print("✅ Produk berhasil diperbarui!");
                  fetchProducts();
                  Navigator.pop(context);
                } catch (e) {
                  print("❌ Error mengedit produk: $e");
                }
              },
              child: Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteProduct(int id) async {
    try {
      print("🗑️ Menghapus produk dengan ID: $id");
      await supabase.from('produk').delete().eq('id', id);
      print("✅ Produk berhasil dihapus!");
      fetchProducts();
    } catch (e) {
      print("❌ Error menghapus produk: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Daftar Produk")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? Center(child: Text("Tidak ada produk yang tersedia."))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    int productId = product['id'] is int ? product['id'] : int.tryParse(product['id'].toString()) ?? 0;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                      shadowColor: Colors.grey.withOpacity(0.5),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.shopping_cart, color: Colors.amber, size: 30),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['nama_produk'],
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  SizedBox(height: 4),
                                  Text("Stok: ${product['stok']} | Harga: Rp${product['harga']}",
                                      style: TextStyle(color: Colors.grey[700])),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    if (productId > 0) {
                                      editProduct(
                                        productId,
                                        product['nama_produk'],
                                        product['stok'] is int ? product['stok'] : int.tryParse(product['stok'].toString()) ?? 0,
                                        product['harga'] is int ? product['harga'] : int.tryParse(product['harga'].toString()) ?? 0,
                                      );
                                    } else {
                                      print("❌ ID tidak valid: ${product['id']}");
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    if (productId > 0) {
                                      deleteProduct(productId);
                                    } else {
                                      print("❌ ID tidak valid: ${product['id']}");
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: addProduct,
        child: Icon(Icons.add),
        backgroundColor: Colors.amber,
      ),
    );
  }
}
