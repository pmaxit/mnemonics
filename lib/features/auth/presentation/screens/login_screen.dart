import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/design/design_system.dart';
import '../widgets/auth_social_button.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    try {
      await ref
          .read(authControllerProvider.notifier)
          .signInWithEmailAndPassword(email, password);

      final authState = ref.read(authControllerProvider);
      if (authState.hasError) {
        throw authState.error!;
      }

      if (mounted) {
        context.go('/main/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();

      final authState = ref.read(authControllerProvider);
      if (authState.hasError) {
        throw authState.error!;
      }

      if (mounted) {
        context.go('/main/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleAppleLogin() async {
    try {
      await ref.read(authControllerProvider.notifier).signInWithApple();

      final authState = ref.read(authControllerProvider);
      if (authState.hasError) {
        throw authState.error!;
      }

      if (mounted) {
        context.go('/main/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Apple Sign-In failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: MnemonicsColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(MnemonicsSpacing.l),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - MnemonicsSpacing.l * 2,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome Back",
                        style: MnemonicsTypography.headingLarge.copyWith(
                          color: MnemonicsColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: MnemonicsSpacing.s),
                      Text(
                        "Log in to continue your learning journey",
                        style: MnemonicsTypography.bodyLarge.copyWith(
                          color: MnemonicsColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Email Field
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Email",
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: Colors.grey),
                          filled: true,
                          fillColor: MnemonicsColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 20),
                        ),
                      ),
                      const SizedBox(height: MnemonicsSpacing.m),

                      // Password Field
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Colors.grey),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: MnemonicsColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 20),
                        ),
                      ),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: MnemonicsColors.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: MnemonicsSpacing.m),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MnemonicsColors.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  "Log In",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                              child: Divider(
                                  color: Colors.grey.shade300, thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "or continue with",
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 14),
                            ),
                          ),
                          Expanded(
                              child: Divider(
                                  color: Colors.grey.shade300, thickness: 1)),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Social Logins
                      AuthSocialButton(
                        label: "Continue with Google",
                        icon: const GoogleIconWidget(),
                        onPressed: isLoading ? () {} : _handleGoogleLogin,
                      ),
                      AuthSocialButton(
                        label: "Continue with Apple",
                        icon: const Icon(Icons.apple,
                            color: Colors.white, size: 28),
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        border: BorderSide.none,
                        onPressed: isLoading ? () {} : _handleAppleLogin,
                      ),


                      const Spacer(),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          TextButton(
                            onPressed: () => context.pushReplacement('/signup'),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: MnemonicsColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
