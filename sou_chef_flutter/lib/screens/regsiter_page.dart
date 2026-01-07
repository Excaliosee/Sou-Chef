import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import '../widgets/my_text_field.dart';
import '../widgets/my_button.dart';

class RegsiterPage extends StatefulWidget {
  const RegsiterPage({super.key});

  @override
  State<RegsiterPage> createState() => _RegsiterPageState();
}

class _RegsiterPageState extends State<RegsiterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();

  void signUserUp() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    );

    if (passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);
      showErrorMessage("Passwords don't match.");
      return;
    }

    if (usernameController.text.isEmpty) {
      Navigator.pop(context);
      showErrorMessage("Please enter a username");
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text
      );

      final user = userCredential.user;
      await user?.updateDisplayName(usernameController.text.trim());
      await user?.reload();

      if (!mounted) return;
      Navigator.pop(context);

      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => LoginPage())
      );
    }
    on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context);
      showErrorMessage(e.code);
    }

  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                const Icon(
                  Icons.person_add,
                  size: 100,
                ),

                const SizedBox(height: 50),

                Text(
                  "Let's create an account for you!",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                MyTextField(
                  controller: emailController, 
                  hintText: "Email", 
                  obscureText: false
                ),

                const SizedBox(height: 25),

                MyTextField(
                  controller: usernameController, 
                  hintText: "Username", 
                  obscureText: false
                ),

                const SizedBox(height: 25),

                MyTextField(
                  controller: passwordController, 
                  hintText: "Password", 
                  obscureText: true
                ),

                const SizedBox(height: 25),

                MyTextField(
                  controller: confirmPasswordController, 
                  hintText: "Confirm Password", 
                  obscureText: true
                ),

                const SizedBox(height: 25),

                MyButton(
                  onTap: signUserUp,
                  text: "Register."
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already a user? ",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const LoginPage())
                        );
                      },
                      child: Text(
                        "Login Here",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}