import 'recipe_bloc.dart';

class FeedBloc extends RecipeBloc {
  FeedBloc({required super.recipeRepository, required super.fetchMethod});
}

class MyRecipesBloc extends RecipeBloc {
  MyRecipesBloc({required super.recipeRepository, required super.fetchMethod});
}

class FavoriteBloc extends RecipeBloc {
  FavoriteBloc({required super.recipeRepository, required super.fetchMethod});
}