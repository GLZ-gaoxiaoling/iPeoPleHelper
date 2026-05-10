import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/sound_item.dart';
import '../services/data_manager.dart';
import '../services/audio_manager.dart';
import '../widgets/sound_card.dart';

/// 主页 - 音效网格 + 搜索 + 拖拽排序
class HomePage extends StatefulWidget {
  final AudioManager audioManager;

  const HomePage({super.key, required this.audioManager});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<SoundItem> _items = [];
  List<SoundItem> _filteredItems = [];
  bool _loading = true;
  final Set<int> _playingIds = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.audioManager.onPlaybackUpdate = _onPlaybackUpdate;
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onPlaybackUpdate(int soundId, bool isPlaying) {
    if (!mounted) return;
    setState(() {
      if (isPlaying) {
        _playingIds.add(soundId);
      } else {
        _playingIds.remove(soundId);
      }
    });
  }

  Future<void> _loadData() async {
    final items = await SoundDataManager.loadItems();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
      _applyFilter();
    });
  }

  void _onSearchChanged() {
    setState(_applyFilter);
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      _filteredItems = List.from(_items);
    } else {
      _filteredItems = _items
          .where((item) => item.title.toLowerCase().contains(query))
          .toList();
    }
  }

  Future<void> _playSound(SoundItem item) async {
    try {
      await widget.audioManager.play(item);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('播放失败：${e.toString().split('\n').first}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
      // 同步到过滤列表
      if (_searchController.text.trim().isEmpty) {
        _filteredItems = List.from(_items);
      } else {
        _applyFilter();
      }
    });
    SoundDataManager.saveOrder(_items);
  }

  Future<void> _addCustomCard() async {
    // 选音频文件
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
      withData: true,  // iOS: 必须立即读数据，安全域会在 await 后过期
    );
    if (result == null || result.files.isEmpty) return;

    final pickedFile = result.files.first;
    final originalName = pickedFile.name;

    // 立即读取文件数据（iOS 安全域保护，必须同步读）
    late Uint8List fileBytes;
    try {
      if (pickedFile.bytes != null) {
        fileBytes = pickedFile.bytes!;
      } else {
        // fallback: 从路径读
        final f = File(pickedFile.path!);
        fileBytes = await f.readAsBytes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('读取文件失败：${e.toString().split('\n').first}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // 输入名称（此时文件数据已安全读入内存）
    if (!mounted) return;
    final name = await _showNameDialog(pickedFile);
    if (name == null || name.isEmpty) return;

    // 写入沙盒
    try {
      final customDir = await SoundDataManager.getCustomSoundsDir();
      final ext = originalName.contains('.')
          ? '.${originalName.split('.').last}'
          : '';
      final fileName = 'custom_${DateTime.now().millisecondsSinceEpoch}$ext';
      final destPath = '${customDir.path}/$fileName';

      await File(destPath).writeAsBytes(fileBytes);

      // 保存
      await SoundDataManager.addCustomItem(name, destPath);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已添加「$name」'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('添加失败：${e.toString().split('\n').first}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<String?> _showNameDialog(PlatformFile pickedFile) {
    final defaultName =
        pickedFile.name.replaceAll(RegExp(r'\.[^.]+$'), '');
    final controller = TextEditingController(text: defaultName);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('给卡片起个名'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入卡片名称',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(SoundItem item) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.red),
              title: const Text('确认删除'),
              subtitle: Text('删除「${item.title}」及其音频文件？'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(ctx);
                await SoundDataManager.deleteCustomItem(item);
                await _loadData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('取消'),
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 8,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索音效...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // 音效网格
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off,
                                size: 48,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                            const SizedBox(height: 8),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? '没有匹配的音效'
                                  : '还没有音效，点击右下角添加',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : _buildSoundGrid(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCustomCard,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 构建音效网格（响应式列数）
  /// - 窄屏（手机）    : 2 列
  /// - 中屏（平板横屏）: 3 列
  /// - 宽屏（桌面/大平板）: 4 列
  Widget _buildSoundGrid() {
    // 根据屏幕宽度动态计算网格列数
    final screenWidth = MediaQuery.of(context).size.width;  // 获取屏幕宽度
    int crossAxisCount;
    if (screenWidth >= 900) {
      crossAxisCount = 4; // 宽屏 / 桌面
    } else if (screenWidth >= 600) {
      crossAxisCount = 3; // 平板 / 中屏
    } else {
      crossAxisCount = 2; // 手机 / 窄屏
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        final isPlaying = _playingIds.contains(item.id);

        return LongPressDraggable<SoundItem>(
          data: item,
          feedback: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            shadowColor: Colors.black38,
            child: SizedBox(
              width: 160,
              height: 110,
              child: SoundCard(
                item: item,
                isPlaying: false,
                onTap: () {},
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.25,
            child: SoundCard(
              item: item,
              isPlaying: false,
              onTap: () {},
            ),
          ),
          child: DragTarget<SoundItem>(
            onWillAcceptWithDetails: (details) =>
                details.data.id != item.id &&
                _searchController.text.trim().isEmpty,
            onAcceptWithDetails: (details) {
              final fromIndex = _filteredItems.indexOf(details.data);
              final toIndex = _filteredItems.indexOf(item);
              if (fromIndex != -1 && toIndex != -1) {
                _onReorder(fromIndex, toIndex);
              }
            },
            builder: (context, candidates, rejected) {
              final isHovering = candidates.isNotEmpty;
              return SoundCard(
                key: ValueKey('card_${item.id}'),
                item: item,
                isPlaying: isPlaying,
                isHovering: isHovering,
                onTap: () => _playSound(item),
                onLongPress: () {
                  if (!item.isAsset) {
                    _confirmDelete(item);
                  }
                },
                onDelete: item.isAsset
                    ? null
                    : () => _confirmDelete(item),
              );
            },
          ),
        );
      },
    );
  }
}
