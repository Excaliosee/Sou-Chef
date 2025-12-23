import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sou_chef_flutter/bloc/recipe_bloc/recipe_bloc.dart';
import 'recipe_detail_screen.dart';

class MyRecipesPage extends StatelessWidget {
  const MyRecipesPage({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("You are not logged in."));
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.grey[200],
            width: double.infinity,
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 40, color: Colors.white,)
                ),

                const SizedBox(height: 10),

                Text(
                  user.email ?? "User",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                Text("User ID: ${user.uid}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  child: const Text("Sign out"),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "My Recipes",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: BlocBuilder<RecipeBloc, RecipeState>(
            builder: (context, state) {
              if (state is RecipeLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is RecipeLoaded) {
                final myRecipes = state.recipes.where((recipe) {
                  return recipe.createdBy == user.uid;
                }).toList();

                if (myRecipes.isEmpty) {
                  return const Center(
                    child: Text("You have no recipes."),
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
            }),
          ),
        ],
      ),
    );
  }
}