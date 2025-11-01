import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model.dart';
import '../screens/chat/chat_cubit.dart';
import '../screens/chat/chat_state.dart';

const imageTypes = XTypeGroup(label: 'images', extensions: ['jpg', 'png']);

class PromptField extends StatefulWidget {
  const PromptField({super.key});

  @override
  PromptFieldState createState() => PromptFieldState();
}

class PromptFieldState extends State<PromptField> {
  bool minimized = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatCubit = context.read<ChatCubit>();

    return Container(
      padding: const EdgeInsets.all(8.0),
      color: theme.cardColor,
      child: BlocBuilder<ChatCubit, ChatState>(
        // buildWhen: (prev, curr) =>
        // prev.promptText != curr.promptText ||
        //     prev.selectedImage != curr.selectedImage,
        builder: (context, state) {
          final selectedImage = state.selectedImage;
          final promptController = chatCubit.promptFieldController;
          final maxLines = minimized ? 1 : 12;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: minimized
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: promptController,
                      maxLines: maxLines,
                      decoration: InputDecoration(
                        label: const Text('Your prompt...'),
                        border: const OutlineInputBorder(),
                        suffixIcon: _PromptActionBar(
                          minimized: minimized,
                          onFileContentAdded: () =>
                              setState(() => minimized = false),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                      onEditingComplete: chatCubit.chat,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => minimized = !minimized),
                    icon: const Icon(Icons.arrow_drop_down),
                  ),
                ],
              ),
              if (selectedImage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      InkWell(
                        child: Image.file(File(selectedImage.path), height: 64),
                        onTap: () => showImage(
                          context: context,
                          path: selectedImage.path,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(selectedImage.path),
                      ),
                      IconButton(
                        onPressed: chatCubit.deleteImage,
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

Future<void> showImage({
  required BuildContext context,
  required String path,
}) =>
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Image.file(File(path)),
      ),
    );

class _PromptActionBar extends StatelessWidget {
  final bool minimized;
  final VoidCallback onFileContentAdded;

  const _PromptActionBar({
    required this.minimized,
    required this.onFileContentAdded,
  });

  @override
  Widget build(BuildContext context) {
    final chatCubit = context.read<ChatCubit>();
    final promptController = chatCubit.promptFieldController;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.add_photo_alternate),
          tooltip: 'Add an image (only multimodal model)',
          onPressed: () async {
            final selectedImage =
            await openFile(acceptedTypeGroups: [imageTypes]);
            if (selectedImage != null) {
              chatCubit.addImage(selectedImage);
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.post_add),
          tooltip: 'Insert a file content',
          onPressed: () async {
            final file = await openFile();
            final fileContent = await file?.readAsString();
            if (fileContent != null) {
              promptController.text =
              '${promptController.text}\n$fileContent';
              onFileContentAdded();
            }
          },
        ),
        if (promptController.text.isNotEmpty)
          IconButton(
            onPressed: chatCubit.chat,
            icon: const Icon(Icons.send),
          ),
      ],
    );
  }
}