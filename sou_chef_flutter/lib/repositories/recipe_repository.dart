import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:http/http.dart' as http;
import 'package:sou_chef_flutter/models/recipe.dart';

final String baseURL = "http://192.168.1.4:8000";

class LikeUpdate {
  final int recipeId;
  final bool isLiked;
  LikeUpdate({required this.recipeId, required this.isLiked});
}

class RecipeRepository {
  final _likeUpdateController = StreamController<LikeUpdate>.broadcast();
  Stream<LikeUpdate> get likeUpdates => _likeUpdateController.stream;

  Future<List<Recipe>> fetchRecipes({required int page, int limit = 20}) async {
    return _fetchHelper("$baseURL/api/v1/recipes/?page=$page&page_size=$limit");
  }

  Future<List<Recipe>> fetchMyRecipes({required int page, int limit = 20}) async {
    return _fetchHelper("$baseURL/api/v1/recipes/mine/?page=$page&page_size=$limit");
  }

  Future<List<Recipe>> getFavorites({required int page, int limit = 20}) async {
    return _fetchHelper("$baseURL/api/v1/recipes/favorites/?page=$page&page_size=$limit");
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

  Future<void> toggleLike(int id, bool currentLikeStatus) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("You ar elogged out.");

    final newStatus = !currentLikeStatus;
    _likeUpdateController.add(LikeUpdate(recipeId: id, isLiked: newStatus));

    final token = await user.getIdToken(true);
    final url = Uri.parse("$baseURL/api/v1/recipes/$id/like/");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        }
      );

      if (response.statusCode != 200) {
        _likeUpdateController.add(LikeUpdate(recipeId: id, isLiked: currentLikeStatus));
        throw Exception("Could not like.");
      }
    }
    catch (e) {
      _likeUpdateController.add(LikeUpdate(recipeId: id, isLiked: currentLikeStatus));
      throw Exception("Error: $e");
    }
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final token = await user.getIdToken(true);
    final url = Uri.parse("$baseURL/api/v1/recipes/?search=$query");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        }
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        List<dynamic> results = [];

        if (data is Map<String, dynamic> && data.containsKey("results")) {
          results = data["results"];
        }
        else if (data is List) {
          results = data;
        }

        return results.map((e) => Recipe.fromJson(e)).toList();
      }
      else {
        return [];
      }
    }
    catch (e) {
      print("There was an error: $e");
      return [];
    }
  }

  Future<List<Recipe>> _fetchHelper(String url) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("You are not logged in.");

    final token = await user.getIdToken(true);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        }
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        List<dynamic> results = [];

        if (data is Map<String, dynamic>) {
          if (data.containsKey("results")) {
            results = data["results"];
          } else {
            return [];
          }
        } else if (data is List) {
          results = data;
        }

        return results.map((e) => Recipe.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load recipes. Code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Unknown error: $e");
    }
  }

  void dispose() {
    _likeUpdateController.close();
  }

}