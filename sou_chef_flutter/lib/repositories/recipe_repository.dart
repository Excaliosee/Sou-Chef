import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sou_chef_flutter/models/recipe.dart';

class RecipeRepository {
  Future<List<Recipe>> fetchRecipes() async {
    final url = Uri.parse("http://10.0.2.2:8000/api/v1/recipes/");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return recipeFromJson(response.body);
      }
      else {
        throw Exception(
          'Failed to load recipes. Status Code: ${response.statusCode}'
        );
      }
    }
    catch (e) {
      throw Exception('An unknown error occured: ${e.toString()}');
    }
  }

  Future<void> createRecipe(Map<String, dynamic> recipeData) async {
    final url = Uri.parse("http://10.0.2.2:8000/api/v1/recipes/");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(recipeData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Recipe created successfully.");
      }
      else {
        throw Exception("Failed to create a recipe. Status Code: ${response.statusCode}\nBody: ${response.body}");
      }
    }
    catch (e) {
      throw Exception("Error creating Recipe: $e");
    }
  }

  Future<void> deleteRecipe(int id) async {
    final url = Uri.parse("http://10.0.2.2:8000/api/v1/recipes/$id/");

    try {
      final response = await http.delete(url);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception("Failed to delete recipe. Please try again, Status Code: ${response.statusCode}");
      }
    }
    catch (e) {
      throw Exception("Error deleting recipe: $e");
    }
  }
}