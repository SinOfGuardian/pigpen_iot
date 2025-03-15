import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pigpen_iot/custom/app_button.dart';
import 'package:pigpen_iot/custom/app_cachednetworkimage.dart';
import 'package:pigpen_iot/custom/app_textfield.dart';
import 'package:pigpen_iot/custom/ui_appbar.dart';
import 'package:pigpen_iot/models/animal_model.dart';
import 'package:pigpen_iot/modules/string_extensions.dart';

final _choosenAnimal = StateProvider.autoDispose<Animal?>((ref) => null);
final _searchQuery = StateProvider.autoDispose<String?>((ref) => null);
final _searchController =
    Provider.autoDispose<TextEditingController>((ref) => TextEditingController());
final _availableAnimals =
    Provider.autoDispose.family<List<Animal>, List<Animal>>((ref, availableAnimals) {
  final query = ref.watch(_searchQuery);
  if (query == null || query.isEmpty) return availableAnimals;
  return availableAnimals
      .where((animal) => animal.name.toLowerCase().contains(query.toLowerCase()))
      .toList();
});

void _unfocus(BuildContext context) => FocusManager.instance.primaryFocus?.unfocus();

Future<Animal?> showAnimalChooser(BuildContext context,
    {required List<Animal> availableGraphics}) async {
  final colorScheme = Theme.of(context).colorScheme;
  // final titleStyle = Theme.of(context).textTheme.titleLarge;

  return showDialog<Animal?>(
    context: context,
    barrierDismissible: true,
    builder: (context) => GestureDetector(
      onTap: () => _unfocus(context),
      child: AlertDialog(
        title: Column(
          children: [
            const TitledAppBar(title: 'Choose Animal Graphic'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Consumer(
                builder: (context, ref, child) {
                  return AppTextField(
                    controller: ref.watch(_searchController),
                    errorText: null,
                    labelText: 'Search Animal',
                    textInputAction: TextInputAction.search,
                    prefixIconData: Icons.search_rounded,
                    suffixIconData: Ionicons.close_outline,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    onChanged: (newId) {
                      ref.read(_searchQuery.notifier).state = newId;
                      ref.read(_choosenAnimal.notifier).state = null;
                    },
                    onSuffixIconTapped: () {
                      ref.read(_searchQuery.notifier).state = null;
                      ref.read(_searchController).clear();
                    },
                  );
                },
              ),
            ),
          ],
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        titlePadding: const EdgeInsets.all(0),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        content: Consumer(
          builder: (context, ref, child) {
            final animals = ref.watch(_availableAnimals(availableGraphics));
            return _AnimalGraphicChooser(animals: animals);
          },
        ),
        actions: <Widget>[
          Consumer(
            builder: (BuildContext context, WidgetRef ref, _) {
              return AppFilledButton(
                text: 'Select',
                width: double.infinity,
                onPressed: () {
                  final selected = ref.read(_choosenAnimal);
                  if (selected == null) return;
                  Navigator.of(context).pop(selected);
                },
                // child: const Text('Select'),
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _AnimalGraphicChooser extends ConsumerWidget {
  final List<Animal> animals;
  const _AnimalGraphicChooser({required this.animals});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    animals.sort((a, b) => a.name.compareTo(b.name));

    return AspectRatio(
      aspectRatio: 1.2,
      child: GridView.count(
        padding: const EdgeInsets.symmetric(vertical: 30),
        crossAxisCount: 3,
        shrinkWrap: true,
        crossAxisSpacing: 5,
        mainAxisSpacing: 30,
        children: [
          for (var animal in animals) _graphicCard(animal, ref, context),
        ],
      ),
    );
  }

  Widget _graphicCard(Animal animal, WidgetRef ref, BuildContext context) {
    final selectedAnimal = ref.watch(_choosenAnimal);
    final colorScheme = Theme.of(context).colorScheme;
    final bodySmall = Theme.of(context).textTheme.bodySmall;

    return GestureDetector(
      onTap: () => ref.read(_choosenAnimal.notifier).state = animal,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: animal == selectedAnimal ? colorScheme.tertiaryContainer : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Expanded(
              child: OverflowBox(
                alignment: Alignment.bottomCenter,
                maxHeight: 75,
                maxWidth: 75,
                child: AppCachedNetworkImage(animal.graphicUrl, memCacheHeight: 220),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Text(
                animal.name.toTitleCase(),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: bodySmall?.copyWith(
                  fontWeight: animal == selectedAnimal ? FontWeight.bold : null,
                  color: animal == selectedAnimal ? colorScheme.primary : null,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}