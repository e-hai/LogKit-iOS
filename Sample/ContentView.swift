import SwiftUI
import LogKit

struct ContentView: View {
    @State private var showLogInspector = false
    @State private var logCounter = 1

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Banner
                    VStack(spacing: 8) {
                        Image(systemName: "terminal.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)

                        Text("LogKit iOS Demo")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("纯 Swift 打造 · 原生 SwiftUI 调试控制台")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)

                    // Control Panel: Open Inspector
                    VStack(spacing: 12) {
                        Button(action: {
                            showLogInspector = true
                        }) {
                            HStack {
                                Image(systemName: "list.bullet.rectangle.portrait.fill")
                                    .font(.system(size: 18))
                                Text("打开应用内日志控制台")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
                        }

                        #if canImport(UIKit)
                        Button(action: {
                            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let rootVC = scene.windows.first?.rootViewController {
                                LogKit.showLogUI(from: rootVC)
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.up.right.square")
                                Text("通过 UIKit (showLogUI) 全屏唤起")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                        }
                        #endif
                    }
                    .padding(.horizontal)

                    Divider()
                        .padding(.vertical, 8)

                    // Quick Log Generators
                    VStack(alignment: .leading, spacing: 14) {
                        Text("日志输出测试")
                            .font(.headline)

                        // Single Level Buttons
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            logButton(title: "VERBOSE", color: .gray) {
                                LogKit.v("TAG_V", "这是第 \(logCounter) 条 Verbose 详细跟踪日志")
                                logCounter += 1
                            }

                            logButton(title: "DEBUG", color: .blue) {
                                LogKit.d("TAG_DEBUG", "调试数据 dump: id=\(logCounter), timestamp=\(Date())")
                                logCounter += 1
                            }

                            logButton(title: "INFO", color: .green) {
                                LogKit.i("USER_ACTION", "用户点击了操作按钮, counter=\(logCounter)")
                                logCounter += 1
                            }

                            logButton(title: "WARN", color: .orange) {
                                LogKit.w("CACHE_WARN", "缓存空间即将超限 (阈值: 80%)")
                                logCounter += 1
                            }

                            logButton(title: "ERROR", color: .red) {
                                LogKit.e("NETWORK_ERR", "HTTP 请求失败: 502 Bad Gateway")
                                logCounter += 1
                            }

                            logButton(title: "WTF / ASSERT", color: .pink) {
                                LogKit.wtf("CRITICAL", "捕获到无法恢复的断言状态")
                                logCounter += 1
                            }
                        }

                        // Structured Format Buttons
                        HStack(spacing: 10) {
                            Button(action: {
                                LogKit.json("{\"orderId\": \"ORD_99812\", \"amount\": 199.9, \"items\": [{\"id\": 1, \"name\": \"Pro Member\"}], \"status\": \"paid\"}")
                            }) {
                                HStack {
                                    Image(systemName: "curlybraces")
                                    Text("打印 JSON")
                                }
                                .font(.system(size: 14, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.purple.opacity(0.15))
                                .foregroundColor(.purple)
                                .cornerRadius(8)
                            }

                            Button(action: {
                                LogKit.xml("<response><status code=\"200\">OK</status><data count=\"2\"><item>Apple</item><item>Google</item></data></response>")
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left.slash.chevron.right")
                                    Text("打印 XML")
                                }
                                .font(.system(size: 14, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.teal.opacity(0.15))
                                .foregroundColor(.teal)
                                .cornerRadius(8)
                            }
                        }

                        // Batch Generate
                        Button(action: {
                            for i in 1...15 {
                                let tags = ["AUTH", "PAYMENT", "DATABASE", "PUSH", "UI"]
                                let tag = tags[i % tags.count]
                                switch i % 5 {
                                case 0: LogKit.v(tag, "批量生成跟踪日志: index=\(i)")
                                case 1: LogKit.d(tag, "批量生成调试日志: query took \(Double(i) * 1.5)ms")
                                case 2: LogKit.i(tag, "批量生成提示日志: operation finished")
                                case 3: LogKit.w(tag, "批量生成警告日志: retry count=\(i)")
                                default: LogKit.e(tag, "批量生成错误日志: timeout code=ETIMEDOUT")
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "bolt.fill")
                                Text("一键批量生成 15 条混合日志")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.secondary.opacity(0.15))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("LogKit Demo")
            .sheet(isPresented: $showLogInspector) {
                LogScreen(onBackClick: {
                    showLogInspector = false
                })
            }
        }
    }

    private func logButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(color.opacity(0.15))
                .foregroundColor(color)
                .cornerRadius(8)
        }
    }
}
