import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart';
import '../async_result.dart';
import '../model.dart';
import '../model_controller.dart';
import 'delete_model_button.dart';
import 'model_list.dart';

class ModelInfoView extends StatelessWidget {
  final Model model;
  final ModelController controller;

  const ModelInfoView({
    super.key,
    required this.model,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 720),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: ListenableBuilder(
            listenable: Listenable.merge(
              [controller.modelInfo, controller.currentModel],
            ),
            builder: (context, _) {
              final modelInfo = controller.modelInfo.value;

              return switch (modelInfo) {
                DataError() => const Icon(Icons.warning, color: Colors.deepOrange),
                Pending() => const Center(
                  child: SizedBox(
                    width: 24,
                    child: CircularProgressIndicator(),
                  ),
                ),
                Data(:final data) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            model.model ?? '/',
                            style: textTheme.titleMedium,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _PullModelButton(model: model, controller: controller),
                            DeleteModelButton(model: model, controller: controller),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    if (data != null) ...[
                      Row(
                        children: [
                          Flexible(
                            child: _InfoTile(
                              title: 'Modified at',
                              data: model.formattedLastUpdate,
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (model.size != null)
                            Flexible(
                              child: _InfoTile(
                                title: 'Size',
                                data: model.size!.asDiskSize(),
                              ),
                            ),
                        ],
                      ),
                      if (data.template != null)
                        _InfoTile(title: 'Template', data: data.template!),
                      if (data.modelfile != null)
                        _InfoTile(title: 'ModelFile', data: data.modelfile!),
                      if (data.parameters != null)
                        _InfoTile(title: 'Parameters', data: data.parameters!),
                    ],
                  ],
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _PullModelButton extends StatelessWidget {
  final Model model;
  final ModelController controller;

  const _PullModelButton({required this.model, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.pullProgress,
      builder: (context, progress, _) => progress == null
          ? IconButton(
        tooltip: 'Update model',
        onPressed: () => controller.updateModel(model),
        icon: const Icon(Icons.refresh),
        color: Colors.cyan.shade700,
      )
          : SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(value: progress),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String data;

  const _InfoTile({required this.title, required this.data});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(title, style: const TextStyle(color: Colors.grey)),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(data),
      ),
    ],
  );
}
