import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../core/theme.dart';

class CameraWidget extends StatefulWidget {
  final Function(XFile) onImageCaptured;

  const CameraWidget({super.key, required this.onImageCaptured});

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isReady = false;
  late FaceDetector _faceDetector;
  bool _isProcessingImage = false;
  bool _isLivenessVerified = false;
  CameraDescription? _frontCamera;

  String _statusText = "Position your face & Blink";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final bool isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (isMobile) {
      // Prepare Google ML Kit Face Detector with classification enabled (for eyes status)
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: true, // Crucial for getting eye open probability
          enableTracking: true,
        ),
      );
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        _frontCamera!,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();
      if (!mounted) return;

      setState(() => _isReady = true);

      // Start raw stream for live face and blink classification
      _controller!.startImageStream((CameraImage image) {
        if (_isProcessingImage || _isLivenessVerified) return;
        _processCameraImage(image);
      });
    } catch (e) {
      debugPrint('Camera Init Error: $e');
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    _isProcessingImage = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final inputImageRotation = InputImageRotationValue.fromRawValue(_frontCamera!.sensorOrientation) ?? InputImageRotation.rotation0deg;
      final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw as int) ?? InputImageFormat.nv21;

      final inputImageData = InputImageMetadata(
        size: imageSize,
        rotation: inputImageRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
      final faces = await _faceDetector.processImage(inputImage);

      for (Face face in faces) {
        if (face.leftEyeOpenProbability != null && face.rightEyeOpenProbability != null) {
          // Both eyes closed under 20% indicates a blink!
          if (face.leftEyeOpenProbability! < 0.2 && face.rightEyeOpenProbability! < 0.2) {
            if (!_isLivenessVerified && mounted) {
              setState(() {
                _isLivenessVerified = true;
                _statusText = "Verified! Capturing photo...";
              });

              // Stop the stream immediately to capture a static photo
              await _controller!.stopImageStream();
              _takePicture();
            }
            break;
          }
        }
      }
    } catch (e) {
      debugPrint("ML Kit Processing Exception: $e");
    } finally {
      if (!_isLivenessVerified) {
        _isProcessingImage = false;
      }
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      // Brief delay to allow standard exposure adjustment
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      final image = await _controller!.takePicture();
      widget.onImageCaptured(image); // Hand back file descriptor to caller
    } catch (e) {
      debugPrint('Capture Error: $e');
      _resetCaptureState();
    }
  }

  void _resetCaptureState() {
    if (mounted) {
      setState(() {
        _isLivenessVerified = false;
        _isProcessingImage = false;
        _statusText = "Position your face & Blink";
      });
      if (_controller != null && _controller!.value.isInitialized) {
        _controller!.startImageStream((image) => _processCameraImage(image));
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      setState(() => _isReady = false);
      _controller?.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _resetCaptureState();
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final bool isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (isMobile) {
      _faceDetector.close();
    }
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (!isMobile) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Biometric face attendance features are only supported on mobile devices (Android/iOS) because they rely on native eye-blink liveness checks.\n\nPlease test this feature on an Android Emulator or a physical device.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
          ),
        ),
      );
    }

    if (!_isReady || _controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    return Stack(
      children: [
        Positioned.fill(child: CameraPreview(_controller!)),
        Center(
          child: Container(
            width: 250,
            height: 340,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(170),
              border: Border.all(color: _isLivenessVerified ? Colors.pinkAccent : AppTheme.primaryColor, width: 3),
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusText, 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        )
      ],
    );
  }
}
