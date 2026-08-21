import 'package:bey_catalog/bey_catalog.dart';
import 'package:bey_domain/bey_domain.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  PartType _selectedType = PartType.blade;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getBeyTypeColor(BeyType? type) {
    return switch (type) {
      BeyType.attack => AppColors.dranzer,
      BeyType.defense => AppColors.dragoon,
      BeyType.stamina => AppColors.pegasus,
      BeyType.balance => AppColors.burst,
      null => AppColors.x,
    };
  }

  void _showPartDetails(BuildContext context, Part part) {
    final accentColor = _getBeyTypeColor(part.beyType);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.steel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AppColors.line),
      ),
      builder: (ctx) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grab handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.line2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PartImage(
                  type: part.type,
                  imageRemote: part.imageRemote,
                  imageLocal: part.imageLocal,
                  size: 72,
                  color: accentColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        part.name.toUpperCase(),
                        style: AppTypography.displayMedium.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${part.type.name.toUpperCase()} · ${part.system.name.toUpperCase()} ${part.code != null ? '· [${part.code}]' : ''}',
                        style: AppTypography.mono.copyWith(fontSize: 11, color: AppColors.mute),
                      ),
                      if (part.hasbroAlias != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Hasbro: "${part.hasbroAlias}"',
                            style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.mute),
                          ),
                        ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (part.beyType != null)
                            BeyBadge(
                              label: part.beyType!.name.toUpperCase(),
                              color: accentColor,
                            ),
                          if (part.metaTier != null)
                            BeyBadge(
                              label: 'TIER ${part.metaTier}',
                              color: AppColors.x,
                            ),
                          if (part.spinDirection != null)
                            BeyBadge(
                              label: part.spinDirection == SpinDirection.left ? 'GIRO L' : 'GIRO R',
                              color: part.spinDirection == SpinDirection.left ? AppColors.dranzer : AppColors.dragoon,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (part.weightG != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.panel,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.x),
                    ),
                    child: Text(
                      '${part.weightG}g',
                      style: AppTypography.mono.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.x,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.line),
            const SizedBox(height: 12),
            Text(
              'ESPECIFICACIONES TÉCNICAS',
              style: AppTypography.mono.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.mute),
            ),
            const SizedBox(height: 12),
            if (part.attack != null || part.defense != null || part.stamina != null) ...[
              if (part.attack != null)
                StatBar(label: 'Ataque', value: part.attack! * 10, maxValue: 100, color: AppColors.dranzer),
              const SizedBox(height: 8),
              if (part.defense != null)
                StatBar(label: 'Defensa', value: part.defense! * 10, maxValue: 100, color: AppColors.dragoon),
              const SizedBox(height: 8),
              if (part.stamina != null)
                StatBar(label: 'Resistencia', value: part.stamina! * 10, maxValue: 100, color: AppColors.pegasus),
              const SizedBox(height: 14),
            ],
            Wrap(
              spacing: 16,
              runSpacing: 10,
              children: [
                if (part.productCode != null)
                  _specTile('CÓDIGO PRODUCTO', part.productCode!),
                if (part.contactPoints != null)
                  _specTile('PUNTOS CONTACTO', '${part.contactPoints}'),
                if (part.gearTeeth != null)
                  _specTile('DIENTES ENGRANAJE', '${part.gearTeeth} (X-Dash)'),
                if (part.shaftWidth != null)
                  _specTile('EJE / BURST RESIST', '${part.shaftWidth} mm'),
                if (part.tipShape != null)
                  _specTile('FORMA PUNTA', part.tipShape!.toUpperCase()),
                if (part.weightClass != null)
                  _specTile('CLASE PESO', part.weightClass!),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _specTile(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.mono.copyWith(fontSize: 8.5, color: AppColors.mute)),
        const SizedBox(height: 2),
        Text(val, style: AppTypography.mono.copyWith(fontSize: 11.5, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CatalogBloc(
        repository: getIt<CatalogRepository>(),
      )..add(CatalogStarted(type: _selectedType)),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppColors.void_,
            appBar: AppBar(
              backgroundColor: AppColors.steel,
              title: Text(
                'CATÁLOGO OFICIAL (239 PIEZAS)',
                style: AppTypography.mono.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
            body: Column(
              children: [
                // Category Filter Tabs
                Container(
                  color: AppColors.steel,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      _buildCategoryChip(context, 'BLADES', PartType.blade),
                      const SizedBox(width: 8),
                      _buildCategoryChip(context, 'RATCHETS', PartType.ratchet),
                      const SizedBox(width: 8),
                      _buildCategoryChip(context, 'BITS', PartType.bit),
                    ],
                  ),
                ),

                // Search Input
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre, código (BX-01) o alias...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.x),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                context.read<CatalogBloc>().add(CatalogSearchChanged(query: ''));
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: AppColors.panel,
                    ),
                    onChanged: (q) => context.read<CatalogBloc>().add(CatalogSearchChanged(query: q)),
                  ),
                ),

                // Catalog List View
                Expanded(
                  child: BlocBuilder<CatalogBloc, CatalogState>(
                    builder: (context, state) {
                      return switch (state) {
                        CatalogLoading() => const Center(
                            child: CircularProgressIndicator(color: AppColors.x),
                          ),
                        CatalogError(:final message) => Center(
                            child: Text('Error: $message', style: const TextStyle(color: AppColors.dranzer)),
                          ),
                        CatalogLoaded(:final parts) => parts.isEmpty
                            ? const Center(
                                child: Text('No se encontraron piezas.', style: TextStyle(color: AppColors.mute)),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                itemCount: parts.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final part = parts[index];
                                  final typeColor = _getBeyTypeColor(part.beyType);

                                  return InkWell(
                                    onTap: () => _showPartDetails(context, part),
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.panel,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.line),
                                      ),
                                      child: Row(
                                        children: [
                                          PartImage(
                                            type: part.type,
                                            imageRemote: part.imageRemote,
                                            imageLocal: part.imageLocal,
                                            size: 44,
                                            color: typeColor,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        part.name,
                                                        style: AppTypography.mono.copyWith(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 13,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    if (part.metaTier != null)
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 6),
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                          decoration: BoxDecoration(
                                                            color: AppColors.panel2,
                                                            borderRadius: BorderRadius.circular(3),
                                                            border: Border.all(color: AppColors.x.withValues(alpha: 0.5)),
                                                          ),
                                                          child: Text(
                                                            'T${part.metaTier}',
                                                            style: AppTypography.mono.copyWith(
                                                              fontSize: 9,
                                                              fontWeight: FontWeight.bold,
                                                              color: AppColors.x,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${part.type.name.toUpperCase()} · ${part.system.name.toUpperCase()} ${part.code != null ? '· [${part.code}]' : ''}',
                                                  style: AppTypography.bodySmall.copyWith(
                                                    color: AppColors.mute,
                                                    fontSize: 10.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (part.weightG != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: AppColors.panel2,
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: AppColors.line),
                                              ),
                                              child: Text(
                                                '${part.weightG}g',
                                                style: AppTypography.mono.copyWith(
                                                  fontSize: 10.5,
                                                  color: AppColors.x,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.chevron_right, color: AppColors.mute, size: 18),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      };
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String label, PartType type) {
    final isSelected = _selectedType == type;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = type;
            _searchController.clear();
          });
          context.read<CatalogBloc>().add(CatalogStarted(type: type));
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.x.withValues(alpha: 0.15) : AppColors.panel,
            border: Border.all(color: isSelected ? AppColors.x : AppColors.line),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.mono.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.x : AppColors.mute,
            ),
          ),
        ),
      ),
    );
  }
}
