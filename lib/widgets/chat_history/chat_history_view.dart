import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../async_result.dart';
import '../../model.dart';
import '../../screens/chat/chat_cubit.dart';
import '../../screens/chat/chat_state.dart';

class ChatHistoryView extends StatefulWidget {
  final ValueChanged<Conversation> onChatSelection;
  final ValueChanged<Conversation> onDeleteChat;
  final VoidCallback onNewChat;

  const ChatHistoryView({
    super.key,
    required this.onChatSelection,
    required this.onDeleteChat,
    required this.onNewChat,
  });

  @override
  State<ChatHistoryView> createState() => _ChatHistoryViewState();
}

class _ChatHistoryViewState extends State<ChatHistoryView> {
  bool minimized = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.canvasColor,
      constraints: const BoxConstraints(maxWidth: 280),
      child: BlocBuilder<ChatCubit, ChatState>(
        buildWhen: (previous, current) =>
        previous.conversations != current.conversations ||
            previous.conversation != current.conversation,
        builder: (context, state) {
          final conversations = state.conversations;

          return switch (conversations) {
            Pending() => const Center(child: CircularProgressIndicator()),
            DataError() => const Center(
              child: Icon(Icons.warning, color: Colors.orange),
            ),
            Data(:final data) => Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (minimized)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      onPressed: () => setState(() => minimized = false),
                      icon: const Icon(Icons.history),
                    ),
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => setState(() => minimized = true),
                          icon: const RotatedBox(
                            quarterTurns: 1,
                            child: Icon(Icons.expand_circle_down),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: widget.onNewChat,
                          icon: const Icon(Icons.add),
                          label: const Text('New conversation'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      itemCount: data.length,
                      separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final conversation = data[index];
                        final subtitle =
                            '${conversation.formattedDate} - ${conversation.model}';

                        return Material(
                          color: conversation == state.conversation
                              ? theme.highlightColor.withOpacity(0.2)
                              : Colors.transparent,
                          child: ListTile(
                            dense: true,
                            selected:
                            conversation == state.conversation,
                            contentPadding:
                            const EdgeInsets.only(left: 8, right: 8),
                            title: Text(
                              conversation.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              subtitle,
                              style: const TextStyle(color: Colors.blueGrey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            leading: const Icon(
                              Icons.chat,
                              color: Colors.blueGrey,
                            ),
                            trailing: IconButton(
                              onPressed: () =>
                                  widget.onDeleteChat(conversation),
                              icon: const Icon(Icons.delete),
                            ),
                            onTap: () =>
                                widget.onChatSelection(conversation),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          };
        },
      ),
    );
  }
}
