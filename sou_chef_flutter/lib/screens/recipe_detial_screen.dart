import 'package:flutter/material.dart';
import 'package:sou_chef_flutter/models/recipe.dart';

class RecipeDetialScreen extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetialScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Description",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 8),

            Text(
              recipe.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const Divider(height: 32, thickness: 1),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _looker("Prep Time", "${recipe.prepTime} mins"),
                _looker("Cook Time", "${recipe.cookTime} mins"),
              ],
            ),

            const Divider(height: 32, thickness: 1),

            Text(
              'Ingredients',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 8),

            Text(
              recipe.ingredients.replaceAll('\\n', '\n'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),

            const Divider(height: 32, thickness: 1),

            Text(
              "Instructions",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              recipe.instructions.replaceAll("\n\n", "\n"),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _looker(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}