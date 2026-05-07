import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sound_item.dart';

/// 音效数据持久化管理
class SoundDataManager {
  static const _keyItems = 'sound_items';
  static const _keyOrder = 'sound_order';
  static const _keyNextId = 'sound_next_id';
  static const _keyVolume = 'global_volume';
  static const _keyMaxStreams = 'max_streams';

  static const _customColors = [
    Color(0xFFE91E63),
    Color(0xFF3F51B5),
    Color(0xFF009688),
    Color(0xFFFF5722),
    Color(0xFF795548),
    Color(0xFF673AB7),
  ];

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// 加载排序后的完整音效列表
  static Future<List<SoundItem>> loadItems() async {
    final prefs = await _prefs;

    final Map<int, SoundItem> itemMap = {
      for (final item in builtInSounds) item.id: item,
    };

    // 加载自定义卡片
    final customJson = prefs.getStringList(_keyItems) ?? [];
    for (final json in customJson) {
      try {
        final item = SoundItem.fromJson(jsonDecode(json));
        itemMap[item.id] = item;
      } catch (_) {
        // 跳过损坏数据
      }
    }

    // 按保存的顺序加载
    final order = prefs.getStringList(_keyOrder);
    if (order != null) {
      final List<SoundItem> result = [];
      for (final idStr in order) {
        final id = int.tryParse(idStr);
        if (id != null && itemMap.containsKey(id)) {
          result.add(itemMap.remove(id)!);
        }
      }
      // 追加不在排序列表里的项
      result.addAll(itemMap.values);
      return result;
    }

    return itemMap.values.toList();
  }

  /// 保存排序
  static Future<void> saveOrder(List<SoundItem> items) async {
    final prefs = await _prefs;
    await prefs.setStringList(
      _keyOrder,
      items.map((e) => e.id.toString()).toList(),
    );
  }

  /// 添加自定义音效卡片
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

  /// 删除自定义卡片（同时删除本地文件）
  static Future<void> deleteCustomItem(SoundItem item) async {
    if (item.isAsset) return;

    final prefs = await _prefs;

    // 删除本地文件
    try {
      final file = File(item.file);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // 文件可能已被删除，忽略
    }

    // 移出自定义列表
    final customJson = prefs.getStringList(_keyItems) ?? [];
    customJson.removeWhere((json) {
      try {
        final parsed = SoundItem.fromJson(jsonDecode(json));
        return parsed.id == item.id;
      } catch (_) {
        return false;
      }
    });
    await prefs.setStringList(_keyItems, customJson);

    // 移出排序
    final order = prefs.getStringList(_keyOrder) ?? [];
    order.remove(item.id.toString());
    await prefs.setStringList(_keyOrder, order);
  }

  /// 获取自定义卡片保存目录
  static Future<Directory> getCustomSoundsDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/custom_sounds');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  // ---- 全局设置 ----

  static Future<double> loadVolume() async {
    final prefs = await _prefs;
    return prefs.getDouble(_keyVolume) ?? 1.0;
  }

  static Future<void> saveVolume(double volume) async {
    final prefs = await _prefs;
    await prefs.setDouble(_keyVolume, volume);
  }

  static Future<int> loadMaxStreams() async {
    final prefs = await _prefs;
    return prefs.getInt(_keyMaxStreams) ?? 3;
  }

  static Future<void> saveMaxStreams(int count) async {
    final prefs = await _prefs;
    await prefs.setInt(_keyMaxStreams, count);
  }
}
