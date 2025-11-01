import 'package:file_selector/file_selector.dart';
import 'package:ollama_dart/ollama_dart.dart';
import '../../async_result.dart';
import '../../model.dart';

class ChatState {
  final bool loading;
  final (String, String) lastReply;
  final XFile? selectedImage;
  final AsyncData<List<Conversation>> conversations;
  final Conversation conversation;
  final Model? model;

  const ChatState({
    this.loading = false,
    this.lastReply = const ('', ''),
    this.selectedImage,
    this.conversations = const Data([]),
    required this.conversation,
    this.model,
  });

  ChatState copyWith({
    bool? loading,
    (String, String)? lastReply,
    XFile? selectedImage,
    AsyncData<List<Conversation>>? conversations,
    Conversation? conversation,
    Model? model,
  }) {
    return ChatState(
      loading: loading ?? this.loading,
      lastReply: lastReply ?? this.lastReply,
      selectedImage: selectedImage ?? this.selectedImage,
      conversations: conversations ?? this.conversations,
      conversation: conversation ?? this.conversation,
      model: model ?? this.model,
    );
  }
}
