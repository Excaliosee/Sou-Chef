import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sou_chef_flutter/bloc/recipe_bloc/recipe_bloc.dart';
import 'package:sou_chef_flutter/bloc/recipe_bloc/blocs.dart';
import 'package:sou_chef_flutter/widgets/recipe_grid_item.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
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
      context.read<FeedBloc>().add(const FetchRecipes());
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
    return BlocBuilder<FeedBloc, RecipeState>(
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
                  onPressed: () => context.read<FeedBloc>().add(const FetchRecipes(isRefreshed: true)),
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
            context.read<FeedBloc>().add(const FetchRecipes(isRefreshed: true));
          },
          child: MasonryGridView.count(
            controller: _scrollController,
            crossAxisCount: 2, 
            padding: const EdgeInsets.all(12),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: state.recipes.length,
            itemBuilder: (context, index) {
              if (index >= state.recipes.length) {
                return const Center(child: CircularProgressIndicator());
              }
              final recipe = state.recipes[index];
              return RecipeGridItem(recipe: recipe);
            }
          )
        );
      }
    );
  }
}