import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sou_chef_flutter/bloc/recipe_bloc/recipe_bloc.dart';
import 'package:sou_chef_flutter/repositories/recipe_repository.dart';
import 'package:sou_chef_flutter/screens/recipe_detail_screen.dart';

class LikesPage extends StatelessWidget {
  const LikesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecipeBloc(RecipeRepository())..add(FetchFavorites()),
      child: BlocBuilder<RecipeBloc, RecipeState>(
        builder: (context, state) {
          if (state is RecipeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RecipeLoaded) {
            if (state.recipes.isEmpty) {
              return const Center(
                child: Text('No liked recipes. Like some.'),
              );
            }
            return ListView.builder(
              itemCount: state.recipes.length,
              itemBuilder: (context, index) {
                final recipe = state.recipes[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(recipe.title),
                    subtitle: Text(
                      'Cook Time: ${recipe.cookTime} mins | Prep Time: ${recipe.prepTime} mins'
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                            RecipeDetailScreen(recipe: recipe),
                        ),
                      );
                    },
                  ),
                );
              }
            );
          }
      
          if (state is RecipeError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
            return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}