import 'package:flutter/material.dart';

import '../audio/bey_audio_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'chamfer_button.dart';

/// Modal dialog for voice selection, pitch/rate tuning and real-time preview.
class BeyVoiceSelectorDialog extends StatefulWidget {
  const BeyVoiceSelectorDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => const BeyVoiceSelectorDialog(),
    );
  }

  @override
  State<BeyVoiceSelectorDialog> createState() => _BeyVoiceSelectorDialogState();
}

class _BeyVoiceSelectorDialogState extends State<BeyVoiceSelectorDialog> {
  final _audioService = BeyAudioService.instance;
  List<Map<String, String>> _voices = [];
  bool _isLoading = true;
  bool _isPreviewing = false;

  late double _rate;
  late double _pitch;
  Map<String, String>? _selectedVoice;
  late AnnouncerLanguage _language;

  @override
  void initState() {
    super.initState();
    _rate = _audioService.speechRate;
    _pitch = _audioService.speechPitch;
    _selectedVoice = _audioService.selectedVoice;
    _language = _audioService.language;
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    final voices = await _audioService.getAvailableVoices();
    if (mounted) {
      setState(() {
        _voices = voices;
        _isLoading = false;
      });
    }
  }

  Future<void> _preview() async {
    setState(() => _isPreviewing = true);
    await _audioService.setVoiceParams(rate: _rate, pitch: _pitch);
    await _audioService.setCustomVoice(_selectedVoice);
    await _audioService.previewVoice();
    if (mounted) {
      setState(() => _isPreviewing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.void_,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.line, width: 1.5),
      ),
      title: Row(
        children: [
          const Icon(Icons.record_voice_over, color: AppColors.x, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'VOCES DEL ÁRBITRO Y ANUNCIADOR',
              style: AppTypography.displayMedium.copyWith(fontSize: 15, color: AppColors.text),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Mode Selector
              Text('MODO DE IDIOMA:', style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.mute, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _language = AnnouncerLanguage.official;
                          _audioService.language = AnnouncerLanguage.official;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _language == AnnouncerLanguage.official ? AppColors.x.withValues(alpha: 0.15) : AppColors.panel,
                          border: Border.all(color: _language == AnnouncerLanguage.official ? AppColors.x : AppColors.line),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'OFICIAL (EN)',
                          style: AppTypography.mono.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _language == AnnouncerLanguage.official ? AppColors.x : AppColors.mute,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _language = AnnouncerLanguage.spanish;
                          _audioService.language = AnnouncerLanguage.spanish;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _language == AnnouncerLanguage.spanish ? AppColors.pegasus.withValues(alpha: 0.15) : AppColors.panel,
                          border: Border.all(color: _language == AnnouncerLanguage.spanish ? AppColors.pegasus : AppColors.line),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'ESPAÑOL (ES)',
                          style: AppTypography.mono.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _language == AnnouncerLanguage.spanish ? AppColors.pegasus : AppColors.mute,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Available System Voices
              Text('SELECCIONAR VOZ DEL SISTEMA:', style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.mute, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: AppColors.x, strokeWidth: 2)))
              else if (_voices.isEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(6)),
                  child: Text('Se utilizará la voz predeterminada del sistema operativo.', style: AppTypography.bodySmall.copyWith(color: AppColors.mute, fontSize: 11)),
                )
              else
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.panel,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _voices.length,
                    separatorBuilder: (context, index) => const Divider(color: AppColors.line, height: 1),
                    itemBuilder: (ctx, idx) {
                      final v = _voices[idx];
                      final isSel = _selectedVoice?['name'] == v['name'];
                      return ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        title: Text(
                          v['name'] ?? '',
                          style: AppTypography.mono.copyWith(fontSize: 11, color: isSel ? AppColors.x : AppColors.text, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(v['locale'] ?? '', style: const TextStyle(fontSize: 9.5, color: AppColors.mute)),
                        trailing: isSel ? const Icon(Icons.check_circle, color: AppColors.x, size: 16) : null,
                        onTap: () => setState(() => _selectedVoice = v),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 14),

              // Pitch slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TONO (PITCH):', style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.mute)),
                  Text(_pitch.toStringAsFixed(2), style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.x, fontWeight: FontWeight.bold)),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.x,
                  thumbColor: AppColors.x,
                  inactiveTrackColor: AppColors.steel,
                ),
                child: Slider(
                  value: _pitch,
                  min: 0.5,
                  max: 1.5,
                  divisions: 20,
                  onChanged: (val) => setState(() => _pitch = val),
                ),
              ),

              // Rate slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('VELOCIDAD DE LOCUCIÓN:', style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.mute)),
                  Text(_rate.toStringAsFixed(2), style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.pegasus, fontWeight: FontWeight.bold)),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.pegasus,
                  thumbColor: AppColors.pegasus,
                  inactiveTrackColor: AppColors.steel,
                ),
                child: Slider(
                  value: _rate,
                  min: 0.4,
                  max: 1,
                  divisions: 12,
                  onChanged: (val) => setState(() => _rate = val),
                ),
              ),
              const SizedBox(height: 10),

              // Preview button
              ChamferButton(
                text: _isPreviewing ? 'REPRODUCIENDO...' : 'PROBAR VOZ (PREVIEW)',
                height: 38,
                variant: ChamferButtonVariant.ghost,
                onPressed: _isPreviewing ? null : _preview,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR', style: TextStyle(color: AppColors.mute)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.x, foregroundColor: Colors.black),
          onPressed: () async {
            await _audioService.setVoiceParams(rate: _rate, pitch: _pitch);
            await _audioService.setCustomVoice(_selectedVoice);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('GUARDAR VOZ', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
