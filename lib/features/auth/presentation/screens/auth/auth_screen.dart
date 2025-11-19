import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../../../components/form_error.dart';
import '../../../../../components/no_account_text.dart';
import '../../../../../constants.dart';
import '../../providers/auth_provider.dart';
import '../../../../../services/fcm_token_service.dart';
import '../complete_profile/complete_profile_screen.dart';
import '../../../../../screens/init_screen.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Logo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/bms_logo.jpg',
                    height: 60,
                    width: 60,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.spa,
                        size: 60,
                        color: kPrimaryColor,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Header Text
                Text(
                  _authMode == AuthMode.signIn
                      ? "Welcome Back!"
                      : "Join Us Today",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _authMode == AuthMode.signIn
                      ? "Sign in to continue your beauty journey"
                      : "Create your account and get started",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 30),

                // Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [kPrimaryColor, Color(0xFFFF6B9D)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[600],
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    tabs: const [
                      Tab(text: "Sign In"),
                      Tab(text: "Sign Up"),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Form Section
                _authMode == AuthMode.signIn
                    ? SignInForm(
                        onSwitchToSignUp: () {
                          _tabController.animateTo(1);
                        },
                      )
                    : const SignUpForm(),

                const SizedBox(height: 20),
              ],
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
  bool _rememberMe = false;
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
          // Email Field with clean design
          TextFormField(
            controller: _emailController,
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
            decoration: InputDecoration(
              labelText: "Email",
              hintText: "Enter your email",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: kPrimaryColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kPrimaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),

          const SizedBox(height: 20),

          // Password Field with clean design
          TextFormField(
            controller: _passwordController,
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
            decoration: InputDecoration(
              labelText: "Password",
              hintText: "Enter your password",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: kPrimaryColor,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kPrimaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),

          const SizedBox(height: 20),

          // Remember Me & Forgot Password
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                activeColor: kPrimaryColor,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
              ),
              const Text("Remember me"),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Navigate to forgot password
                  Navigator.pushNamed(context, ForgotPasswordScreen.routeName);
                },
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),

          FormError(errors: errors),
          const SizedBox(height: 24),

          // Sign In Button with gradient
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kPrimaryColor, Color(0xFFFF6B9D)],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _handleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: authProvider.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 20),

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

          const SizedBox(height: 20),

          // Google Sign-In Button with enhanced styling
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.grey[300]!, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: OutlinedButton.icon(
              onPressed: authProvider.isLoading ? null : _handleGoogleSignIn,
              icon: Image.asset(
                'assets/images/google-icon.png',
                height: 24,
                width: 24,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.g_mobiledata,
                      size: 28, color: Colors.blue);
                },
              ),
              label: const Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide.none,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
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
        print('🔔 AuthScreen: FCM Token retrieved for login');
      }

      print('🔐 AuthScreen: Attempting login...');
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
        fcmToken: fcmToken,
      );

      print('🔐 AuthScreen: Login result = $success');
      if (!mounted) return;

      if (success) {
        print('✅ AuthScreen: Login successful, navigating to InitScreen...');
        Navigator.pushReplacementNamed(context, InitScreen.routeName);
      } else {
        print('❌ AuthScreen: Login failed - ${authProvider.errorMessage}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print('⚠️ AuthScreen: Form validation failed');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      print('🔵 AuthScreen: Starting Google Sign-In...');

      // Get FCM token
      final fcmToken = await FCMTokenService.getFCMToken();
      if (fcmToken != null) {
        print('🔔 AuthScreen: FCM Token retrieved for Google Sign-In');
      }

      // Sign in with Google
      final result = await authProvider.signInWithGoogle(fcmToken: fcmToken);

      if (!mounted) return;

      if (result['success'] == true) {
        print('✅ AuthScreen: Google Sign-In successful');

        if (result['isComplete'] == true) {
          // Profile is complete, navigate to home
          print('✅ AuthScreen: Profile complete, navigating to InitScreen...');
          Navigator.pushReplacementNamed(context, InitScreen.routeName);
        } else {
          // Profile is incomplete, navigate to complete profile
          print(
              '⚠️ AuthScreen: Profile incomplete, navigating to CompleteProfileScreen...');
          Navigator.pushReplacementNamed(
            context,
            CompleteProfileScreen.routeName,
            arguments: {
              'isSocialAuth': true,
              'socialUser': result['user'],
              'email': result['user']?.email ?? '',
            },
          );
        }
      } else {
        print('❌ AuthScreen: Google Sign-In failed');
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
      print('❌ AuthScreen: Google Sign-In error - $e');
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
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: Icon(
          icon,
          color: kPrimaryColor,
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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

          const SizedBox(height: 16),

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

          const SizedBox(height: 16),

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

          const SizedBox(height: 16),

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

          const SizedBox(height: 16),

          // Phone Number with clean design
          IntlPhoneField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: "Phone Number",
              hintText: "Enter your phone number",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kPrimaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
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

          const SizedBox(height: 16),

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
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),

          const SizedBox(height: 16),

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
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),

          FormError(errors: errors),
          const SizedBox(height: 20),

          // Sign Up Button with gradient
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kPrimaryColor, Color(0xFFFF6B9D)],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _handleSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: authProvider.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 20),

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

          const SizedBox(height: 20),

          // Google Sign-Up Button with enhanced styling
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.grey[300]!, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: OutlinedButton.icon(
              onPressed: authProvider.isLoading ? null : _handleGoogleSignUp,
              icon: Image.asset(
                'assets/images/google-icon.png',
                height: 24,
                width: 24,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.g_mobiledata,
                      size: 28, color: Colors.blue);
                },
              ),
              label: const Text(
                'Sign up with Google',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide.none,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'By continuing you confirm that you agree\nwith our Terms and Conditions',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 20),
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
        print('🔔 AuthScreen: FCM Token retrieved for registration');
      }

      print('📝 AuthScreen: Attempting registration...');
      final success = await authProvider.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fcmToken: fcmToken,
      );

      print('📝 AuthScreen: Registration result = $success');
      if (!mounted) return;

      if (success) {
        print(
            '✅ AuthScreen: Registration successful, navigating to CompleteProfileScreen...');
        Navigator.pushReplacementNamed(
            context, CompleteProfileScreen.routeName);
      } else {
        print(
            '❌ AuthScreen: Registration failed - ${authProvider.errorMessage}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Registration failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print('⚠️ AuthScreen: Form validation failed');
    }
  }

  Future<void> _handleGoogleSignUp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      print('🔵 AuthScreen: Starting Google Sign-Up...');

      // Get FCM token
      final fcmToken = await FCMTokenService.getFCMToken();
      if (fcmToken != null) {
        print('🔔 AuthScreen: FCM Token retrieved for Google Sign-Up');
      }

      // Sign in with Google (same as sign-in, Google auth doesn't differentiate)
      final result = await authProvider.signInWithGoogle(fcmToken: fcmToken);

      if (!mounted) return;

      if (result['success'] == true) {
        print('✅ AuthScreen: Google Sign-Up successful');

        if (result['isComplete'] == true) {
          // Profile is complete, navigate to home
          print('✅ AuthScreen: Profile complete, navigating to InitScreen...');
          Navigator.pushReplacementNamed(context, InitScreen.routeName);
        } else {
          // Profile is incomplete, navigate to complete profile
          print(
              '⚠️ AuthScreen: Profile incomplete, navigating to CompleteProfileScreen...');
          Navigator.pushReplacementNamed(
            context,
            CompleteProfileScreen.routeName,
            arguments: {
              'isSocialAuth': true,
              'socialUser': result['user'],
              'email': result['user']?.email ?? '',
            },
          );
        }
      } else {
        print('❌ AuthScreen: Google Sign-Up failed');
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
      print('❌ AuthScreen: Google Sign-Up error - $e');
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
