import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sou_chef_flutter/bloc/timer_bloc/timer_bloc.dart';
import 'package:sou_chef_flutter/models/recipe.dart';
import 'package:sou_chef_flutter/repositories/recipe_repository.dart';
import 'package:sou_chef_flutter/widgets/my_timer.dart';
import 'package:sou_chef_flutter/services/voice_recording_service.dart';
import 'dart:async';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final TimerBloc _timerBloc = TimerBloc();
  final FlutterTts _flutterTts = FlutterTts();
  final VoiceRecordingService _recordingService = VoiceRecordingService();
  // final GlobalKey _instructionsKey = GlobalKey();

  // bool _isRecording = false;
  // bool _isProcessing = false;

  late bool _isLiked;
  late int _likesCount;
  StreamSubscription? _likeSubscription;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.recipe.isLiked;
    _likesCount = widget.recipe.likesCount;
    final repo = context.read<RecipeRepository>();
    _likeSubscription = repo.likeUpdates.listen((update) {
      if (update.recipeId == widget.recipe.id) {
        if (!mounted) return;
        setState(() {
          if (_isLiked == update.isLiked) return;
          _isLiked = update.isLiked;
          _likesCount = _isLiked ? _likesCount + 1 : (_likesCount > 0 ? _likesCount - 1 : 0);
        });
      }
    });
  }

  @override
  void dispose() {
    _timerBloc.close();
    _flutterTts.stop();
    _recordingService.dispose();
    _likeSubscription?.cancel();
    super.dispose();
  }

  void _onToggleLike() {
    context.read<RecipeRepository>().toggleLike(widget.recipe.id, _isLiked);
  }


  Future<void> _speak(String text) async {
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.speak(text);
  }

  // void _handleVoiceCommand() async {
  //   if (_isRecording) {
  //     setState(() {
  //       _isRecording = false;
  //     });
  //     setState(() {
  //       _isProcessing = true;
  //     });

  //     final filePath = await _recordingService.stopRecording();
  //     if (filePath == null) {
  //       _isProcessing = false;
  //       _speak("An error has occured. Please try again.");
  //       return;
  //     }

  //     final transcribedText = await _recordingService.uploadAudio(filePath);

  //     setState(() {
  //       _isProcessing = false;
  //     });

  //     if (transcribedText != null && transcribedText.isNotEmpty) {
  //       print("User said $transcribedText");
  //       _handleCommand(transcribedText);
  //     }
  //     else {
  //       _speak("Sorry. I couldn't understand that.");
  //     }
  //   }
  //   else {
  //     bool hasPermission = await _recordingService.requestMicrophonePermission();
  //     if (!hasPermission) {
  //       _speak("Please enable proper permissions for voice commandss.");
  //       return;
  //     }

  //     setState(() {
  //       _isRecording = true;
  //     });
  //     await _recordingService.startRecording();
  //   }
  // }

  // void _handleCommand(String text) {
  //   text = text.toLowerCase();
  //   print("Text: $text");

  //   if (text.contains("timer") && (text.contains("start") || text.contains("set"))) {
  //     final RegExp numberRegex = RegExp(r"\d+");
  //     final match = numberRegex.firstMatch(text);

  //     if (match != null) {
  //       final int minutes = int.parse(match.group(0)!);
  //       _timerBloc.add(StartTimer(minutes * 60));
  //       _speak("Timer set for $minutes minutes");
  //     }
  //     else {
  //       _speak("The duration of the timer could not be heard.");
  //     }
  //   }
  //   else if (text.contains("stop") || text.contains("pause")) {
  //     _timerBloc.add(PauseTimer());
  //     _speak("Timer has been paused.");
  //   }
  //   else if (text.contains("reset")) {
  //     _timerBloc.add(ResetTimer());
  //   }
  //   else if (text.contains("next") || text.contains("instruction") || text.contains("scroll")) {
  //     _scrollToInstructions();
  //     _speak("Scrolling to Instructions.");
  //   }
  //   else if (text.contains("repeat")) {
  //     _speak("Repeating the Instruction. ${widget.recipe.instructions}");
  //   }
  //   else {
  //     _speak("The command $text was not clear. Please try again.");
  //   }
  // }

  // void _scrollToInstructions() {
  //   if (_instructionsKey.currentContext != null) {
  //     Scrollable.ensureVisible(
  //       _instructionsKey.currentContext!,
  //       duration: const Duration(seconds: 1),
  //       curve: Curves.easeInOut,
  //     );
  //   }
  // }

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
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                stretch: true,
                backgroundColor: Colors.orange,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    widget.recipe.title,
                    style: const TextStyle(
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.recipe.image != null
                        ? CachedNetworkImage(
                          imageUrl: widget.recipe.image!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[300]),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                          )
                        : Container(
                          color: Colors.orange.shade200,
                          child: const Icon(Icons.restaurant, size: 80, color: Colors.white54),
                        ),

                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                            stops: [0.6, 1.0],
                          )
                        )
                      ),
                    ],
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black26,
                    ),
                    child: IconButton(
                      onPressed: _onToggleLike,
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "$_likesCount likes",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Center(child: MyTimer(initialDuration: widget.recipe.cookTime * 60)),
                      const Divider(height: 32, thickness: 1),

                      Text(
                        "Description",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 8),

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
                        "Ingredients",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 16),
                      if (widget.recipe.ingredients.isEmpty)
                        const Center(child: Text("No ingredients listed.")),
                      ...widget.recipe.ingredients.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.circle, size: 6, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                item.quantity,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.name,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      }),

                      const Divider(height: 32, thickness: 1),

                      Text(
                        "Instructions",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (widget.recipe.steps.isEmpty)
                        const Text("No instructions provided."),
                      ...widget.recipe.steps.map((step) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  "${step.stepNumber}",
                                  style: const TextStyle(
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  step.instruction,
                                  style: const TextStyle(fontSize: 16, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),     
                    ],
                  ),
                ),
              )
            ],
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