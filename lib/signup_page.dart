import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> registerUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar("Passwords do not match!", Colors.red);
      return;
    }

    // Palitan ang localhost ng iyong IP address kung gagamit ng physical phone
    var url = Uri.parse("http://localhost/flutter_api/register.php");

    try {
      var response = await http.post(
        url,
        body: {
          "first_name": firstNameController.text,
          "last_name": lastNameController.text,
          "contact_number": contactController.text,
          "email": emailController.text,
          "password": passwordController.text,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showSnackBar("Registration Successful!", Colors.green);
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar("Connection Error", Colors.red);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Colors.blue;

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Light blue background
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- BLUE HEADER SECTION ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, bottom: 30),
              decoration: const BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Icon(Icons.person_add, size: 80, color: Colors.white),
                  const SizedBox(height: 10),
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // --- FORM FIELDS SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                children: [
                  buildField(
                    firstNameController,
                    "First Name",
                    Icons.person_outline,
                  ),
                  buildField(
                    lastNameController,
                    "Last Name",
                    Icons.person_outline,
                  ),
                  buildField(
                    contactController,
                    "Contact Number",
                    Icons.phone_android,
                    isPhone: true,
                  ),
                  buildField(
                    emailController,
                    "Username/Email",
                    Icons.email_outlined,
                  ),
                  buildField(
                    passwordController,
                    "Password",
                    Icons.lock_outline,
                    isPassword: true,
                    obscure: _obscurePassword,
                    onToggle: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  buildField(
                    confirmPasswordController,
                    "Confirm Password",
                    Icons.lock_reset,
                    isPassword: true,
                    obscure: _obscureConfirmPassword,
                    onToggle: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- SIGN UP BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        "SIGN UP",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // --- LOGIN LINK ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Common Widget for Fields based on your image
  Widget buildField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
    bool isPhone = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        obscureText: isPassword ? obscure : false,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.blue),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: onToggle,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
