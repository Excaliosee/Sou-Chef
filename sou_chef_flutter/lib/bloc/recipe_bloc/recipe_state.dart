part of 'recipe_bloc.dart';

enum RecipeStatus{initial, success, failure}

class RecipeState extends Equatable{
  final RecipeStatus status;
  final List<Recipe> recipes;
  final bool hasReachedMax;
  final int page;
  final String? errorMessage;

  const RecipeState({
    this.status = RecipeStatus.initial,
    this.recipes = const <Recipe>[],
    this.hasReachedMax = false,
    this.page = 1,
    this.errorMessage,
  });

  RecipeState copyWith({
    RecipeStatus? status,
    List<Recipe>? recipes,
    bool? hasReachedMax,
    int? page,
    String? errorMessage,
  }) {
    return RecipeState(
      status: status ?? this.status,
      recipes : recipes ?? this.recipes,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, recipes, hasReachedMax, page, errorMessage];
  
}