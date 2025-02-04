import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:s3_client/src/models/user.dart';
import 'package:s3_client/src/screens/search_page/search_page.dart';
import 'package:s3_client/src/screens/settings_page/settings_page.dart';
import 'package:s3_client/src/screens/start_page/start_page_view.dart';
import 'package:s3_client/src/screens/upload_file_page/upload_file_page.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {

  void requestFileUpload() {
    
    return;
  }

  
  @override
  Widget build(BuildContext context) {
    User loggedUser = context.read<User>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(onPressed: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=> const SearchPageWidget())
                ),
              
              icon: const Icon(Icons.search)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          //ScaffoldMessenger.of(context).showSnackBar(
          //const SnackBar(content: Text('File successfully uploaded')),
          //)

          
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=> const UploadFilePage())
                )
        },
        tooltip: "Upload File",
        backgroundColor: const Color.fromARGB(150, 210, 100, 10),
        child: const Icon(Icons.add)
      ),
      
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.orange,
                gradient: LinearGradient(colors: [
            Color.fromARGB(255, 220, 130, 25),
            Color.fromARGB(255, 23, 22, 22)
          ])
              ),
              child: Text("Menu",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24
              )),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=> const SettingsPageWidget())
                );
              },
            ),
            ListTile(
                leading: const Icon(Icons.upload_file),
              title: const Text("Upload File"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=> const UploadFilePage())
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Log Out"),
              onTap: () {
                loggedUser.logout();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=> const StartPageWidget())
                );
              },
            ),
          ],
        )
      ),
    );
  }
}