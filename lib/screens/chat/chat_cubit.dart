import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:ollama_dart/ollama_dart.dart';
import '../../async_result.dart';
import '../../db.dart';
import '../../model.dart';
import 'chat_state.dart';

Conversation emptyConversationWith(String model) => Conversation(
  lastUpdate: DateTime.now(),
  model: model,
  title: 'Chat',
  messages: [],
);

class ChatCubit extends Cubit<ChatState> {
  final _log = Logger('ChatCubit');
  final OllamaClient _client;
  final ConversationService _conversationService;
  final TextEditingController promptFieldController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ValueNotifier<Model?> model;

  ChatCubit({
    required OllamaClient client,
    required this.model,
    required ConversationService conversationService,
    Conversation? initialConversation,
  })  : _client = client,
        _conversationService = conversationService,
        super(
        ChatState(
          model: model.value,
          conversation:
          initialConversation ?? emptyConversationWith(model.value?.model ?? '/'),
        ),
      );

  Future<void> loadHistory() async {
    emit(state.copyWith(conversations: const Pending()));
    try {
      final convos = await _conversationService.loadConversations();
      emit(state.copyWith(conversations: Data(convos)));
    } catch (err) {
      _log.severe('ERROR !!! loadHistory $err');
    }
  }

  Future<void> chat() async {
    if (state.model == null) return;
    final name = state.model!.model;
    if (name == null) return;

    emit(state.copyWith(loading: true));
    final question = promptFieldController.text;
    emit(state.copyWith(lastReply: (question, '')));

    final image = state.selectedImage;
    String? b64Image;
    if (image != null) {
      b64Image = base64Encode(await image.readAsBytes());
    }

    final generateChatCompletionRequest = GenerateChatCompletionRequest(
      model: name,
      messages: [
        for (final qa in state.conversation.messages) ...[
          Message(role: MessageRole.user, content: qa.$1),
          Message(role: MessageRole.assistant, content: qa.$2),
        ],
        Message(
          role: MessageRole.user,
          content: question,
          images: b64Image != null ? [b64Image] : null,
        ),
      ],
    );

    final streamResponse = _client.generateChatCompletionStream(
      request: generateChatCompletionRequest,
    );

    await for (final chunk in streamResponse) {
      final reply = '${state.lastReply.$2}${chunk.message?.content ?? ''}';
      emit(state.copyWith(lastReply: (question, reply)));
      scrollToEnd();
    }

    final messages = List<(String, String)>.from(state.conversation.messages)
      ..add(state.lastReply);

    final firstQuestion = messages.firstOrNull?.$1 ?? question;

    final newConversation = state.conversation.copyWith(
      newMessages: messages,
      newTitle: firstQuestion,
    );

    await _conversationService.saveConversation(newConversation);
    await loadHistory();

    emit(state.copyWith(
      conversation: newConversation,
      loading: false,
      lastReply: (question, state.lastReply.$2),
    ));

    promptFieldController.clear();
    Future.delayed(const Duration(milliseconds: 100), scrollToEnd);
  }

  void scrollToEnd() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.decelerate,
      );
    }
  }

  Future<void> addImage(XFile? image) async {
    emit(state.copyWith(selectedImage: image));
  }

  void deleteImage() {
    emit(state.copyWith(selectedImage: null));
  }

  void selectConversation(Conversation conversation) {
    emit(state.copyWith(conversation: conversation));
  }

  void newConversation() {
    emit(
      state.copyWith(
        conversation: Conversation(
          lastUpdate: DateTime.now(),
          model: state.model?.model ?? '/',
          title: 'New Chat',
          messages: [],
        ),
      ),
    );
  }

  Future<void> deleteConversation(Conversation deleted) async {
    await _conversationService.deleteConversation(deleted);
    emit(state.copyWith(
      conversation: emptyConversationWith(state.model?.model ?? '/'),
    ));
    loadHistory();
  }
}
