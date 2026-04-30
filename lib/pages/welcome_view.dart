import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/tactile_wrapper.dart';

class WelcomeView extends StatefulWidget {
  final Future<String?> Function(String email, String password) onSignIn;
  final Future<String?> Function(String name, String email, String password)
  onRegister;

  const WelcomeView({
    super.key,
    required this.onSignIn,
    required this.onRegister,
  });

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.toastBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (!_isLogin && name.isEmpty) {
      _snack('Please enter your name');
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      _snack('Please fill in all fields');
      return;
    }

    if (!_isValidEmail(email)) {
      _snack('Please enter a valid email address');
      return;
    }

    if (password.length < 6) {
      _snack('Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);

    String? error;

    if (_isLogin) {
      error = await widget.onSignIn(email, password);
    } else {
      error = await widget.onRegister(name, email, password);
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (error != null) {
      _snack(error);
    }
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _nameCtrl.clear();
      _emailCtrl.clear();
      _passCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.cake_outlined,
                  size: 46,
                  color: AppColors.accentPink,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "L'Artisan Dulce",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Premium desserts delivered to your door',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.textTertiary),
              ),

              const SizedBox(height: 36),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _isLogin ? 'Welcome Back' : 'Create Account',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _isLogin
                          ? 'Sign in to continue'
                          : 'Register to save your profile',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textTertiary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (!_isLogin) ...[
                      _inputField(
                        controller: _nameCtrl,
                        hint: 'Full name',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 14),
                    ],

                    _inputField(
                      controller: _emailCtrl,
                      hint: 'Email address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 14),

                    _inputField(
                      controller: _passCtrl,
                      hint: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    _gradientButton(
                      _isLogin ? 'Sign In' : 'Create Account',
                      _submit,
                    ),

                    const SizedBox(height: 18),

                    GestureDetector(
                      onTap: _isLoading ? null : _toggleMode,
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                          ),
                          children: [
                            TextSpan(
                              text: _isLogin
                                  ? "Don't have an account? "
                                  : 'Already have an account? ',
                            ),
                            TextSpan(
                              text: _isLogin ? 'Register' : 'Sign In',
                              style: const TextStyle(
                                color: AppColors.accentPink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Team: Akhmet, Bekzat, Syltan, Batyrkhan',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: !_isLoading,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.accentPink),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.accentPink, width: 1.4),
        ),
      ),
    );
  }

  Widget _gradientButton(String text, VoidCallback onTap) {
    return TactileWrapper(
      onTap: _isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryPink, AppColors.accentPink],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPink.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
