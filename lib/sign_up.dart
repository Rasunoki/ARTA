import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _rememberMe = false;
  bool _isFormValid = false;
  String? _emailError;
  String? _confirmError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account created for ${_emailController.text}')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create account')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _validateForm() {
    final email = _emailController.text.trim();
    final pass = _passwordController.text;
    final confirm = _confirmController.text;

    final emailValid = email.isNotEmpty && email.contains('@') && email.toLowerCase().endsWith('gov.ph');

    if (email.isNotEmpty && !emailValid) {
      _emailError = 'Only government emails (@gov.ph) are allowed';
    } else {
      _emailError = null;
    }

    final passStrong = _isPasswordStrong(pass);
    final passwordsMatch = pass == confirm && pass.isNotEmpty;

    if (confirm.isNotEmpty && pass != confirm) {
      _confirmError = 'Passwords do not match';
    } else {
      _confirmError = null;
    }

    final valid = emailValid && passStrong && passwordsMatch;
    if (valid != _isFormValid) {
      setState(() {
        _isFormValid = valid;
      });
    }
  }

  bool _isPasswordStrong(String p) {
    if (p.length < 8) return false;
    final hasDigit = p.contains(RegExp(r'\d'));
    final hasLetter = p.contains(RegExp(r'[A-Za-z]'));
    return hasDigit && hasLetter;
  }

  Widget _strokedText(String text, TextStyle style, {double strokeWidth = 4.0, Color strokeColor = Colors.black}) {
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
      body: LayoutBuilder(
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
                Center( 
                  child: Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: narrow ? 24 : 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ) ??
                      const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                ),
                ),
                SizedBox(height: narrow ? 12 : 16),

                // Email
                Text('Email', style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter email',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    errorText: _emailError,
                    suffixIcon: _emailController.text.isNotEmpty && _emailController.text.toLowerCase().endsWith('gov.ph')
                        ? const Icon(Icons.verified, color: Colors.green, size: 20)
                        : null,
                  ),
                ),
                if (_emailError == null && _emailController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '✓ Valid government email',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 11,
                      ),
                    ),
                  ),
                SizedBox(height: narrow ? 10 : 12),

                // Password
                Text('Password', style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, size: 20),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Password strength
                Builder(builder: (c) {
                  final p = _passwordController.text;
                  double score = 0.0;
                  if (p.isNotEmpty) {
                    score = (p.length.clamp(0, 12)) / 12.0;
                    if (p.contains(RegExp(r'\d'))) score += 0.1;
                    if (p.contains(RegExp(r'[A-Z]'))) score += 0.1;
                    if (p.contains(RegExp(r'[!@#\$%\^&\*]'))) score += 0.1;
                    score = score.clamp(0.0, 1.0);
                  }
                  Color barColor;
                  if (score > 0.75) {
                    barColor = Colors.green;
                  } else if (score > 0.4) {
                    barColor = Colors.orange;
                  } else {
                    barColor = Colors.red;
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 4,
                        child: LinearProgressIndicator(
                          value: score,
                          color: barColor,
                          backgroundColor: Colors.grey.shade200,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (p.isNotEmpty)
                        Text(
                          score > 0.75 ? 'Strong' : (score > 0.4 ? 'Medium' : 'Weak'),
                          style: TextStyle(color: barColor, fontSize: 11),
                        ),
                    ],
                  );
                }),
                SizedBox(height: narrow ? 8 : 10),

                // Confirm Password
                Text('Confirm Password', style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                const SizedBox(height: 6),
                TextField(
                  focusNode: _confirmFocus,
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (_isFormValid) _handleSubmit();
                  },
                  decoration: InputDecoration(
                    hintText: 'Re-enter password',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off, size: 20),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    errorText: _confirmError,
                  ),
                ),
                SizedBox(height: narrow ? 10 : 12),

                // Remember Me
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (v) => setState(() => _rememberMe = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('Remember me', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  ],
                ),
                SizedBox(height: narrow ? 14 : 16),

                // Sign Up Button
                AnimatedOpacity(
                  opacity: _isFormValid && !_isSubmitting ? 1.0 : 0.6,
                  duration: const Duration(milliseconds: 250),
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _isFormValid && !_isSubmitting ? _handleSubmit : null,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007BFF)),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Sign Up', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                SizedBox(height: narrow ? 12 : 14),

                // Sign In Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Already have an account?", style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4)),
                        child: const Text('Sign in now', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ],
                  ),
                ),

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
                      image: const AssetImage('assets/background.jpeg'),
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
    );
  }
}