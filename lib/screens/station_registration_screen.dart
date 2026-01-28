import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class StationRegistrationScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onRegistrationComplete;
  final int currentStep;
  final int totalSteps;

  const StationRegistrationScreen({
    super.key,
    this.onBackPressed,
    this.onRegistrationComplete,
    this.currentStep = 1,
    this.totalSteps = 3,
  });

  @override
  State<StationRegistrationScreen> createState() =>
      _StationRegistrationScreenState();
}

class _StationRegistrationScreenState extends State<StationRegistrationScreen> {
  // Station Owner Details Controllers (for new user)
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerEmailController = TextEditingController();
  final TextEditingController _ownerPhoneController = TextEditingController();
  final TextEditingController _ownerPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // Station Details Controllers
  final TextEditingController _stationNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _pumpsController = TextEditingController(text: '4');
  
  // State Variables
  File? _certificationFile;
  bool _isUnionPartner = true;
  int _pumpCount = 4;
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  
  // Location variables
  double? _latitude;
  double? _longitude;
  String _address = '';
  Position? _currentPosition;

  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _pumpsController.addListener(() {
      if (_pumpsController.text.isNotEmpty) {
        setState(() {
          _pumpCount = int.tryParse(_pumpsController.text) ?? 0;
        });
      }
    });
    // Request location permission
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _ownerEmailController.dispose();
    _ownerPhoneController.dispose();
    _ownerPasswordController.dispose();
    _confirmPasswordController.dispose();
    _stationNameController.dispose();
    _locationController.dispose();
    _pumpsController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLoading = true);
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('Please enable location services');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      // Get address from coordinates
      await _getAddressFromLatLng(position.latitude, position.longitude);
      
    } catch (e) {
      _showError('Error getting location: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = '${place.street}, ${place.locality}, ${place.country}';
        
        setState(() {
          _address = address;
          if (_locationController.text.isEmpty) {
            _locationController.text = address;
          }
        });
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  Future<void> _pickCertificationFile() async {
    final result = await showDialog<File?>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1b1f27),
        title: const Text('Upload Certification', style: TextStyle(color: Colors.white)),
        content: const Text('Select file type', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final pickedFile = await _picker.pickImage(
                source: ImageSource.gallery,
              );
              if (pickedFile != null) {
                if (!mounted) return;
                Navigator.pop(context, File(pickedFile.path));
              }
            },
            child: const Text('Gallery', style: TextStyle(color: Color(0xFF256af4))),
          ),
          TextButton(
            onPressed: () async {
              final pickedFile = await _picker.pickImage(
                source: ImageSource.camera,
              );
              if (pickedFile != null) {
                if (!mounted) return;
                Navigator.pop(context, File(pickedFile.path));
              }
            },
            child: const Text('Camera', style: TextStyle(color: Color(0xFF256af4))),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _certificationFile = result;
      });
    }
  }

  void _incrementPumps() {
    setState(() {
      _pumpCount++;
      _pumpsController.text = _pumpCount.toString();
    });
  }

  void _decrementPumps() {
    if (_pumpCount > 0) {
      setState(() {
        _pumpCount--;
        _pumpsController.text = _pumpCount.toString();
      });
    }
  }

  Future<String?> _uploadCertificationFile() async {
    if (_certificationFile == null) return null;
    
    try {
      String fileName = 'certifications/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child(fileName);
      
      UploadTask uploadTask = storageRef.putFile(_certificationFile!);
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<void> _registerStationAndOwner() async {
    if (!_validateForm()) return;
    
    setState(() => _isLoading = true);

    try {
      // 1. CREATE NEW USER ACCOUNT
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _ownerEmailController.text.trim(),
        password: _ownerPasswordController.text.trim(),
      );
      
      User user = userCredential.user!;
      
      // 2. UPDATE USER DISPLAY NAME
      await user.updateDisplayName(_ownerNameController.text.trim());
      
      // 3. UPLOAD CERTIFICATION FILE
      String? certificationUrl = await _uploadCertificationFile();

      // 4. PREPARE USER DATA (for 'users' collection)
      Map<String, dynamic> userData = {
        'userId': user.uid,
        'fullName': _ownerNameController.text.trim(),
        'email': _ownerEmailController.text.trim(),
        'phone': _ownerPhoneController.text.trim(),
        'role': 'station', // Default role for station owner
        'userType': 'station_owner',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'emailVerified': false,
      };

      // 5. PREPARE STATION DATA (for 'drivers' collection - or create 'stations' collection)
      Map<String, dynamic> stationData = {
        'stationId': user.uid, // Using same ID as user for easy reference
        'ownerId': user.uid,
        'ownerName': _ownerNameController.text.trim(),
        'ownerEmail': _ownerEmailController.text.trim(),
        'ownerPhone': _ownerPhoneController.text.trim(),
        'stationName': _stationNameController.text.trim(),
        'location': _locationController.text.trim(),
        'address': _address,
        'latitude': _latitude,
        'longitude': _longitude,
        'pumpCount': _pumpCount,
        'isUnionPartner': _isUnionPartner,
        'role': 'station', // Default role
        'status': 'pending', // Default status - needs admin approval
        'certificationUrl': certificationUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      // 6. BATCH WRITE TO FIRESTORE (Atomic Operation)
      WriteBatch batch = _firestore.batch();
      
      // Save user data to 'users' collection
      DocumentReference userDoc = _firestore.collection('users').doc(user.uid);
      batch.set(userDoc, userData);
      
      // Save station data to 'drivers' collection (or create 'stations' collection)
      DocumentReference stationDoc = _firestore.collection('drivers').doc(user.uid);
      batch.set(stationDoc, stationData);
      
      // Execute batch
      await batch.commit();

      // 7. SEND EMAIL VERIFICATION (Optional)
      // await user.sendEmailVerification();

      // 8. SHOW SUCCESS MESSAGE
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Station registered successfully! Account created.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // 9. AUTO-LOGIN THE USER AND NAVIGATE
      widget.onRegistrationComplete?.call();

    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth errors
      if (e.code == 'weak-password') {
        _showError('Password is too weak. Please use a stronger password.');
      } else if (e.code == 'email-already-in-use') {
        _showError('An account already exists with this email.');
      } else if (e.code == 'invalid-email') {
        _showError('Invalid email address.');
      } else {
        _showError('Registration failed: ${e.message}');
      }
    } catch (e) {
      _showError('Registration failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _validateForm() {
    // Station Owner Validation
    if (_ownerNameController.text.isEmpty) {
      _showError('Please enter your full name');
      return false;
    }
    if (_ownerEmailController.text.isEmpty) {
      _showError('Please enter your email address');
      return false;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_ownerEmailController.text)) {
      _showError('Please enter a valid email address');
      return false;
    }
    if (_ownerPhoneController.text.isEmpty) {
      _showError('Please enter your phone number');
      return false;
    }
    if (_ownerPasswordController.text.isEmpty) {
      _showError('Please enter a password');
      return false;
    }
    if (_ownerPasswordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return false;
    }
    if (_confirmPasswordController.text.isEmpty) {
      _showError('Please confirm your password');
      return false;
    }
    if (_ownerPasswordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return false;
    }

    // Station Validation
    if (_stationNameController.text.isEmpty) {
      _showError('Please enter station name');
      return false;
    }
    if (_locationController.text.isEmpty) {
      _showError('Please enter station location');
      return false;
    }
    if (_pumpCount <= 0) {
      _showError('Please enter number of pumps');
      return false;
    }
    if (_certificationFile == null) {
      _showError('Please upload business certification');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressPercentage = (widget.currentStep / widget.totalSteps) * 100;

    return Scaffold(
      backgroundColor: const Color(0xFF101622),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(),
            
            // Progress Bar
            _buildProgressBar(progressPercentage),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Headline
                    _buildHeadline(),
                    
                    // Station Owner Details Section
                    _buildOwnerFormSection(),
                    
                    // Station Details Section
                    _buildStationFormSection(),
                    
                    // Location Status
                    _buildLocationStatus(),
                    
                    // Union Partner Checkbox
                    _buildUnionPartnerSection(),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            
            // Bottom Action Button
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101622).withOpacity(0.8),
        border: Border(
          bottom: BorderSide(color: Colors.grey[800]!.withOpacity(0.2)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Back Button
            GestureDetector(
              onTap: widget.onBackPressed ?? () => Navigator.pop(context),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFF256af4),
                  size: 20,
                ),
              ),
            ),
            
            // Title
            Expanded(
              child: Text(
                'Register Your Station',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Spacer for alignment
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double percentage) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${widget.currentStep} of ${widget.totalSteps}',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '${percentage.round()}%',
                style: GoogleFonts.inter(
                  color: const Color(0xFF256af4),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: const Color(0xFF256af4).withOpacity(0.6),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(1),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF256af4),
                  borderRadius: BorderRadius.circular(1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF256af4).withOpacity(0.4),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadline() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Station Owner Registration',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your account and register your station to join our network',
            style: GoogleFonts.inter(
              color: const Color(0xFF94a3b8),
              fontSize: 14,
              fontWeight: FontWeight.normal,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerFormSection() {
    return Column(
      children: [
        // Section Title
        _buildSectionTitle('Station Owner Details'),
        
        // Full Name Field
        _buildTextField(
          label: 'Full Name',
          controller: _ownerNameController,
          hintText: 'Enter your full name',
          icon: Icons.person,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        ),
        
        // Email Field
        _buildTextField(
          label: 'Email Address',
          controller: _ownerEmailController,
          hintText: 'your.email@example.com',
          keyboardType: TextInputType.emailAddress,
          icon: Icons.email,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        ),
        
        // Phone Field
        _buildTextField(
          label: 'Phone Number',
          controller: _ownerPhoneController,
          hintText: '+1 234 567 8900',
          keyboardType: TextInputType.phone,
          icon: Icons.phone,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        ),
        
        // Password Field
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Password',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFe2e8f0),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextField(
                controller: _ownerPasswordController,
                obscureText: !_passwordVisible,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
                decoration: InputDecoration(
                  hintText: 'Create a secure password',
                  hintStyle: GoogleFonts.inter(
                    color: const Color(0xFF94a3b8),
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1b1f27).withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF3b4354),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF3b4354),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF256af4),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF64748b),
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Confirm Password Field
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Confirm Password',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFe2e8f0),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_confirmPasswordVisible,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
                decoration: InputDecoration(
                  hintText: 'Confirm your password',
                  hintStyle: GoogleFonts.inter(
                    color: const Color(0xFF94a3b8),
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1b1f27).withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF3b4354),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF3b4354),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF256af4),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF64748b),
                    ),
                    onPressed: () {
                      setState(() {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStationFormSection() {
    return Column(
      children: [
        // Section Title
        _buildSectionTitle('Station Details'),
        
        // Station Name Field
        _buildTextField(
          label: 'Station Name',
          controller: _stationNameController,
          hintText: 'e.g. Neon Fuel Hub',
          icon: Icons.local_gas_station,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        ),
        
        // Location Field
        _buildLocationField(),
        
        // Number of Pumps Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
              child: Text(
                'Number of Pumps',
                style: GoogleFonts.inter(
                  color: const Color(0xFF256af4),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey[800]!,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _pumpsController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: GoogleFonts.inter(
                            color: const Color(0xFF64748b),
                            fontSize: 16,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1b1f27).withOpacity(0.5),
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF256af4),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.grey[800]!,
                              width: 1,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Decrement Button
                  Container(
                    width: 48,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey[900]!,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[800]!,
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: _decrementPumps,
                      icon: const Icon(Icons.remove, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Increment Button
                  Container(
                    width: 48,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey[900]!,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[800]!,
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: _incrementPumps,
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        // Certification Upload
        _buildCertificationUpload(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: const Color(0xFF256af4),
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: const Color(0xFFe2e8f0),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey[800]!,
                width: 1,
              ),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.inter(
                  color: const Color(0xFF94a3b8),
                  fontSize: 16,
                ),
                filled: true,
                fillColor: const Color(0xFF1b1f27).withOpacity(0.5),
                border: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF256af4),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.grey[800]!,
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                suffixIcon: Icon(
                  icon,
                  color: const Color(0xFF64748b),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Station Location/Address',
              style: GoogleFonts.inter(
                color: const Color(0xFFe2e8f0),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // Address Field
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey[800]!,
                width: 1,
              ),
            ),
            child: TextField(
              controller: _locationController,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              decoration: InputDecoration(
                hintText: 'Enter station address',
                hintStyle: GoogleFonts.inter(
                  color: const Color(0xFF64748b),
                  fontSize: 16,
                ),
                filled: true,
                fillColor: const Color(0xFF1b1f27).withOpacity(0.5),
                border: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF256af4),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.grey[800]!,
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.location_searching, color: Color(0xFF256af4)),
                  onPressed: _getCurrentLocation,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Map Preview
          GestureDetector(
            onTap: _getCurrentLocation,
            child: Container(
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey[800]!,
                  width: 1,
                ),
                image: DecorationImage(
                  image: const NetworkImage(
                    'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?q=80&w=2070&auto=format&fit=crop',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF256af4).withOpacity(0.1),
                          const Color(0xFF256af4).withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                  
                  // GPS Button
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101622).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFF256af4).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _currentPosition != null ? Icons.check : Icons.gps_fixed,
                            color: const Color(0xFF256af4),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _currentPosition != null 
                                ? 'Location Set ✓' 
                                : 'Tap to set GPS',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF256af4),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _currentPosition != null 
              ? Colors.green.withOpacity(0.1)
              : Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _currentPosition != null 
                ? Colors.green.withOpacity(0.3)
                : Colors.orange.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              _currentPosition != null ? Icons.location_on : Icons.location_disabled,
              color: _currentPosition != null ? Colors.green : Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentPosition != null 
                        ? 'Location Detected ✓'
                        : 'Location Optional',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentPosition != null 
                        ? 'GPS: ${_latitude?.toStringAsFixed(6)}, ${_longitude?.toStringAsFixed(6)}'
                        : 'Tap to enable location services',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94a3b8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (_currentPosition == null)
              GestureDetector(
                onTap: _getCurrentLocation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF256af4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Enable',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificationUpload() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Business Certification (Required)',
              style: GoogleFonts.inter(
                color: const Color(0xFFe2e8f0),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _certificationFile == null ? Colors.red.withOpacity(0.3) : Colors.grey[800]!,
                width: 2,
                style: BorderStyle.solid,
              ),
              color: const Color(0xFF1b1f27).withOpacity(0.3),
            ),
            child: Column(
              children: [
                Icon(
                  _certificationFile != null ? Icons.check_circle : Icons.cloud_upload,
                  color: _certificationFile != null ? Colors.green : const Color(0xFF64748b),
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  _certificationFile?.path.split('/').last ??
                      'Upload PDF or JPEG (Max 5MB)',
                  style: GoogleFonts.inter(
                    color: _certificationFile != null
                        ? Colors.green
                        : const Color(0xFF64748b),
                    fontSize: 12,
                    fontWeight: _certificationFile != null
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickCertificationFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFF256af4),
                    side: BorderSide(
                      color: const Color(0xFF256af4),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    shadowColor: const Color(0xFF256af4).withOpacity(0.4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.upload_file, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _certificationFile != null
                            ? 'Change File'
                            : 'Upload File',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF256af4),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnionPartnerSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF256af4).withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF256af4).withOpacity(0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            GestureDetector(
              onTap: () {
                setState(() {
                  _isUnionPartner = !_isUnionPartner;
                });
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFF256af4).withOpacity(0.5),
                    width: 2,
                  ),
                  color: _isUnionPartner
                      ? const Color(0xFF256af4)
                      : Colors.transparent,
                ),
                child: _isUnionPartner
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isUnionPartner = !_isUnionPartner;
                          });
                        },
                        child: Text(
                          'Join as Union Partner',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF256af4),
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get featured in the Priority Network. Unlock loyalty rewards, increased visibility, and automated tax reporting tools.',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94a3b8),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      // TODO: Show benefits dialog
                    },
                    child: Row(
                      children: [
                        Text(
                          'Learn about benefits',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF256af4),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward,
                          color: Color(0xFF256af4),
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101622),
        border: Border(
          top: BorderSide(
            color: Colors.grey[800]!.withOpacity(0.5),
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: _isLoading
            ? Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF256af4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: _registerStationAndOwner,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF256af4),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0xFF256af4).withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ).copyWith(
                  overlayColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.pressed)) {
                        return Colors.white.withOpacity(0.2);
                      }
                      return null;
                    },
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Create Account & Register Station',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}