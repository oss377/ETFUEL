import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onRegisterAsDriver;
  final VoidCallback? onRegisterAsStationOwner;
  final VoidCallback? onJoinUnion;

  const LoginScreen({
    super.key,
    this.onBackPressed,
    this.onLoginSuccess,
    this.onRegisterAsDriver,
    this.onRegisterAsStationOwner,
    this.onJoinUnion,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _showRegisterOptions = false;
  String _errorMessage = '';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Session keys for local storage
  static const String _userSessionKey = 'user_session';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userRoleKey = 'user_role';
  static const String _isLoggedInKey = 'is_logged_in';

  Future<void> _loginWithEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter email and password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Login successful - now get user role from Firestore
      if (userCredential.user != null) {
        await _fetchUserRoleAndNavigate(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Login failed';
      if (e.code == 'user-not-found') {
        errorMsg = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        errorMsg = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        errorMsg = 'Invalid email address';
      } else if (e.code == 'user-disabled') {
        errorMsg = 'This account has been disabled';
      } else if (e.code == 'too-many-requests') {
        errorMsg = 'Too many attempts. Please try again later.';
      }

      setState(() {
        _errorMessage = errorMsg;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchUserRoleAndNavigate(User user) async {
    try {
      // Check user document in 'users' collection
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        // User doesn't exist in 'users' collection
        setState(() {
          _errorMessage = 'User profile not found. Please register again.';
        });
        // Optional: Sign out the user since profile doesn't exist
        await _auth.signOut();
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      
      // Get user role - default to 'driver' if not specified
      final String role = userData['role']?.toString().toLowerCase() ?? 'driver';
      final String fullName = userData['fullName']?.toString() ?? 'User';
      final String email = userData['email']?.toString() ?? user.email ?? '';

      // Validate role
      if (role != 'driver' && role != 'station') {
        setState(() {
          _errorMessage = 'Invalid user role. Please contact support.';
        });
        return;
      }

      // Save user session to local storage
      await _saveUserSession(
        userId: user.uid,
        email: email,
        fullName: fullName,
        role: role,
      );

      // Navigate to appropriate home page based on role
      _navigateToHomePage(role);

    } catch (e) {
      print('Error fetching user role: $e');
      setState(() {
        _errorMessage = 'Failed to load user profile. Please try again.';
      });
    }
  }

  Future<void> _saveUserSession({
    required String userId,
    required String email,
    required String fullName,
    required String role,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Create session data map
      final sessionData = {
        _userIdKey: userId,
        _userEmailKey: email,
        _userNameKey: fullName,
        _userRoleKey: role,
        _isLoggedInKey: true,
        'loginTimestamp': DateTime.now().toIso8601String(),
      };

      // Save as JSON string
      await prefs.setString(_userSessionKey, json.encode(sessionData));
      
      // Also save individual values for easy access
      await prefs.setString(_userIdKey, userId);
      await prefs.setString(_userEmailKey, email);
      await prefs.setString(_userNameKey, fullName);
      await prefs.setString(_userRoleKey, role);
      await prefs.setBool(_isLoggedInKey, true);

      print('User session saved: $fullName ($role)');
    } catch (e) {
      print('Error saving user session: $e');
      // Continue with navigation even if session save fails
    }
  }

  void _navigateToHomePage(String role) {
    // Clear navigation stack and go to home page
    // You'll need to implement the actual navigation based on your app structure
    
    if (role == 'driver') {
      // Navigate to Driver Home Page
      _showSuccessAndNavigate('Driver Home', 'Welcome back, Driver!');
      
      // In your actual app, you might do:
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(builder: (context) => DriverHomePage()),
      //   (route) => false,
      // );
      
    } else if (role == 'station') {
      // Navigate to Station Owner Home Page
      _showSuccessAndNavigate('Station Home', 'Welcome back, Station Owner!');
      
      // In your actual app, you might do:
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(builder: (context) => StationOwnerHomePage()),
      //   (route) => false,
      // );
    }
  }

  void _showSuccessAndNavigate(String title, String message) {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Call the success callback if provided
    if (widget.onLoginSuccess != null) {
      widget.onLoginSuccess!();
    }
  }

  // Method to check if user is already logged in (for app startup)
  static Future<Map<String, dynamic>?> getStoredUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if user is logged in
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      if (!isLoggedIn) return null;
      
      // Get session data from JSON
      final sessionJson = prefs.getString(_userSessionKey);
      if (sessionJson != null) {
        return json.decode(sessionJson) as Map<String, dynamic>;
      }
      
      // Fallback to individual keys
      final userId = prefs.getString(_userIdKey);
      final userEmail = prefs.getString(_userEmailKey);
      final userName = prefs.getString(_userNameKey);
      final userRole = prefs.getString(_userRoleKey);
      
      if (userId != null && userRole != null) {
        return {
          _userIdKey: userId,
          _userEmailKey: userEmail ?? '',
          _userNameKey: userName ?? '',
          _userRoleKey: userRole,
          _isLoggedInKey: true,
        };
      }
      
      return null;
    } catch (e) {
      print('Error getting stored session: $e');
      return null;
    }
  }

  // Method to clear user session (for logout)
  static Future<void> clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear all session data
      await prefs.remove(_userSessionKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userRoleKey);
      await prefs.remove(_isLoggedInKey);
      
      print('User session cleared');
    } catch (e) {
      print('Error clearing user session: $e');
    }
  }

  void _showRegisterOptionsScreen() {
    setState(() {
      _showRegisterOptions = true;
    });
  }

  void _hideRegisterOptions() {
    setState(() {
      _showRegisterOptions = false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showRegisterOptions) {
      return _buildRegisterOptionsScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Hero Header Image
              _buildHeroImage(),

              // Headline
              _buildHeadline(),

              // Error Message
              if (_errorMessage.isNotEmpty) _buildErrorMessage(),

              // Form Section
              _buildFormSection(),

              // Action Button
              _buildLoginButton(),

              // Social Login Section
              _buildSocialLogin(),

              // Don't have account? Create Account
              _buildNoAccountSection(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterOptionsScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
                    child: IconButton(
                      onPressed: _hideRegisterOptions,
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Text(
                  'Create Account',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Choose how you want to join our automotive community',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9ca6ba),
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Station Owner Button
                    _buildRegisterOption(
                      title: 'Station Owner',
                      subtitle: 'Own a fuel station or service center',
                      icon: Icons.local_gas_station,
                      iconColor: const Color(0xFF256af4),
                      borderColor: const Color(0xFF256af4).withAlpha(77),
                      onTap:
                          widget.onRegisterAsStationOwner ??
                          () {
                            // Navigate to station owner registration
                            _showSnackBar(
                              'Station Owner Registration Selected',
                            );
                          },
                    ),

                    const SizedBox(height: 24),

                    // Driver Button
                    _buildRegisterOption(
                      title: 'Driver',
                      subtitle: 'Car owner looking for fuel & services',
                      icon: Icons.directions_car,
                      iconColor: const Color(0xFF0df259),
                      borderColor: const Color(0xFF0df259).withAlpha(77),
                      onTap:
                          widget.onRegisterAsDriver ??
                          () {
                            // Navigate to driver registration
                            _showSnackBar('Driver Registration Selected');
                          },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Already have account link
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: GestureDetector(
                  onTap: _hideRegisterOptions,
                  child: Text(
                    'Already have an account? Login',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF256af4),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF256af4),
      ),
    );
  }

  Widget _buildRegisterOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [iconColor.withOpacity(0.25), iconColor.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(51),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF9ca6ba),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: iconColor.withOpacity(0.5), blurRadius: 10),
                ],
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAccountSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Column(
        children: [
          Text(
            'Don\'t have an account?',
            style: GoogleFonts.inter(
              color: const Color(0xFF9ca6ba),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _showRegisterOptionsScreen,
            child: Column(
              children: [
                Text(
                  'CREATE ACCOUNT',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF256af4),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 2,
                  width: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF256af4).withAlpha(102),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Color(0xFF0a0a0a)],
        ),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1503376780353-7e6692767b70?q=80&w=2070&auto=format&fit=crop',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildHeadline() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          Text(
            'Welcome Back',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              height: 1.1,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to continue to your account',
            style: GoogleFonts.inter(
              color: const Color(0xFF9ca6ba),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withAlpha(77)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage,
                style: GoogleFonts.inter(color: Colors.red, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Email Field
          _buildEmailField(),
          const SizedBox(height: 16),

          // Password Field
          _buildPasswordField(),
          const SizedBox(height: 8),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                _showForgotPasswordDialog();
              },
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.inter(
                  color: const Color(0xFF9ca6ba),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1b1f27),
          title: Text(
            'Reset Password',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your email to receive a password reset link',
                style: GoogleFonts.inter(color: const Color(0xFF9ca6ba)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: GoogleFonts.inter(color: const Color(0xFF9ca6ba)),
                  filled: true,
                  fillColor: const Color(0xFF2a2f3a),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: const Color(0xFF9ca6ba)),
              ),
            ),
            TextButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your email'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  await _auth.sendPasswordResetEmail(email: email);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password reset email sent to $email'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Send',
                style: GoogleFonts.inter(
                  color: const Color(0xFF256af4),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
    
    emailController.dispose();
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Email Address',
            style: GoogleFonts.inter(
              color: const Color(0xFF256af4),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextField(
          controller: _emailController,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          decoration: InputDecoration(
            hintText: 'driver@carunion.com',
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFF5c6881),
              fontSize: 16,
            ),
            filled: true,
            fillColor: const Color(0xFF1b1f27),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: const BorderSide(color: Color(0xFF3b4354), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: const BorderSide(color: Color(0xFF3b4354), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: const BorderSide(color: Color(0xFF256af4), width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Password',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: GoogleFonts.inter(
                    color: const Color(0xFF5c6881),
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1b1f27),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(999),
                      bottomLeft: Radius.circular(999),
                    ),
                    borderSide: BorderSide(color: Color(0xFF3b4354), width: 1),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(999),
                      bottomLeft: Radius.circular(999),
                    ),
                    borderSide: BorderSide(color: Color(0xFF3b4354), width: 1),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(999),
                      bottomLeft: Radius.circular(999),
                    ),
                    borderSide: BorderSide(color: Color(0xFF3b4354), width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                ),
              ),
            ),
            Container(
              height: 60,
              width: 60,
              decoration: const BoxDecoration(
                color: Color(0xFF1b1f27),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(999),
                  bottomRight: Radius.circular(999),
                ),
                border: Border(
                  left: BorderSide.none,
                  top: BorderSide(color: Color(0xFF3b4354), width: 1),
                  right: BorderSide(color: Color(0xFF3b4354), width: 1),
                  bottom: BorderSide(color: Color(0xFF3b4354), width: 1),
                ),
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF9ca6ba),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _loginWithEmail,
        style:
            ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF256af4),
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: const Color(0xFF256af4).withAlpha(102),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              minimumSize: const Size(double.infinity, 56),
              disabledBackgroundColor: const Color(0xFF256af4).withAlpha(128),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith<Color?>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.white.withAlpha(51);
                }
                return null;
              }),
            ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Login',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.bolt, color: Colors.white, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          // Divider with text
          Row(
            children: [
              Expanded(
                child: Container(height: 1, color: const Color(0xFF3b4354)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Or continue with',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9ca6ba),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Expanded(
                child: Container(height: 1, color: const Color(0xFF3b4354)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Social buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Apple
              _buildSocialButton(
                icon: Icons.apple,
                onPressed: () {
                  // Handle Apple login
                },
              ),
              const SizedBox(width: 24),

              // Google
              _buildSocialButton(
                icon: Icons.mail,
                onPressed: () {
                  // Handle Google login
                },
              ),
              const SizedBox(width: 24),

              // Fingerprint
              _buildSocialButton(
                icon: Icons.fingerprint,
                color: const Color(0xFF256af4),
                onPressed: () {
                  // Handle fingerprint login
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withAlpha(26), width: 1),
        ),
        child: Icon(icon, color: color ?? Colors.white, size: 28),
      ),
    );
  }
}