import 'package:flutter/material.dart';
import 'package:portfolio_admin/src/components/auth_required_state.dart';
import 'package:portfolio_admin/src/features/auth/change_password_screen.dart';
import 'package:portfolio_admin/src/features/tech/articles/tech_articles.dart';
import 'package:portfolio_admin/src/settings/settings_view.dart';
import 'package:portfolio_admin/src/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  static const routeName = '/dashboard';

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends AuthRequiredState<DashboardScreen> {
  void _navigateToChangePasswordScreen() {
    Navigator.restorablePushNamed(
      context,
      ChangePasswordScreen.routeName,
    );
  }

  void _navigateToTechArticleListScreen() {
    Navigator.restorablePushNamed(
      context,
      TechArticlesScreen.routeName,
    );
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
      appBar: AppBar(
        title: const Text('ダッシュボード'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          ElevatedButton(
            onPressed: _navigateToTechArticleListScreen,
            child: const Text('技術ブログ'),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _navigateToChangePasswordScreen,
            child: const Text('パスワード変更'),
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _signOut, child: const Text('Sign Out')),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
