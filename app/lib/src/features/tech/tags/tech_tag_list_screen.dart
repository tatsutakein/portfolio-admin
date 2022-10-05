import 'package:flutter/material.dart';
import 'package:portfolio_admin/src/components/auth_required_state.dart';
import 'package:portfolio_admin/src/features/auth/change_password_screen.dart';
import 'package:portfolio_admin/src/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TechTagListScreen extends StatefulWidget {
  const TechTagListScreen({Key? key}) : super(key: key);

  static const routeName = '/tech/tags';

  @override
  _TechTagListScreenState createState() => _TechTagListScreenState();
}

class _TechTagListScreenState extends AuthRequiredState<TechTagListScreen> {
  void _navigateToChangePasswordScreen() {
    Navigator.of(context).pushNamedAndRemoveUntil(
        ChangePasswordScreen.routeName, (route) => false);
  }

  Future<void> _signOut() async {
    final response = await supabase.auth.signOut();

    if (!mounted) return;

    final error = response.error;
    if (error != null) {
      context.showErrorSnackBar(message: error.message);
    }
  }

  @override
  void onAuthenticated(Session session) {
    final user = session.user;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          ElevatedButton(
            onPressed: _navigateToChangePasswordScreen,
            child: const Text('ChangePassword'),
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _signOut, child: const Text('Sign Out')),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
