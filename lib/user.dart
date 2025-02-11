import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await supabase.from('user').select();
      print("🔍 Data User: $response");

      setState(() {
        users = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetch data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await supabase.from('user').delete().eq('id', id);
      fetchUsers();
    } catch (e) {
      print("❌ Error delete data: $e");
    }
  }

  Future<void> updateUser(int id, String newUsername, String newPassword) async {
    try {
      await supabase.from('user').update({
        'username': newUsername,
        'password': newPassword,
      }).eq('id', id);
      fetchUsers();
    } catch (e) {
      print("❌ Error update data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar User"),
        automaticallyImplyLeading: false, // Hilangkan tombol back
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? Center(child: Text("Tidak ada user yang tersedia."))
              : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(
                            user['username'] ?? 'Tidak Ada Username',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Password: ${user['password'] ?? '-'}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showEditUserDialog(context, user),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteUser(user['id']),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tambah User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: "Username"),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                await supabase.from('user').insert({
                  'username': usernameController.text,
                  'password': passwordController.text,
                });
                fetchUsers();
                Navigator.pop(context);
              },
              child: Text("Tambah"),
            ),
          ],
        );
      },
    );
  }

  void _showEditUserDialog(BuildContext context, Map<String, dynamic> user) {
    TextEditingController usernameController =
        TextEditingController(text: user['username']);
    TextEditingController passwordController =
        TextEditingController(text: user['password']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: "Username"),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                await updateUser(
                    user['id'], usernameController.text, passwordController.text);
                Navigator.pop(context);
              },
              child: Text("Simpan"),
            ),
          ],
        );
      },
    );
  }
}
