import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ipeoplehelper/main.dart';

void main() {
  testWidgets('App renders title and sound grid', (WidgetTester tester) async {
    // 初始化 SharedPreferences（避免依赖原生平台）
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const IPeopleHelperApp());

    // 此时 app 还在 loading 状态，先确认 loading 显示
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 等待异步 _initialize 完成
    await tester.pumpAndSettle();

    // loading 结束后显示主页
    expect(find.text('我要验牌'), findsWidgets); // AppBar + 音效卡片
    expect(find.text('小瘪三'), findsOneWidget);
  });
}
