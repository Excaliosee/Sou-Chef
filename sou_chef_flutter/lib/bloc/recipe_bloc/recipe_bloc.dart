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
}
