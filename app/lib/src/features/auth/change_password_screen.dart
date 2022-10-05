import 'package:flutter/material.dart';
import 'package:portfolio_admin/src/components/auth_required_state.dart';
import 'package:portfolio_admin/src/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  static const routeName = '/auth/change-password';

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends AuthRequiredState<ChangePasswordScreen> {
  final _newPasswordController = TextEditingController();
  var _loading = false;

  /// Called when user taps `Update` button
  Future<void> _updatePassword() async {
    setState(() {
      _loading = true;
    });
    final userName = _newPasswordController.text;
    final updates = UserAttributes(
      password: userName,
    );
    final response = await supabase.auth.update(updates);

    if (!mounted) return;

    final error = response.error;
    if (error != null) {
      context.showErrorSnackBar(message: error.message);
    } else {
      context.showSnackBar(message: 'Successfully updated password!');
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  void onAuthenticated(Session session) {
    final user = session.user;
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChangePassword')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          TextFormField(
            controller: _newPasswordController,
            decoration: const InputDecoration(labelText: 'New Password'),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
              onPressed: _updatePassword,
              child: Text(_loading ? 'Saving...' : 'Update')),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}
