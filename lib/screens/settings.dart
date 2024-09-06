import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:musichub/helpers/constants.dart';
import 'package:musichub/miniplayer.dart';
import 'package:musichub/themes/colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String quality = Audiosetting.get('quality') ?? 'High';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: black,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Download Quality',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            ToggleOptions(
              onOptionChanged: (value) {
                setState(() {
                  quality = value;
                });
              },
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: ElevatedButton(
                  onPressed: () {
                    Audiosetting.put('quality', quality);
                    // Fluttertoast.showToast(
                    //   msg: "New settings are saved",
                    //   toastLength: Toast.LENGTH_SHORT,
                    //   gravity: ToastGravity.BOTTOM,
                    //   backgroundColor: Colors.green,
                    //   textColor: Colors.white,
                    //   fontSize: 16.0,
                    // );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Settings',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MiniPlayer(),
    );
  }
}

class ToggleOptions extends StatefulWidget {
  final ValueChanged<String> onOptionChanged;

  const ToggleOptions({required this.onOptionChanged});

  @override
  _ToggleOptionsState createState() => _ToggleOptionsState();
}

class _ToggleOptionsState extends State<ToggleOptions> {
  String selectedOption = Audiosetting.get('quality') ?? 'High';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildOption('Low'),
        buildOption('Medium'),
        buildOption('High'),
      ],
    );
  }

  Widget buildOption(String option) {
    bool isActive = selectedOption == option;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = option;
          widget.onOptionChanged(selectedOption);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.white,
            width: 1,
          ),
        ),
        child: Text(
          option,
          style: TextStyle(
            color: isActive ? Colors.blue : Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
