import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../errors/failures.dart';

class ImageUploadService {
  final FirebaseStorage _storage;
  final ImagePicker _picker;

  ImageUploadService({
    FirebaseStorage? storage,
    ImagePicker? picker,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _picker = picker ?? ImagePicker();

  /// Pick an image from the gallery or camera
  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  /// Upload a file to Firebase Storage and return the download URL
  Future<Either<Failure, String>> uploadMealImage(File file) async {
    try {
      final ext = file.path.split('.').last;
      final fileName = '${const Uuid().v4()}.$ext';
      final ref = _storage.ref().child('meal_images/$fileName');
      final task = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/$ext'),
      );
      final url = await task.ref.getDownloadURL();
      return Right(url);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Upload failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Upload a restaurant logo
  Future<Either<Failure, String>> uploadRestaurantLogo(File file) async {
    try {
      final ext = file.path.split('.').last;
      final fileName = '${const Uuid().v4()}.$ext';
      final ref = _storage.ref().child('restaurant_logos/$fileName');
      final task = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/$ext'),
      );
      final url = await task.ref.getDownloadURL();
      return Right(url);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Upload failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

final imageUploadServiceProvider = Provider<ImageUploadService>(
  (_) => ImageUploadService(),
);
