import 'package:bey_domain/bey_domain.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';

class DeckPage extends StatelessWidget {
  const DeckPage({super.key});

  @override
  Widget build(BuildContext context) {
    final deckRepo = getIt<DeckRepository>();
    final comboRepo = getIt<ComboRepository>();
    final catalogRepo = getIt<CatalogRepository>();

    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: AppBar(
        backgroundColor: AppColors.steel,
        title: Text(
          'MIS DECKS 3ON3 OFICIALES',
          style: AppTypography.mono.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.x),
            onPressed: () => context.push('/decks/new'),
          ),
        ],
      ),
      body: StreamBuilder<List<Part>>(
        stream: catalogRepo.watchByType(PartType.blade),
        builder: (context, bladeSnapshot) {
          final bladesMap = {for (final b in bladeSnapshot.data ?? <Part>[]) b.id: b};

          return StreamBuilder<List<Combo>>(
            stream: comboRepo.watchAll(),
            builder: (context, comboSnapshot) {
              final allCombos = {for (final c in comboSnapshot.data ?? <Combo>[]) c.id: c};

              return StreamBuilder<List<Deck>>(
                stream: deckRepo.watchAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.x));
                  }

                  final decks = snapshot.data ?? [];

                  if (decks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.layers, color: AppColors.mute, size: 44),
                          const SizedBox(height: 12),
                          const Text(
                            'No tienes Decks 3on3 registrados',
                            style: TextStyle(color: AppColors.mute, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          ChamferButton(
                            text: 'CREAR MI PRIMER DECK 3ON3',
                            variant: ChamferButtonVariant.go,
                            onPressed: () => context.push('/decks/new'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: decks.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final d = decks[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.panel,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.layers, color: AppColors.dragoon, size: 22),
                                    const SizedBox(width: 8),
                                    Text(
                                      d.name.toUpperCase(),
                                      style: AppTypography.mono.copyWith(fontWeight: FontWeight.bold, fontSize: 13.5),
                                    ),
                                  ],
                                ),
                                const BeyBadge(label: 'OFICIAL V12', color: AppColors.dragoon),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...d.comboIds.asMap().entries.map((entry) {
                              final slotIdx = entry.key + 1;
                              final comboId = entry.value;
                              final combo = allCombos[comboId];
                              final bladePart = combo != null ? bladesMap[combo.bladeId] : null;

                              final accentColor = switch (bladePart?.beyType) {
                                BeyType.attack => AppColors.dranzer,
                                BeyType.defense => AppColors.dragoon,
                                BeyType.stamina => AppColors.pegasus,
                                BeyType.balance => AppColors.burst,
                                null => AppColors.x,
                              };

                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.void_,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.line2.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.panel2,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Text(
                                        '#$slotIdx',
                                        style: AppTypography.mono.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.x),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    PartImage(
                                      type: PartType.blade,
                                      imageRemote: bladePart?.imageRemote,
                                      imageLocal: bladePart?.imageLocal,
                                      size: 32,
                                      color: accentColor,
                                      showBorder: false,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            combo != null ? combo.name : 'Combo: $comboId',
                                            style: AppTypography.bodySmall.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (combo != null)
                                            Text(
                                              '${combo.bladeId.replaceAll('blade-', '')} · ${combo.ratchetId.replaceAll('ratchet-', '')} · ${combo.bitId.replaceAll('bit-', '')}',
                                              style: AppTypography.bodySmall.copyWith(fontSize: 9.5, color: AppColors.mute),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (combo?.calculatedWeight != null)
                                      Text(
                                        '${combo!.calculatedWeight}g',
                                        style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.x),
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
