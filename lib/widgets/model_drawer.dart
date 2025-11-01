import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart';

import '../async_result.dart';
import '../model.dart';
import '../model_controller.dart';
import 'add_model_dialog.dart';
import 'delete_model_button.dart';
import 'model_info_view.dart';
import 'model_list.dart';

class ModelMenuDrawer extends StatelessWidget {
  final ModelController controller;

  const ModelMenuDrawer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final filterNotifier = ValueNotifier('');

    return Drawer(
      width: 360,
      child: ListenableBuilder(
        listenable: Listenable.merge([
          controller.models,
          controller.currentModel,
        ]),
        builder: (context, _) {
          final models = controller.models.value;

          return switch (models) {
            Data(:final data) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _FilterField(
                        onFilterChanged: (value) =>
                        filterNotifier.value = value,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: filterNotifier,
                    builder: (context, filter, _) {
                      bool match(Model element) =>
                          (element.model ?? '/')
                              .toLowerCase()
                              .contains(filter.toLowerCase());
                      final filtered = filter.isEmpty
                          ? data
                          : data.where(match).toList();

                      return _ModelList(
                        models: filtered,
                        currentModel: controller.currentModel.value,
                        controller: controller,
                      );
                    },
                  ),
                ),
              ],
            ),
            DataError() => const Icon(Icons.warning, color: Colors.deepOrange),
            Pending() => const Center(
              child: SizedBox(
                width: 24,
                child: CircularProgressIndicator(),
              ),
            ),
          };
        },
      ),
    );
  }
}

class _ModelList extends StatelessWidget {
  final List<Model> models;
  final Model? currentModel;
  final ModelController controller;

  const _ModelList({
    required this.models,
    required this.currentModel,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) => ListView(
    children: models
        .map(
          (model) => _ModelTile(
        model: model,
        selected: currentModel == model,
        controller: controller,
      ),
    )
        .toList(),
  );
}

class _ModelTile extends StatefulWidget {
  final Model model;
  final bool selected;
  final ModelController controller;

  const _ModelTile({
    required this.model,
    required this.selected,
    required this.controller,
  });

  @override
  State<_ModelTile> createState() => _ModelTileState();
}

class _ModelTileState extends State<_ModelTile> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return MouseRegion(
      onHover: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: ListTile(
        title: Text(widget.model.model ?? '/'),
        subtitle: Text(
          '${(widget.model.size ?? 0).asDiskSize()} - updated ${widget.model.formattedLastUpdate}',
        ),
        dense: true,
        leading: const Icon(Icons.psychology),
        trailing: hovered || widget.selected
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => unawaited(showDialog(
                context: context,
                builder: (context) => ModelInfoView(
                  model: widget.model,
                  controller: controller,
                ),
              )),
              icon: const Icon(Icons.info),
              color: Colors.cyan.shade700,
            ),
            DeleteModelButton(
              model: widget.model,
              controller: controller,
            ),
          ],
        )
            : null,
        selected: widget.selected,
        onTap: () => unawaited(controller.selectModel(widget.model)),
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  final ValueChanged<String> onFilterChanged;
  final TextEditingController controller = TextEditingController();

  _FilterField({required this.onFilterChanged});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        label: const Text('Search model'),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          onPressed: () {
            controller.clear();
            onFilterChanged('');
          },
          icon: const Icon(Icons.close),
          iconSize: 14,
        ),
        isDense: true,
      ),
      onChanged: onFilterChanged,
    ),
  );
}
