import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:hackfinity/utils/assets.dart';
import 'package:hackfinity/utils/strings.dart';

class HomeScreenSecond extends StatefulWidget {
  const HomeScreenSecond({super.key});

  @override
  State<HomeScreenSecond> createState() => _HomeScreenSecondState();
}

class _HomeScreenSecondState extends State<HomeScreenSecond>
    with WidgetsBindingObserver {
  bool _isCameraInitialized = false;
  bool isStreaming = true;
  bool isFlashActive = false;

  CameraController? controller;

  late final List<CameraDescription> cameras;
  SpeechToText speechToText = SpeechToText();
  bool speechEnabled = false;

  FlutterTts textToSpeech = FlutterTts();

  String lastWords = 'hello';

  Timer? streamingTimer;

  Assets assets = Assets();
  Strings strings = Strings();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initCamera();
    initSpeech();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    await onNewCameraSelected(cameras.first);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    controller?.dispose();
  }

  void toggleFlash() async {
    if (controller?.value.flashMode == FlashMode.torch) {
      await controller?.setFlashMode(FlashMode.off);
      setState(() {
        isFlashActive = false;
      });
    } else {
      await controller?.setFlashMode(FlashMode.torch);
      setState(() {
        isFlashActive = true;
      });
    }
  }

  void initSpeech() async {
    speechEnabled = await speechToText.initialize();
    setState(() {});
  }

  void startListening() async {
    // setState(() {
    //   isStreaming = false;
    // });

    print(isStreaming);

    try {
      await speechToText.listen(
        onResult: onSpeechResult,
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.deviceDefault,
          autoPunctuation: true,
          enableHapticFeedback: true,
          partialResults: true,
        ),
        listenFor: const Duration(
          minutes: 2,
        ),
        pauseFor: const Duration(
          seconds: 59,
        ),
      );
    } catch (e) {
      print('Error in startListening: $e');
    }
  }

  void stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
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

    textToSpeech.setLanguage('en-US');
    textToSpeech.setSpeechRate(0.5);
    textToSpeech.setPitch(1.0);
    textToSpeech.setVolume(1.0);

    if (_isCameraInitialized) {
      return SafeArea(
        child: Scaffold(
          // AppBar
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {},
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              icon: Icon(
                isFlashActive
                    ? Icons.flash_on_rounded
                    : Icons.flash_off_rounded,
                color: Colors.transparent,
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  assets.logo,
                  width: 32,
                  height: 32,
                ),
                const SizedBox(width: 8),
                Text(
                  strings.projectName,
                ),
              ],
            ),
            centerTitle: true,
            backgroundColor: Colors.green,
            actions: [
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

          // Body
          body: Stack(
            children: [
              // Camera
              SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: CameraPreview(
                  controller!,
                ),
              ),

              // Text Container
              Visibility(
                visible: lastWords.isNotEmpty,
                child: Positioned(
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
              ),

              // Stream Start/Stop Button
              Positioned(
                right: 80,
                bottom: 16,
                child: FloatingActionButton(
                  onPressed: () {
                    if (isStreaming) {
                      setState(() {
                        isStreaming = false;
                      });
                      stopStreaming();
                    } else {
                      setState(() {
                        isStreaming = true;
                      });
                      streamToBackend();
                    }
                  },
                  backgroundColor: Colors.green,
                  tooltip: 'Stream',
                  child: Icon(
                    isStreaming ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                  ),
                ),
              ),

              // Speak Button
              Visibility(
                visible: lastWords.isNotEmpty,
                child: Positioned(
                  left: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    onPressed: speak,
                    backgroundColor: Colors.green,
                    tooltip: 'Speak',
                    child: const Icon(
                      Icons.record_voice_over_rounded,
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (speechToText.isNotListening) {
                setState(() {
                  isStreaming = false;
                });
                stopStreaming();
                startListening();
              } else {
                stopListening();
              }
            },
            backgroundColor:
                speechToText.isListening ? Colors.brown : Colors.green,
            tooltip: 'Listen',
            child: Icon(
              speechToText.isNotListening
                  ? Icons.mic_off_rounded
                  : Icons.mic_rounded,
            ),
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
    final previousCameraController = controller;

    final CameraController cameraController = CameraController(
      description,
      ResolutionPreset.ultraHigh,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: $e');
    }

    await previousCameraController?.dispose();

    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }

    streamToBackend();
  }

  void streamToBackend() {
    if (isStreaming) {
      lastWords = '';
      streamingTimer =
          Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
        if (controller != null && controller!.value.isInitialized) {
          try {
            final XFile? frame = await controller?.takePicture();
            if (frame != null) {
              Uint8List imageBytes = await frame.readAsBytes();
              await sendFrameToBackend(imageBytes);
            }
          } catch (e) {
            debugPrint('Error capturing frame: $e');
          }
        }
      });
    }
  }

  Future<void> sendFrameToBackend(Uint8List imageBytes) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.9.214.176:5000/stream'), // Meenakshi
        // Uri.parse('http://10.3.65.221:5000/stream'), // Pratyush
        // Uri.parse('http://10.9.205.208:5000/stream'), // My
        headers: {'Content-Type': 'application/octet-stream'},
        body: imageBytes,
      );
      if (response.statusCode == 200 && speechToText.isNotListening) {
        debugPrint('Frame sent successfully!');

        lastWords = lastWords + response.body.toString();

        if (response.body.isNotEmpty) {
          lastWords = lastWords + response.body.toString();
        } else {
          lastWords = lastWords;
        }

        if (lastWords[lastWords.length - 1] == '' &&
            lastWords[lastWords.length - 2] == '') {
          lastWords = lastWords.substring(0, lastWords.length - 1);
        }
      } else {
        debugPrint('Failed to send frame: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending frame: $e');
    }
  }

  void stopStreaming() {
    if (streamingTimer != null) {
      setState(() {
        isStreaming = false;
      });

      streamingTimer!.cancel();
      streamingTimer = null;
    }
  }

  Future<void> speak() async {
    if (lastWords.isNotEmpty) {
      await textToSpeech.speak(lastWords);
    }
  }

  Future<void> stopSpeaking() async {
    await textToSpeech.stop();
  }
}
