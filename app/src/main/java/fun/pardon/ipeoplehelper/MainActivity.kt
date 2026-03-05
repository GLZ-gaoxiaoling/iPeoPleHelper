package `fun`.pardon.ipeoplehelper

import android.os.Bundle
import android.media.AudioAttributes
import android.media.SoundPool
import androidx.compose.ui.platform.LocalContext
import androidx.activity.ComponentActivity
import android.util.Log // 记得导入
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
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.runtime.DisposableEffect
import `fun`.pardon.ipeoplehelper.ui.theme.IPeopleHelperTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            IPeopleHelperTheme {
                // 主应用界面
                MainApp()
            }
        }
    }
}

// 网格项数据类
// 类似于ArkTS中的class或interface
data class GridItem(
    val id: Int,
    val title: String,
    val color: Color
)

// 导航项数据类
data class NavItem(
    val title: String,
    val icon: androidx.compose.ui.graphics.vector.ImageVector
)

// 音频配置映射表
// 这里可以配置不同卡片ID对应的音频资源
// 格式: 卡片ID to 音频资源ID
private val soundMapping = mapOf(
    1 to R.raw.woyaoyanpai,  // 功能1对应我要验牌.mp3
    2 to R.raw.paimeiyouwenti,  // 功能2对应click_sound.mp3
    3 to R.raw.geiwocapixie,  // 功能3对应click_sound.mp3
    4 to R.raw.xiaobiesan,  // 功能4对应click_sound.mp3
    5 to R.raw.xiaoerke,  // 功能5对应click_sound.mp3
    6 to R.raw.wuchuangtianjia,  // 功能6对应click_sound.mp3
    7 to R.raw.bibirabu,   // 功能7对应click_sound.mp3
    8 to R.raw.bababoi,
    9 to R.raw.bagayaru,
    10 to R.raw.wodedaodun,  // 功能10对应click_sound.mp3
    11 to R.raw.gugugaga,  // 功能11对应click_sound.mp3
    12 to R.raw.annotangku,
    13 to R.raw.annotangxiao,
    14 to R.raw.geibaishazimaiguaziqu,
    15 to R.raw.woshangzaoba,
    // 可以根据需要添加更多映射
)

// 主应用界面
// 类似于ArkTS中的@Entry组件
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainApp() {
    val context = LocalContext.current
    // --- 1. 初始化 SoundPool ---
    val soundPool = remember {
        val attributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ASSISTANCE_SONIFICATION)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        SoundPool.Builder()
            .setMaxStreams(5)
            .setAudioAttributes(attributes)
            .build()
    }
    
    // --- 2. 加载所有音频并记住 ID ---
    val soundIds = remember {
        soundMapping.mapValues { (_, resourceId) ->
            soundPool.load(context, resourceId, 1)
        }
    }

    // --- 3. 页面关闭时自动释放资源 ---
    DisposableEffect(Unit) {
        onDispose {
            soundPool.release()
        }
    }

    // 状态管理 - 类似于ArkTS中的@State
    var selectedTab by remember { mutableStateOf(0) }
    
    // 网格数据 - 类似于ArkTS中的数组
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
    
    // 导航项数据
    val navItems = listOf(
        NavItem("首页", Icons.Default.Home),
//        NavItem("个人", Icons.Default.Person),
        NavItem("设置", Icons.Default.Settings)
    )
    
    // Scaffold布局 - 类似于ArkTS中的Column/Row组合
    Scaffold(
        modifier = Modifier.fillMaxSize(),
        topBar = {
            // 顶部应用栏
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
            // 底部导航栏
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
                            Column(
                                horizontalAlignment = Alignment.CenterHorizontally
                            ) {
                                Icon(
                                    imageVector = item.icon,
                                    contentDescription = item.title,
                                    tint = if (selectedTab == index) MaterialTheme.colorScheme.primary 
                                          else MaterialTheme.colorScheme.onSurfaceVariant
                                )
                                Text(
                                    text = item.title,
                                    fontSize = 12.sp,
                                    color = if (selectedTab == index) MaterialTheme.colorScheme.primary 
                                          else MaterialTheme.colorScheme.onSurfaceVariant
                                )
                            }
                        }
                    }
                }
            }
        }
    ) { innerPadding ->
        // 主内容区域 - 根据selectedTab切换显示不同内容
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
        ) {
            // 根据选中的tab显示不同内容
            when (selectedTab) {
                0 -> HomeContent(gridItems) { itemId ->
                    // 根据卡片ID获取对应的音频ID并播放
                    soundIds[itemId]?.let {
                        soundPool.play(it, 1f, 1f, 0, 0, 1f)
                    }
                }
//                1 -> ProfileContent()
                1 -> SettingsContent()
            }
        }
    }
}

// 首页内容 - 显示网格布局
@Composable
fun HomeContent(gridItems: List<GridItem>, onItemClick: (Int) -> Unit) {
    LazyVerticalGrid(
        columns = GridCells.Fixed(2),
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
        horizontalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        items(gridItems) { item ->
            GridItemCard(item = item, onClick = { onItemClick(item.id) })
        }
    }
}

// 个人页面内容
//@Composable
//fun ProfileContent() {
//    Box(
//        modifier = Modifier.fillMaxSize(),
//        contentAlignment = Alignment.Center
//    ) {
//        Column(
//            horizontalAlignment = Alignment.CenterHorizontally
//        ) {
//            Text(
//                text = "个人中心",
//                fontSize = 24.sp,
//                fontWeight = FontWeight.Bold
//            )
//            Text(
//                text = "这里显示个人信息",
//                fontSize = 16.sp,
//                color = MaterialTheme.colorScheme.onSurfaceVariant
//            )
//        }
//    }
//}

// 设置页面内容
@Composable
fun SettingsContent() {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "设置",
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold
            )
            Text(
                text = "我根本就没做",
                fontSize = 16.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

// 网格项卡片组件
// 类似于ArkTS中的自定义组件
private const val TAG = "GridItemCard"
@Composable
fun GridItemCard(item: GridItem, onClick: () -> Unit) {
    Surface(
        modifier = Modifier
            .height(120.dp)
            .clip(RoundedCornerShape(12.dp)),
        color = item.color.copy(alpha = 0.8f),
        onClick = {
            // 点击事件处理 - 类似于ArkTS中的onClick
            // 这里可以添加具体的点击逻辑
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



// 预览组件
@Preview(showBackground = true)
@Composable
fun MainAppPreview() {
    IPeopleHelperTheme {
        MainApp()
    }
}