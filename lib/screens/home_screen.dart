import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:hackfinity/utils/strings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  late final List<CameraDescription> _cameras;
  // bool _isRecording = false;

  bool isFlashActive = false;

  SpeechToText speechToText = SpeechToText();
  bool speechEnabled = false;
  String lastWords = '';

  Strings strings = Strings();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initCamera();
    initSpeech();
  }

  Future<void> initCamera() async {
    _cameras = await availableCameras();
    // Initialize the camera with the first camera in the list
    await onNewCameraSelected(_cameras.first);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    final CameraController? cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void toggleFlash() async {
    if (_controller?.value.flashMode == FlashMode.torch) {
      await _controller?.setFlashMode(FlashMode.off);
      setState(() {
        isFlashActive = false;
      });
    } else {
      await _controller?.setFlashMode(FlashMode.torch);
      setState(() {
        isFlashActive = true;
      });
    }
  }

  void initSpeech() async {
    speechEnabled = await speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void startListening() async {
    await speechToText.listen(
      onResult: onSpeechResult,
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.confirmation,
        autoPunctuation: true,
        enableHapticFeedback: true,
        partialResults: true,
      ),
      listenFor: const Duration(
        seconds: 30,
      ),
      pauseFor: const Duration(
        seconds: 5,
      ),
    );
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
      // log(4);
      debugPrint('Speech: $lastWords');
    });
  }

  // Future<XFile?> captureVideo() async {
  //   final CameraController? cameraController = _controller;
  //   try {
  //     setState(() {
  //       _isRecording = true;
  //     });
  //     await cameraController?.startVideoRecording();
  //     await Future.delayed(const Duration(seconds: 5));
  //     final video = await cameraController?.stopVideoRecording();
  //     setState(() {
  //       _isRecording = false;
  //     });
  //     return video;
  //   } on CameraException catch (e) {
  //     debugPrint('Error occured while taking picture: $e');
  //     return null;
  //   }
  // }

  // void _onTakePhotoPressed() async {
  //   final navigator = Navigator.of(context);
  //   final xFile = await capturePhoto();
  //   if (xFile != null) {
  //     if (xFile.path.isNotEmpty) {
  //       navigator.push(
  //         MaterialPageRoute(
  //           builder: (context) => PreviewPage(
  //             imagePath: xFile.path,
  //           ),
  //         ),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    if (_isCameraInitialized) {
      return SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: CameraPreview(
                  _controller!,
                ),
              ),
              Container(
                height: kToolbarHeight,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      strings.projectName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  height: height * 0.4,
                  width: width,
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  padding: const EdgeInsets.only(
                    top: 12,
                    left: 12,
                    right: 23,
                    bottom: 75,
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      lastWords,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                bottom: 10,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: toggleFlash,
                      icon: Icon(
                        isFlashActive
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: FloatingActionButton(
                  onPressed: () {
                    if (speechToText.isNotListening) {
                      startListening();
                    } else {
                      stopListening();
                    }
                  },
                  tooltip: 'Listen',
                  child: Icon(
                    speechToText.isNotListening ? Icons.mic_off : Icons.mic,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  Future<void> onNewCameraSelected(CameraDescription description) async {
    final previousCameraController = _controller;

    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      description,
      ResolutionPreset.ultraHigh,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: $e');
    }
    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        _controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = _controller!.value.isInitialized;
      });
    }
  }
}
