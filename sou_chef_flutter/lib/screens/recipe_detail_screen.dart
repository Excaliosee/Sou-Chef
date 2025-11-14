import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sou_chef_flutter/bloc/timer_bloc/timer_bloc.dart';
import 'package:sou_chef_flutter/models/recipe.dart';
import 'package:sou_chef_flutter/widgets/my_timer.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final TimerBloc _timerBloc = TimerBloc();
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void dispose() {
    _timerBloc.close();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _timerBloc,
      child: BlocListener<TimerBloc, TimerState>(
        listener: (context, state) {
          if (state is TimerFinished) {
            _speak("Timer Finished");
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.recipe.title),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                MyTimer(initialDuration: widget.recipe.prepTime * 60),
                const Divider(height: 32, thickness: 1),
                
                Text(
                  "Description",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
        
                SizedBox(height: 8),
        
                Text(
                  widget.recipe.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
        
                const Divider(height: 32, thickness: 1),
        
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _looker("Prep Time", "${widget.recipe.prepTime} mins"),
                    _looker("Cook Time", "${widget.recipe.cookTime} mins"),
                  ],
                ),
        
                const Divider(height: 32, thickness: 1),
        
                Text(
                  'Ingredients',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                
                const SizedBox(height: 8),
        
                Text(
                  widget.recipe.ingredients.replaceAll('\\n', '\n'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
        
                const Divider(height: 32, thickness: 1),
        
                Text(
                  "Instructions",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
        
                const SizedBox(height: 8),
        
                Text(
                  widget.recipe.instructions.replaceAll("\n\n", "\n"),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
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