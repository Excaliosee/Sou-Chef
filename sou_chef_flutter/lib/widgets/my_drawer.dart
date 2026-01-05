import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sou_chef_flutter/screens/intro_screen.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({super.key});

  void signUserOut(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (context) => const IntroScreen()),
      (Route<dynamic> route) => false,
    );
  }

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              user?.displayName ?? "Chef",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ), 
            accountEmail: Text(user?.email ?? "No email"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (user?.displayName ?? "U")[0].toUpperCase(),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.grey[900],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () => {
              Navigator.of(context).pop(),
            },
          ),

          ListTile(
            leading: const Icon(Icons.support_agent_sharp),
            title: const Text("Help"),
            onTap: () => {
              Navigator.of(context).pop(),
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text("Feedback"),
            onTap: () => {
              Navigator.of(context).pop(),
            },
          ),

          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text("Invite Friend"),
            onTap: () => {
              Navigator.of(context).pop(),
            },
          ),

          ListTile(
            leading: const Icon(Icons.share),
            title: const Text("Rate our app"),
            onTap: () => {
              Navigator.of(context).pop(),
            },
          ),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About us"),
            onTap: () => {
              Navigator.of(context).pop(),
            },
          ),

          const Divider(),

          ListTile(
            leading: Icon(Icons.logout),
            title: const Text("Sign Out"),
            onTap: () => signUserOut(context),
          )
        ],
      )
    );
  }
}