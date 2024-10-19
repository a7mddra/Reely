import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    final Uri furl = Uri.parse('https://www.facebook.com/a7mddra');
    final Uri lurl = Uri.parse('https://linkedin.com/in/a7mddra');
    final Uri gurl = Uri.parse('https://github.com/a7mddra');
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(children: [
          Stack(alignment: Alignment.topCenter, children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width,
                child: ClipRect(
                  child:
                      Image.asset('assets/images/dev.jpg', fit: BoxFit.cover),
                ),
              ),
            ),
            Column(
              children: [
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.11,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 27, 27, 27)
                            .withOpacity(0.85),
                        border: Border.all(
                          color: const Color.fromARGB(255, 255, 255, 255)
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 34),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 15,
                            ),
                            SizedBox(
                              height: 50,
                              width: 80,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                    shadowColor: Colors.transparent,
                                    backgroundColor: Colors.transparent,
                                    alignment: Alignment.center),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 3.0),
                                      child: Icon(
                                        Icons.arrow_back_ios,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        size: 22,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Center(
                                child: Text("About Developer",
                                    style: TextStyle(
                                        fontSize: 22,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(
                              width: 85,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.31,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.08,
                    width: MediaQuery.of(context).size.width,
                    color: const Color.fromARGB(123, 0, 0, 0),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Text("Eng. Ahmed Ramadan",
                            style: TextStyle(
                                fontSize: 25,
                                fontFamily: 'be',
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.verified,
                          color: Colors.blue,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "A student in Engineering At Damanhour University in Egypt, With A Keen Interest In technology and problem-solving. From 2020 to 2022, I took programming courses that sharpened my proficiency in Python and C++. I also participated in the ECPC 2024, further enhancing my problem-solving skills. In addition to my technical background, I completed an Arduino course (2023-2024) and developed expertise in Flutter for mobile app development.",
                    style: TextStyle(fontSize: 15.5),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () async {
                            await launchUrl(furl);
                          },
                          child: const Icon(
                            FontAwesomeIcons.squareFacebook,
                            color: Color.fromARGB(255, 15, 112, 192),
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 25),
                        InkWell(
                          onTap: () async {
                            await launchUrl(lurl);
                          },
                          child: const Icon(
                            FontAwesomeIcons.linkedin,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 25),
                        InkWell(
                          onTap: () async {
                            await launchUrl(gurl);
                          },
                          child: const Icon(
                            FontAwesomeIcons.github,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text("Reely App © 1.0.0",
                        style: TextStyle(
                            color: Color.fromARGB(255, 190, 190, 190),
                            fontSize: 17,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'be'))
                  ],
                ),
              ],
            ),
          ]),
        ]),
      ),
    );
  }
}
