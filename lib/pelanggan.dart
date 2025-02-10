import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomersPage extends StatefulWidget {
  @override
  _CustomersPageState createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> customers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  //  Ambil data pelanggan dari Supabase
  Future<void> fetchCustomers() async {
    try {
      final response = await supabase.from('pelanggan').select();
      print("Customer Data: $response"); // Debugging

      setState(() {
        customers = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching customers: $e");
      setState(() => isLoading = false);
    }
  }

  //  Tambah atau Edit pelanggan
  Future<void> showCustomerDialog({int? pelangganId, String? nama, String? alamat, String? telepon}) async {
    TextEditingController nameController = TextEditingController(text: nama ?? '');
    TextEditingController addressController = TextEditingController(text: alamat ?? '');
    TextEditingController phoneController = TextEditingController(text: telepon ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(pelangganId == null ? "Tambah Pelanggan" : "Edit Pelanggan"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Nama Pelanggan")),
              TextField(controller: addressController, decoration: InputDecoration(labelText: "Alamat")),
              TextField(controller: phoneController, decoration: InputDecoration(labelText: "Nomor Telepon"), keyboardType: TextInputType.phone),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal")),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                  try {
                    if (pelangganId == null) {
                      //  Insert data baru
                      await supabase.from('pelanggan').insert({
                        'nama_pelanggan': nameController.text,
                        'alamat': addressController.text,
                        'nomor_telepon': phoneController.text,
                        'created_at': DateTime.now().toIso8601String(), // Sesuai tabel
                      });
                    } else {
                      //  Update data pelanggan
                      await supabase.from('pelanggan').update({
                        'nama_pelanggan': nameController.text,
                        'alamat': addressController.text,
                        'nomor_telepon': phoneController.text,
                      }).match({'pelanggan_id': pelangganId}); // 🔹 Gunakan match()
                    }
                    fetchCustomers();
                    Navigator.pop(context);
                  } catch (e) {
                    print("Error updating customer: $e");
                  }
                }
              },
              child: Text(pelangganId == null ? "Tambah" : "Simpan"),
            ),
          ],
        );
      },
    );
  }

  // Hapus pelanggan berdasarkan ID
  Future<void> deleteCustomer(int pelangganId) async {
    try {
      final response = await supabase.from('pelanggan').delete().match({'pelanggan_id': pelangganId});
      print("Delete Response: $response"); // Debugging
      fetchCustomers();
    } catch (e) {
      print("Error deleting customer: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Daftar Pelanggan")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : customers.isEmpty
              ? Center(child: Text("Tidak ada pelanggan yang tersedia."))
              : ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];

                    //  Pastikan ID tidak null, default ke -1 jika null
                    int pelangganId = customer['pelanggan_id'] ?? -1;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                      shadowColor: Colors.grey.withOpacity(0.5),
                      child: ListTile(
                        leading: Icon(Icons.person, color: Colors.blue),
                        title: Text(customer['nama_pelanggan'] ?? 'Tanpa Nama', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Alamat: ${customer['alamat'] ?? 'Tidak Ada'}"),
                            Text("Telepon: ${customer['nomor_telepon'] ?? 'Tidak Ada'}"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 🔹 Tombol Edit
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.green),
                              onPressed: () {
                                showCustomerDialog(
                                  pelangganId: pelangganId,
                                  nama: customer['nama_pelanggan'],
                                  alamat: customer['alamat'],
                                  telepon: customer['nomor_telepon'],
                                );
                              },
                            ),
                            // 🔹 Tombol Hapus
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                if (pelangganId > 0) { // 🔹 Pastikan ID valid sebelum menghapus
                                  deleteCustomer(pelangganId);
                                } else {
                                  print("Invalid ID: $pelangganId");
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCustomerDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
