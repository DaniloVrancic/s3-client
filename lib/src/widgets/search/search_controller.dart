import 'package:flutter/material.dart';
import 'package:s3_client/src/widgets/search/search_service.dart';

class SearchController with ChangeNotifier{
  SearchController(this._searchService);

  final SearchService _searchService;

  
}