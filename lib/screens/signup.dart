import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:shorts_a7md/resources/auth_methods.dart';
import 'package:shorts_a7md/utils/utils.dart';
import 'package:shorts_a7md/widgets/text_feild_input.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String error = '';
  bool isLoading = false;
  bool isVisible = false;
  bool check = true;
  Uint8List? image;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_validateInputs);
    _bioController.addListener(_validateInputs);
    _emailController.addListener(_validateInputs);
    _passwordController.addListener(_validateInputs);
  }

  void _validateInputs() {
    setState(() {
      check = _emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _usernameController.text.isEmpty ||
          _bioController.text.isEmpty;
    });
  }

  void signUpUser() async {
    setState(() {
      isLoading = true;
    });

    String res = await AuthMethods().signUpUser(
      username: _usernameController.text,
      bio: _bioController.text,
      email: _emailController.text,
      password: _passwordController.text,
      file: image,
    );

    if (res == 'Success') {
      Navigator.of(context).pop({
        'error': 'Please verify your email before logging in.',
        'mail': _emailController.text,
        'pass': _passwordController.text,
      });
    } else {
      setState(() {
        error = res;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      setState(() {
        image = img;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardActive = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 60),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/reely.svg',
                          width: 80,
                          height: 38,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  Stack(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor:
                                const Color.fromARGB(255, 36, 36, 38),
                            child: image != null
                                ? ClipOval(
                                    child: Image.memory(
                                      image!,
                                      fit: BoxFit.cover,
                                      width: 140,
                                      height: 140,
                                    ),
                                  )
                                : ClipOval(
                                    child: SizedBox(
                                      width: 140,
                                      height: 140,
                                      child: SvgPicture.asset(
                                        'assets/images/user.svg',
                                        fit: BoxFit.cover,
                                        width: 140,
                                        height: 140,
                                      ),
                                    ),
                                  ),
                          )),
                      Positioned(
                        bottom: 15,
                        left: 95,
                        child: CircleAvatar(
                          backgroundColor:
                              const Color.fromARGB(250, 224, 224, 224),
                          radius: 19,
                          child: IconButton(
                            icon: const Icon(
                              Icons.photo_camera,
                              color: Colors.black,
                              size: 24,
                            ),
                            onPressed: selectImage,
                            alignment: Alignment.center,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: 310,
                    child: TextFeildInput(
                      hintText: "Username",
                      textEditingController: _usernameController,
                      isPass: false,
                      textInputType: TextInputType.name,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: 310,
                    child: TextFeildInput(
                      hintText: "Bio",
                      textEditingController: _bioController,
                      isPass: false,
                      textInputType: TextInputType.text,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: 310,
                    child: TextFeildInput(
                      hintText: "Email",
                      textEditingController: _emailController,
                      isPass: false,
                      textInputType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: 310,
                    child: Stack(
                      alignment: AlignmentDirectional.centerEnd,
                      children: [
                        TextFeildInput(
                          hintText: "Password",
                          textEditingController: _passwordController,
                          isPass: !isVisible,
                          textInputType: TextInputType.text,
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              isVisible = !isVisible;
                            });
                          },
                          child: SizedBox(
                            width: 60,
                            child: Text(
                              isVisible ? "Hide" : "Show",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    height: 48,
                    width: 310,
                    child: ElevatedButton(
                        onPressed: () {
                          check ? null : signUpUser();
                        },
                        style: ElevatedButton.styleFrom(
                            overlayColor: check
                                ? Colors.transparent
                                : const Color.fromARGB(148, 255, 255, 255),
                            backgroundColor: check
                                ? const Color.fromARGB(148, 33, 149, 243)
                                : Colors.blue,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                            enabledMouseCursor: check
                                ? SystemMouseCursors.basic
                                : SystemMouseCursors.click),
                        child: isLoading
                            ? Center(
                                child: LottieBuilder.asset(
                                  'assets/animations/loading.json',
                                  height: 40,
                                  width: 40,
                                ),
                              )
                            : Text(
                                "Sign up",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: check
                                        ? const Color.fromARGB(
                                            148, 255, 255, 255)
                                        : Colors.white),
                              )),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Text(
                      error,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )),
                ],
              ),
            ),
          ),
          if (!isKeyboardActive)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("Have an account? ",
                      style: TextStyle(fontSize: 14.5)),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Sign in.",
                      style: TextStyle(fontSize: 14.7, color: Colors.blue),
                    ),
                  )
                ]),
              ),
            ),
        ],
      ),
    );
  }
}
