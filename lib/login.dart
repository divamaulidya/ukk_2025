import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kasir/home.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    final supabase = Supabase.instance.client;
    final username = usernameController.text;
    final password = passwordController.text;

    try {
      // Query tabel `user` untuk mencocokkan username dan password 
      final response = await supabase
          .from('user')
          .select()
          .eq('username', username)
          .eq('password', password)
          .maybeSingle();

      if (response != null) {
        // Login berhasil
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(username: '',)),
        );
      } else {
        // Login gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Username atau password salah!'),
          ),
        );
      }
    } catch (error) {
      // Tangani error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 143, 101, 11),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 150, 0, 0),
              padding: EdgeInsets.all(0),
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Color(0xffffffff),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32.0),
                  topRight: Radius.circular(32.0),
                ),
                border: Border.all(color: Color(0x4d9e9e9e), width: 1),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 60, 16, 16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      TextField(
                        controller: usernameController,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: "User Name",
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                        child: TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                        child: MaterialButton(
                          onPressed: () => login(context),
                          color: Color.fromARGB(255, 163, 129, 35),
                          padding: EdgeInsets.all(16),
                          child: Text(
                            "LOG IN",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          minWidth: MediaQuery.of(context).size.width,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}