import 'package:flutter/material.dart';
import '../services/data_manager.dart';

/// 设置页面
class SettingsPage extends StatefulWidget {
  final int maxStreams;
  final double volume;
  final ValueChanged<int> onMaxStreamsChanged;
  final ValueChanged<double> onVolumeChanged;

  const SettingsPage({
    super.key,
    required this.maxStreams,
    required this.volume,
    required this.onMaxStreamsChanged,
    required this.onVolumeChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late int _maxStreams;
  late double _volume;

  @override
  void initState() {
    super.initState();
    _maxStreams = widget.maxStreams;
    _volume = widget.volume;
  }

  @override
  void didUpdateWidget(SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maxStreams != widget.maxStreams) {
      _maxStreams = widget.maxStreams;
    }
    if (oldWidget.volume != widget.volume) {
      _volume = widget.volume;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // 标题
        Text(
          '设置',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),

        // 音量控制
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.volume_up, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '全局音量',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _volume,
                  min: 0,
                  max: 1.0,
                  divisions: 20,
                  label: '${(_volume * 100).round()}%',
                  onChanged: (value) {
                    setState(() => _volume = value);
                    widget.onVolumeChanged(value);
                    SoundDataManager.saveVolume(value);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 最大同时播放数
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.multitrack_audio,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '最大同时播放数',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '同时播放的音效数量上限，超出时自动停止最早播放的',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 1, label: Text('1')),
                    ButtonSegment(value: 2, label: Text('2')),
                    ButtonSegment(value: 3, label: Text('3')),
                    ButtonSegment(value: 5, label: Text('5')),
                    ButtonSegment(value: 10, label: Text('10')),
                  ],
                  selected: {_maxStreams},
                  onSelectionChanged: (value) {
                    final count = value.first;
                    setState(() => _maxStreams = count);
                    widget.onMaxStreamsChanged(count);
                    SoundDataManager.saveMaxStreams(count);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 关于
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '关于',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '我要验牌 v1.1.0',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '一个很正经的整活音效板 App',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
