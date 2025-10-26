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
  final List<FocusNode> _codeFocusNodes = List.generate(6, (_) => FocusNode());
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _sentCode;
  bool _isSendingCode = false;
  int _countdown = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _codeFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _sendCode() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@') || !email.toLowerCase().endsWith('gov.ph')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid government email')));
      return;
    }

    setState(() => _isSendingCode = true);
    try {
      final code = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
      _sentCode = code;
      _startCountdown();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification code sent to $email (Demo: $code)')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to send verification code')));
    } finally {
      if (mounted) setState(() => _isSendingCode = false);
    }
  }

  void _startCountdown() {
    setState(() {
      _countdown = 15;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _countdown--;
      });
      return _countdown > 0;
    });
  }

  void _submit() {
    final email = _emailController.text;
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
                const SizedBox(height: 4),
                Center( 
                  child: Text(
                  'Forgot Password',
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

                Text('Email', style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter email',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 1,
                          height: 20,
                          color: Colors.grey.withAlpha((0.3 * 255).round()),
                        ),
                        const SizedBox(width: 8),
                        Opacity(
                          opacity: 1,
                          child: TextButton(
                            onPressed: _sendCode,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Get Code', style: TextStyle(fontSize: 13, )),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: narrow ? 10 : 12),

                // New Password
                Text('New Password', style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                const SizedBox(height: 6),
                TextField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNewPassword ? Icons.visibility : Icons.visibility_off, size: 20),
                      onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                    ),
                  ),
                ),
                SizedBox(height: narrow ? 10 : 12),

                // Confirm Password
                Text('Confirm Password', style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                const SizedBox(height: 6),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Re-enter password',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off, size: 20),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                ),
                SizedBox(height: narrow ? 10 : 12),

                // Verification Code
                Text('Verification Code', style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                const SizedBox(height: 6),
                Row(
                  // left aligned boxes with resend button at the end
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ...List.generate(6, (i) {
                      return Padding(
                        padding: EdgeInsets.only(right: i == 5 ? 0.0 : 8.0),
                        child: SizedBox(
                          width: narrow ? 32 : 36,
                          height: narrow ? 40 : 44,
                          child: TextField(
                            controller: _codeControllers[i],
                            focusNode: _codeFocusNodes[i],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (v) {
                              if (v.length > 1) {
                                final paste = v;
                                for (var k = 0; k < paste.length && (i + k) < 6; k++) {
                                  _codeControllers[i + k].text = paste[k];
                                }
                                final next = i + paste.length;
                                if (next < 6) {
                                  _codeFocusNodes[next].requestFocus();
                                } else {
                                  FocusScope.of(context).unfocus();
                                }
                                return;
                              }
                              if (v.isNotEmpty) {
                                if (i < 5) {
                                  _codeFocusNodes[i + 1].requestFocus();
                                } else {
                                  FocusScope.of(context).unfocus();
                                }
                              } else {
                                if (i > 0) _codeFocusNodes[i - 1].requestFocus();
                              }
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      );
                    }),
                    const Spacer(),
                    TextButton(
                      onPressed: (_isSendingCode || _countdown > 0) ? null : _sendCode,
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4)),
                      child: Text(_countdown > 0 ? 'Resend Code ${_countdown}s' : "Resend Code", style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),

                SizedBox(height: narrow ? 12 : 14),
                // Reset Password button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007BFF)),
                    child: const Text('Reset Password', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                SizedBox(height: narrow ? 10 : 12),

                // Back to Login button
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4)),
                    child: const Text('Back to Login', style: TextStyle(fontSize: 13)),
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