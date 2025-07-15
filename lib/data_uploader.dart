import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' as rootBundle;

class DataUploader {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> uploadData() async {
    // Check if any data exists in the 'Recipes' collection
    QuerySnapshot existingData = await firestore.collection('Recipes').get();

    // Only upload data if the collection is empty
    if (existingData.docs.isEmpty) {
      // Load JSON data from assets
      final String jsonString =
          await rootBundle.rootBundle.loadString('assets/recipeRover.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);

      // Upload each item to Firestore
      for (var item in jsonData) {
        Map<String, dynamic> data = Map<String, dynamic>.from(item);
        await firestore.collection('Recipes').add(data);
      }

      print("Data uploaded successfully!");
    } else {
      print("Data already exists in Firestore. No upload necessary.");
    }
  }
}
