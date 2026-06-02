import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/audio/app_audio_controller.dart';
import '../../../../core/audio/app_audio_preferences_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/spillr_bottom_sheet_scaffold.dart';

class MusicSoundsSheet extends ConsumerStatefulWidget {
  const MusicSoundsSheet({super.key});

  @override
  ConsumerState<MusicSoundsSheet> createState() => _MusicSoundsSheetState();
}

class _MusicSoundsSheetState extends ConsumerState<MusicSoundsSheet> {
  double _masterVolume = 1.0;
  double _bgmVolume = 1.0;
  double _sfxVolume = 1.0;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repo = ref.read(appAudioPreferencesRepositoryProvider);
    final settings = await repo.fetchVolumeSettings();
    if (mounted) {
      setState(() {
        _masterVolume = settings.masterVolume;
        _bgmVolume = settings.bgmVolume;
        _sfxVolume = settings.sfxVolume;
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final settings = AudioVolumeSettings(
      masterVolume: _masterVolume,
      bgmVolume: _bgmVolume,
      sfxVolume: _sfxVolume,
    );
    final repo = ref.read(appAudioPreferencesRepositoryProvider);
    await repo.saveVolumeSettings(settings);
    await ref.read(appAudioControllerProvider).updateVolumes(settings);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SpillrBottomSheetScaffold(
      title: 'Music and Sounds',
      primaryActionLabel: 'Save',
      onPrimaryAction: _isLoading || _isSaving ? null : _save,
      isPrimaryActionLoading: _isSaving,
      child: _isLoading
          ? const SizedBox(
              height: 160,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.teal500),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                _VolumeSliderRow(
                  label: 'Master Volume',
                  value: _masterVolume,
                  onChanged: (v) => setState(() => _masterVolume = v),
                ),
                const SizedBox(height: 20),
                _VolumeSliderRow(
                  label: 'Background Music',
                  value: _bgmVolume,
                  onChanged: (v) => setState(() => _bgmVolume = v),
                ),
                const SizedBox(height: 20),
                _VolumeSliderRow(
                  label: 'Sound Effects',
                  value: _sfxVolume,
                  onChanged: (v) => setState(() => _sfxVolume = v),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

class _VolumeSliderRow extends StatelessWidget {
  const _VolumeSliderRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral700,
          ),
        ),
        const SizedBox(height: 6),
        _SliderWithBadge(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _SliderWithBadge extends StatelessWidget {
  const _SliderWithBadge({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final displayValue = (value * 100).round();

    return LayoutBuilder(
      builder: (context, constraints) {
        const thumbRadius = 12.0;
        const badgeWidth = 36.0;
        const badgeHeight = 24.0;
        final trackWidth = constraints.maxWidth - thumbRadius * 2;
        final thumbX = thumbRadius + value * trackWidth;
        final badgeLeft = (thumbX - badgeWidth / 2).clamp(
          0.0,
          constraints.maxWidth - badgeWidth,
        );

        return SizedBox(
          height: 56,
          child: Stack(
            children: [
              Positioned(
                left: badgeLeft,
                top: 0,
                child: Container(
                  width: badgeWidth,
                  height: badgeHeight,
                  decoration: BoxDecoration(
                    color: AppColors.teal500,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$displayValue',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.teal500,
                    inactiveTrackColor: AppColors.teal500.withValues(
                      alpha: 0.25,
                    ),
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 18,
                    ),
                    trackHeight: 4,
                    overlayColor: AppColors.teal500.withValues(alpha: 0.12),
                  ),
                  child: Slider(
                    value: value,
                    min: 0,
                    max: 1,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
