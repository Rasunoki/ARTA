import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final List<TextEditingController> _codeControllers = List.generate(6, (_) => TextEditingController());
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _sentCode;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _codeControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _sendCode() {
    final email = _emailController.text;
    // Generate a mock 6-digit code and show it in a snackbar (frontend-only)
    final code = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
    _sentCode = code;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification code (demo): $code sent to $email')));
  }

  void _submit() {
    final email = _emailController.text;
    // Verify code frontend-only
    final entered = _codeControllers.map((c) => c.text).join();
    if (_sentCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please request a verification code first')));
      return;
    }
    if (entered != _sentCode) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid verification code')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password updated for $email (demo)')),
    );
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
            padding: EdgeInsets.all(narrow ? 24 : 40),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              'Forgot Password',
                              style: GoogleFonts.racingSansOne(
                                textStyle: TextStyle(
                                  fontSize: narrow ? 28 : 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Email + Get Code
                            Text('Email', style: TextStyle(fontSize: 14, color: Colors.grey[800])),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter email',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: _sendCode,
                                  child: const Text('Get Code'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // New Password
                            Text('New Password', style: TextStyle(fontSize: 14, color: Colors.grey[800])),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _newPasswordController,
                              obscureText: _obscureNewPassword,
                              decoration: InputDecoration(
                                hintText: 'Enter password',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Confirm Password
                            Text('Confirm Password', style: TextStyle(fontSize: 14, color: Colors.grey[800])),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                hintText: 'Re-enter password',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Verification Code
                            Text('Verification Code', style: TextStyle(fontSize: 14, color: Colors.grey[800])),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(6, (i) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: SizedBox(
                                    width: narrow ? 35 : 40,
                                    height: narrow ? 44 : 48,
                                    child: TextField(
                                      controller: _codeControllers[i],
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(1),
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(onPressed: _sendCode, child: const Text("Didn't get code?")),
                            ),

                            const SizedBox(height: 20),
                            // Action button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007BFF)),
                                child: const Text('Reset Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Back button
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Back to Login'),
                              ),
                            ),

                            // Add some space before footer on scroll
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),

                    // Footer at the bottom
                    _buildFooter(),
                  ],
                );
              },
            ),
          );

          if (narrow) {
            // Mobile layout: Column layout
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
                    // Header takes 30% of screen
                    SizedBox(
                      height: screenHeight * 0.3,
                      child: leftHeader,
                    ),
                    // Right panel takes remaining 70%
                    Expanded(
                      child: rightPanel,
                    ),
                  ],
                ),
              ],
            );
          } else {
            // Desktop layout: Side-by-side
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
                leftHeader,
                Align(
                  alignment: Alignment.centerRight,
                  child: rightPanel,
                ),
              ],
            );
          }
        },
      ),
    );
  }
}