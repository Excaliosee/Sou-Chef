import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:http/http.dart' as http;
import 'package:sou_chef_flutter/models/recipe.dart';

final String baseURL = "http://192.168.1.8:8000";

class RecipeRepository {
    Future<List<Recipe>> fetchRecipes() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("You are not logged in.");
      final url = Uri.parse("$baseURL/api/v1/recipes/");
      final token = await user.getIdToken(true);

      try {
        final response = await http.get(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          }
        );

        if (response.statusCode == 200) {
          return recipeFromJson(response.body);
        }
        else {
          throw Exception(
            "Recipes could not be loaded. Status Code: ${response.statusCode}"
          );
        }
      }
      catch (e) {
        throw Exception("An unknown error has occured: ${e.toString()}");
      }
    }

  Future<List<Recipe>> fetchMyRecipes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("You are not logged in.");

    final token = await user.getIdToken(true);
    final url = Uri.parse("$baseURL/api/v1/recipes/mine/");

    final response = await http.get(
      url,
      headers: {
        "Authorization" : "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return recipeFromJson(response.body);
    }
    else {
      throw Exception("Could not load your recipes: ${response.statusCode}");
    }
  }

  Future<void> createRecipe(Map<String, dynamic> recipeData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("You are not logged in.");

    final url = Uri.parse("$baseURL/api/v1/recipes/");
    final String? token = await user.getIdToken(true);

    if (token == null) {
      throw Exception("Could not retrive authentication token.");
    }

    print("User ID: ${user.uid}");
    print("Token (First 20 chars): ${token.substring(0, 20)}...");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(recipeData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Recipe created successfully.");
      }
      else {
        throw Exception("Could not create a recipe. Status Code: ${response.statusCode}\nBody: ${response.body}");
      }
    }
    catch (e) {
      throw Exception("Error creating Recipe: $e");
    }
  }

  Future<void> deleteRecipe(int id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User is logged out.");

    final token = await user.getIdToken(true);
    final url = Uri.parse("$baseURL/api/v1/recipes/$id/");

    try {
      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception("Failed to delete recipe. Status Code: ${response.statusCode}");
      }
    }
    catch (e) {
      throw Exception("Error deleting recipe: $e");
    }
  }

  Future<void> toggleLike(int id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("You ar elogged out.");

    final token = await user.getIdToken(true);
    final url = Uri.parse("$baseURL/api/v1/recipes/$id/like/");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      }
    );

    if (response.statusCode != 200) {
      throw Exception("Could not like.");
    }
  }

  Future<List<Recipe>> getFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("You ar elogged out.");

    final token = await user.getIdToken(true);
    final url = Uri.parse("$baseURL/api/v1/recipes/favorites/");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      }
    );

    if (response.statusCode == 200) {
      return recipeFromJson(response.body);
    }
    else {
      throw Exception("Could not load your favorites.");
    }
  }
}