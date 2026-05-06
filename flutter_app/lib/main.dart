import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IPeopleHelperApp());
}

class IPeopleHelperApp extends StatelessWidget {
  const IPeopleHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '我要验牌',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

// ==================== 数据层 ====================

class SoundItem {
  final int id;
  final String title;
  final String file;
  final Color color;
  final bool isAsset; // true=内置assets, false=用户自定义本地文件

  const SoundItem({
    required this.id,
    required this.title,
    required this.file,
    required this.color,
    this.isAsset = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'file': file,
        'color': color.toARGB32(),
        'isAsset': isAsset,
      };

  factory SoundItem.fromJson(Map<String, dynamic> json) => SoundItem(
        id: json['id'] as int,
        title: json['title'] as String,
        file: json['file'] as String,
        color: Color(json['color'] as int),
        isAsset: json['isAsset'] as bool? ?? true,
      );
}

// 内置音效
const _builtInSounds = [
  SoundItem(id: 1, title: '我要验牌', file: 'woyaoyanpai.mp3', color: Color(0xFF4CAF50)),
  SoundItem(id: 2, title: '牌没有问题', file: 'paimeiyouwenti.mp3', color: Color(0xFF2196F3)),
  SoundItem(id: 3, title: '给我擦皮鞋', file: 'geiwocapixie.mp3', color: Color(0xFFFF9800)),
  SoundItem(id: 4, title: '小瘪三', file: 'xiaobiesan.mp3', color: Color(0xFF9C27B0)),
  SoundItem(id: 5, title: '小儿科', file: 'xiaoerke.mp3', color: Color(0xFFF44336)),
  SoundItem(id: 6, title: '误闯天家', file: 'wuchuangtianjia.mp3', color: Color(0xFF607D8B)),
  SoundItem(id: 7, title: 'bibirabu', file: 'bibirabu.mp3', color: Color(0xFF00BCD4)),
  SoundItem(id: 8, title: 'bababoi', file: 'bababoi.mp3', color: Color(0xFF4CAF50)),
  SoundItem(id: 9, title: '八嘎呀路', file: 'bagayaru.mp3', color: Color(0xFF2196F3)),
  SoundItem(id: 10, title: '我的刀盾', file: 'wodedaodun.mp3', color: Color(0xFFFF9800)),
  SoundItem(id: 11, title: '咕咕嘎嘎', file: 'gugugaga.mp3', color: Color(0xFF9C27B0)),
  SoundItem(id: 12, title: '爱音糖哭', file: 'annotangku.wav', color: Color(0xFFF44336)),
  SoundItem(id: 13, title: '爱音糖笑', file: 'annotangxiao.wav', color: Color(0xFF607D8B)),
  SoundItem(id: 14, title: '给白傻子买瓜子去', file: 'geibaishazimaiguaziqu.wav', color: Color(0xFF00BCD4)),
  SoundItem(id: 15, title: '我上早八', file: 'woshangzaoba.wav', color: Color(0xFF00BCD4)),
];

const _customColors = [
  Color(0xFFE91E63), Color(0xFF3F51B5), Color(0xFF009688),
  Color(0xFFFF5722), Color(0xFF795548), Color(0xFF673AB7),
];

// 数据管理
class SoundDataManager {
  static const _keyItems = 'sound_items';
  static const _keyOrder = 'sound_order';
  static const _keyNextId = 'sound_next_id';

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // 加载排序后的完整列表
  static Future<List<SoundItem>> loadItems() async {
    final prefs = await _prefs;

    // 先拿内置列表
    final Map<int, SoundItem> itemMap = {
      for (final item in _builtInSounds) item.id: item,
    };

    // 加载自定义卡片
    final customJson = prefs.getStringList(_keyItems) ?? [];
    for (final json in customJson) {
      final item = SoundItem.fromJson(jsonDecode(json));
      itemMap[item.id] = item;
    }

    // 加载排序
    final order = prefs.getStringList(_keyOrder);
    if (order != null) {
      final List<SoundItem> result = [];
      for (final idStr in order) {
        final id = int.tryParse(idStr);
        if (id != null && itemMap.containsKey(id)) {
          result.add(itemMap[id]!);
        }
      }
      // 追加不在排序列表里的新项
      for (final item in itemMap.values) {
        if (!order.contains(item.id.toString())) {
          result.add(item);
        }
      }
      return result;
    }

    return itemMap.values.toList();
  }

  // 保存排序
  static Future<void> saveOrder(List<SoundItem> items) async {
    final prefs = await _prefs;
    await prefs.setStringList(
      _keyOrder,
      items.map((e) => e.id.toString()).toList(),
    );
  }

  // 添加自定义卡片
  static Future<SoundItem> addCustomItem(String title, String filePath) async {
    final prefs = await _prefs;
    final nextId = prefs.getInt(_keyNextId) ?? 100;
    final colorIndex = (nextId - 100) % _customColors.length;

    final item = SoundItem(
      id: nextId,
      title: title,
      file: filePath,
      color: _customColors[colorIndex],
      isAsset: false,
    );

    final customJson = prefs.getStringList(_keyItems) ?? [];
    customJson.add(jsonEncode(item.toJson()));
    await prefs.setStringList(_keyItems, customJson);
    await prefs.setInt(_keyNextId, nextId + 1);

    return item;
  }

  // 删除自定义卡片（同时删除文件）
  static Future<void> deleteCustomItem(SoundItem item) async {
    if (item.isAsset) return; // 不允许删除内置卡片

    final prefs = await _prefs;

    // 删除本地文件
    final file = File(item.file);
    if (await file.exists()) {
      await file.delete();
    }

    // 从自定义列表移除
    final customJson = prefs.getStringList(_keyItems) ?? [];
    customJson.removeWhere((json) {
      final parsed = SoundItem.fromJson(jsonDecode(json));
      return parsed.id == item.id;
    });
    await prefs.setStringList(_keyItems, customJson);

    // 从排序中移除
    final order = prefs.getStringList(_keyOrder) ?? [];
    order.remove(item.id.toString());
    await prefs.setStringList(_keyOrder, order);
  }
}

// ==================== 主页 ====================

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late final AudioPlayer _player;
  int _maxStreams = 3;
  List<SoundItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final items = await SoundDataManager.loadItems();
    setState(() {
      _maxStreams = prefs.getInt('max_streams') ?? 3;
      _items = items;
      _loading = false;
    });
  }

  Future<void> _playSound(SoundItem item) async {
    if (item.isAsset) {
      await _player.play(AssetSource('sounds/${item.file}'));
    } else {
      await _player.play(DeviceFileSource(item.file));
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) newIndex -= 1;
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
    SoundDataManager.saveOrder(_items);
  }

  void _onDeleteItem(SoundItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除「${item.title}」吗？\n音频文件也会一起删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await SoundDataManager.deleteCustomItem(item);
              await _loadData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _addCustomCard() async {
    // 选音频文件
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final pickedFile = result.files.first;
    final sourcePath = pickedFile.xFile.path;

    // 检查文件大小估算时长（32kbps ~ 4KB/s，30s ~ 120KB，取宽松 500KB）
    final file = File(sourcePath);
    final fileSize = await file.length();
    if (fileSize > 500 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('音频文件过大，请选择30秒以内的音频')),
      );
      return;
    }

    // 弹窗输入名称
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(
          text: pickedFile.name.replaceAll(RegExp(r'\.[^.]+$'), ''),
        );
        return AlertDialog(
          title: const Text('给卡片起个名'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: '输入卡片名称'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );

    if (name == null || name.isEmpty) return;

    // 拷贝到本地沙盒
    final appDir = await getApplicationDocumentsDirectory();
    final customDir = Directory('${appDir.path}/custom_sounds');
    if (!await customDir.exists()) {
      await customDir.create(recursive: true);
    }

    final fileName = 'custom_${DateTime.now().millisecondsSinceEpoch}${pickedFile.name.replaceAll(RegExp(r'^.*(\.[^.]+)$'), r'$1')}';
    final destPath = '${customDir.path}/$fileName';
    await file.copy(destPath);

    // 保存
    await SoundDataManager.addCustomItem(name, destPath);
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已添加「$name」')),
      );
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '我要验牌',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildSoundGrid(),
          _buildSettingsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: '首页'),
          NavigationDestination(icon: Icon(Icons.settings), label: '设置'),
        ],
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        selectedIndex: _currentIndex,
      ),
    );
  }

  Widget _buildSoundGrid() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return LongPressDraggable<SoundItem>(
          data: item,
          feedback: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            child: _DragFeedback(item: item),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _SoundCard(
              item: item,
              onTap: () {},
            ),
          ),
          child: DragTarget<SoundItem>(
            onWillAcceptWithDetails: (details) => details.data.id != item.id,
            onAcceptWithDetails: (details) {
              final fromItem = details.data;
              final fromIndex = _items.indexOf(fromItem);
              final toIndex = _items.indexOf(item);
              if (fromIndex != -1 && toIndex != -1) {
                _onReorder(fromIndex, toIndex);
              }
            },
            builder: (context, candidateItems, rejectedItems) {
              return _SoundCard(
                item: item,
                onTap: () => _playSound(item),
                onLongPress: item.isAsset ? null : () => _onDeleteItem(item),
                isHovering: candidateItems.isNotEmpty,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSettingsPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '设置',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            DropdownButtonFormField<int>(
              initialValue: _maxStreams,
              decoration: const InputDecoration(
                labelText: '最大同时播放数',
                border: OutlineInputBorder(),
              ),
              items: [1, 2, 3, 5, 10]
                  .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                  .toList(),
              onChanged: (value) async {
                if (value != null) {
                  setState(() => _maxStreams = value);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('max_streams', value);
                }
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _addCustomCard,
              icon: const Icon(Icons.add),
              label: const Text('添加自定义卡片'),
            ),
            const SizedBox(height: 16),
            Text(
              '长按卡片可拖拽排序\n长按自定义卡片可删除',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 音效卡片 ====================

class _SoundCard extends StatelessWidget {
  final SoundItem item;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isHovering;

  const _SoundCard({
    required this.item,
    required this.onTap,
    this.onLongPress,
    this.isHovering = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isHovering
          ? Colors.white.withValues(alpha: 0.3)
          : item.color.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Icon(
                item.isAsset ? Icons.music_note : Icons.person,
                color: Colors.white.withValues(alpha: 0.7),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 拖拽时浮动预览
class _DragFeedback extends StatelessWidget {
  final SoundItem item;

  const _DragFeedback({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 100,
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          item.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
