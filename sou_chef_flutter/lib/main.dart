import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sou_chef_flutter/bloc/recipe_bloc/blocs.dart';
import 'package:sou_chef_flutter/bloc/recipe_bloc/recipe_bloc.dart';
import 'package:sou_chef_flutter/repositories/recipe_repository.dart';
import 'firebase_options.dart';
import 'package:sou_chef_flutter/screens/intro_screen.dart';

Future<void> main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => RecipeRepository()
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<FeedBloc>(
            create: (context) {
              final repo = context.read<RecipeRepository>();
              return FeedBloc(
                recipeRepository: repo, 
                fetchMethod: repo.fetchRecipes,
              )..add(const FetchRecipes());
            }
          ),

          BlocProvider<MyRecipesBloc>(
            create: (context) {
              final repo = context.read<RecipeRepository>();
              return MyRecipesBloc(
                recipeRepository: repo, 
                fetchMethod: repo.fetchMyRecipes,
              )..add(const FetchRecipes());
            }
          ),

          BlocProvider<FavoriteBloc>(
            create: (context) {
              final repo = context.read<RecipeRepository>();
              return FavoriteBloc(
                recipeRepository: repo, 
                fetchMethod: repo.getFavorites,
              )..add(const FetchRecipes());
            }
          ),
        ],
        child: MyApp(),
      )
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sou-Chef",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme:  ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const IntroScreen(),
    );
  }
}