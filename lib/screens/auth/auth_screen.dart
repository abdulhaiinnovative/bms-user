import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/custom_surfix_icon.dart';
import '../../components/form_error.dart';
import '../../components/no_account_text.dart';
import '../../constants.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/fcm_token_service.dart';
import '../complete_profile/complete_profile_screen.dart';
import '../init_screen.dart';
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Authentication"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Sign In"),
            Tab(text: "Sign Up"),
          ],
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    _authMode == AuthMode.signIn
                        ? "Welcome Back"
                        : "Register Account",
                    style: headingStyle,
                  ),
                  Text(
                    _authMode == AuthMode.signIn
                        ? "Sign in to continue"
                        : "Complete your details to get started",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Email/Password Form
                  _authMode == AuthMode.signIn
                      ? SignInForm(
                          onSwitchToSignUp: () {
                            _tabController.animateTo(1);
                          },
                        )
                      : const SignUpForm(),
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
          // Email Field
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
            decoration: const InputDecoration(
              labelText: "Email",
              hintText: "Enter your email",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
            ),
          ),

          const SizedBox(height: 20),

          // Password Field
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
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
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
          const SizedBox(height: 16),

          // Sign In Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _handleSignIn,
              child: authProvider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text("Sign In"),
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // First Name
          TextFormField(
            controller: _firstNameController,
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
            decoration: const InputDecoration(
              labelText: "First Name",
              hintText: "Enter your first name",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
            ),
          ),

          const SizedBox(height: 20),

          // Last Name
          TextFormField(
            controller: _lastNameController,
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
            decoration: const InputDecoration(
              labelText: "Last Name",
              hintText: "Enter your last name",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
            ),
          ),

          const SizedBox(height: 20),

          // Username
          TextFormField(
            controller: _usernameController,
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
            decoration: const InputDecoration(
              labelText: "Username",
              hintText: "Choose a unique username",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
            ),
          ),

          const SizedBox(height: 20),

          // Phone Number
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError(error: "Phone number is required");
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                addError(error: "Phone number is required");
                return "";
              }
              if (value.length < 10) {
                addError(error: "Please enter a valid phone number");
                return "";
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: "Phone Number",
              hintText: "Enter your phone number",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Phone.svg"),
            ),
          ),

          const SizedBox(height: 20),

          // Email
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
            decoration: const InputDecoration(
              labelText: "Email",
              hintText: "Enter your email",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
            ),
          ),

          const SizedBox(height: 20),

          // Password
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
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
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
            decoration: InputDecoration(
              labelText: "Confirm Password",
              hintText: "Re-enter your password",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
          ),

          FormError(errors: errors),
          const SizedBox(height: 20),

          // Sign Up Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _handleSignUp,
              child: authProvider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text("Sign Up"),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'By continuing you confirm that you agree\nwith our Terms and Conditions',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
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
}
