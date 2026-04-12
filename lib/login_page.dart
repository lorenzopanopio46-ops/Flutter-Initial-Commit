import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser(BuildContext context) async {
    // Tandaan: 10.0.2.2 para sa Emulator, IP Address naman kung real phone.
    var url = Uri.parse("http://10.0.2.2/flutter_api/login.php");
    
    try {
      var response = await http.post(url, body: {
        "email": emailController.text,
        "password": passwordController.text,
      });

      var data = json.decode(response.body);
      if (data == "Success") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login Successful!")),
        );
        // Dito mo ilalagay yung pag-redirect sa Homepage mamaya.
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Maling Email o Password!")),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => loginUser(context), 
              child: Text("Login")
            ),
          ],
        ),
      ),
    );
  }
}