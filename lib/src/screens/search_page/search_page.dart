import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPageWidget extends GetView<SearchController> {
  const SearchPageWidget({super.key});

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