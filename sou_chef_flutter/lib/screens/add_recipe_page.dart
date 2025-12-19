import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sou_chef_flutter/bloc/recipe_bloc/recipe_bloc.dart';
import 'package:sou_chef_flutter/repositories/recipe_repository.dart';
import 'package:sou_chef_flutter/widgets/my_button.dart';

class AddRecipe extends StatefulWidget {
  const AddRecipe({super.key});

  @override
  State<AddRecipe> createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    super.dispose();
  }

  Future<void> _submitRecipe() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception("Not legged in.");
        }

        final recipeData = {
          "title": _titleController.text,
          "description": _descriptionController.text,
          "ingredients": _ingredientsController.text,
          "instructions": _instructionsController.text,
          "prep_time": int.parse(_prepTimeController.text),
          "cook_time": int.parse(_cookTimeController.text),
          "created_by": user.uid,
        };

        final repository = RepositoryProvider.of<RecipeRepository>(context);
        await repository.createRecipe(recipeData);

        if (mounted) {
          context.read<RecipeBloc>().add(FetchRecipes());
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Recipe Created Successfully.")),
          );
        }
      }
      catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to create a recipe: $e")),
          );
        }
      }
      finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) {
            return "Please enter $hint";
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Recipe.")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(controller: _titleController, hint: "Title"),
              _buildTextField(controller: _descriptionController, hint: "Description"),
              _buildTextField(controller: _ingredientsController, hint: "Ingredients", maxLines: 5),
              _buildTextField(controller: _instructionsController, hint: "Instructions", maxLines: 5),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _prepTimeController,
                      hint: "Prep Time",
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Required value";
                        if (int.tryParse(value) == null) return "Invalid Value";
                        return null;
                      },     
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _buildTextField(
                      controller: _cookTimeController,
                      hint: "Cook Time",
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Required value";
                        if (int.tryParse(value) == null) return "Invalid Value";
                        return null;
                      },     
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _isSubmitting ? const CircularProgressIndicator() : MyButton(onTap: _submitRecipe, text: "Submit"),
            ],
          ),
        ),
      ),
    );
  }
}