import 'package:bey_domain/bey_domain.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';

class ComboPage extends StatelessWidget {
  const ComboPage({super.key});

  @override
  Widget build(BuildContext context) {
    final comboRepo = getIt<ComboRepository>();
    final catalogRepo = getIt<CatalogRepository>();

    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: AppBar(
        backgroundColor: AppColors.steel,
        title: Text(
          'MIS COMBOS REGISTRADOS',
          style: AppTypography.mono.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.x),
            onPressed: () => context.push('/combos/new'),
          ),
        ],
      ),
      body: StreamBuilder<List<Part>>(
        stream: catalogRepo.watchByType(PartType.blade),
        builder: (context, bladeSnapshot) {
          final bladesMap = {for (final b in bladeSnapshot.data ?? <Part>[]) b.id: b};

          return StreamBuilder<List<Combo>>(
            stream: comboRepo.watchAll(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.x));
              }

              final combos = snapshot.data ?? [];

              if (combos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.tune, color: AppColors.mute, size: 44),
                      const SizedBox(height: 12),
                      const Text(
                        'No tienes combos en tu arsenal',
                        style: TextStyle(color: AppColors.mute, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      ChamferButton(
                        text: 'CREAR MI PRIMER COMBO',
                        variant: ChamferButtonVariant.go,
                        onPressed: () => context.push('/combos/new'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: combos.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final c = combos[index];
                  final bladePart = bladesMap[c.bladeId];

                  final accentColor = switch (bladePart?.beyType) {
                    BeyType.attack => AppColors.dranzer,
                    BeyType.defense => AppColors.dragoon,
                    BeyType.stamina => AppColors.pegasus,
                    BeyType.balance => AppColors.burst,
                    null => AppColors.x,
                  };

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
                          children: [
                            PartImage(
                              type: PartType.blade,
                              imageRemote: bladePart?.imageRemote,
                              imageLocal: bladePart?.imageLocal,
                              size: 48,
                              color: accentColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.name.toUpperCase(),
                                    style: AppTypography.mono.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      if (bladePart?.beyType != null)
                                        BeyBadge(
                                          label: bladePart!.beyType!.name.toUpperCase(),
                                          color: accentColor,
                                        ),
                                      if (bladePart?.metaTier != null) ...[
                                        const SizedBox(width: 6),
                                        BeyBadge(
                                          label: 'TIER ${bladePart!.metaTier}',
                                          color: AppColors.x,
                                        ),
                                      ],
                                      const Spacer(),
                                      if (c.calculatedWeight != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.panel2,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: AppColors.line),
                                          ),
                                          child: Text(
                                            '${c.calculatedWeight}g',
                                            style: AppTypography.mono.copyWith(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.x,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.void_,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.line2.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _partBadge('BLADE', c.bladeId.replaceAll('blade-', ''), AppColors.x),
                              _partBadge('RATCHET', c.ratchetId.replaceAll('ratchet-', ''), AppColors.dragoon),
                              _partBadge('BIT', c.bitId.replaceAll('bit-', ''), AppColors.pegasus),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _partBadge(String type, String name, Color color) {
    return Column(
      children: [
        Text(type, style: AppTypography.mono.copyWith(fontSize: 8.5, color: AppColors.mute)),
        const SizedBox(height: 2),
        Text(
          name.toUpperCase(),
          style: AppTypography.mono.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
