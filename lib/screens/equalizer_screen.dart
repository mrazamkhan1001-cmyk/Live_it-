import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  String _selectedPreset = 'Custom';

  double _band60 = 5.0;
  double _band230 = 2.0;
  double _band910 = 0.0;
  double _band3k6 = 6.0;
  double _band14k = 4.0;

  bool _bassBoost = true;
  bool _virtualizer = false;
  bool _loudness = true;

  final List<String> _presets = ['Custom', 'Rock', 'Pop', 'Hip Hop'];

  void _applyPreset(String preset) {
    setState(() {
      _selectedPreset = preset;
      switch (preset) {
        case 'Rock':
          _band60 = 6.0;
          _band230 = 4.0;
          _band910 = -1.0;
          _band3k6 = 5.0;
          _band14k = 7.0;
          break;
        case 'Pop':
          _band60 = 3.0;
          _band230 = 5.0;
          _band910 = 6.0;
          _band3k6 = 4.0;
          _band14k = 2.0;
          break;
        case 'Hip Hop':
          _band60 = 8.0;
          _band230 = 6.0;
          _band910 = 2.0;
          _band3k6 = 5.0;
          _band14k = 6.0;
          break;
        default:
          _band60 = 5.0;
          _band230 = 2.0;
          _band910 = 0.0;
          _band3k6 = 6.0;
          _band14k = 4.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Equalizer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Presets Chips Bar matching Mockup #12
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _presets.map((preset) {
                    final isSelected = _selectedPreset == preset;
                    return GestureDetector(
                      onTap: () => _applyPreset(preset),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.brightRed : AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.brightRed : AppColors.divider,
                          ),
                        ),
                        child: Text(
                          preset,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.primaryText,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),

              // 5 Red Vertical Frequency Pillars (60, 230, 910, 3.6K, 14K) matching Mockup #12
              Container(
                height: 240,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPillarSlider('60', _band60, (v) => setState(() => _band60 = v)),
                    _buildPillarSlider('230', _band230, (v) => setState(() => _band230 = v)),
                    _buildPillarSlider('910', _band910, (v) => setState(() => _band910 = v)),
                    _buildPillarSlider('3.6K', _band3k6, (v) => setState(() => _band3k6 = v)),
                    _buildPillarSlider('14K', _band14k, (v) => setState(() => _band14k = v)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Toggle Switches (Bass Boost, Virtualizer, Loudness) matching Mockup #12
              _buildSwitchRow('Bass Boost', _bassBoost, (v) => setState(() => _bassBoost = v)),
              const SizedBox(height: 12),
              _buildSwitchRow('Virtualizer', _virtualizer, (v) => setState(() => _virtualizer = v)),
              const SizedBox(height: 12),
              _buildSwitchRow('Loudness', _loudness, (v) => setState(() => _loudness = v)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillarSlider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      children: [
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 14,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                activeTrackColor: AppColors.brightRed,
                inactiveTrackColor: AppColors.divider,
              ),
              child: Slider(
                min: -10,
                max: 10,
                value: value,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(color: AppColors.secondaryText, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSwitchRow(String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.brightRed,
            activeTrackColor: AppColors.darkRed,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
