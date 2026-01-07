import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:sou_chef_flutter/bloc/recipe_bloc/recipe_bloc.dart';
import 'package:sou_chef_flutter/screens/likes_page.dart';
import 'package:sou_chef_flutter/screens/my_recipes_page.dart';
import 'package:sou_chef_flutter/screens/recipe_page.dart';
import 'package:sou_chef_flutter/screens/search_page.dart';
import 'package:sou_chef_flutter/widgets/my_drawer.dart';
import 'package:sou_chef_flutter/screens/add_recipe_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> _pages = [
    const RecipePage(),
    const LikesPage(),
    const SearchPage(),
    const MyRecipesPage(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<RecipeBloc>().add(FetchRecipes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          floatingActionButton: _selectedIndex == 0 ? FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddRecipe())
              );
              
              if (!context.mounted) {
                return;
              }
              context.read<RecipeBloc>().add(FetchRecipes());
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.add),
          ): null,
          appBar: AppBar(
            title: const Text('Sou-Chef'),
          ),
          drawer: MyDrawer(),
        
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: _pages,
          ),
        
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black.withOpacity(.1),
                )
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                child: GNav(
                  rippleColor: Colors.grey[300]!,
                  hoverColor: Colors.grey[100]!,
                  gap: 8,
                  haptic: true,
                  activeColor: Colors.black,
                  iconSize: 24,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  duration: Duration(milliseconds: 400),
                  tabBackgroundColor: Colors.grey[100]!,
                  color: Colors.black,
                  tabs: [
                    GButton(
                      icon: Icons.home,
                      text: 'Home',
                    ),
                    GButton(
                      icon: Icons.favorite,
                      text: 'Likes',
                    ),
                    GButton(
                      icon: Icons.search,
                      text: 'Search',
                    ),
                    GButton(
                      icon: Icons.person,
                      text: 'Profile',
                    ),
                  ],
                  selectedIndex: _selectedIndex,
                  onTabChange: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                    if (index == 0) {
                      context.read<RecipeBloc>().add(FetchRecipes());
                    }
                  },
                ),
              ),
            ),
          ),
        );
  }
}
