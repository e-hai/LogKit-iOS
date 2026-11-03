import SwiftUI
import LogKit

@main
struct LogKitDemoApp: App {
    init() {
        // 初始化全部日志功能（控制台美化输出 + 后台异步磁盘持久化）
        LogKit.initAllLog()

        // 打印各类基础日志
        LogKit.v("APP", "应用初始化开始...")
        LogKit.d("NETWORK", "模拟请求成功: code=200")
        LogKit.i("USER", "用户已登录, uid=10001")
        LogKit.w("STORAGE", "磁盘缓存空间剩余不足 15%")
        LogKit.e("DATABASE", "数据库查询超时")

        // 链式临时 Tag
        LogKit.t("CUSTOM_TAG").d("这是一条使用链式指定 Tag 的日志")

        // JSON 美化打印
        LogKit.json("{\"user\": \"iOS_Developer\", \"role\": \"admin\", \"status\": \"online\"}")

        // XML 格式化打印
        LogKit.xml("<config><theme>dark</theme><notifications enabled=\"true\"/></config>")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var showLogInspector = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("LogKit iOS 演示")
                    .font(.title2)
                    .fontWeight(.bold)

                Button("输出更多测试日志") {
                    LogKit.d("TEST", "生成调试信息: \(Date())")
                    LogKit.i("PAYMENT", "订单支付成功, orderId=ORD_\(Int.random(in: 1000...9999))")
                    LogKit.w("MEMORY", "收到内存警告通知")
                    LogKit.e("AUTH", "Token 已过期，需要刷新")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("打开 LogKit 日志控制台") {
                    showLogInspector = true
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            .navigationTitle("LogKit Demo")
            .sheet(isPresented: $showLogInspector) {
                LogScreen(onBackClick: {
                    showLogInspector = false
                })
            }
        }
    }
}
