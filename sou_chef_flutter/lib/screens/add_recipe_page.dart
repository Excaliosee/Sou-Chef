import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sou_chef_flutter/bloc/recipe_bloc/recipe_bloc.dart';
import 'package:sou_chef_flutter/repositories/recipe_repository.dart';
import 'package:sou_chef_flutter/widgets/my_button.dart';

class _IngredientRow{
  final TextEditingController name = TextEditingController();
  final TextEditingController quantity = TextEditingController();
}

class _StepRow{
  final TextEditingController instruction = TextEditingController();
}

class AddRecipe extends StatefulWidget {
  const AddRecipe({super.key});

  @override
  State<AddRecipe> createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final List<_IngredientRow> _ingredientRows = [];
  final List<_StepRow> _stepRows = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _addIngredient();
    _addStep();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    for (var row in _ingredientRows) {
      row.name.dispose();
      row.quantity.dispose();
    }
    for (var row in _stepRows) {
      row.instruction.dispose();
    }
    super.dispose();
  }

  void _addIngredient() {
    setState(() {
      _ingredientRows.add(_IngredientRow());
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredientRows[index].name.dispose();
      _ingredientRows[index].quantity.dispose();
      _ingredientRows.removeAt(index);
    });
  }

  void _addStep() {
    setState(() {
      _stepRows.add(_StepRow());
    });
  }

  void _removeStep(int index) {
    setState(() {
      _stepRows[index].instruction.dispose();
      _stepRows.removeAt(index);
    });
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

        final ingredientsList = _ingredientRows.map((row) {
          return {
            "name": row.name.text,
            "quantity": row.quantity.text,
          };
        }).toList();

        final stepsList = _stepRows.asMap().entries.map((entry) {
          int index = entry.key;
          _StepRow row = entry.value;
          return {
            "step_number": index + 1,
            "instruction": row.instruction.text,
          };
        }).toList();

        final recipeData = {
          "title": _titleController.text,
          "description": _descriptionController.text,
          "prep_time": int.parse(_prepTimeController.text),
          "cook_time": int.parse(_cookTimeController.text),
          "created_by": user.uid,
          "ingredients": ingredientsList,
          "steps": stepsList,
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
            return "Required";
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(controller: _titleController, hint: "Title"),
              _buildTextField(controller: _descriptionController, hint: "Description"),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _prepTimeController,
                      hint: "Prep (mins)",
                      keyboardType: TextInputType.number, 
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _buildTextField(
                      controller: _cookTimeController,
                      hint: "Cook Time",
                      keyboardType: TextInputType.number,    
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Ingredients", style: Theme.of(context).textTheme.titleMedium),
                  IconButton(onPressed: _addIngredient, icon: const Icon(Icons.add, color: Colors.green)
                  ),
                ],
              ),

              ..._ingredientRows.asMap().entries.map((entry) {
                int index = entry.key;
                _IngredientRow row = entry.value;
                return Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: _buildTextField(controller: row.quantity, hint: "Qty"),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTextField(controller: row.name, hint: "Ingredient Name")),

                    IconButton(onPressed: () => _removeIngredient(index), icon: const Icon(Icons.delete, color: Colors.redAccent)),

                  ],
                );
              }),

              const Divider(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Instructions", style: Theme.of(context).textTheme.titleMedium),
                  IconButton(onPressed: _addStep, icon: const Icon(Icons.add, color: Colors.green)),
                ],
              ),

              ..._stepRows.asMap().entries.map((entry) {
                int index = entry.key;
                _StepRow row = entry.value;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, right: 8.0),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.orange.shade100,
                        child: Text("${index + 1}", style: const TextStyle(fontSize: 12)),
                      ),
                    ),

                    Expanded(
                      child: _buildTextField(controller: row.instruction, hint: "Describe step ${index + 1}", maxLines: 2),
                    ),

                    IconButton(onPressed: () => _removeStep(index), icon: const Icon(Icons.delete, color: Colors.redAccent)),
                  ],
                );
              }),

              const SizedBox(height: 20),
              _isSubmitting ? const CircularProgressIndicator() : MyButton(onTap: _submitRecipe, text: "Submit"),
            ],
          ),
        ),
      ),
    );
  }
}