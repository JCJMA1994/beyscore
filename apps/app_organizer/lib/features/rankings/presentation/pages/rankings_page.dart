import 'package:bey_catalog/bey_catalog.dart';
import 'package:bey_domain/bey_domain.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RankingsPage extends StatefulWidget {
  const RankingsPage({super.key});

  @override
  State<RankingsPage> createState() => _RankingsPageState();
}

class _RankingsPageState extends State<RankingsPage> {
  final _service = const MetaRankingsService();
  bool _isLoading = true;

  List<MetaCombo> _topCombos = [];
  List<MetaPieceRanking> _blades = [];
  List<MetaPieceRanking> _ratchets = [];
  List<MetaPieceRanking> _bits = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final combos = await _service.loadTopCombos();
    final rankings = await _service.loadPieceRankings();

    if (mounted) {
      setState(() {
        _topCombos = combos;
        _blades = rankings.blades;
        _ratchets = rankings.ratchets;
        _bits = rankings.bits;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.void_,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.x),
        ),
      );
    }

    return MetaRankingsPage(
      topCombos: _topCombos,
      blades: _blades,
      ratchets: _ratchets,
      bits: _bits,
      onSelectCombo: (combo) {
        context.push('/combos/new');
      },
    );
  }
}
