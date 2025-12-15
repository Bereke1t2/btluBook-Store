import 'package:ethio_book_store/app/app.dart';
import 'package:ethio_book_store/injections.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const App());
}