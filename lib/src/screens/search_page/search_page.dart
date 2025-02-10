import 'package:flutter/material.dart';

class SearchPageWidget extends StatefulWidget {
  final List<Object> objects;

    const SearchPageWidget({
    super.key,
    required this.objects
    });

  @override
  State<SearchPageWidget> createState() => _SearchPageWidgetState();
}

class _SearchPageWidgetState extends State<SearchPageWidget> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const Border(bottom: BorderSide()),
        title: const TextField(
          decoration: InputDecoration.collapsed(hintText: "Search for an object..."),
          autofocus: true,
        ),
        
      ),
      body: const Center(
        child: Text("Search Page"),
      ),
    );
  }
}