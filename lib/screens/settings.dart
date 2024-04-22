import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:musichub/helpers/constants.dart';
import 'package:musichub/themes/colors.dart';

class settings extends StatefulWidget {
  const settings({super.key});

  @override
  State<settings> createState() => _settingsState();
}

class _settingsState extends State<settings> {
  String quality = Audiosetting.get('quality') == null
      ? 'High'
      : Audiosetting.get('quality');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('settings'),
        actions: [
          TextButton(
              onPressed: () {
                print(Audiosetting.get('quality'));
                Audiosetting.put('quality', quality);

                setState(() {});
              },
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Colors.green,
                  ),
                  height: 35,
                  width: 60,
                  child: const Center(
                      child: Text(
                    'save',
                    style: TextStyle(color: Colors.white),
                  ))))
        ],
        centerTitle: true,
      ),
      backgroundColor: black,
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Column(children: [
          const Text(
            'download quality',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(
            height: 15,
          ),
          ToggleOptions(
            onOptionChanged: (value) {
              setState(() {
                quality = value;
              });
            },
          ),
          const SizedBox(
            height: 30,
          ),

          // SizedBox(
          //   height: 30,
          // ),
          // const Text(
          //   'base color',
          //   style: TextStyle(fontSize: 18),
          // ),
          // const SizedBox(
          //   height: 15,
          // ),
          // ToggleColorOptions(
          //   options: [Colors.green, Colors.red, Colors.yellow],
          //   onOptionChanged: (color) {
          //     print('Selected Color: $color');
          //   },
          // )
        ]),
      ),
    );
  }
}

class ToggleOptions extends StatefulWidget {
  final ValueChanged<String> onOptionChanged;

  ToggleOptions({required this.onOptionChanged});
  @override
  _ToggleOptionsState createState() => _ToggleOptionsState();
}

class _ToggleOptionsState extends State<ToggleOptions> {
  String selectedOption = Audiosetting.get('quality') == null
      ? 'High'
      : Audiosetting.get('quality');

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color.fromARGB(255, 33, 149, 243).withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          option,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class ToggleColorOptions extends StatefulWidget {
  final List<Color> options;
  final ValueChanged<Color> onOptionChanged;

  ToggleColorOptions({required this.options, required this.onOptionChanged});

  @override
  _ToggleColorOptionsState createState() => _ToggleColorOptionsState();
}

class _ToggleColorOptionsState extends State<ToggleColorOptions> {
  Color selectedOption = Colors.green;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildOption(Colors.green),
        buildOption(Colors.red),
        buildOption(Colors.yellow),
      ],
    );
  }

  Widget buildOption(Color option) {
    bool isActive = selectedOption == option;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = option;
          widget.onOptionChanged(selectedOption);
        });
      },
      child: Container(
        // width: 50,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
            color: isActive
                ? const Color.fromARGB(47, 255, 255, 255)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isActive
                ? null
                : Border.all(color: const Color.fromARGB(138, 255, 255, 255))),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                FeatherIcons.arrowDownCircle,
                color: option,
                size: 20,
              ),
              const SizedBox(
                width: 10,
              ),
              Icon(
                FeatherIcons.playCircle,
                color: option,
                size: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
