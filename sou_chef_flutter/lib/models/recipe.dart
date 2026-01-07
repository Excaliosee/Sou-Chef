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

  final int likesCount;
  final bool isLiked;
  final String createdBy;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.prepTime,
    required this.cookTime,
    required this.createdAt,
    required this.ingredients,
    required this.steps,
    this.isLiked = false,
    this.likesCount = 0,
    required this.createdBy,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
  // --- 🕵️ DETECTIVE BLOCK START ---
  // This helps us catch the "2 Likes" bug. 
  // Watch your Debug Console for these logs when you reload the page!
  if (json["likes_count"] != null && json["likes_count"] > 0) {
    print("🔍 RECIPE ID [${json['id']}]: Server sent Likes=${json['likes_count']} | is_liked=${json['is_liked']} (${json['is_liked'].runtimeType})");
  }
  // --- DETECTIVE BLOCK END ---

  // Helper to safely parse the creator, handling both Maps and Strings
  String parseCreator(dynamic createdByField) {
    if (createdByField is Map) {
      return createdByField["username"] ?? "Unknown";
    }
    return (createdByField ?? "Unknown").toString();
  }

  return Recipe(
    id: json["id"],
    title: json["title"] ?? "Untitled Recipe", // Safety default
    description: json["description"] ?? "",
    prepTime: json["prep_time"] ?? 0,
    cookTime: json["cook_time"] ?? 0,
    
    // Safety: tryParse prevents app crash if date string is malformed
    createdAt: DateTime.tryParse(json["created_at"].toString()) ?? DateTime.now(),
    
    likesCount: json["likes_count"] ?? 0,
    
    // logic: Handles boolean true, integer 1, or string "true"
    isLiked: json["is_liked"] == true || json["is_liked"] == 1 || json["is_liked"].toString() == 'true',

    // Safety: Handles null lists gracefully
    ingredients: json["ingredients"] != null 
        ? List<RecipeIngredient>.from(json["ingredients"].map((x) => RecipeIngredient.fromJson(x)))
        : [],
        
    steps: json["steps"] != null 
        ? List<RecipeStep>.from(json["steps"].map((x) => RecipeStep.fromJson(x)))
        : [],
        
    createdBy: parseCreator(json["created_by"]),
  );
}

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "prep_time": prepTime,
    "cook_time": cookTime,
    "created_at": createdAt.toIso8601String(),
    "likes_count": likesCount,
    "is_liked": isLiked,
    "created_by": createdBy,
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
