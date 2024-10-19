import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:shorts_a7md/resources/firestore_methods.dart';
import 'package:shorts_a7md/utils/utils.dart';
import 'package:video_player/video_player.dart';

class Upload extends StatefulWidget {
  final bool isTabVisible;
  final String? username;
  final String? photoUrl;
  final bool hasData;

  const Upload(
      {super.key,
      required this.isTabVisible,
      required this.username,
      required this.photoUrl,
      required this.hasData});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedVideo;
  VideoPlayerController? _videoController;
  final TextEditingController _descriptionController = TextEditingController();
  bool _hasPickedVideo = false;
  bool isLoading = false;
  bool isPosting = false;
  bool isPickingVideo = false;

  @override
  void initState() {
    super.initState();
    if (widget.isTabVisible && !_hasPickedVideo) {
      _pickVideo();
    }
  }

  @override
  void didUpdateWidget(covariant Upload oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isTabVisible && !_hasPickedVideo) {
      _pickVideo();
    }
  }

  Future<void> _pickVideo() async {
    if (isPickingVideo) return;
    isPickingVideo = true;
    setState(() {
      isLoading = true;
    });
    try {
      XFile? video = await _picker.pickVideo(source: ImageSource.gallery);

      if (video != null) {
        setState(() {
          _pickedVideo = video;
          _hasPickedVideo = true;
          _videoController = VideoPlayerController.file(File(video.path))
            ..initialize().then((_) {
              setState(() {
                isLoading = false;
              });
              _videoController?.play();
            });
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      showSnackBar(context, 'Error picking video: $e');
      setState(() {
        isLoading = false;
      });
    } finally {
      isPickingVideo = false;
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _upload() async {
    final description = _descriptionController.text;
    if (_pickedVideo != null && description.isNotEmpty) {
      setState(() {
        isPosting = true;
      });

      try {
        Uint8List vidData = await _pickedVideo!.readAsBytes();
        String uid = FirebaseAuth.instance.currentUser!.uid;
        String username = widget.username!;
        String profImage = widget.photoUrl!;

        String res = await FireStoreMethods()
            .uploadPost(description, vidData, uid, username, profImage);

        if (res == "success") {
          setState(() {
            _descriptionController.clear();
            _pickedVideo = null;
            _hasPickedVideo = false;
            isPosting = false;
          });
          showSnackBar(context, 'Video uploaded successfully!');
        } else {
          showSnackBar(context, res);
        }
      } catch (err) {
        showSnackBar(context, err.toString());
        setState(() {
          isPosting = false;
        });
      }
    } else {
      showSnackBar(context, 'Please provide a description and a video file.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _hasPickedVideo
              ? GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _videoController != null &&
                                  _videoController!.value.isInitialized
                              ? SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: AspectRatio(
                                    aspectRatio:
                                        _videoController!.value.aspectRatio,
                                    child: VideoPlayer(_videoController!),
                                  ),
                                )
                              : const Center(
                                  child: CircularProgressIndicator()),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: "Video Description",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 48,
                            width: 330,
                            child: ElevatedButton(
                                onPressed: () {
                                  (_descriptionController.text.isEmpty ||
                                          !widget.hasData)
                                      ? null
                                      : _upload();
                                },
                                style: ElevatedButton.styleFrom(
                                    overlayColor:
                                        (_descriptionController.text.isEmpty ||
                                                !widget.hasData)
                                            ? Colors.transparent
                                            : const Color.fromARGB(
                                                148, 255, 255, 255),
                                    backgroundColor:
                                        (_descriptionController.text.isEmpty ||
                                                !widget.hasData)
                                            ? const Color.fromARGB(
                                                148, 33, 149, 243)
                                            : Colors.blue,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    enabledMouseCursor:
                                        (_descriptionController.text.isEmpty ||
                                                !widget.hasData)
                                            ? SystemMouseCursors.basic
                                            : SystemMouseCursors.click),
                                child: isPosting
                                    ? Center(
                                        child: LottieBuilder.asset(
                                          'assets/animations/loading.json',
                                          height: 40,
                                          width: 40,
                                        ),
                                      )
                                    : Text(
                                        "Upload",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: (_descriptionController
                                                        .text.isEmpty ||
                                                    !widget.hasData)
                                                ? const Color.fromARGB(
                                                    148, 255, 255, 255)
                                                : Colors.white),
                                      )),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const Center(child: Text("No video picked")),
    );
  }
}
