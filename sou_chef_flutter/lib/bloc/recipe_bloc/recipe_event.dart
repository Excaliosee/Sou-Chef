part of 'recipe_bloc.dart';

abstract class RecipeEvent extends Equatable{
  const RecipeEvent();

  @override
  List<Object> get props => [];
}

class FetchRecipes extends RecipeEvent{}

class FetchMyRecipes extends RecipeEvent{}

class DeleteRecipe extends RecipeEvent{
  final int recipeId;
  const DeleteRecipe(this.recipeId);
}

class ToggleLike extends RecipeEvent{
  final int recipeId;
  const ToggleLike(this .recipeId);
}

class FetchFavorites extends RecipeEvent{}