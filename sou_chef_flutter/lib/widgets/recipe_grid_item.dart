import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sou_chef_flutter/bloc/recipe_bloc/blocs.dart';
import 'package:sou_chef_flutter/bloc/recipe_bloc/recipe_bloc.dart';
import 'package:sou_chef_flutter/models/recipe.dart';
import 'package:sou_chef_flutter/screens/recipe_detail_screen.dart';

class RecipeGridItem extends StatelessWidget {
  final Recipe recipe;
  const RecipeGridItem({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: recipe.image != null
                ? CachedNetworkImage(
                  imageUrl: recipe.image!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.image, color: Colors.grey)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 100,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                )
                : Container(
                  height: 120,
                  color: Colors.orange.shade100,
                  child: Center(
                    child: Icon(Icons.restaurant_menu, size: 40, color: Colors.orange.shade300),
                  ),
                )
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            "${recipe.cookTime + recipe.prepTime}m",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.read<FeedBloc>().add(ToggleLike(recipe.id));
                            },
                            child: Icon(
                              recipe.isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: recipe.isLiked ? Colors.red : null,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${recipe.likesCount}",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}