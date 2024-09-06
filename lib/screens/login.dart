// import 'package:blackhole/CustomWidgets/gradient_containers.dart';
// import 'package:blackhole/Helpers/backup_restore.dart';
// import 'package:blackhole/Helpers/config.dart';
// import 'package:blackhole/Helpers/supabase.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:musichub/helpers/constants.dart';
import 'package:musichub/main.dart';
import 'package:musichub/screens/search.dart';
import 'package:uuid/uuid.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  TextEditingController controller = TextEditingController();
  Uuid uuid = const Uuid();
  bool isLoading = false; // Add this flag

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  static const snackBar = SnackBar(
    content: Text('Enter your Email to proceed'),
  );

  Future _addUserData(String email) async {
    setState(() {
      isLoading = true; // Show the progress indicator
    });

    try {
      await LoginBox.add({'logged': 'true'});
      await supabase.from('emails').insert({
        'email': '${email.trim()}',
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => home(),
        ),
      );
    } catch (e) {
      print(e);
      // Handle error if needed
    } finally {
      setState(() {
        isLoading = false; // Hide the progress indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: MediaQuery.of(context).size.width / 1.85,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
              ),
            ),
            Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [],
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: 'Music\n',
                                  style: TextStyle(
                                    height: 0.97,
                                    fontSize: 60,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  children: <TextSpan>[
                                    const TextSpan(
                                      text: 'Hub',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 60,
                                        color: Color.fromARGB(255, 225, 20, 20),
                                      ),
                                    ),
                                    TextSpan(
                                      text: '.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 60,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                          ),
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(
                                  top: 5,
                                  bottom: 5,
                                  left: 10,
                                  right: 10,
                                ),
                                height: 57.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.grey[900],
                                ),
                                child: TextField(
                                  controller: controller,
                                  textAlignVertical: TextAlignVertical.center,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.mail_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    border: InputBorder.none,
                                    hintText: "Enter Email",
                                    hintStyle: const TextStyle(
                                      color: Colors.white60,
                                    ),
                                  ),
                                  // onSubmitted: (String value) async {
                                  //   if (value.trim() == '') {
                                  //     ScaffoldMessenger.of(context)
                                  //         .showSnackBar(snackBar);
                                  //     // Handle empty input if needed
                                  //   } else {
                                  //     _addUserData(value.trim());
                                  //   }
                                  // },
                                  onSubmitted: (String value) async {
                                    String trimmedValue = value.trim();
                                    if (trimmedValue == '') {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    } else if (!_isValidEmail(trimmedValue)) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Please enter a valid email address')),
                                      );
                                    } else {
                                      _addUserData(trimmedValue);
                                    }
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  // if (controller.text.trim() == '') {
                                  //   ScaffoldMessenger.of(context)
                                  //       .showSnackBar(snackBar);
                                  // } else {
                                  //   await _addUserData(
                                  //     controller.text.trim(),
                                  //   );
                                  // }
                                  String trimmedValue = controller.text.trim();
                                  if (trimmedValue == '') {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else if (!_isValidEmail(trimmedValue)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Please enter a valid email address')),
                                    );
                                  } else {
                                    _addUserData(trimmedValue);
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                  ),
                                  height: 55.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 5.0,
                                        offset: Offset(0.0, 3.0),
                                      )
                                    ],
                                  ),
                                  child: Center(
                                    child: isLoading
                                        ? CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.black),
                                          )
                                        : const Text(
                                            "Get Started",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 20.0,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "  we collect email to keep you updated",
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
