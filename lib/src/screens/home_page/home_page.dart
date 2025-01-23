import 'package:flutter/material.dart';
import 'package:s3_client/src/screens/search_page/search_page.dart';
import 'package:s3_client/src/screens/settings_page/settings_page.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(onPressed: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=> SearchPageWidget())
                ),
              
              icon: const Icon(Icons.search)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File successfully uploaded')),
          )
        },
        tooltip: "Upload File",
        backgroundColor: Color.fromARGB(150, 210, 100, 10),
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
            Color.fromARGB(255, 228, 58, 11),
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
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=> SettingsPageWidget())
                );
              },
            ),
            ListTile(

            )
          ],
        )
      ),
    );
  }
}