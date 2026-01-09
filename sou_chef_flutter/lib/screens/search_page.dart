import 'package:flutter/material.dart';
import 'package:sou_chef_flutter/models/recipe.dart';
import 'package:sou_chef_flutter/repositories/recipe_repository.dart';
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
              suggestionsBuilder: (BuildContext context, SearchController controller) async {
                final String query = controller.text.toLowerCase();
                if (query.length < 3) {
                  return [
                    const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("Please type three letters atleast."))),    
                  ];
                }
              

                try {
                  final List<Recipe> recipes = await context.read<RecipeRepository>().searchRecipes(query);
                  if (recipes.isEmpty) {
                    return [
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: Text("No recipes found.")),
                      )
                    ];
                  }

                  return recipes.map((recipe) {
                    return ListTile(
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
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),

                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)));
                      },
                    );
                  }).toList();
                }
                catch (e) {
                  return [Center(child: Text("Error searching: $e"))];
                }
              }
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