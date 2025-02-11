import 'package:flutter/material.dart';
import 'package:minio/models.dart';
import 'package:provider/provider.dart';
import 'package:s3_client/src/models/user.dart';
import 'package:s3_client/src/screens/search_page/search_page.dart';
import 'package:s3_client/src/screens/settings_page/settings_page.dart';
import 'package:s3_client/src/screens/start_page/start_page_view.dart';
import 'package:s3_client/src/screens/upload_file_page/upload_file_page.dart';
import 'package:s3_client/src/utils/backblaze_service.dart';
import 'package:s3_client/src/widgets/cloud_object/cloud_object.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});
  

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {

  late BackblazeService _b2service;
  late List<Object> foundFiles = [];

  void requestFileUpload() {
    
    return;
  }

  @override
  void initState() {
    super.initState();
    
    _b2service = context.read<BackblazeService>();

    loadObjects();
    
  }

  Future<void> loadObjects() async {
    User currentUser = context.read<User>();
    List<Object> objects = await getAllBucketObjects(currentUser.username.toLowerCase());
    setState(() {
      foundFiles = objects;
    });
  }

  Future<List<Object>> getAllBucketObjects(String bucket) async{

      ListObjectsResult? list = await _b2service.fetchAllObjectsFromBucket(bucket);
      list ??= ListObjectsResult(objects: [], prefixes: []); 
      
      List<Object> objectsList =  list.objects;
      return objectsList;
  }

  
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    User loggedUser = context.read<User>();
    List<Color> listOfIconColors = [
      Colors.orangeAccent,
      Colors.purple.shade300,
      Colors.purple.shade400,
      Colors.purple.shade500,
      Colors.purple.shade600,
      Colors.orange.shade300,
      Colors.orange.shade400,
      Colors.orange.shade500,
      Colors.orange.shade600,
      Colors.limeAccent,
      Colors.indigo,
      Colors.blue.shade700,
      Colors.blue.shade800,
      Colors.blue.shade900,
      Colors.yellow.shade300,
      Colors.pink.shade300,
      Colors.pink.shade400,
      Colors.pink.shade500,
      
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(onPressed: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=> SearchPageWidget(objects: foundFiles,))
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      gradient: LinearGradient(colors: [
                  Color.fromARGB(255, 228, 58, 11),
                              (theme.brightness == Brightness.light) ? Color.fromARGB(235, 245, 145, 30) : Color.fromARGB(174, 50, 20, 5),
                ])
                    ),
                    child: Text("Menu",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36
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
                
              ),
            ),
          const Divider(), // Divider above the user info
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage('assets/images/default_user.png'), // Use a default profile picture
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loggedUser.username,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  loggedUser.email,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
          ],
        ),
        
        
      ),
      
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
            child: foundFiles.isEmpty
                ? const Center(
                    child: Text("No files found.", style: TextStyle(fontSize: 20.0),),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:  MediaQuery.of(context).size.width <= 800 ? (MediaQuery.of(context).size.width <= 450 ? 1 : 2) : 3,
                      mainAxisSpacing: 5.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: MediaQuery.of(context).size.width <= 800 ? (MediaQuery.of(context).size.width <= 450 ? 1.5 : 0.9) : 0.7,
                    ),
                    itemCount: foundFiles.length,
                    itemBuilder: (context, index) {
                      return CloudObject(
                        eTag: foundFiles[index].eTag,
                        size: foundFiles[index].size,
                        owner: foundFiles[index].owner,
                        lastModified: foundFiles[index].lastModified,
                        fileName: foundFiles[index].key.toString(),
                        iconColor: listOfIconColors[foundFiles[index].hashCode % listOfIconColors.length],
                        onDownload: (){},
                        onDelete: (){
                          setState(() {
                            foundFiles.removeAt(index);
                          });
                        },
                        border: Border.all(
                          color: const Color.fromARGB(125, 226, 158, 11),
                          width: 1.25,
                          ),
                        borderRadius: BorderRadius.circular(20.0),
                      );
                    },
                  ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}