import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AuthActivityApp());
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> register(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);
  Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);
  Future<void> signOut() => _auth.signOut();
  Future<void> updatePassword(String password) async {
    final user = _auth.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'not-signed-in');
    await user.updatePassword(password);
  }
}

class AuthActivityApp extends StatelessWidget {
  const AuthActivityApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Firebase Auth Lab',
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const AuthGate(),
      );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.data == null ? const SignInScreen() : const ProfileScreen();
        },
      );
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _form = GlobalKey<FormState>();
  final _service = AuthService();
  bool _registerMode = false, _loading = false, _obscure = true;

  String _message(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use': return 'That email is already registered.';
        case 'invalid-credential':
        case 'wrong-password': return 'Email or password is incorrect.';
        case 'user-not-found': return 'No account was found for that email.';
        case 'weak-password': return 'Use a stronger password with at least 6 characters.';
        case 'invalid-email': return 'Enter a valid email address.';
        case 'network-request-failed': return 'Network error. Check your connection.';
      }
    }
    return 'Authentication failed. Please try again.';
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_registerMode) {
        await _service.register(_email.text.trim(), _password.text);
      } else {
        await _service.signIn(_email.text.trim(), _password.text);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_message(e))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Firebase Auth Lab')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Icon(Icons.verified_user, size: 70),
                const SizedBox(height: 12),
                Text(_registerMode ? 'Create account' : 'Sign in', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()), validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null),
                const SizedBox(height: 14),
                TextFormField(controller: _password, obscureText: _obscure, decoration: InputDecoration(labelText: 'Password', border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure))), validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null),
                const SizedBox(height: 20),
                FilledButton(onPressed: _loading ? null : _submit, child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_registerMode ? 'Register' : 'Sign in')),
                TextButton(onPressed: _loading ? null : () => setState(() => _registerMode = !_registerMode), child: Text(_registerMode ? 'Already have an account? Sign in' : 'New user? Create an account')),
              ]),
            ),
          ),
        ),
      );
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _password = TextEditingController();
  bool _loading = false;
  Future<void> _changePassword() async {
    if (_password.text.length < 6) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New password must be at least 6 characters'))); return; }
    setState(() => _loading = true);
    try { await AuthService().updatePassword(_password.text); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully'))); _password.clear(); }
    on FirebaseAuthException catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code == 'requires-recent-login' ? 'Sign in again before changing your password.' : 'Password update failed.'))); }
    finally { if (mounted) setState(() => _loading = false); }
  }
  @override
  Widget build(BuildContext context) { final email = AuthService().currentUser?.email ?? 'Unknown email'; return Scaffold(appBar: AppBar(title: const Text('Protected Profile'), actions: [IconButton(onPressed: () => AuthService().signOut(), icon: const Icon(Icons.logout))]), body: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Icon(Icons.account_circle, size: 90), const SizedBox(height: 16), Text('Signed in as', style: Theme.of(context).textTheme.titleMedium), SelectableText(email, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 32), TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'New password', border: OutlineInputBorder())), const SizedBox(height: 12), FilledButton(onPressed: _loading ? null : _changePassword, child: _loading ? const CircularProgressIndicator() : const Text('Update password')), const SizedBox(height: 24), const Text('This profile is visible only while Firebase authStateChanges() reports a signed-in user.')]))); }
}
