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
  String? _emailError;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus on email field for desktop
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

  void _handleLogin() {
  final email = _emailController.text.trim();

    // Basic client-side validation (frontend only)
    String? err;
    if (email.isEmpty) {
      err = 'Email is required';
    } else if (!email.contains('@')) {
      err = 'Enter a valid email address';
    }

    if (err != null) {
      setState(() => _emailError = err);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), duration: const Duration(seconds: 2)));
      return;
    }

    setState(() => _emailError = null);

    // Simulate successful login (frontend-only)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome, ${email.split('@').first} (demo)'),
        duration: const Duration(seconds: 2),
      ),
    );

    // For developer convenience, if credentials match demo pattern, navigate to admin
    if (email.endsWith('@gov.ph') || email.contains('admin')) {
      Navigator.of(context).pushReplacementNamed('/admin/profile');
    }
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

              if (!narrow) {
                // Desktop/tablet layout: background + side-by-side
                return Stack(
                  children: [
                    _buildBackground(),
                    _buildLeftHeader(),
                    _buildLoginContainer(),
                  ],
                );
              }

              // Narrow/mobile layout: keep background and stack header+login vertically
              return Stack(
                children: [
                  _buildBackground(),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        // Left header becomes full-width
                        _buildLeftHeader(),
                        // Login container becomes centered and constrained to viewport
                        Center(child: _buildLoginContainer()),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Helper to render stroked text: stroke using Paint on the lower Text and fill on top
  Widget _strokedText(String text, TextStyle style, {double strokeWidth = 3.0, Color strokeColor = Colors.black}) {
    return Stack(
      children: [
        // Stroke
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        // Fill
        Text(
          text,
          style: style,
        ),
      ],
    );
  }

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/background.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            // withOpacity deprecated; use withAlpha (0.5 -> 128)
            Colors.black.withAlpha(128),
            BlendMode.darken,
          ),
        ),
      ),
    );
  }

  Widget _buildLeftHeader() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ARTA Logo and Text
            Row(
              children: [
              
              Expanded(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ANTI-
                  _strokedText(
                  'ANTI-',
                  GoogleFonts.racingSansOne(
                    textStyle: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      letterSpacing: 3.0,
                      shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black.withAlpha(128),
                              offset: const Offset(2.0, 2.0),
                            ),
                          ],
                    ),
                  ),
                  strokeWidth: 6.0,
                  strokeColor: Colors.black.withAlpha(204),
                  ),
                  // REDTAPE
                  _strokedText(
                  'REDTAPE',
                  GoogleFonts.racingSansOne(
                    textStyle: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 3.0,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black.withAlpha(128),
                          offset: const Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  strokeWidth: 6.0,
                  strokeColor: const Color.fromARGB(230, 187, 0, 0),
                  ),
                  // AUTHORITY
                  _strokedText(
                  'AUTHORITY',
                  GoogleFonts.racingSansOne(
                    textStyle: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      letterSpacing: 3.0,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black.withAlpha(128),
                          offset: const Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  strokeWidth: 6.0,
                  strokeColor: Colors.black.withAlpha(204),
                  ),
                ],
                ),
              ),
              ],
            ),
            const SizedBox(height: 30),
            const SizedBox(height: 30),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginContainer() {
    final width = MediaQuery.of(context).size.width;
    final bool narrow = width < 900;

    // For narrow screens, use almost full width with padding; for wide screens, use a limited panel
  final double containerWidth = narrow
    ? ((width * 0.95) > 700.0 ? 700.0 : (width * 0.95))
    : (width * 0.4);

    return Align(
      alignment: narrow ? Alignment.topCenter : Alignment.centerRight,
      child: Container(
        width: containerWidth,
        constraints: BoxConstraints(
          maxWidth: 700,
          // allow the container to shrink on small screens
          minWidth: 0,
          maxHeight: MediaQuery.of(context).size.height,
        ),
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Valenzuela City Header with Logo
              _buildCityHeader(),
              const SizedBox(height: 32),
              
              // ADMIN Title
              _buildLoginHeader(),
              const SizedBox(height: 32),

              // Login Form
              _buildLoginForm(),
              const SizedBox(height: 40),
              
              // Footer
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // City Logo
          Image.asset(
            'assets/city_logo.png',
            width: 50,
            height: 50,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.account_balance,
                  color: Colors.blue[700],
                  size: 30,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          // City Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Valenzuela City',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              Text(
                'Local Government',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ADMIN',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 8),
        Container(
          height: 3,
          width: 60,
          color: Colors.blue[700],
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Email Field
        Text(
          'Email or phone number',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            errorText: _emailError,
          ),
          textInputAction: TextInputAction.next,
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
          onSubmitted: (_) {
            _passwordFocusNode.requestFocus();
          },
        ),
        const SizedBox(height: 20),

        // Password Field
        Text(
          'Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Enter password',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleLogin(),
        ),
        const SizedBox(height: 20),

        // Remember Me & Forgot Password
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                ),
                Text(
                  'Remember me',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                _showForgotPasswordDialog();
              },
              child: Text(
                'Forgot password?',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Divider
        const Divider(
          color: Colors.grey,
          height: 1,
        ),
        const SizedBox(height: 24),

        // Sign In Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text(
              'Sign in',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        const SizedBox(height: 16),

        // Sign Up
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account?",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignUpPage())),
                child: Text(
                  'Sign up now',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pushReplacementNamed('/admin/profile'),
          child: const Text('Open Admin (dev)'),
        ),
      ],
    );
  }

  void _showForgotPasswordDialog() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ForgotPasswordPage()));
  }

  // Google sign-in removed (frontend-only demo app)

  Widget _buildFooter() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool narrow = constraints.maxWidth < 420;
        final logo = Image.asset(
          'assets/arta_logo.png',
          width: 120,
          height: 40,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Text(
              'ARTA',
              style: TextStyle(
                fontSize: 18,
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
            fontSize: 14,
          ),
        );

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: narrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    logo,
                    const SizedBox(height: 8),
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
}