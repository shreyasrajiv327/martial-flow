import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../screens/onboarding/onboarding_screen.dart';
class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _nameController = TextEditingController();
  late TabController _tabController;
  bool _loading = false;
  String? _info;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showInfo(String msg, {bool error = false}) {
    setState(() { _info = msg; });
    Future.delayed(const Duration(seconds: 3), () { if(mounted) setState(() => _info = null); });
  }

Future<void> _signIn(BuildContext ctx) async {
  setState(() { _loading = true; _info = null; });
  final auth = Provider.of<AuthService>(ctx, listen: false);
  await auth.signIn(_emailController.text, _passController.text);
  if (auth.errorMessage != null) {
    _showInfo(auth.errorMessage!, error: true);
  }
  setState(() { _loading = false; });
}

Future<void> _signUp(BuildContext ctx) async {
  setState(() { _loading = true; _info = null; });
  final auth = Provider.of<AuthService>(ctx, listen: false);
  await auth.signUp(_emailController.text, _passController.text);
  if (auth.errorMessage != null) {
    _showInfo(auth.errorMessage!, error: true);
  } else if (auth.user != null) {
    await auth.updateProfile(displayName: _nameController.text);
    // DO NOT navigate here!
  }
  setState(() { _loading = false; });
}


  Future<void> _resetPassword(BuildContext ctx) async {
    setState(() { _loading = true; _info = null; });
    final auth = Provider.of<AuthService>(ctx, listen: false);
    await auth.resetPassword(_emailController.text);
    if (auth.errorMessage != null) {
      _showInfo(auth.errorMessage!, error: true);
    } else {
      _showInfo('Password reset sent!', error: false);
    }
    setState(() { _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final tabBar = TabBar(
      controller: _tabController,
      tabs: const [ Tab(text: 'Sign In'), Tab(text: 'Sign Up') ],
    );
    return Scaffold(
      appBar: AppBar(title: const Text('MartialFlow Auth'), bottom: tabBar),
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
        onSubmit: () => _signIn(ctx),
        bottomWidget: TextButton(
          onPressed: _loading ? null : () => _resetPassword(ctx),
          child: const Text('Forgot password?'),
        ),
        buttonText: 'Sign In'
      );

  Widget _buildSignUp(BuildContext ctx) => _buildForm(
        ctx,
        onSubmit: () => _signUp(ctx),
        showName: true,
        buttonText: 'Create Account',
      );

  Widget _buildForm(BuildContext ctx, {required VoidCallback onSubmit, String buttonText = '', bool showName = false, Widget? bottomWidget}) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_info != null)
            Text(_info!, style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          if (showName)
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')), 
          TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')), 
          TextField(controller: _passController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true,),
          const SizedBox(height: 16),
          _loading ? const CircularProgressIndicator() : ElevatedButton(onPressed: onSubmit, child: Text(buttonText)),
          if (bottomWidget != null) ...[
            const SizedBox(height: 10),
            bottomWidget,
          ]
        ],
      ),
    );
  }
}
