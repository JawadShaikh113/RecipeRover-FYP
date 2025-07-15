import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http;

void main() {
  runApp(const RecipeFinderApp());
}

class RecipeFinderApp extends StatelessWidget {
  const RecipeFinderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController();
  String _mealType = "Breakfast";
  List<dynamic> _recipes = [];
  bool _isLoading = false;

  Future<void> fetchRecipes() async {
    final String apiUrl =
        "http://127.0.0.1:5000/recommend"; 

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ingredients": _ingredientsController.text,
          "diet": _mealType,
          "prep_time": int.parse(_prepTimeController.text),
          "course_category": _mealType
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _recipes = json.decode(response.body)['recommendations'];
          _isLoading = false;
        });
      } else {
        print("Failed to fetch recipes: ${response.body}");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipe Finder"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ingredientsController,
              decoration: const InputDecoration(
                labelText: "Ingredients (comma-separated)",
              ),
            ),
            TextField(
              controller: _prepTimeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Preparation Time (minutes)",
              ),
            ),
            DropdownButton<String>(
              value: _mealType,
              items: ["Breakfast", "Lunch", "Dinner", "Snack"]
                  .map((meal) => DropdownMenuItem(
                        value: meal,
                        child: Text(meal),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _mealType = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchRecipes,
              child: const Text("Find Recipes"),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _recipes[index];
                        return Card(
                          child: ListTile(
                            title: Text(recipe["Recipe"]),
                            subtitle: Text(
                              "Matching: ${recipe["Matching Percentage"]}%",
                            ),
                            onTap: () {
                              // Optionally show more details here
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
