import 'package:flutter/material.dart';
import 'package:shorts_a7md/resources/auth_methods.dart';
import 'package:shorts_a7md/screens/about.dart';
import 'package:shorts_a7md/screens/login.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool mode = true;

  @override
  Widget build(BuildContext context) {
    final Uri url = Uri.parse('https://t.me/a7mddra');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 3),
          _buildButton(
            icon: Icons.dark_mode_sharp,
            text: "Dark mode",
            trailing: Switch(
              value: mode,
              onChanged: (bool value) {
                setState(() {
                  mode = !mode;
                });
              },
            ),
            onTap: () {
              setState(() {
                mode = !mode;
              });
            },
          ),
          _buildButton(
            icon: Icons.help_rounded,
            text: "Help & Support",
            onTap: () async {
              await launchUrl(url);
            },
          ),
          _buildButton(
            icon: Icons.bug_report_sharp,
            text: "Report a bug",
            onTap: () async {
              await launchUrl(url);
            },
          ),
          _buildButton(
            icon: Icons.info_rounded,
            text: "About developer",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const About()),
              );
            },
          ),
          _buildButton(
            icon: Icons.logout,
            text: "Logout",
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: () async {
              await AuthMethods().signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => Login(error: '', mail: '', pass: ''),
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          const Text(
            "Reely App © 1.0.0",
            style: TextStyle(
              color: Color.fromARGB(255, 190, 190, 190),
              fontSize: 15,
              fontWeight: FontWeight.normal,
              fontFamily: 'be',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String text,
    Widget? trailing,
    required VoidCallback onTap,
    Color iconColor = Colors.white70,
    Color textColor = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white12,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
