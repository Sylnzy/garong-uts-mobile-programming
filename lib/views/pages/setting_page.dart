import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/views/widgets/custom_drawer.dart';
import '/views/widgets/custom_navbar.dart';
import '/views/widgets/feature_guide.dart';
import '/core/services/onboarding_service.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  double _textSize = 1.0; // 1.0 is the default text size multiplier

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _locationEnabled = prefs.getBool('location') ?? true;
      _textSize = prefs.getDouble('textSize') ?? 1.0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setBool('notifications', _notificationsEnabled);
    await prefs.setBool('location', _locationEnabled);
    await prefs.setDouble('textSize', _textSize);
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _isDarkMode ? const Color(0xFF0D1B2A) : Colors.white,
      appBar: AppBar(
        backgroundColor: _isDarkMode ? const Color(0xFF0D1B2A) : Colors.white,
        elevation: 0,
        title: Text(
          "Pengaturan",
          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.settings,
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: CustomDrawer(currentRoute: '/setting', onLogout: _logout),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Personalisasi",
                  style: TextStyle(
                    fontSize: 18 * _textSize,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: _isDarkMode ? const Color(0xFF1E2C3D) : Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Dark Mode Toggle
                      SwitchListTile(
                        title: Text(
                          "Mode Gelap",
                          style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.black,
                            fontSize: 16 * _textSize,
                          ),
                        ),
                        secondary: Icon(
                          _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: _isDarkMode ? Colors.white : Colors.black,
                        ),
                        value: _isDarkMode,
                        activeColor: const Color(0xFF0D1B2A),
                        onChanged: (value) {
                          setState(() {
                            _isDarkMode = value;
                            _saveSettings();
                          });
                        },
                      ),

                      // Text Size Slider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ukuran Teks",
                              style: TextStyle(
                                color:
                                    _isDarkMode ? Colors.white : Colors.black,
                                fontSize: 16 * _textSize,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.text_fields,
                                  color:
                                      _isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                  size: 16,
                                ),
                                Expanded(
                                  child: Slider(
                                    value: _textSize,
                                    min: 0.8,
                                    max: 1.4,
                                    divisions: 6,
                                    activeColor: const Color(0xFF0D1B2A),
                                    inactiveColor:
                                        _isDarkMode
                                            ? Colors.white30
                                            : Colors.grey.shade300,
                                    onChanged: (value) {
                                      setState(() {
                                        _textSize = value;
                                      });
                                    },
                                    onChangeEnd: (value) {
                                      _saveSettings();
                                    },
                                  ),
                                ),
                                Icon(
                                  Icons.text_fields,
                                  color:
                                      _isDarkMode ? Colors.white : Colors.black,
                                  size: 24,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  "Bantuan",
                  style: TextStyle(
                    fontSize: 18 * _textSize,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: _isDarkMode ? const Color(0xFF1E2C3D) : Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.help_outline,
                      color: _isDarkMode ? Colors.white : Colors.black,
                    ),
                    title: Text(
                      'Lihat Panduan Fitur',
                      style: TextStyle(
                        fontSize: 16 * _textSize,
                        color: _isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: _isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                    onTap: () async {
                      // Reset onboarding status
                      await OnboardingService.resetOnboarding();

                      // Return to home page to show the guide
                      if (mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  "Notifikasi",
                  style: TextStyle(
                    fontSize: 18 * _textSize,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: _isDarkMode ? const Color(0xFF1E2C3D) : Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      "Aktifkan Notifikasi",
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black,
                        fontSize: 16 * _textSize,
                      ),
                    ),
                    secondary: Icon(
                      _notificationsEnabled
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: _isDarkMode ? Colors.white : Colors.black,
                    ),
                    value: _notificationsEnabled,
                    activeColor: const Color(0xFF0D1B2A),
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                        _saveSettings();
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  "Privasi & Keamanan",
                  style: TextStyle(
                    fontSize: 18 * _textSize,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: _isDarkMode ? const Color(0xFF1E2C3D) : Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text(
                          "Aktifkan Lokasi",
                          style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.black,
                            fontSize: 16 * _textSize,
                          ),
                        ),
                        secondary: Icon(
                          _locationEnabled
                              ? Icons.location_on
                              : Icons.location_off,
                          color: _isDarkMode ? Colors.white : Colors.black,
                        ),
                        value: _locationEnabled,
                        activeColor: const Color(0xFF0D1B2A),
                        onChanged: (value) {
                          setState(() {
                            _locationEnabled = value;
                            _saveSettings();
                          });
                        },
                      ),
                      ListTile(
                        title: Text(
                          "Ubah Password",
                          style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.black,
                            fontSize: 16 * _textSize,
                          ),
                        ),
                        leading: Icon(
                          Icons.lock_outline,
                          color: _isDarkMode ? Colors.white : Colors.black,
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: _isDarkMode ? Colors.white54 : Colors.black54,
                        ),
                        onTap: () {
                          // Navigate to change password page
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur akan segera tersedia'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  "Informasi Aplikasi",
                  style: TextStyle(
                    fontSize: 18 * _textSize,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: _isDarkMode ? const Color(0xFF1E2C3D) : Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          "Tentang Aplikasi",
                          style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.black,
                            fontSize: 16 * _textSize,
                          ),
                        ),
                        leading: Icon(
                          Icons.info_outline,
                          color: _isDarkMode ? Colors.white : Colors.black,
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: _isDarkMode ? Colors.white54 : Colors.black54,
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/about');
                        },
                      ),
                      ListTile(
                        title: Text(
                          "Versi Aplikasi",
                          style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.black,
                            fontSize: 16 * _textSize,
                          ),
                        ),
                        leading: Icon(
                          Icons.android,
                          color: _isDarkMode ? Colors.white : Colors.black,
                        ),
                        subtitle: Text(
                          "v1.0.0",
                          style: TextStyle(
                            color:
                                _isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100), // For bottom navigation bar space
              ],
            ),
          ),
          CustomNavBar(scaffoldKey: _scaffoldKey, currentRoute: '/setting'),
        ],
      ),
    );
  }
}
