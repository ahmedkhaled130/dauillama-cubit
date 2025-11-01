import 'package:dauillama/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'db.dart';
import 'model_controller.dart';
import 'screens/chat/chat_cubit.dart';

class RootCubitProvider extends StatefulWidget {
  final SharedPreferences prefs;
  final Database db;
  final String? ollamaBaseUrl;
  final Widget child;

  const RootCubitProvider({
    required this.child,
    required this.prefs,
    required this.db,
    this.ollamaBaseUrl,
    super.key,
  });

  @override
  State<RootCubitProvider> createState() => _RootCubitProviderState();
}

class _RootCubitProviderState extends State<RootCubitProvider> {
  late final OllamaClient ollamaClient =
  OllamaClient(baseUrl: widget.ollamaBaseUrl);

  late final ConversationService conversationService =
  ConversationService(widget.db);

  late final ModelController modelController = ModelController(
    client: ollamaClient,
    prefs: widget.prefs,
  )..init();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ChatCubit(
            client: ollamaClient,
            model: modelController.currentModel,
            conversationService: conversationService,
          )..loadHistory(),
        ),

        BlocProvider(
          create: (_) => ThemeCubit(),
        ),

        RepositoryProvider.value(value: modelController),
        RepositoryProvider.value(value: conversationService),
      ],
      child: widget.child,
    );
  }
}
