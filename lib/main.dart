import 'dart:io';
import 'package:dauillama/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'db.dart';
import 'log.dart';
import 'rootBlocProvider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initLog();

  final prefs = await SharedPreferences.getInstance();
  final db = await initDB();

  runApp(
        RootCubitProvider(
          prefs: prefs,
          db: db,
          ollamaBaseUrl: Platform.environment['OLLAMA_BASE_URL'],
          child: BlocProvider(
            create: (_) => ThemeCubit(),
            child: const App(),
          ),

      ),);


  }
