import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/station_registration_screen.dart';
import 'screens/vehicle_registration_screen.dart';
import 'screens/station_owner.dart';
import 'screens/car_owner.dart';
import 'screens/home_page.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Error initializing Firebase: $e');
  }

  runApp(const ETFUELApp());
}

class ETFUELApp extends StatelessWidget {
  const ETFUELApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ETFUEL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF256af4),
        scaffoldBackgroundColor: const Color(0xFF0a0c10),
        fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0a0c10),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF256af4),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.dark,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = true;
  AppState _appState = AppState.splash;
  String _userName = '';
  String _userRole = '';
  String _userId = '';
  int _landingTabIndex = 0;

  // Add auth state listener
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAuthState();
  }

  @override
  void dispose() {
    // Clean up the listener
    _authSubscription?.cancel();
    super.dispose();
  }

  void _initializeAuthState() {
    // Set up auth state listener for real-time changes
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        // User signed out or session expired
        print('User session ended or expired');
        if (_appState != AppState.login && _appState != AppState.splash) {
          _navigateToLogin();
        }
      } else {
        // User signed in or session restored
        print('User session active: ${user.uid}');
        if (_appState == AppState.login || _appState == AppState.splash) {
          // If we're on login/splash and user logs in elsewhere, fetch role
          _fetchUserRole(user.uid);
        }
      }
    });

    // Initial check
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      // Start with splash screen for 1.5 seconds
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Check if user is already logged in from local storage
      final user = _auth.currentUser;
      
      if (user != null && user.uid.isNotEmpty) {
        print('✅ Session found in local storage for user: ${user.uid}');
        // User has active session, fetch their role and navigate to appropriate page
        await _fetchUserRole(user.uid);
      } else {
        print('❌ No active session found in local storage');
        // No session found, navigate directly to login
        _navigateToLogin();
      }
    } catch (e) {
      print('Error checking auth state: $e');
      _navigateToLogin();
    }
  }

  Future<void> _fetchUserRole(String userId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final role = data['role']?.toString().toLowerCase() ?? 'driver';
        final fullName = data['fullName']?.toString() ?? 'User';
        
        setState(() {
          _isLoading = false;
          _userName = fullName;
          _userRole = role;
          _userId = userId;
          
          // Navigate based on role
          if (role == 'driver') {
            _appState = AppState.landing;
            print('🚗 Navigating to Landing (Driver)');
          } else if (role == 'station') {
            _appState = AppState.stationHomePage;
            print('⛽ Navigating to Station Home Page');
          } else {
            // Unknown role, sign out and go to login
            print('⚠️ Unknown role: $role, signing out');
            _performLogout();
          }
        });
      } else {
        // User document doesn't exist in Firestore
        print('❌ User document not found in Firestore');
        await _performLogout();
      }
    } catch (e) {
      print('Error fetching user role: $e');
      await _performLogout();
    }
  }

  void _navigateToLogin() {
    setState(() {
      _isLoading = false;
      _appState = AppState.login;
      print('🔐 Navigating to Login');
    });
  }

  void _handleSplashComplete() {
    // After splash, check if we have a session
    if (_auth.currentUser != null) {
      // If user exists, we should already be in a different state
      // This is just a fallback
      _checkAuthState();
    } else {
      _navigateToLogin();
    }
  }

  void _handleLoginSuccess() {
    // After successful login, check auth state again
    setState(() {
      _isLoading = true;
    });
    _checkAuthState();
  }

  void _handleLogout() async {
    await _performLogout();
  }

  Future<void> _performLogout() async {
    try {
      // Clear all local data and session
      await _auth.signOut();
      
      // Clear local state
      setState(() {
        _userName = '';
        _userRole = '';
        _userId = '';
        _isLoading = false;
        _appState = AppState.login;
      });
      
      print('✅ Logout successful, session cleared');
    } catch (e) {
      print('❌ Error during logout: $e');
      // Still navigate to login even if logout fails
      _navigateToLogin();
    }
  }


  void _handleGoToLanding() {
    if (_auth.currentUser != null && _userRole == 'driver') {
      setState(() {
        _appState = AppState.landing;
      });
    } else {
      _navigateToLogin();
    }
  }

  void _handleRegisterVehicle() {
    setState(() {
      _appState = AppState.vehicleRegistration;
    });
  }

  void _handleRegisterStation() {
    setState(() {
      _appState = AppState.stationRegistration;
    });
  }

  void _handleLandingTabChange(int index) {
    setState(() {
      _landingTabIndex = index;
    });
  }

  void _handleLandingNavigation(String route) {
    switch (route) {
      case 'register_vehicle':
        _handleRegisterVehicle();
        break;
      case 'map':
        _handleLandingTabChange(1);
        break;
    }
  }

  Widget _buildCurrentScreen() {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0a0c10),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF256af4)),
              const SizedBox(height: 20),
              Text(
                _auth.currentUser != null 
                  ? 'Restoring your session...' 
                  : 'Checking Authentication...',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              if (_auth.currentUser != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Welcome back!',
                  style: GoogleFonts.spaceGrotesk(
                    color: const Color(0xFF256af4),
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    switch (_appState) {
      case AppState.splash:
        return SplashScreen(
          autoNavigate: true,
          autoNavigateDuration: const Duration(seconds: 2),
          onGetStarted: _handleSplashComplete,
        );

      case AppState.landing:
        return LandingScreen(
          onLogin: () {
            // This shouldn't happen if user is logged in, but handle gracefully
            if (_auth.currentUser == null) {
              _navigateToLogin();
            } else {
              setState(() {
                _appState = AppState.login;
              });
            }
          },
          onLogout: _handleLogout,
          onRegisterVehicle: _handleRegisterVehicle,
          currentTabIndex: _landingTabIndex,
          onTabChanged: _handleLandingTabChange,
          onNavigate: _handleLandingNavigation,
          onRegisterAsDriver: _handleRegisterVehicle,
          onRegisterAsStationOwner: _handleRegisterStation,
          onRegisterStation: _handleRegisterStation,
          userName: _userName, // Pass user name to landing screen
          userRole: _userRole, // Pass user role to landing screen
        );

      case AppState.login:
        return LoginScreen(
          onLoginSuccess: _handleLoginSuccess,
          onBackPressed: () {
            // If user came from somewhere and wants to go back
            if (_auth.currentUser != null) {
              _checkAuthState();
            } else {
              _navigateToLogin();
            }
          },
          onRegisterAsDriver: _handleRegisterVehicle,
          onRegisterAsStationOwner: _handleRegisterStation,
        );

      case AppState.vehicleRegistration:
        return VehicleRegistrationScreen(
          onBackPressed: _handleGoToLanding,
          onCreateAccount: _handleLoginSuccess,
        );

      case AppState.stationRegistration:
        return StationRegistrationScreen(
          onBackPressed: _handleGoToLanding,
          onRegistrationComplete: _handleLoginSuccess,
        );

      case AppState.carOwnerHome:
        return CarOwnerHome(
          userName: _userName,
          onLogout: _handleLogout,
        );

      case AppState.stationOwnerDashboard:
        return StationOwnerDashboard(
          userName: _userName,
          onLogout: _handleLogout,
        );

      case AppState.stationHomePage:
        return HomePage(
          userName: _userName,
          onLogout: _handleLogout,
        );

      }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _buildCurrentScreen(),
    );
  }
}

enum AppState {
  splash,
  landing,
  login,
  carOwnerHome,
  stationOwnerDashboard,
  stationHomePage,
  vehicleRegistration,
  stationRegistration,
}