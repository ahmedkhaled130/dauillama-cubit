import 'package:dauillama/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'async_result.dart';
import 'model_controller.dart';
import 'screens/chat/chat_cubit.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/error_screen.dart';
import 'db.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final modelController = context.read<ModelController>();

    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, theme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: ValueListenableBuilder(
            valueListenable: modelController.models,
            builder: (context, modelListResult, _) => switch (modelListResult) {
              Pending() => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              Data(:final data) when data.isEmpty =>
              const NoModelErrorScreen(),
              Data(:final data) when data.isNotEmpty => ValueListenableBuilder(
                valueListenable: modelController.currentModel,
                builder: (context, model, _) => model == null
                    ? const Center(child: CircularProgressIndicator())
                    : BlocProvider(
                  create: (context) => ChatCubit(
                    client: modelController.client,
                    conversationService:
                    context.read<ConversationService>(),
                    model: modelController.currentModel,
                  )..loadHistory(),
                  child: const ChatScreen(),
                ),
              ),
              _ => const NollamaScreen(),
            },
          ),
        );
      },
    );
  }
}
