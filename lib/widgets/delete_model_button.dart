import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart';

import '../model_controller.dart';

class DeleteModelButton extends StatelessWidget {
  final Model model;
  final ModelController controller;

  const DeleteModelButton({
    super.key,
    required this.model,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Delete model',
      onPressed: () async {
        final confirm = await showAdaptiveDialog<bool>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Delete ${model.model} ?'),
            actions: [
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        );
        if (confirm ?? false) {
          controller.deleteModel(model);
        }
      },
      icon: const Icon(Icons.delete),
      color: Theme.of(context).colorScheme.secondary,
    );
  }
}
