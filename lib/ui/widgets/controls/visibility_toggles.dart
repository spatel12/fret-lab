import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/app_state.dart';

class VisibilityToggles extends StatelessWidget {
  const VisibilityToggles({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCheckbox(
          label: 'Notes',
          value: appState.showNoteLabels,
          onChanged: (_) => appState.toggleShowNoteLabels(),
        ),
        const SizedBox(width: 12),
        _buildCheckbox(
          label: 'Roots',
          value: appState.showRoots,
          onChanged: (_) => appState.toggleShowRoots(),
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
