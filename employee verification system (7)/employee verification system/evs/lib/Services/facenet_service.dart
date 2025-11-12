import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:google_ml_kit/google_ml_kit.dart';

class FaceNetService {
  late Interpreter _interpreter;
  bool _loaded = false;

  /// Load the FaceNet TFLite model from assets
  Future<void> loadModel({String assetName = 'assets/models/facenet.tflite'}) async {
    if (_loaded) return;
    _interpreter = await Interpreter.fromAsset(assetName);
    _loaded = true;
    print('✅ FaceNet model loaded: $assetName');
  }

  /// Get 128-d embedding for a given image file
  Future<List<double>> getEmbedding(File imageFile) async {
    // 1️⃣ Detect face using ML Kit
    // ignore: deprecated_member_use
    final detector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
    );
    final inputImage = InputImage.fromFile(imageFile);
    final faces = await detector.processImage(inputImage);
    await detector.close();

    if (faces.isEmpty) throw Exception('No face detected');

    final face = faces.first;

    // 2️⃣ Decode image
    final bytes = await imageFile.readAsBytes();
    if (bytes.isEmpty) throw Exception('Image bytes empty');
    final original = img.decodeImage(bytes);
    if (original == null) throw Exception('Cannot decode image');

    // 3️⃣ Crop face
    final rect = face.boundingBox;
    final left = rect.left.clamp(0, original.width - 1).toInt();
    final top = rect.top.clamp(0, original.height - 1).toInt();
    final width = rect.width.clamp(1, original.width - left).toInt();
    final height = rect.height.clamp(1, original.height - top).toInt();

    final faceCrop = img.copyCrop(
      original,
      x: left,
      y: top,
      width: width,
      height: height,
    );

    // 4️⃣ Resize to model input size
    const inputSize = 112;
    final resized = img.copyResize(faceCrop, width: inputSize, height: inputSize);

    // 5️⃣ Convert to 4D Float32 input [1,112,112,3]
    final input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) => [
            (resized.getPixel(x, y).r - 128) / 128.0,
            (resized.getPixel(x, y).g - 128) / 128.0,
            (resized.getPixel(x, y).b - 128) / 128.0,
          ],
        ),
      ),
    );

    // 6️⃣ Prepare output array
    final output = List.filled(128, 0.0).reshape([1, 128]);

    // 7️⃣ Run interpreter
    _interpreter.run(input, output);

    // 8️⃣ Normalize embedding
    final emb = output[0];
    final norm = sqrt(emb.fold(0.0, (sum, v) => sum + v * v));
    return emb.map((e) => e / norm).toList();
  }

  /// Cosine similarity between two embeddings
  double cosineSimilarity(List<double> a, List<double> b) {
    double dot = 0, na = 0, nb = 0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      na += a[i] * a[i];
      nb += b[i] * b[i];
    }
    return dot / (sqrt(na) * sqrt(nb));
  }
}

/// Extension method to reshape a flat list to 2D
extension ListReshapeExtension<T> on List<T> {
  List<List<T>> reshape(List<int> dims) {
    if (dims.length != 2) throw Exception('Only 2D reshape supported');
    final rows = dims[0];
    final cols = dims[1];
    if (rows * cols != this.length) throw Exception('Invalid reshape dimensions');
    List<List<T>> reshaped = [];
    for (int i = 0; i < rows; i++) {
      reshaped.add(this.sublist(i * cols, (i + 1) * cols));
    }
    return reshaped;
  }
}
