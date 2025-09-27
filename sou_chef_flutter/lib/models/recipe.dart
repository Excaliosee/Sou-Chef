import 'dart:convert';

List<Recipe> recipeFromJson(String str) =>
    List<Recipe>.from(json.decode(str).map((x) => Recipe.fromJson(x)));

String recipeToJson(List<Recipe> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Recipe {
  final int id;
  final String title;
  final String description;
  final String ingredients;
  final String instructions;
  final int prepTime;
  final int cookTime;
  final String createdBy;
  final DateTime createdAt;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.prepTime,
    required this.cookTime,
    required this.createdBy,
    required this.createdAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    ingredients: json["ingredients"],
    instructions: json["instructions"],
    prepTime: json["prep_time"],
    cookTime: json["cook_time"],
    createdBy: json["created_by"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "ingredients": ingredients,
    "instructions": instructions,
    "prep_time": prepTime,
    "cook_time": cookTime,
    "created_by": createdBy,
    "created_at": createdAt.toIso8601String(),
  };
}
