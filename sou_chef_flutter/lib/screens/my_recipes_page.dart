import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sou_chef_flutter/bloc/recipe_bloc/recipe_bloc.dart';
import 'package:sou_chef_flutter/screens/recipe_detail_screen.dart';
import 'package:sou_chef_flutter/bloc/recipe_bloc/blocs.dart';

class MyRecipesPage extends StatefulWidget {
  const MyRecipesPage({super.key});

  @override
  State<MyRecipesPage> createState() => _MyRecipesPageState();
}

class _MyRecipesPageState extends State<MyRecipesPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<MyRecipesBloc>().add(const FetchRecipes());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyRecipesBloc, RecipeState>(
      builder: (context, state) {
        if (state.status == RecipeStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == RecipeStatus.failure && state.recipes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Failed."),
                ElevatedButton(
                  onPressed: () => context.read<MyRecipesBloc>().add(const FetchRecipes(isRefreshed: true)),
                  child: const Text("Retry"),
                )
              ],
            ),
          );
        }

        if (state.status == RecipeStatus.success && state.recipes.isEmpty) {
          return const Center(child: Text("No recipes found"));
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<MyRecipesBloc>().add(const FetchRecipes(isRefreshed: true));
          },
          child: ListView.builder(
            controller: _scrollController,
            itemCount: state.hasReachedMax ? state.recipes.length : state.recipes.length + 1,
            itemBuilder: (context, index) {
              if (index >= state.recipes.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2)
                    ),
                  )
                );
              }

              final recipe = state.recipes[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${recipe.prepTime}m prep', style: const TextStyle(fontSize: 12)),
                      
                        const SizedBox(width: 12),
                        
                        const Icon(Icons.soup_kitchen, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${recipe.cookTime}m cook', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          context.read<MyRecipesBloc>().add(ToggleLike(recipe.id));
                        },
                        child: Icon(
                          recipe.isLiked ? Icons.favorite : Icons.favorite_border, color: recipe.isLiked ? Colors.red : null,
                        ),
                      ),
                      Text("${recipe.likesCount}", style: const TextStyle(fontSize: 10, color: Colors.grey))
                    ],
                  ),

                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)));
                  },
                ),
              );
            }
          ), 
        );
      }
    );
  }
}