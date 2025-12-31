import 'dart:convert';

List<Recipe> recipeFromJson(String str) =>
    List<Recipe>.from(json.decode(str).map((x) => Recipe.fromJson(x)));

String recipeToJson(List<Recipe> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Recipe {
  final int id;
  final String title;
  final String description;

  final int prepTime;
  final int cookTime;
  final DateTime createdAt;

  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.prepTime,
    required this.cookTime,
    required this.createdAt,
    required this.ingredients,
    required this.steps,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    prepTime: json["prep_time"],
    cookTime: json["cook_time"],
    createdAt: DateTime.parse(json["created_at"]),
    ingredients: List<RecipeIngredient>.from(
      json["ingredients"].map((x) => RecipeIngredient.fromJson(x))),
    steps: List<RecipeStep>.from(
      json["steps"].map((x) => RecipeStep.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "prep_time": prepTime,
    "cook_time": cookTime,
    "created_at": createdAt.toIso8601String(),
    "ingredients": List<dynamic>.from(ingredients.map((x) => x.toJson())),
    "steps": List<dynamic>.from(steps.map((x) => x.toJson())),
  };
}

class RecipeIngredient{
  final String name;
  final String quantity;

  RecipeIngredient({required this.name, required this.quantity});

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) => RecipeIngredient(
    name: json["name"],
    quantity: json["quantity"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "quantity": quantity
  };
}

class RecipeStep{
  final int stepNumber;
  final String instruction;

  RecipeStep({required this.stepNumber, required this.instruction});

  factory RecipeStep.fromJson(Map<String, dynamic> json) => RecipeStep(instruction: json["instruction"], stepNumber: json["step_number"]);

  Map<String, dynamic> toJson() => {
    "step_number": stepNumber,
    "instruction": instruction
  };
}
