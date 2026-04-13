import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../../../components/form_error.dart';
import '../../../../../components/no_account_text.dart';
import '../../../../../constants.dart';
import '../../providers/auth_provider.dart';
import '../../../../../services/fcm_token_service.dart';
import '../complete_profile/complete_profile_screen.dart';
import '../../../../home/presentation/screens/init_screen.dart';
import '../forgot_password/forgot_password_screen.dart';

enum AuthMode { signIn, signUp }

class AuthScreen extends StatefulWidget {
  static String routeName = "/auth";

  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  AuthMode _authMode = AuthMode.signIn;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _authMode =
            _tabController.index == 0 ? AuthMode.signIn : AuthMode.signUp;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Do nothing - prevent back navigation
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Skip button - minimal design aligned to right
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const InitScreen()),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        backgroundColor: Colors.grey[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Header Text - Modern typography
                  Text(
                    _authMode == AuthMode.signIn
                        ? "Welcome Back"
                        : "Get Started",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    _authMode == AuthMode.signIn
                        ? "Sign in to continue"
                        : "Create your account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Tab Bar - Minimal design
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: kPrimaryColor,
                      unselectedLabelColor: Colors.grey[600],
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: "Sign In"),
                        Tab(text: "Sign Up"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Form Section
                  _authMode == AuthMode.signIn
                      ? SignInForm(
                          onSwitchToSignUp: () {
                            _tabController.animateTo(1);
                          },
                        )
                      : const SignUpForm(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Sign In Form
class SignInForm extends StatefulWidget {
  final VoidCallback onSwitchToSignUp;

  const SignInForm({
    super.key,
    required this.onSwitchToSignUp,
  });

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final List<String?> errors = [];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Email Field - Modern minimal design
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 15),
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError(error: kEmailNullError);
              }
              if (emailValidatorRegExp.hasMatch(value)) {
                removeError(error: kInvalidEmailError);
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                addError(error: kEmailNullError);
                return "";
              } else if (!emailValidatorRegExp.hasMatch(value)) {
                addError(error: kInvalidEmailError);
                return "";
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: "Email",
              hintText: "you@example.com",
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              labelStyle: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: Colors.grey[600],
                size: 22,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: kPrimaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red[300]!, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),

          const SizedBox(height: 18),

          // Password Field - Modern minimal design
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(fontSize: 15),
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError(error: kPassNullError);
              }
              if (value.length >= 8) {
                removeError(error: kShortPassError);
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                addError(error: kPassNullError);
                return "";
              } else if (value.length < 8) {
                addError(error: kShortPassError);
                return "";
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: "Password",
              hintText: "••••••••",
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              labelStyle: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: Colors.grey[600],
                size: 22,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey[500],
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: kPrimaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red[300]!, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),

          const SizedBox(height: 16),

          // Forgot Password - Aligned to right
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen()),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                "Forgot Password?",
                style: TextStyle(
                  fontSize: 14,
                  color: kPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          FormError(errors: errors),
          const SizedBox(height: 24),

          // Sign In Button - Modern gradient
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _handleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: authProvider.isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 24),

          // Divider with "OR"
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
            ],
          ),

          const SizedBox(height: 24),

          // Google Sign-In Button with modern minimal styling
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: authProvider.isLoading ? null : _handleGoogleSignIn,
              icon: Image.asset(
                'assets/images/google-icon.png',
                height: 22,
                width: 22,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.g_mobiledata,
                      size: 24, color: Colors.blue);
                },
              ),
              label: const Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                foregroundColor: Colors.black87,
                backgroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          NoAccountText(onSignUpTap: widget.onSwitchToSignUp),
        ],
      ),
    );
  }

  Future<void> _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Get FCM token
      final fcmToken = await FCMTokenService.getFCMToken();
      if (fcmToken != null) {
        // FCM token retrieved
      }
      
      // Call login API - this will save token and user data to local storage on success (status 200)
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
        fcmToken: fcmToken,
      );

      if (!mounted) return;

      // On successful login (status 200), auth data is already saved to local storage
      // Navigate to home screen
      if (success) {
        // Clear any existing errors
        setState(() {
          errors.clear();
        });
        
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InitScreen()),
        );
      } else {
        if (!mounted) return;

        // Extract clean error message
        String errorMessage = authProvider.errorMessage ?? 'Login failed';

        // Clean up the error message - remove "Login failed: Exception: " prefix if present
        if (errorMessage.startsWith('Login failed: Exception: ')) {
          errorMessage =
              errorMessage.replaceFirst('Login failed: Exception: ', '');
        } else if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.replaceFirst('Exception: ', '');
        }

        // Show prominent error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Also add the error to the form errors list for visibility
        setState(() {
          errors.clear();
          errors.add(errorMessage);
        });
      }
    } else {
      // Form validation failed
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Starting Google Sign-In

      // Get FCM token
      final fcmToken = await FCMTokenService.getFCMToken();
      if (fcmToken != null) {
        // FCM token retrieved for Google Sign-In
      }

      // Sign in with Google
      final result = await authProvider.signInWithGoogle(fcmToken: fcmToken);

      if (!mounted) return;

      if (result['success'] == true) {
        if (result['isComplete'] == true) {
          // Profile is complete, navigate to home
          // Profile complete, navigating to InitScreen (log removed)
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const InitScreen()),
          );
        } else {
          // Profile is incomplete, navigate to CompleteProfileScreen
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CompleteProfileScreen(),
              settings: RouteSettings(arguments: {
                'isSocialAuth': true,
                'socialUser': result['user'],
                'email': result['user']?.email ?? '',
              }),
            ),
          );
        }
      } else {
        // Google Sign-In failed
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'Google sign-in failed',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Google Sign-In error
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Sign Up Form
class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final List<String?> errors = [];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    required Function(String?) validator,
    required Function(String) onChanged,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      validator: (value) => validator(value) as String?,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
          letterSpacing: 0.2,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey[400],
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.grey[600],
          size: 22,
        ),
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: kPrimaryColor.withOpacity(0.8), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // First Name
          _buildStyledTextField(
            controller: _firstNameController,
            label: "First Name",
            hint: "Enter your first name",
            icon: Icons.person_outline,
            keyboardType: TextInputType.name,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError(error: "First name is required");
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                addError(error: "First name is required");
                return "";
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Last Name
          _buildStyledTextField(
            controller: _lastNameController,
            label: "Last Name",
            hint: "Enter your last name",
            icon: Icons.person_outline,
            keyboardType: TextInputType.name,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError(error: "Last name is required");
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                addError(error: "Last name is required");
                return "";
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Username
          _buildStyledTextField(
            controller: _usernameController,
            label: "Username",
            hint: "Choose a unique username",
            icon: Icons.alternate_email,
            keyboardType: TextInputType.text,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError(error: "Username is required");
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                addError(error: "Username is required");
                return "";
              }
              if (value.length < 3) {
                addError(error: "Username must be at least 3 characters");
                return "";
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Email
          _buildStyledTextField(
            controller: _emailController,
            label: "Email",
            hint: "Enter your email",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError(error: kEmailNullError);
              }
              if (emailValidatorRegExp.hasMatch(value)) {
                removeError(error: kInvalidEmailError);
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                addError(error: kEmailNullError);
                return "";
              } else if (!emailValidatorRegExp.hasMatch(value)) {
                addError(error: kInvalidEmailError);
                return "";
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

            // Phone Number with modern design
            IntlPhoneField(
            controller: _phoneController,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            dropdownTextStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            // counterStyle: TextStyle(
            //   fontSize: 12,
            //   fontWeight: FontWeight.w500,
            //   color: Colors.grey[600],
            // ),
            decoration: InputDecoration(
              labelText: "Phone Number",
              hintText: "Enter your phone number",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              letterSpacing: 0.2,
              ),
              hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
              ),
              contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                BorderSide(color: kPrimaryColor.withOpacity(0.8), width: 2),
              ),
              errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.shade300),
              ),
              focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            initialCountryCode: 'PK',
            onChanged: (phone) {
              if (phone.completeNumber.isNotEmpty) {
              removeError(error: "Phone number is required");
              }
            },
            onSaved: (phone) {
              if (phone != null) {
              _phoneController.text = phone.completeNumber;
              }
            },
            validator: (phone) {
              if (phone == null || phone.completeNumber.isEmpty) {
              addError(error: "Phone number is required");
              return "";
              }
              return null;
            },
            ),


          const SizedBox(height: 20),

          // Password
          _buildStyledTextField(
            controller: _passwordController,
            label: "Password",
            hint: "Enter your password",
            icon: Icons.lock_outline,
            keyboardType: TextInputType.visiblePassword,
            obscureText: _obscurePassword,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError(error: kPassNullError);
              }
              if (value.length >= 8) {
                removeError(error: kShortPassError);
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                addError(error: kPassNullError);
                return "";
              } else if (value.length < 8) {
                addError(error: kShortPassError);
                return "";
              }
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey[600],
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          // Confirm Password
          _buildStyledTextField(
            controller: _confirmPasswordController,
            label: "Confirm Password",
            hint: "Re-enter your password",
            icon: Icons.lock_outline,
            keyboardType: TextInputType.visiblePassword,
            obscureText: _obscureConfirmPassword,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError(error: kPassNullError);
              }
              if (value == _passwordController.text) {
                removeError(error: kMatchPassError);
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                addError(error: kPassNullError);
                return "";
              } else if (value != _passwordController.text) {
                addError(error: kMatchPassError);
                return "";
              }
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey[600],
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),

          FormError(errors: errors),
          const SizedBox(height: 24),

          // Sign Up Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _handleSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: authProvider.isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 24),

          // Divider with "OR"
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),

          const SizedBox(height: 24),

          // Google Sign-Up Button with modern minimal styling
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: authProvider.isLoading ? null : _handleGoogleSignUp,
              icon: Image.asset(
                'assets/images/google-icon.png',
                height: 22,
                width: 22,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.g_mobiledata,
                      size: 24, color: Colors.blue);
                },
              ),
              label: const Text(
                'Sign up with Google',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                foregroundColor: Colors.black87,
                backgroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'By continuing you confirm that you agree\nwith our Terms and Conditions',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Get FCM token
      final fcmToken = await FCMTokenService.getFCMToken();
      if (fcmToken != null) {
        // FCM token retrieved (debug log removed)
      }

      // Store email and password for auto-login after registration
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Call registration API - this will save token and user data on success (status 200)
      final success = await authProvider.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: email,
        password: password,
        fcmToken: fcmToken,
      );

      if (!mounted) return;

      if (success) {
        // Registration successful (status 200) - auth data is already saved to local storage
        // Clear any existing errors
        setState(() {
          errors.clear();
        });
        
        // Navigate directly to home screen since registration response includes auth token
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InitScreen()),
        );
      } else {
        // Registration failed - show error
        if (!mounted) return;

        // Extract clean error message
        String errorMessage =
            authProvider.errorMessage ?? 'Registration failed';

        // Handle special case for already exists
        if (errorMessage.toLowerCase().contains('already exists')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Account already exists. Please sign in instead.',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange.shade600,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          return;
        }

        // Clean up the error message - remove "Exception: " prefix if present
        if (errorMessage.startsWith('Registration failed: Exception: ')) {
          errorMessage =
              errorMessage.replaceFirst('Registration failed: Exception: ', '');
        } else if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.replaceFirst('Exception: ', '');
        }

        // Show prominent error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Also add the error to the form errors list for visibility
        setState(() {
          errors.clear();
          errors.add(errorMessage);
        });
      }
    } else {
      // Form validation failed (debug log removed)
    }
  }

  Future<void> _handleGoogleSignUp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Starting Google Sign-Up (debug log removed)

      // Get FCM token
      final fcmToken = await FCMTokenService.getFCMToken();
      if (fcmToken != null) {
        // FCM token for Google Sign-Up retrieved (debug log removed)
      }

      // Sign in with Google (same as sign-in, Google auth doesn't differentiate)
      final result = await authProvider.signInWithGoogle(fcmToken: fcmToken);

      if (!mounted) return;

      if (result['success'] == true) {
        // Google Sign-Up successful (debug log removed)

        if (result['isComplete'] == true) {
          // Profile complete, navigating to InitScreen (debug log removed)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const InitScreen()),
          );
        } else {
          // Profile is incomplete, navigate to complete profile
          // Profile incomplete, navigating to CompleteProfileScreen (debug log removed)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CompleteProfileScreen(),
              settings: RouteSettings(arguments: {
                'isSocialAuth': true,
                'socialUser': result['user'],
                'email': result['user']?.email ?? '',
              }),
            ),
          );
        }
      } else {
        // Google Sign-Up failed (debug log removed)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'Google sign-up failed',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Google Sign-Up error (debug log removed)
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
