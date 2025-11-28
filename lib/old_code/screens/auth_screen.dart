import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _nameController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  late TabController _tabController;
  bool _loading = false;
  String? _info;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showInfo(String msg, {bool error = false}) {
    setState(() {
      _info = msg;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _info = null);
    });
  }

  Future<void> _signIn(BuildContext ctx) async {
    setState(() {
      _loading = true;
      _info = null;
    });

    final auth = Provider.of<AuthService>(ctx, listen: false);
    await auth.signIn(_emailController.text, _passController.text);

    if (auth.errorMessage != null) {
      _showInfo(auth.errorMessage!, error: true);
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _signUp(BuildContext ctx) async {
    setState(() {
      _loading = true;
      _info = null;
    });

    if (_passController.text != _confirmPassController.text) {
      _showInfo("Passwords do not match!", error: true);
      setState(() => _loading = false);
      return;
    }

    final auth = Provider.of<AuthService>(ctx, listen: false);
    await auth.signUp(_emailController.text, _passController.text);

    if (auth.errorMessage != null) {
      _showInfo(auth.errorMessage!, error: true);
    } else if (auth.user != null) {
      await auth.updateProfile(displayName: _nameController.text);
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _resetPassword(BuildContext ctx) async {
    setState(() {
      _loading = true;
      _info = null;
    });

    final auth = Provider.of<AuthService>(ctx, listen: false);
    await auth.resetPassword(_emailController.text);

    if (auth.errorMessage != null) {
      _showInfo(auth.errorMessage!, error: true);
    } else {
      _showInfo("Password reset email sent!");
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabBar = TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: "Sign In"),
        Tab(text: "Sign Up"),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("MartialFlow Auth"),
        bottom: tabBar,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSignIn(context),
          _buildSignUp(context),
        ],
      ),
    );
  }

  Widget _buildSignIn(BuildContext ctx) => _buildForm(
        ctx,
        buttonText: "Sign In",
        onSubmit: () => _signIn(ctx),
        bottomWidget: TextButton(
          onPressed: _loading ? null : () => _resetPassword(ctx),
          child: const Text("Forgot password?"),
        ),
      );

  Widget _buildSignUp(BuildContext ctx) => _buildForm(
        ctx,
        showName: true,
        buttonText: "Create Account",
        onSubmit: () => _signUp(ctx),
      );

  Widget _buildForm(
    BuildContext ctx, {
    required VoidCallback onSubmit,
    required String buttonText,
    bool showName = false,
    Widget? bottomWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_info != null)
              Text(
                _info!,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),

            if (showName)
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: _passController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
              ),
            ),

            if (showName)
              TextField(
                controller: _confirmPassController,
                obscureText: !_showConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: onSubmit,
                    child: Text(buttonText),
                  ),

            if (bottomWidget != null) ...[
              const SizedBox(height: 10),
              bottomWidget,
            ],
          ],
        ),
      ),
    );
  }
}
