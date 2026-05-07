import 'package:flutter/material.dart';

/// 音效数据模型
class SoundItem {
  final int id;
  final String title;
  final String file;
  final Color color;
  final bool isAsset;

  const SoundItem({
    required this.id,
    required this.title,
    required this.file,
    required this.color,
    this.isAsset = true,
  });

  SoundItem copyWith({
    int? id,
    String? title,
    String? file,
    Color? color,
    bool? isAsset,
  }) {
    return SoundItem(
      id: id ?? this.id,
      title: title ?? this.title,
      file: file ?? this.file,
      color: color ?? this.color,
      isAsset: isAsset ?? this.isAsset,
    );
  }

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

  /// 内置音效资源路径
  String get assetPath => 'sounds/$file';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SoundItem && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 预定义内置音效
const builtInSounds = [
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
