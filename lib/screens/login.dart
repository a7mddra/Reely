import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:shorts_a7md/resources/auth_methods.dart';
import 'package:shorts_a7md/layout.dart';
import 'package:shorts_a7md/screens/signup.dart';
import 'package:shorts_a7md/widgets/text_feild_input.dart';

class Login extends StatefulWidget {
  String error;
  String? mail;
  String? pass;
  Login({
    super.key,
    required this.error,
    required this.mail,
    required this.pass,
  });

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late TextEditingController _emailController = TextEditingController();
  late TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  bool isVisible = false;
  bool check = true;
  bool isBack = false;

  @override
  void initState() {
    super.initState();

    if (widget.mail != null && widget.pass != null) {
      setState(() {
        widget.error = widget.error;
      });
    }

    _emailController.addListener(_validateInputs);
    _passwordController.addListener(_validateInputs);
  }

  void _validateInputs() {
    setState(() {
      check = _emailController.text.isEmpty || _passwordController.text.isEmpty;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void loginUser() async {
    setState(() {
      isLoading = true;
    });

    String res = await AuthMethods().logInUser(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (res == 'Success') {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.emailVerified) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const Layout(),
          ),
        );
      } else {
        setState(() {
          widget.error = 'Please verify your email before logging in.';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        widget.error = res;
        isLoading = false;
      });
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      setState(() {
        widget.error = e.toString();
      });
    }
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
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Center(
                        child: SvgPicture.asset(
                      'assets/images/reely.svg',
                    )),
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
                          check ? null : loginUser();
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
                                "Log in",
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
                  isBack
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              const Text("Email not sent? ",
                                  style: TextStyle(fontSize: 16)),
                              InkWell(
                                onTap: () async {
                                  await AuthMethods()
                                      .resendVerificationEmail(context);
                                },
                                child: const Text(
                                  "Resend it.",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.blue),
                                ),
                              )
                            ])
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              const Text("Forgot your password? ",
                                  style: TextStyle(fontSize: 16)),
                              InkWell(
                                onTap: () {
                                  _emailController.text.isEmpty
                                      ? setState(() {
                                          widget.error =
                                              "Please enter your email first.";
                                        })
                                      : sendPasswordReset(
                                          _emailController.text);
                                },
                                child: const Text(
                                  "Reset it.",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.blue),
                                ),
                              )
                            ]),
                  const SizedBox(
                    height: 15,
                  ),
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Text(
                      widget.error,
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
                  const Text("Don't have an account? ",
                      style: TextStyle(fontSize: 14.5)),
                  InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                          builder: (context) => const Signup(),
                        ),
                      )
                          .then((result) {
                        if (result != null) {
                          setState(() {
                            widget.error = result['error'];
                            _emailController =
                                TextEditingController(text: result['mail']);
                            _passwordController =
                                TextEditingController(text: result['pass']);
                            check = false;
                            isBack = true;
                          });
                        }
                      });
                    },
                    child: const Text(
                      "Sign up.",
                      style: TextStyle(fontSize: 14.7, color: Colors.blue),
                    ),
                  )
                ]),
              ),
            )
        ],
      ),
    );
  }
}
