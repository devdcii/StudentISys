import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'variables.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('student_cache');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Information',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Color(0xFF1E40AF),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF334155)),
          bodyMedium: TextStyle(color: Color(0xFF64748B)),
          titleLarge: TextStyle(color: Color(0xFF1E40AF)),
        ),
      ),
      home: const AuthenticationScreen(),
    );
  }
}

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _ipController = TextEditingController();
  bool networkStatus = false;
  bool isLoading = false;
  String error = "";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showAboutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.info_circle,
                color: Color(0xFF3B82F6),
                size: 20,
              ),
              SizedBox(width: 6),
              Text(
                'About',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E40AF),
                ),
              ),
            ],
          ),
          content: const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'StudentISys',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF334155),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Developers:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Canlas, Adrian S.\nDigman, Christian D.\nParagas, John Ian Joseph M.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String cleanIPAddress(String input) {
    String cleaned = input.trim();
    cleaned = cleaned.replaceAll(RegExp(r'^https?://'), '');
    if (cleaned.contains('/')) {
      cleaned = cleaned.split('/')[0];
    }
    return cleaned;
  }

  Future<void> authenticate() async {
    setState(() {
      isLoading = true;
      error = "";
    });

    try {
      String cleanedIP = cleanIPAddress(_ipController.text);

      if (cleanedIP.isEmpty) {
        setState(() {
          error = "Please enter a valid IP address";
          networkStatus = false;
          isLoading = false;
        });
        return;
      }

      server = "http://$cleanedIP/sqlacc";
      final response = await http.get(
        Uri.parse("$server/authenticate.php"),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.body.trim() == "Server Connected!") {
        setState(() {
          error = "";
          networkStatus = true;
          isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const StudentDashboard(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        );
      } else {
        setState(() {
          error = "Invalid IP Address";
          networkStatus = false;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Connection failed. Check IP address.";
        networkStatus = false;
        isLoading = false;
      });
    }
  }

  Widget _buildGearBackground() {
    return Stack(
      children: [
        Positioned(
          top: 40,
          left: -20,
          child: Transform.rotate(
            angle: 0.3,
            child: Icon(
              CupertinoIcons.gear_alt,
              size: 80,
              color: const Color(0xFF3B82F6).withOpacity(0.12),
            ),
          ),
        ),
        Positioned(
          top: 60,
          right: -30,
          child: Transform.rotate(
            angle: -0.2,
            child: Icon(
              CupertinoIcons.gear,
              size: 120,
              color: const Color(0xFF3B82F6).withOpacity(0.10),
            ),
          ),
        ),
        Positioned(
          top: 200,
          left: -40,
          child: Transform.rotate(
            angle: 0.5,
            child: Icon(
              CupertinoIcons.gear_alt_fill,
              size: 100,
              color: const Color(0xFF3B82F6).withOpacity(0.08),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: -10,
          child: Transform.rotate(
            angle: -0.4,
            child: Icon(
              CupertinoIcons.gear,
              size: 90,
              color: const Color(0xFF3B82F6).withOpacity(0.12),
            ),
          ),
        ),
        Positioned(
          top: 150,
          right: 80,
          child: Transform.rotate(
            angle: 0.1,
            child: Icon(
              CupertinoIcons.gear_alt,
              size: 150,
              color: const Color(0xFF3B82F6).withOpacity(0.06),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Stack(
          children: [
            _buildGearBackground(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B82F6).withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              CupertinoIcons.info_circle,
                              color: Color(0xFF3B82F6),
                              size: 20,
                            ),
                            onPressed: _showAboutDialog,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Hero(
                            tag: "logo",
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3B82F6).withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                CupertinoIcons.device_laptop,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'StudentISys',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E40AF),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Connect to server',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3B82F6).withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _ipController,
                              style: const TextStyle(
                                color: Color(0xFF334155),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter server IP address',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.wifi,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                              ),
                              keyboardType: TextInputType.url,
                            ),
                          ),
                          if (error.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFECACA),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.exclamationmark_circle,
                                    color: Color(0xFFEF4444),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      error,
                                      style: const TextStyle(
                                        color: Color(0xFFEF4444),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : authenticate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                disabledBackgroundColor: const Color(0xFF94A3B8),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                                  : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.wifi_tethering_rounded,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Connect to Server',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.1,
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
            ),
          ],
        ),
      ),
    );
  }
}

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> students = [];
  List<dynamic> filteredStudents = [];
  bool isLoading = false;
  final Box _cacheBox = Hive.box('student_cache');
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    fetchStudents();
    _searchController.addListener(_filterStudents);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showBackConfirmationDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text(
            'Go Back',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E40AF),
            ),
          ),
          content: const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Are you sure you want to go back to the connection screen?',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuthenticationScreen(),
                  ),
                );
              },
              isDestructiveAction: true,
              child: const Text(
                'Go Back',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchStudents([String? searchQuery]) async {
    setState(() => isLoading = true);

    try {
      String url = "$server/index.php";
      if (searchQuery != null && searchQuery.isNotEmpty) {
        url += "?search=${Uri.encodeComponent(searchQuery)}";
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          students = data;
          filteredStudents = data;
        });
        _cacheBox.put('students', data);
      }
    } catch (e) {
      final cachedData = _cacheBox.get('students', defaultValue: []);
      setState(() {
        students = cachedData;
        filteredStudents = cachedData;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredStudents = students.where((student) {
        return student['name'].toString().toLowerCase().contains(query) ||
            student['student_id'].toString().toLowerCase().contains(query) ||
            student['course'].toString().toLowerCase().contains(query) ||
            (student['email']?.toString().toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  Future<void> _deleteStudent(dynamic student) async {
    try {
      final response = await http.post(
        Uri.parse("$server/delete_student.php"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'id': student['id'],
        }),
      );

      if (response.statusCode == 200) {
        if (response.body.contains('Fatal error') ||
            response.body.contains('<br />')) {
          if (mounted) {
            _showErrorDialog(context, 'Server Error',
                'There was a server-side error. Please check the PHP configuration and try again.');
          }
          return;
        }

        try {
          final responseData = json.decode(response.body);
          if (mounted) {
            if (responseData['status'] == 'success') {
              await fetchStudents();
              if (mounted) {
                _showSuccessDialog(context, 'Deleted', responseData['message'] ?? 'Student deleted successfully!');
              }
            } else {
              if (mounted) {
                _showErrorDialog(context, 'Error',
                    responseData['message'] ?? 'Failed to delete student.');
              }
            }
          }
        } catch (e) {
          if (mounted) {
            _showErrorDialog(context, 'Error',
                'Invalid response from server. Please check server configuration.');
          }
        }
      } else {
        if (mounted) {
          _showErrorDialog(context, 'Network Error',
              'Server responded with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(context, 'Connection Error',
            'Failed to connect to server: $e');
      }
    }
  }

  void _showDeleteConfirmation(dynamic student) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  CupertinoIcons.delete,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Delete Student',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E40AF),
                ),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure you want to delete "${student['name']}"?',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'ID: ${student['student_id']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8)
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteStudent(student);
              },
              isDestructiveAction: true,
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: Colors.white,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    CupertinoIcons.checkmark_alt_circle_fill,
                    color: Color(0xFF10B981),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: Colors.white,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    CupertinoIcons.exclamationmark_circle,
                    color: Color(0xFFEF4444),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddStudentDialog() {
    final nameController = TextEditingController();
    final studentIdController = TextEditingController();
    final courseController = TextEditingController();
    final yearLevelController = TextEditingController();
    final gpaController = TextEditingController();
    final emailController = TextEditingController();
    bool isAdding = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 250,
                  maxHeight: MediaQuery.of(context).size.height * 0.67,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Add New Student',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E40AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildTextField(nameController, 'Full Name', Icons.person_rounded),
                            const SizedBox(height: 14),
                            _buildTextField(studentIdController, 'Student ID', Icons.badge_rounded),
                            const SizedBox(height: 14),
                            _buildTextField(emailController, 'Email Address', Icons.email_rounded,
                                keyboardType: TextInputType.emailAddress),
                            const SizedBox(height: 14),
                            _buildTextField(courseController, 'Course', Icons.school_rounded),
                            const SizedBox(height: 14),
                            _buildTextField(yearLevelController, 'Year Level', Icons.star_rounded,
                                keyboardType: TextInputType.number),
                            const SizedBox(height: 14),
                            _buildTextField(gpaController, 'GPA (Optional)', Icons.star_rounded,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF64748B),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isAdding ? null : () async {
                                if (nameController.text.trim().isEmpty ||
                                    studentIdController.text.trim().isEmpty ||
                                    emailController.text.trim().isEmpty ||
                                    courseController.text.trim().isEmpty ||
                                    yearLevelController.text.trim().isEmpty) {
                                  _showErrorDialog(context, 'Validation Error',
                                      'Please fill in all required fields.');
                                  return;
                                }

                                setState(() => isAdding = true);

                                try {
                                  String? gpaValue = gpaController.text.trim().isEmpty
                                      ? null
                                      : gpaController.text.trim();

                                  final response = await http.post(
                                    Uri.parse("$server/add_student.php"),
                                    headers: {
                                      'Content-Type': 'application/json',
                                      'Accept': 'application/json',
                                    },
                                    body: json.encode({
                                      'name': nameController.text.trim(),
                                      'student_id': studentIdController.text.trim(),
                                      'email': emailController.text.trim(),
                                      'course': courseController.text.trim(),
                                      'year_level': yearLevelController.text.trim(),
                                      'gpa': gpaValue,
                                    }),
                                  );

                                  setState(() => isAdding = false);

                                  if (response.statusCode == 200) {
                                    if (response.body.contains('Fatal error') ||
                                        response.body.contains('<br />')) {
                                      if (mounted) {
                                        Navigator.of(context).pop();
                                        _showErrorDialog(this.context, 'Server Error',
                                            'There was a server-side error. Please check the PHP configuration and try again.');
                                      }
                                      return;
                                    }

                                    try {
                                      final responseData = json.decode(response.body);
                                      if (mounted) {
                                        Navigator.of(context).pop();

                                        if (responseData['status'] == 'success') {
                                          await fetchStudents();
                                          if (mounted) {
                                            _showSuccessDialog(this.context, 'Success', responseData['message'] ?? 'Student added successfully!');
                                          }
                                        } else {
                                          if (mounted) {
                                            _showErrorDialog(this.context, 'Error',
                                                responseData['message'] ?? 'Failed to add student.');
                                          }
                                        }
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        Navigator.of(context).pop();
                                        _showErrorDialog(this.context, 'Error',
                                            'Invalid response from server. Please check server configuration.');
                                      }
                                    }
                                  } else {
                                    if (mounted) {
                                      Navigator.of(context).pop();
                                      _showErrorDialog(this.context, 'Network Error',
                                          'Server responded with status: ${response.statusCode}');
                                    }
                                  }
                                } catch (e) {
                                  setState(() => isAdding = false);
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                    _showErrorDialog(this.context, 'Connection Error',
                                        'Failed to connect to server: $e');
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: const Color(0xFF94A3B8),
                              ),
                              child: isAdding
                                  ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                'Add Student',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditStudentDialog(dynamic student) {
    final nameController = TextEditingController(text: student['name']);
    final studentIdController = TextEditingController(text: student['student_id']);
    final courseController = TextEditingController(text: student['course']);
    final yearLevelController = TextEditingController(text: student['year_level'].toString());
    final gpaController = TextEditingController(text: student['gpa']?.toString() ?? '');
    final emailController = TextEditingController(text: student['email'] ?? '');
    bool isEditing = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 250,
                  maxHeight: MediaQuery.of(context).size.height * 0.67,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Student Profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E40AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildTextField(nameController, 'Full Name', Icons.person_rounded),
                            const SizedBox(height: 14),
                            _buildTextField(studentIdController, 'Student ID', Icons.badge_rounded),
                            const SizedBox(height: 14),
                            _buildTextField(emailController, 'Email Address', Icons.email_rounded,
                                keyboardType: TextInputType.emailAddress),
                            const SizedBox(height: 14),
                            _buildTextField(courseController, 'Course', Icons.school_rounded),
                            const SizedBox(height: 14),
                            _buildTextField(yearLevelController, 'Year Level', Icons.star_rounded,
                                keyboardType: TextInputType.number),
                            const SizedBox(height: 14),
                            _buildTextField(gpaController, 'GPA (Optional)', Icons.star_rounded,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF64748B),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isEditing ? null : () async {
                                setState(() => isEditing = true);

                                try {
                                  Map<String, dynamic> updateData = {
                                    'id': student['id'],
                                  };

                                  if (nameController.text.trim().isNotEmpty) {
                                    updateData['name'] = nameController.text.trim();
                                  }
                                  if (studentIdController.text.trim().isNotEmpty) {
                                    updateData['student_id'] = studentIdController.text.trim();
                                  }
                                  if (emailController.text.trim().isNotEmpty) {
                                    updateData['email'] = emailController.text.trim();
                                  }
                                  if (courseController.text.trim().isNotEmpty) {
                                    updateData['course'] = courseController.text.trim();
                                  }
                                  if (yearLevelController.text.trim().isNotEmpty) {
                                    updateData['year_level'] = yearLevelController.text.trim();
                                  }
                                  updateData['gpa'] = gpaController.text.trim();

                                  final response = await http.post(
                                    Uri.parse("$server/edit_student.php"),
                                    headers: {
                                      'Content-Type': 'application/json',
                                      'Accept': 'application/json',
                                    },
                                    body: json.encode(updateData),
                                  );

                                  setState(() => isEditing = false);

                                  if (response.statusCode == 200) {
                                    try {
                                      final responseData = json.decode(response.body);
                                      if (mounted) {
                                        Navigator.of(context).pop();

                                        if (responseData['status'] == 'success') {
                                          await fetchStudents();
                                          if (mounted) {
                                            _showSuccessDialog(this.context, 'Success', responseData['message'] ?? 'Student updated successfully!');
                                          }
                                        } else {
                                          if (mounted) {
                                            _showErrorDialog(this.context, 'Error',
                                                responseData['message'] ?? 'Failed to update student.');
                                          }
                                        }
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        Navigator.of(context).pop();
                                        _showErrorDialog(this.context, 'Error',
                                            'Invalid response from server.');
                                      }
                                    }
                                  }
                                } catch (e) {
                                  setState(() => isEditing = false);
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                    _showErrorDialog(this.context, 'Connection Error',
                                        'Failed to connect to server: $e');
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: const Color(0xFF94A3B8),
                              ),
                              child: isEditing
                                  ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                'Update Student',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon,
      {TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Color(0xFF334155),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.white, size: 14),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  void _showStudentDetails(dynamic student) {
    _showEditStudentDialog(student);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showBackConfirmationDialog();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          CupertinoIcons.back,
                          color: Color(0xFF3B82F6),
                          size: 20,
                        ),
                        onPressed: _showBackConfirmationDialog,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'StudentISys',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E40AF),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.person_add_alt_1_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _showAddStudentDialog,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search students...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              CupertinoIcons.search,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${filteredStudents.length} students',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF8FAFC),
                  child: isLoading
                      ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF3B82F6),
                      strokeWidth: 2.5,
                    ),
                  )
                      : filteredStudents.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Icon(
                            CupertinoIcons.search,
                            size: 48,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No students found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: Key(student['id'].toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEF4444).withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.delete,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            _showDeleteConfirmation(student);
                            return false;
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3B82F6).withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _showStudentDetails(student),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3B82F6),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Center(
                                          child: Text(
                                            student['name'][0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              student['name'],
                                              style: const TextStyle(
                                                color: Color(0xFF1E40AF),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'ID: ${student['student_id']}',
                                              style: const TextStyle(
                                                color: Color(0xFF64748B),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (student['email'] != null)
                                              Text(
                                                student['email'],
                                                style: const TextStyle(
                                                  color: Color(0xFF64748B),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    student['course'],
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Color(0xFF3B82F6),
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                                  ),
                                                  child: Text(
                                                    'Year ${student['year_level']}',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Color(0xFF3B82F6),
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                if (student['gpa'] != null && student['gpa'].toString().isNotEmpty) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      'GPA: ${student['gpa']}',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Color(0xFF3B82F6),
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          CupertinoIcons.chevron_right,
                                          size: 14,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}