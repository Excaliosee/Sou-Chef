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
}