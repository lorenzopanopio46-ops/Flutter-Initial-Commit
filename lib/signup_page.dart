import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignupPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> registerUser() async {
    // Tandaan: Gamitin ang IP address ng PC mo kung physical phone ang gamit
    var url = Uri.parse("http://10.0.2.2/flutter_api/register.php"); 
    
    var response = await http.post(url, body: {
      "name": nameController.text,
      "email": emailController.text,
      "password": passwordController.text,
    });

    if (response.statusCode == 200) {
      print("Tagumpay ang Registration!");
    } else {
      print("May error sa pag-register.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signup")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: registerUser, child: Text("Register")),
          ],
        ),
      ),
    );
  }
}