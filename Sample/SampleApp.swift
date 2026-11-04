import SwiftUI
import LogKit

@main
struct SampleApp: App {
    init() {
        // 初始化全功能日志（控制台美化排版输出 + 后台异步磁盘持久化）
        LogKit.initAllLog()

        // 打印初始启动日志
        LogKit.v("APP", "LogKitDemoApp 正在启动...")
        LogKit.d("CONFIG", "加载初始配置: debug=true, env=development")
        LogKit.i("SYSTEM", "iOS 版本: \(UIDevice.current.systemVersion), 设备: \(UIDevice.current.model)")
        LogKit.w("STORAGE", "检测到临时缓存目录占用 24.5MB")
        LogKit.e("NETWORK", "模拟网络连接尝试 (备用通道)")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
