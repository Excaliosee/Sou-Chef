part of 'recipe_bloc.dart';

abstract class RecipeEvent extends Equatable{
  const RecipeEvent();

  @override
  List<Object> get props => [];
}

class FetchRecipes extends RecipeEvent{
  final bool isRefreshed;
  const FetchRecipes({this.isRefreshed = false});

  @override
  List<Object> get props => [isRefreshed];
}

class DeleteRecipe extends RecipeEvent{
  final int recipeId;
  const DeleteRecipe(this.recipeId);
}

class ToggleLike extends RecipeEvent{
  final int recipeId;
  const ToggleLike(this .recipeId);
}

class ExternalLikeUpdate extends RecipeEvent {
  final int recipeId;
  final bool isLiked;
  const ExternalLikeUpdate(this.recipeId, this.isLiked);

  @override
  List<Object> get props => [recipeId, isLiked];
}
