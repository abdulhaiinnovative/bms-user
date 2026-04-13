import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../constants.dart';
import '../../providers/auth_provider.dart';
import '../reset_password/reset_password_screen.dart';

class VerificationScreen extends StatefulWidget {
  static String routeName = "/verification";

  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _email;
  String? _verificationType; // 'password_reset' or 'email_verification'
  bool _isLoading = false;
  bool _hasError = false;
  int _resendTimer = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get arguments from navigation
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _email = args['email'] as String?;
      _verificationType = args['verificationType'] as String?;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer = 60;
    _canResend = false;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _handleVerify() async {
    if (_email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email not found. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_codeController.text.length < 4) {
      setState(() {
        _hasError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = false;

      if (_verificationType == 'password_reset') {
        // For password reset, we just navigate to reset password screen with the code
        // The actual verification happens when resetting the password
        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ResetPasswordScreen(),
            settings: RouteSettings(arguments: {
              'email': _email,
              'code': _codeController.text,
            }),
          ),
        );
        return;
      } else {
        // For email verification
        success = await authProvider.verifyEmail(
          email: _email!,
          code: _codeController.text,
        );
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to appropriate screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        setState(() {
          _hasError = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Verification failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleResend() async {
    if (!_canResend || _email == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = false;

      if (_verificationType == 'password_reset') {
        success = await authProvider.resendResetCode(_email!);
      } else {
        success = await authProvider.resendVerificationCode(_email!);
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (success) {
        _startResendTimer();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code resent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to resend code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPasswordReset = _verificationType == 'password_reset';
    final codeLength = isPasswordReset ? 6 : 4;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_user,
                      size: 80,
                      color: kPrimaryColor,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Title
                  Text(
                    isPasswordReset ? "Enter Reset Code" : "Verify Email",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Description
                  Text(
                    isPasswordReset
                        ? "We've sent a $codeLength-digit code to\n${_email ?? 'your email'}"
                        : "We've sent a $codeLength-digit verification code to\n${_email ?? 'your email'}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // OTP Input Fields
                  Form(
                    key: _formKey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        codeLength,
                        (index) => SizedBox(
                          width: 50,
                          height: 60,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: _hasError ? Colors.red : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: _hasError ? Colors.red : kPrimaryColor,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              setState(() {
                                _hasError = false;
                              });

                              if (value.length == 1) {
                                // Update the code controller
                                String currentCode = _codeController.text;
                                if (currentCode.length > index) {
                                  // Replace character at index
                                  _codeController.text =
                                      currentCode.substring(0, index) +
                                          value +
                                          currentCode.substring(index + 1);
                                } else {
                                  // Append to the code
                                  _codeController.text = currentCode + value;
                                }

                                // Move to next field
                                if (index < codeLength - 1) {
                                  FocusScope.of(context).nextFocus();
                                } else {
                                  // Last field - auto verify
                                  FocusScope.of(context).unfocus();
                                  if (_codeController.text.length ==
                                      codeLength) {
                                    _handleVerify();
                                  }
                                }
                              } else if (value.isEmpty) {
                                // Update code controller - remove character
                                String currentCode = _codeController.text;
                                if (currentCode.length > index) {
                                  _codeController.text =
                                      currentCode.substring(0, index) +
                                          (index < currentCode.length - 1
                                              ? currentCode.substring(index + 1)
                                              : '');
                                }

                                // Move to previous field
                                if (index > 0) {
                                  FocusScope.of(context).previousFocus();
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (_hasError)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'Invalid code. Please try again.',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              "Verify",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Resend Code
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive code? ",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed:
                            _canResend && !_isLoading ? _handleResend : null,
                        child: Text(
                          _canResend ? "Resend" : "Resend in ${_resendTimer}s",
                          style: TextStyle(
                            color: _canResend ? kPrimaryColor : Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
