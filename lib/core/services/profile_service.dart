import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ProfileService {
  static Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      // Create unique file name
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Get reference to storage location
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child(userId)
          .child(fileName);

      // Upload file
      await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  static Future<void> updateUserProfile({
    required String userId,
    required String displayName,
    String? photoUrl,
  }) async {
    try {
      // Update Auth profile
      await FirebaseAuth.instance.currentUser?.updateProfile(
        displayName: displayName,
        photoURL: photoUrl,
      );

      // Update Firestore document
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'name': displayName,
        if (photoUrl != null) 'profilePicture': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  static Future<void> deleteOldProfilePicture(String userId) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child(userId);
      
      final ListResult result = await storageRef.listAll();
      
      // Delete all old images except the most recent one
      if (result.items.length > 1) {
        final sortedItems = result.items..sort((a, b) => b.name.compareTo(a.name));
        for (var i = 1; i < sortedItems.length; i++) {
          await sortedItems[i].delete();
        }
      }
    } catch (e) {
      print('Error deleting old profile pictures: $e');
    }
  }
}