# IPeopleHelper（我要验牌）

一个很正经的整活音效板 App。点一下按钮，放一句骚话，就这么简单。

## 分支说明

- **master** — 原版 Kotlin + Jetpack Compose Android 项目
- **flutter** — Flutter 跨平台版本（Android + iOS），迁移自 master

## 音效列表

| 按钮名 | 格式 |
|--------|------|
| 我要验牌 | mp3 |
| 牌没有问题 | mp3 |
| 给我擦皮鞋 | mp3 |
| 小瘪三 | mp3 |
| 小儿科 | mp3 |
| 误闯天家 | wav |
| bibirabu | mp3 |
| bababoi | mp3 |
| 八嘎呀路 | mp3 |
| 我的刀盾 | mp3 |
| 咕咕嘎嘎 | mp3 |
| 爱音糖哭 | wav |
| 爱音糖笑 | wav |
| 给白傻子买瓜子去 | wav |
| 我上早八 | wav |

## Flutter 版技术栈

- Dart + Flutter 3.41
- Material 3
- audioplayers 播放音效
- shared_preferences 存设置
- iOS 静音模式也能播放（AVAudioSession.playback）

## 构建

```bash
cd flutter_app
flutter pub get
flutter run
```

## License

MIT
