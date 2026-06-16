import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/widgets/glass_dialog.dart';
import 'package:tracker/core/widgets/glass_text_field.dart';
import 'package:tracker/core/services/haptic_service.dart';
import 'package:tracker/features/sales/add_on_repository.dart';
import 'package:tracker/db/app_database.dart';

class AddOnTypesScreen extends ConsumerWidget {
  const AddOnTypesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(addOnTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ADD-ON TYPES'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              HapticService.trigger(HapticProfile.medium);
              _showTypeDialog(context, ref);
            },
          ),
        ],
      ),
      body: typesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (types) {
          if (types.isEmpty) {
            return const Center(
              child: Text(
                'No add-on types defined',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: types.length,
            itemBuilder: (context, index) {
              final type = types[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassPanel(
                  noBlur: true,
                  child: ListTile(
                    title: Text(
                      type.name,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: type.isActive,
                          onChanged: (v) async {
                            HapticService.trigger(HapticProfile.light);
                            await ref.read(addOnRepositoryProvider).updateType(
                                  id: type.id,
                                  name: type.name,
                                  isActive: v,
                                );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () =>
                              _showTypeDialog(context, ref, type: type),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              size: 20, color: Colors.redAccent),
                          onPressed: () =>
                              _confirmDelete(context, ref, type.id),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int id) {
    showGlassDialog(
      context: context,
      title: 'Delete Type',
      message: 'Are you sure you want to delete this add-on type?',
      actionsBuilder: (ctx) => [
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        GlassDialogAction(
          label: 'Delete',
          isDestructive: true,
          isPrimary: true,
          onPressed: () async {
            HapticService.trigger(HapticProfile.heavy);
            await ref.read(addOnRepositoryProvider).deleteType(id);
            Navigator.of(ctx).pop();
          },
        ),
      ],
    );
  }

  static Future<void> _showTypeDialog(BuildContext context, WidgetRef ref,
      {AddOnType? type}) async {
    final controller = TextEditingController(text: type?.name ?? '');
    bool isActive = type?.isActive ?? true;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: GlassPanel(
            solid: true,
            radius: 24,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  type == null ? 'Add Type' : 'Edit Type',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: controller,
                  label: 'Type Name',
                  hint: 'e.g. Extra Cheese, Gift Wrap',
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Active',
                      style: TextStyle(color: Colors.white)),
                  value: isActive,
                  onChanged: (v) {
                    HapticService.trigger(HapticProfile.light);
                    setState(() => isActive = v);
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          final name = controller.text.trim();
                          if (name.isEmpty) return;
                          HapticService.trigger(HapticProfile.medium);
                          if (type == null) {
                            await ref.read(addOnRepositoryProvider).createType(
                                  name: name,
                                  isActive: isActive,
                                );
                          } else {
                            await ref.read(addOnRepositoryProvider).updateType(
                                  id: type.id,
                                  name: name,
                                  isActive: isActive,
                                );
                          }
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
