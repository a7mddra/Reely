import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Loading extends StatelessWidget {
  final bool isLoading;
  final Widget loadingContent;
  final Widget loadedContent;

  const Loading({
    super.key,
    required this.isLoading,
    required this.loadedContent,
    required this.loadingContent,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Shimmer.fromColors(
            baseColor: const Color.fromARGB(255, 20, 20, 20),
            highlightColor: const Color.fromARGB(255, 68, 68, 68),
            child: loadingContent,
          )
        : loadedContent;
  }
}

Widget buildShimmerBox(double width, double height) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    width: width,
    height: height * 1.2,
  );
}

Widget buildShimmerMetrics() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const SizedBox(height: 18),
      buildShimmerBox(50, 18),
      const SizedBox(height: 9),
      buildShimmerBox(50, 12),
    ],
  );
}

Widget reelLoading() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildShimmerBox(100, 16),
                            const SizedBox(height: 4),
                            buildShimmerBox(85, 16),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    buildShimmerBox(250, 15),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget buildShimmerContent() {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 15),
                      buildShimmerBox(80, 15),
                      const SizedBox(height: 9),
                      buildShimmerBox(120, 15),
                    ],
                  ),
                  const SizedBox(width: 15),
                  buildShimmerMetrics(),
                  const SizedBox(width: 10),
                  buildShimmerMetrics(),
                  const SizedBox(width: 10),
                  buildShimmerMetrics(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildShimmerBox(165, 35 / 1.2),
                  buildShimmerBox(165, 35 / 1.2),
                ],
              ),
            ),
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.white,
            ),
          ],
        ),
      ),
    ],
  );
}
