import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'forgot_password.dart';
import 'sign_up.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _emailError;
  String? _passwordError;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _keyboardFocusNode = FocusNode();

  bool get _isFormValid {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _emailError == null &&
        _passwordError == null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_isFormValid) return;

    setState(() => _isSubmitting = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (email.isEmpty) {
      setState(() {
        _emailError = 'Email is required';
        _isSubmitting = false;
      });
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() {
        _emailError = 'Enter a valid email address';
        _isSubmitting = false;
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password is required';
        _isSubmitting = false;
      });
      return;
    }

    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isSubmitting = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome back, ${email.split('@').first}!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      if (!mounted) return;
      if (email.endsWith('@gov.ph') || email.contains('admin')) {
        Navigator.of(context).pushReplacementNamed('/admin/profile');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      _showRouteError();
    }
  }

  void _showRouteError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation route not configured'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_passwordFocusNode.hasFocus) {
          _handleLogin();
        } else {
          _passwordFocusNode.requestFocus();
        }
      }
      if (event.logicalKey == LogicalKeyboardKey.tab) {
        if (_emailFocusNode.hasFocus) {
          _passwordFocusNode.requestFocus();
        } else {
          _emailFocusNode.requestFocus();
        }
      }
    }
  }

  Widget _strokedText(String text, TextStyle style, {double strokeWidth = 3.0, Color strokeColor = Colors.black}) {
    return Stack(
      children: [
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        Text(text, style: style),
      ],
    );
  }

  Widget _buildFooter() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool narrow = constraints.maxWidth < 420;
        final logo = Image.asset(
          'assets/arta_logo.png',
          width: 100,
          height: 35,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Text(
              'ARTA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            );
          },
        );

        final copyright = Text(
          '© Valenzuela City',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        );

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: narrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    logo,
                    const SizedBox(height: 6),
                    copyright,
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    logo,
                    copyright,
                  ],
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FocusableActionDetector(
        autofocus: true,
        child: KeyboardListener(
          focusNode: _keyboardFocusNode,
          onKeyEvent: _handleKeyEvent,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 900;
              final screenHeight = constraints.maxHeight;

              Widget leftHeader = Container(
                width: narrow ? double.infinity : constraints.maxWidth * 0.6,
                height: narrow ? screenHeight * 0.3 : double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: narrow ? 40 : 80,
                  vertical: narrow ? 30 : 60,
                ),
                child: Column(
                  mainAxisAlignment: narrow ? MainAxisAlignment.center : MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _strokedText(
                      'ANTI-',
                      GoogleFonts.racingSansOne(
                        textStyle: TextStyle(
                          fontSize: narrow ? 48 : 72,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          letterSpacing: 3.0,
                        ),
                      ),
                      strokeWidth: 6.0,
                      strokeColor: Colors.black.withAlpha(204),
                    ),
                    _strokedText(
                      'REDTAPE',
                      GoogleFonts.racingSansOne(
                        textStyle: TextStyle(
                          fontSize: narrow ? 48 : 72,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3.0,
                        ),
                      ),
                      strokeWidth: 6.0,
                      strokeColor: const Color.fromARGB(230, 187, 0, 0),
                    ),
                    _strokedText(
                      'AUTHORITY',
                      GoogleFonts.racingSansOne(
                        textStyle: TextStyle(
                          fontSize: narrow ? 48 : 72,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          letterSpacing: 3.0,
                        ),
                      ),
                      strokeWidth: 6.0,
                      strokeColor: Colors.black.withAlpha(204),
                    ),
                  ],
                ),
              );

              Widget rightPanel = Container(
                width: narrow ? constraints.maxWidth : constraints.maxWidth * 0.4,
                height: narrow ? screenHeight * 0.7 : double.infinity,
                color: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: narrow ? 24 : 40,
                  vertical: narrow ? 20 : 30,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // City Header
                    Row(
                      children: [
                        Image.asset(
                          'assets/city_logo.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.account_balance, color: Colors.blue[700], size: 30);
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Valenzuela City',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ADMIN',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: narrow ? 24 : 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ) ??
                          const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                    ),
                    SizedBox(height: narrow ? 12 : 16),

                    // Email Field
                    Text('Email', style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) {
                        if (_emailError != null) setState(() => _emailError = null);
                      },
                      onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                      decoration: InputDecoration(
                        hintText: 'Enter email',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        errorText: _emailError,
                      ),
                    ),
                    SizedBox(height: narrow ? 12 : 14),

                    // Password Field
                    Text('Password', style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) {
                        if (_passwordError != null) setState(() => _passwordError = null);
                      },
                      onSubmitted: (_) => _handleLogin(),
                      decoration: InputDecoration(
                        hintText: 'Enter password',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        errorText: _passwordError,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    SizedBox(height: narrow ? 10 : 12),

                    // Remember Me & Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (value) => setState(() => _rememberMe = value ?? false),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('Remember me', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                          ],
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                          ),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                          child: const Text("Forgot password?", style: TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                    SizedBox(height: narrow ? 14 : 16),

                    // Sign In Button
                    AnimatedOpacity(
                      opacity: _isFormValid && !_isSubmitting ? 1.0 : 0.6,
                      duration: const Duration(milliseconds: 250),
                      child: SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _isFormValid && !_isSubmitting ? _handleLogin : null,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007BFF)),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    SizedBox(height: narrow ? 12 : 14),

                    // Sign Up Link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Don't have an account?", style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                          const SizedBox(width: 4),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SignUpPage()),
                            ),
                            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4)),
                            child: const Text('Sign up now', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),

                    if (kDebugMode) ...[
                      SizedBox(height: narrow ? 10 : 12),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            try {
                              Navigator.of(context).pushReplacementNamed('/admin/profile');
                            } catch (e) {
                              _showRouteError();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Open Admin (dev)', style: TextStyle(fontSize: 13)),
                        ),
                      ),
                    ],

                    const Spacer(),
                    _buildFooter(),
                  ],
                ),
              );

              if (narrow) {
                return Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: const AssetImage('assets/background.jpg'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black.withAlpha(128), BlendMode.darken),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(height: screenHeight * 0.3, child: leftHeader),
                        Expanded(child: rightPanel),
                      ],
                    ),
                  ],
                );
              } else {
                return Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: const AssetImage('assets/background.jpeg'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black.withAlpha(128), BlendMode.darken),
                        ),
                      ),
                    ),
                    leftHeader,
                    Align(alignment: Alignment.centerRight, child: rightPanel),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}