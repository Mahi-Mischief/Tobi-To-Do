import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tobi_todo/core/theme/app_colors.dart';
import 'package:tobi_todo/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _nameController;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => _visible = true));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields');
      return;
    }
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
          );
    } catch (e) {
      setState(() => _errorMessage = 'Registration failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      body: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _visible ? 1 : 0,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEDF4FB), Color(0xFFF7FAFD)],
            ),
          ),
          child: Center(
            child: Card(
              elevation: 18,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520, minWidth: 320),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Branding
                      SizedBox(
                        height: 72,
                        child: Center(
                          child: Image.asset('assets/tobi_animations/app_logo.png', height: 48, errorBuilder: (c, e, s) => const Text('Tobi To-Do', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0E2540)))),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Create your account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF22324A))),
                      const SizedBox(height: 6),
                      const Text('Join Tobi and get focused.', style: TextStyle(fontSize: 14, color: Color(0xFF6F7A89))),
                      const SizedBox(height: 18),

                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFFFEAEA), border: Border.all(color: const Color(0xFFFF6B6B)), borderRadius: BorderRadius.circular(8)),
                          child: Text(_errorMessage!, style: const TextStyle(color: Color(0xFFFF6B6B))),
                        ),

                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        style: const TextStyle(color: Color(0xFF2B2B2B)),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF9AA3B2)),
                          hintText: 'Full name',
                          hintStyle: const TextStyle(color: Color(0xFFB0B7C4)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Color(0xFF2B2B2B)),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF9AA3B2)),
                          hintText: 'Email address',
                          hintStyle: const TextStyle(color: Color(0xFFB0B7C4)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Color(0xFF2B2B2B)),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF9AA3B2)),
                          hintText: 'Password',
                          hintStyle: const TextStyle(color: Color(0xFFB0B7C4)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
                          suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF9AA3B2)), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                        ),
                      ),

                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 8),
                          child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),

                      const SizedBox(height: 12),
                      Row(children: [Expanded(child: Divider(color: Colors.grey.shade300)), const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('or', style: TextStyle(color: Color(0xFF9AA3B2)))), Expanded(child: Divider(color: Colors.grey.shade300))]),
                      const SizedBox(height: 12),

                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google sign-in not implemented'))),
                              icon: const Icon(Icons.g_mobiledata, color: Colors.black),
                              label: const Text('Continue with Google', style: TextStyle(color: Colors.black)),
                              style: OutlinedButton.styleFrom(backgroundColor: Colors.white, side: BorderSide(color: Colors.grey.shade300), padding: const EdgeInsets.symmetric(vertical: 12)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Apple sign-in not implemented'))),
                              icon: const Icon(Icons.apple, color: Colors.white),
                              label: const Text('Continue with Apple', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 12)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?', style: TextStyle(color: Color(0xFF9AA3B2))),
                          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Log In', style: TextStyle(color: Color(0xFF3B82F6)))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
