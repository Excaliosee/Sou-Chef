import 'package:equatable/equatable.dart';
import 'package:sou_chef_flutter/models/recipe.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sou_chef_flutter/repositories/recipe_repository.dart';

part 'recipe_event.dart';
part 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent,RecipeState>{
  final RecipeRepository _recipeRepository;

  RecipeBloc(this._recipeRepository) : super(RecipeInitial()) {
    on<FetchRecipes>(_onFetchRecipes);
    on<FetchMyRecipes>(_onFetchMyRecipes);
    on<DeleteRecipe>(_deleteRecipe);
    on<ToggleLike>(_toggleLike);
    on<FetchFavorites>(_fetchFavorites);
  }

  Future<void> _onFetchRecipes(
    FetchRecipes event,
    Emitter<RecipeState> emit,
  ) async {
    emit(RecipeLoading());
    try{
      final recipes = await _recipeRepository.fetchRecipes();
      emit(RecipeLoaded(recipes));
    }
    catch(e) {
      emit(RecipeError("Failed to fetch recipes: ${e.toString()}"));
    }
  }

  Future<void> _onFetchMyRecipes(
    FetchMyRecipes event,
    Emitter<RecipeState> emit,
  ) async {
    emit(RecipeLoading());
    try {
      final recipes = await _recipeRepository.fetchMyRecipes();
      emit(RecipeLoaded(recipes));
    }
    catch(e) {
      emit(RecipeError("Failed to fetch your recipes: ${e.toString()}"));
    }
  }

  Future<void> _deleteRecipe(
    DeleteRecipe event,
    Emitter<RecipeState> emit,
  ) async {
    try {
      await _recipeRepository.deleteRecipe(event.recipeId);
      add(FetchMyRecipes());
    }
    catch(e) {
      emit(RecipeError("Could not delete recipe: ${e.toString()}"));
    }
  }

  Future<void> _toggleLike(
    ToggleLike event,
    Emitter<RecipeState> emit,
  ) async {
    if (state is RecipeLoaded) {
      final current = state as RecipeLoaded;
      final updatedRecipe = current.recipes.map((recipe) {
        if (recipe.id == event.recipeId) {
          final isNowLiked = !recipe.isLiked;
          return Recipe(
            id: recipe.id,
            title: recipe.title,
            description: recipe.description,
            prepTime: recipe.prepTime,
            cookTime: recipe.cookTime,
            createdAt: recipe.createdAt,
            ingredients: recipe.ingredients,
            steps: recipe.steps,
            createdBy: recipe.createdBy,
            isLiked: isNowLiked,
            likesCount: isNowLiked ? recipe.likesCount + 1 : recipe.likesCount - 1,
          );
        }
        return recipe;
      }).toList();

      emit(RecipeLoaded(updatedRecipe));

      try {
        await _recipeRepository.toggleLike(event.recipeId);
      }
      catch(e) {
        print("Error liking recipe: $e");
        add(FetchRecipes());
      }
    }
    else {
      add(FetchRecipes());
    }

    
  }

  Future<void> _fetchFavorites(
    FetchFavorites event,
    Emitter<RecipeState> emit,
  ) async {
    emit(RecipeLoading());
    try {
      final recipes = await _recipeRepository.getFavorites();
      emit(RecipeLoaded(recipes));
    }
    catch(e) {
      emit(RecipeError("Failed to fetch your recipes: ${e.toString()}"));
    }
  }
}
