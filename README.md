# IPeopleHelper（我要验牌）

一个很正经的整活音效板 Android App，用 Kotlin + Jetpack Compose 写的。

点一下按钮，放一句骚话，就这么简单。

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

## 功能

- 音效板首页，按钮网格排列，点击即播
- 设置页可调音频通道（媒体/通知）和最大同时播放数
- 设置持久化到 SharedPreferences

## 技术栈

- Kotlin
- Jetpack Compose + Material3
- SoundPool 播放音效
- Gradle Kotlin DSL
- minSdk 30 / targetSdk 35

## 构建

用 Android Studio 打开项目，直接跑就行。或者命令行：

```bash
./gradlew assembleDebug
```

## 关于图标

App 图标是撇科松（是的，就是你想的那个）。

## License

MIT
