import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:musichub/themes/colors.dart';
import 'package:provider/provider.dart';

class themeSetting extends StatelessWidget {
  const themeSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Light Theme'),
            onTap: () => themeProvider.setTheme('lightTheme'),
          ),
          ListTile(
            title: Text('Dark Theme'),
            onTap: () => themeProvider.setTheme('darkTheme'),
          ),
          ListTile(
            title: Text('Red Theme'),
            onTap: () => themeProvider.setTheme('redTheme'),
          ),
          // Add more theme options as needed
        ],
      ),
    );
  }
}
