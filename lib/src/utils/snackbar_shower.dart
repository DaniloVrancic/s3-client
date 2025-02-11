import 'package:flutter/material.dart';

class SnackbarShower {

  static showSnackbar({required BuildContext context, String message = "", Color? color}){
    if (!context.mounted) return; // Ensure the widget is still active
    if(color != null)
    {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: color,),
  );

    }
  else{
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
  }
  }
}