import 'package:flutter/material.dart';
import 'package:sou_chef_flutter/bloc/recipe_bloc/recipe_bloc.dart';
import 'package:sou_chef_flutter/models/recipe.dart';
import 'package:sou_chef_flutter/screens/recipe_detail_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 16.0),),
                  onTap: () {
                    controller.openView();
                  },
                  onChanged: (_) {
                    controller.openView();
                  },
                  leading: const Icon(Icons.search),
                );
              },
              suggestionsBuilder: (BuildContext context, SearchController controller) {
                final String query = controller.text.toLowerCase();
                final state = context.read<RecipeBloc>().state;

                if (state is RecipeLoaded) {
                  final List<Recipe> matches = state.recipes.where((recipe) {
                    return recipe.title.toLowerCase().contains(query);
                  }).toList();

                  if (matches.isEmpty) {
                    return [
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(child: Text("No yunmy recipes found.")),
                      ),
                    ];
                  }

                  return matches.map((recipe) {
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(recipe.title),
                        subtitle: Text(
                          'Cook Time: ${recipe.cookTime} mins | Prep Time: ${recipe.prepTime} mins',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          controller.closeView(recipe.title); 

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailScreen(recipe: recipe),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList();
                }

                return [const Center(child: CircularProgressIndicator())];
              },
            )
          ),

          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.manage_search, size: 64, color: Colors.grey,),
                  SizedBox(height: 10),
                  Text("Find your favorite recipes", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}