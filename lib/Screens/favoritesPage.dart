import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Recipe {
  final String title;
  final List<String> ingredients;
  final String instructions;

  Recipe({
    required this.title,
    required this.ingredients,
    required this.instructions,
  });
}

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailPage({required this.recipe, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        backgroundColor: const Color(0xFF6F35A5),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF3E5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingredients',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6F35A5),
              ),
            ),
            const SizedBox(height: 8),
            ...recipe.ingredients
                .map((ingredient) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        '- $ingredient',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ))
                .toList(),
            const SizedBox(height: 24),
            const Text(
              'Instructions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6F35A5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              recipe.instructions,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user == null) {
      return const Center(child: Text('Please log in to view your favorites.'));
    }

    print('Current User UID: ${user.uid}'); // Debug: Print current user UID

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Recipes'),
        backgroundColor: const Color(0xFF6F35A5),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E5F5), Color(0xFF6F35A5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder(
          stream: _firestore
              .collection('favorites')
              .where('uid', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Debug: Print the number of documents
            print('Snapshot data count: ${snapshot.data?.docs.length}');

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No favorite recipes yet.'));
            }

            final favorites = snapshot.data!.docs.map((doc) {
              return Recipe(
                title: doc['title'],
                ingredients: List<String>.from(doc['ingredients']),
                instructions: doc['instructions'],
              );
            }).toList();

            return ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final recipe = favorites[index];
                return Card(
                  color: Colors.white,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side:
                        const BorderSide(color: Color(0xFF6F35A5), width: 1.5),
                  ),
                  elevation: 5,
                  child: ListTile(
                    title: Text(
                      recipe.title,
                      style: const TextStyle(
                        color: Color(0xFF6F35A5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetailPage(recipe: recipe),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
