import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:sou_chef_flutter/bloc/recipe_bloc/blocs.dart';
import 'package:sou_chef_flutter/models/recipe.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sou_chef_flutter/repositories/recipe_repository.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

part 'recipe_event.dart';
part 'recipe_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

typedef RecipeFetcher = Future<List<Recipe>> Function({required int page, int limit});

class RecipeBloc extends Bloc<RecipeEvent,RecipeState>{
  final RecipeRepository recipeRepository;
  final RecipeFetcher fetchMethod;

  StreamSubscription? _likeSubscription;

  RecipeBloc({required this.recipeRepository, required this.fetchMethod}) : super(const RecipeState()) {
    on<FetchRecipes>(_onFetchRecipes, transformer: throttleDroppable(throttleDuration));
    on<ToggleLike>(_toggleLike, transformer: throttleDroppable(const Duration(milliseconds: 300)));
    on<ExternalLikeUpdate>(_onExternalLikeUpdate);
    on<DeleteRecipe>(_deleteRecipe);

    _likeSubscription = recipeRepository.likeUpdates.listen((update) {
      add(ExternalLikeUpdate(update.recipeId, update.isLiked));
    });
  }

  @override
  Future<void> close() {
    _likeSubscription?.cancel();
    return super.close();
  }

  Future<void> _onExternalLikeUpdate(
    ExternalLikeUpdate event, 
    Emitter<RecipeState> emit
  ) async {
    if (this is FavoriteBloc && event.isLiked == false) {
      final updatedRecipes = List.of(state.recipes)..removeWhere((r) => r.id == event.recipeId);
      return emit(state.copyWith(recipes: updatedRecipes));
    }
    final updatedRecipes = state.recipes.map((recipe) {
      if (recipe.id == event.recipeId) {

        if (recipe.isLiked == event.isLiked) return recipe;

        int newCount = event.isLiked ? recipe.likesCount + 1 : (recipe.likesCount > 0 ? recipe.likesCount - 1 : 0);

        return recipe.copyWith(
          isLiked: event.isLiked,
          likesCount: newCount,
        );
      }
      return recipe;
    }).toList();

    emit(state.copyWith(recipes: updatedRecipes));
  }

  Future<void> _onFetchRecipes(
    FetchRecipes event,
    Emitter<RecipeState> emit,
  ) async {
    if (state.hasReachedMax && !event.isRefreshed) return;

    try {
      if (state.status == RecipeStatus.initial || event.isRefreshed) {
        final recipes = await fetchMethod(page: 1, limit: 20);
        return emit(state.copyWith(
          status: RecipeStatus.success,
          recipes: recipes,
          hasReachedMax: recipes.length < 20,
          page: 2,
        ));
      }

      final recipes = await fetchMethod(page: state.page, limit: 20);

      emit(recipes.isEmpty ? state.copyWith(hasReachedMax: true) : state.copyWith(
        status: RecipeStatus.success,
        recipes: List.of(state.recipes)..addAll(recipes),
        hasReachedMax: recipes.length < 20,
        page: state.page + 1,
      ));
    }
    catch (e) {
      emit(state.copyWith(status: RecipeStatus.failure));
    }
  }

  Future<void> _deleteRecipe(
    DeleteRecipe event,
    Emitter<RecipeState> emit,
  ) async {
    final updatedRecipes = List.of(state.recipes)..removeWhere((r) => r.id == event.recipeId);
    emit(state.copyWith(recipes: updatedRecipes));

    try {
      await recipeRepository.deleteRecipe(event.recipeId);
    }
    catch (e) {
      add(const FetchRecipes(isRefreshed: true));
    }
  }

  Future<void> _toggleLike(
    ToggleLike event,
    Emitter<RecipeState> emit,
  ) async {
    bool currentStatus = false;
    try {
      final r = state.recipes.firstWhere((r) => r.id == event.recipeId);
      currentStatus = r.isLiked;
    }
    catch (_) {
      if (this is FavoriteBloc) currentStatus = true;
    }

    await recipeRepository.toggleLike(event.recipeId, currentStatus);
  }
}
