import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool showPassword = false;
  String? errorMsg;

  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign In")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Error message
            if (errorMsg != null)
              Text(errorMsg!, style: TextStyle(color: Colors.red)),

            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: passwordController,
              obscureText: !showPassword,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => showPassword = !showPassword),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              child: Text("Sign In"),
              onPressed: () async {
                final error = await _auth.signIn(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );
                // After successful signIn():
                if (error == null) {
                  Navigator.of(context).pop(); // Just go back to previous screen
                  // AuthWrapper will instantly detect login and redirect to Onboarding or Home
                }
              },
            ),

            TextButton(
              child: Text("Create an account"),
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => SignUpScreen())
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
