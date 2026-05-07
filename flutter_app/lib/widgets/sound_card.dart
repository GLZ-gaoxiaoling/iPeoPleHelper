import 'package:flutter/material.dart';
import '../models/sound_item.dart';

/// 音效卡片组件 - 支持播放动画、拖拽、删除
class SoundCard extends StatelessWidget {
  final SoundItem item;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final bool isHovering;

  const SoundCard({
    super.key,
    required this.item,
    this.isPlaying = false,
    required this.onTap,
    this.onLongPress,
    this.onDelete,
    this.isHovering = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = isHovering
        ? Colors.white.withValues(alpha: 0.3)
        : item.color.withValues(alpha: isPlaying ? 1.0 : 0.8);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isPlaying
            ? [
                BoxShadow(
                  color: item.color.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // 播放动画
              if (isPlaying)
                Positioned.fill(
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 500),
                    scale: 1.0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              // 主内容
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 名称
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        item.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isPlaying ? 18 : 16,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // 状态图标
                    _buildStatusIcon(theme),
                    // 自定义卡片标识
                    if (!item.isAsset)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.person,
                          color: Colors.white.withValues(alpha: 0.5),
                          size: 12,
                        ),
                      ),
                  ],
                ),
              ),
              // 删除按钮（仅自定义卡片显示）
              if (!item.isAsset && !isPlaying)
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              // 播放指示动画
              if (isPlaying)
                Positioned(
                  bottom: 6,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _PlayingIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ThemeData theme) {
    if (isPlaying) {
      return Icon(
        Icons.equalizer,
        color: Colors.white.withValues(alpha: 0.9),
        size: 18,
      );
    }
    return Icon(
      Icons.music_note,
      color: Colors.white.withValues(alpha: 0.6),
      size: 16,
    );
  }
}

/// 播放中的音频波形动画
class _PlayingIndicator extends StatefulWidget {
  final Color color;

  const _PlayingIndicator({required this.color});

  @override
  State<_PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<_PlayingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          height: 12,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(4, (i) {
              final delay = i * 0.15;
              final value = (_controller.value + delay) % 1.0;
              final barHeight = 4.0 + 8.0 * value;
              return Container(
                width: 3,
                height: barHeight,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
