package `fun`.pardon.ipeoplehelper

import android.media.AudioAttributes
import android.media.SoundPool
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.BottomAppBar
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import `fun`.pardon.ipeoplehelper.ui.theme.IPeopleHelperTheme

// ==================== 常量定义 ====================

private const val TAG = "MainActivity"
private const val PREFS_NAME = "app_settings"
private const val PREF_KEY_AUDIO_CHANNEL = "audio_channel_type"
private const val PREF_KEY_MAX_STREAMS = "max_streams"
private const val DEFAULT_MAX_STREAMS = 3

private const val GRID_COLUMNS = 2
private const val CARD_HEIGHT = 120
private const val CARD_CORNER_RADIUS = 12
private const val GRID_SPACING = 16
private const val CONTENT_PADDING = 16

// ==================== 数据类定义 ====================

data class GridItem(
    val id: Int,
    val title: String,
    val color: Color
)

data class NavItem(
    val title: String,
    val icon: ImageVector
)

enum class AudioChannelType {
    MEDIA,
    NOTIFICATION
}

// ==================== 音频配置 ====================

val maxStreamsOptions = listOf(1, 2, 3, 5, 10)

private val soundMapping = mapOf(
    1 to R.raw.woyaoyanpai,
    2 to R.raw.paimeiyouwenti,
    3 to R.raw.geiwocapixie,
    4 to R.raw.xiaobiesan,
    5 to R.raw.xiaoerke,
    6 to R.raw.wuchuangtianjia,
    7 to R.raw.bibirabu,
    8 to R.raw.bababoi,
    9 to R.raw.bagayaru,
    10 to R.raw.wodedaodun,
    11 to R.raw.gugugaga,
    12 to R.raw.annotangku,
    13 to R.raw.annotangxiao,
    14 to R.raw.geibaishazimaiguaziqu,
    15 to R.raw.woshangzaoba,
)

// ==================== 主Activity ====================

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            IPeopleHelperTheme {
                MainApp()
            }
        }
    }
}

// ==================== 主应用界面 ====================

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainApp() {
    val context = LocalContext.current
    val sharedPreferences = remember { context.getSharedPreferences(PREFS_NAME, 0) }
    
    var audioChannelType by remember {
        mutableStateOf(
            AudioChannelType.valueOf(
                sharedPreferences.getString(PREF_KEY_AUDIO_CHANNEL, AudioChannelType.NOTIFICATION.name)
                    ?: AudioChannelType.NOTIFICATION.name
            )
        )
    }
    var maxStreams by remember {
        mutableStateOf(sharedPreferences.getInt(PREF_KEY_MAX_STREAMS, DEFAULT_MAX_STREAMS))
    }

    fun saveSettings() {
        with(sharedPreferences.edit()) {
            putString(PREF_KEY_AUDIO_CHANNEL, audioChannelType.name)
            putInt(PREF_KEY_MAX_STREAMS, maxStreams)
            apply()
        }
    }

    val soundPool = remember(audioChannelType, maxStreams) {
        val usage = if (audioChannelType == AudioChannelType.MEDIA) {
            AudioAttributes.USAGE_MEDIA
        } else {
            AudioAttributes.USAGE_ASSISTANCE_SONIFICATION
        }
        val contentType = if (audioChannelType == AudioChannelType.MEDIA) {
            AudioAttributes.CONTENT_TYPE_MUSIC
        } else {
            AudioAttributes.CONTENT_TYPE_SONIFICATION
        }
        
        val attributes = AudioAttributes.Builder()
            .setUsage(usage)
            .setContentType(contentType)
            .build()
        
        SoundPool.Builder()
            .setMaxStreams(maxStreams)
            .setAudioAttributes(attributes)
            .build()
    }

    val soundIds = remember(soundPool) {
        soundMapping.mapValues { (_, resourceId) ->
            soundPool.load(context, resourceId, 1)
        }
    }

    DisposableEffect(soundPool) {
        onDispose {
            soundPool.release()
        }
    }

    var selectedTab by remember { mutableStateOf(0) }
    
    val gridItems = listOf(
        GridItem(1, "我要验牌", Color(0xFF4CAF50)),
        GridItem(2, "牌没有问题", Color(0xFF2196F3)),
        GridItem(3, "给我擦皮鞋", Color(0xFFFF9800)),
        GridItem(4, "小瘪三", Color(0xFF9C27B0)),
        GridItem(5, "小儿科", Color(0xFFF44336)),
        GridItem(6, "误闯天家", Color(0xFF607D8B)),
        GridItem(7, "bibirabu", Color(0xFF00BCD4)),
        GridItem(8, "bababoi", Color(0xFF4CAF50)),
        GridItem(9, "八嘎呀路", Color(0xFF2196F3)),
        GridItem(10, "我的刀盾", Color(0xFFFF9800)),
        GridItem(11, "咕咕嘎嘎", Color(0xFF9C27B0)),
        GridItem(12, "爱音糖哭", Color(0xFFF44336)),
        GridItem(13, "爱音糖笑", Color(0xFF607D8B)),
        GridItem(14, "给白傻子买瓜子去", Color(0xFF00BCD4)),
        GridItem(15, "我上早八", Color(0xFF00BCD4)),
    )
    
    val navItems = listOf(
        NavItem("首页", Icons.Default.Home),
        NavItem("设置", Icons.Default.Settings)
    )
    
    Scaffold(
        modifier = Modifier.fillMaxSize(),
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "我要验牌",
                        fontWeight = FontWeight.Bold,
                        fontSize = 18.sp
                    )
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer
                )
            )
        },
        bottomBar = {
            BottomAppBar(
                containerColor = MaterialTheme.colorScheme.surfaceVariant
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    navItems.forEachIndexed { index, item ->
                        IconButton(
                            onClick = { selectedTab = index },
                            modifier = Modifier.weight(1f)
                        ) {
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Icon(
                                    imageVector = item.icon,
                                    contentDescription = item.title,
                                    tint = if (selectedTab == index) {
                                        MaterialTheme.colorScheme.primary
                                    } else {
                                        MaterialTheme.colorScheme.onSurfaceVariant
                                    }
                                )
                                Text(
                                    text = item.title,
                                    fontSize = 12.sp,
                                    color = if (selectedTab == index) {
                                        MaterialTheme.colorScheme.primary
                                    } else {
                                        MaterialTheme.colorScheme.onSurfaceVariant
                                    }
                                )
                            }
                        }
                    }
                }
            }
        }
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
        ) {
            when (selectedTab) {
                0 -> HomeContent(gridItems) { itemId ->
                    soundIds[itemId]?.let { soundId ->
                        soundPool.play(soundId, 1f, 1f, 0, 0, 1f)
                    }
                }
                1 -> SettingsContent(
                    audioChannelType = audioChannelType,
                    onAudioChannelTypeChange = {
                        audioChannelType = it
                        saveSettings()
                    },
                    maxStreams = maxStreams,
                    onMaxStreamsChange = {
                        maxStreams = it
                        saveSettings()
                    }
                )
            }
        }
    }
}

// ==================== 首页内容 ====================

@Composable
fun HomeContent(gridItems: List<GridItem>, onItemClick: (Int) -> Unit) {
    LazyVerticalGrid(
        columns = GridCells.Fixed(GRID_COLUMNS),
        modifier = Modifier
            .fillMaxSize()
            .padding(CONTENT_PADDING.dp),
        verticalArrangement = Arrangement.spacedBy(GRID_SPACING.dp),
        horizontalArrangement = Arrangement.spacedBy(GRID_SPACING.dp)
    ) {
        items(gridItems) { item ->
            GridItemCard(item = item, onClick = { onItemClick(item.id) })
        }
    }
}

// ==================== 设置页面 ====================

@Composable
fun SettingsContent(
    audioChannelType: AudioChannelType,
    onAudioChannelTypeChange: (AudioChannelType) -> Unit,
    maxStreams: Int,
    onMaxStreamsChange: (Int) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(CONTENT_PADDING.dp),
        verticalArrangement = Arrangement.Top,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "设置",
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(bottom = 32.dp)
        )
        
        DropdownSelector(
            label = "音频通道",
            selectedValue = audioChannelType,
            options = AudioChannelType.values().toList(),
            onSelect = onAudioChannelTypeChange
        )
        
        DropdownSelector(
            label = "最大同时播放数",
            selectedValue = maxStreams,
            options = maxStreamsOptions,
            onSelect = onMaxStreamsChange
        )
        
        Text(
            text = "设置将在下次点击卡片时生效",
            fontSize = 14.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(top = 32.dp)
        )
    }
}

// ==================== 通用组件 ====================

@Composable
fun <T> DropdownSelector(
    label: String,
    selectedValue: T,
    options: List<T>,
    onSelect: (T) -> Unit
) {
    var expanded by remember { mutableStateOf(false) }
    
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = CONTENT_PADDING.dp, vertical = 8.dp)
    ) {
        Text(
            text = label,
            fontSize = 16.sp,
            fontWeight = FontWeight.Medium,
            modifier = Modifier.padding(bottom = 8.dp)
        )
        Surface(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(8.dp),
            color = MaterialTheme.colorScheme.surfaceVariant,
            onClick = { expanded = true }
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(CONTENT_PADDING.dp),
                contentAlignment = Alignment.CenterStart
            ) {
                Text(text = selectedValue.toString())
            }
        }
        DropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false }
        ) {
            options.forEach { option ->
                DropdownMenuItem(
                    text = { Text(text = option.toString()) },
                    onClick = {
                        onSelect(option)
                        expanded = false
                    }
                )
            }
        }
    }
}

// ==================== 卡片组件 ====================

@Composable
fun GridItemCard(item: GridItem, onClick: () -> Unit) {
    Surface(
        modifier = Modifier
            .height(CARD_HEIGHT.dp)
            .clip(RoundedCornerShape(CARD_CORNER_RADIUS.dp)),
        color = item.color.copy(alpha = 0.8f),
        onClick = {
            Log.d(TAG, "点击了 ${item.title}")
            onClick()
        }
    ) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                Text(
                    text = item.title,
                    color = Color.White,
                    fontWeight = FontWeight.Bold,
                    fontSize = 16.sp
                )
                Text(
                    text = "ID: ${item.id}",
                    color = Color.White.copy(alpha = 0.8f),
                    fontSize = 12.sp
                )
            }
        }
    }
}

// ==================== 预览 ====================

@Preview(showBackground = true)
@Composable
fun MainAppPreview() {
    IPeopleHelperTheme {
        MainApp()
    }
}
