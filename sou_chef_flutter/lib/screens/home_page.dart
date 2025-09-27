import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:sou_chef_flutter/models/recipe.dart';
import 'package:sou_chef_flutter/screens/recipe_detial_screen.dart';
import 'package:sou_chef_flutter/widgets/my_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Recipe> _recipes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/v1/recipes/');

    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List<Recipe> loadedRecipe = recipeFromJson(response.body);
        if (mounted) {
          setState(() {
            _recipes = loadedRecipe;
            _isLoading = false;
          });
        }
      }

      else {
        if (mounted) {
          setState(() {
            _errorMessage = "Failed to load recipes. Status Code: ${response.statusCode}";
            _isLoading = false;
          });
        }
      }
    }
    catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to connect to the server. Please check the connection.";
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sou-Chef'),
      ),
      drawer: MyDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } 
    
    else if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } 
    
    else if (_recipes.isEmpty) {
      return const Center(
          child: Text('No recipes found.'));
    } 
    
    else {
      return ListView.builder(
        itemCount: _recipes.length,
        itemBuilder: (context, index) {
          final recipe = _recipes[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(recipe.title),
              subtitle: Text(
                'Cook Time: ${recipe.cookTime} mins | Prep Time: ${recipe.prepTime} mins',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: 
                    (context) => RecipeDetialScreen(recipe: recipe),
                  )
                );
              },
            ),
          );
        },
      );
    }
  }
}