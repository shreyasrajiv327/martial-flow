import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'onboarding_screen.dart';
import 'signup_screen.dart';
import 'auth_wrapper.dart';
class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool showPassword = false;
  bool showConfirm = false;
  String? errorMsg;

final _auth = AuthService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (errorMsg != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(errorMsg!, style: TextStyle(color: Colors.red)),
                ),

              TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
              SizedBox(height: 12),
              TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
              SizedBox(height: 12),
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
              SizedBox(height: 12),
              TextField(
                controller: confirmController,
                obscureText: !showConfirm,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  suffixIcon: IconButton(
                    icon: Icon(showConfirm ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => showConfirm = !showConfirm),
                  ),
                ),
              ),
              SizedBox(height: 30),

              ElevatedButton(
                child: Text("Create Account"),
                onPressed: () async {
                  if (passwordController.text != confirmController.text) {
                    setState(() => errorMsg = "Passwords do not match");
                    return;
                  }

                  setState(() => errorMsg = null);

                  final error = await _auth.signUp(
                    nameController.text.trim(),
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  );

                  // Inside your "Create Account" button, after successful signUp():
                  if (error == null) {
                    // Success! Clear stack and go to Onboarding
                    // Navigator.of(context).pushAndRemoveUntil(
                    //   MaterialPageRoute(builder: (_) => OnboardingScreen()),
                    //   (route) => false,
                    // );
                   Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => AuthWrapper()),
  (route) => false,
);


                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}