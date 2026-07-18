# SwiftMessengerLab

[![Verify and deploy](https://github.com/estelledc/SwiftMessengerLab/actions/workflows/pages.yml/badge.svg)](https://github.com/estelledc/SwiftMessengerLab/actions/workflows/pages.yml)
[![Version](https://img.shields.io/badge/version-1.0.0-27c9ff)](CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-ff8b73)](LICENSE)

一个公开、原创、可离线运行的 Swift/UIKit IM 学习实验室。App 有两个实验入口：`Messenger` 用于追踪发送、失败和重试，`Learn` 用 20 条课程路线连接 52 个类型与 18 个语言概念；详细讲义、代码与命令留在 docs。

[项目展示页](https://estelledc.github.io/SwiftMessengerLab/) · [20 节课程](docs/20-session-curriculum.md) · [70 个学习卡](docs/experiment-cards.md) · [类型实验室方法](docs/type-lab.md) · [编译器显微镜](docs/compiler-lab.md)

![Messenger、Learn 与 UIView 实验的真实 Simulator 界面](docs/assets/og-image.png)

展示页使用与 [Jason Xun 主站](https://estelledc.github.io/) 相同的 Jason DS 2.2.0 vendor copy：共享纸白/墨黑双主题、排版、状态、导航、证据来源和页脚契约；项目只保留类型搜索、编译器流水线与真实 Simulator 截图等领域组件。

## 它解决什么问题

零基础学习 API 时，最难的通常不是记名字，而是把名字放回一次真实变化中：

```text
预测 -> App 控件改值 -> 观察预览/日志 -> LLDB 改当前实例
     -> 修改源码默认值 -> 解释类型、所有权和控制流 -> 检索题验证
```

Messenger 把常见 IM 客户端问题压缩成一条本地链路：

```text
会话列表 -> 输入文本 -> Repository 乐观插入 -> Mock Transport
         -> sent / failed -> 同一 message id 重试 -> JSON Cache
```

项目不连接真实聊天服务，也不复刻任何商业客户端。示例会话、消息和服务器回执均为虚构本地数据。

## 5 分钟运行

要求：macOS、Xcode 16+、iOS 17+ Simulator。App target 保持 Swift 5 language mode；Core 使用 Swift Package Manager 测试。

```bash
git clone https://github.com/estelledc/SwiftMessengerLab.git
cd SwiftMessengerLab
make run-fresh
```

如果本机没有默认的 `iPhone 17 Pro`：

```bash
make run-fresh SIMULATOR_NAME="你的 Simulator 名称"
```

`run-fresh` 会在启动前分别清空 Messenger JSON Cache 与学习进度，适合从确定性基线开始；`make run` 会保留两者。默认 Simulator OS 会匹配当前 Xcode 的 iOS Simulator SDK，并按名称 + OS 解析唯一设备，仍可用 `SIMULATOR_OS=...` 或 `SIMULATOR_TARGET=UDID` 显式覆盖。

打开 Xcode：

```bash
make open
```

## 第一个业务实验

1. 打开任意会话，先预测普通消息的状态顺序。
2. 发送普通文本，观察 `queued → sending → sent`。
3. 发送 `/fail`，观察 `sending → failed`。
4. 点击失败消息，确认同一个 `Message.id` 重试后变为 `sent`。
5. 打开 `Logs`，复述 `UI → Repository → Transport → Repository → UI`。
6. 在 `MockMessageTransport.send` 暂停后停止 App；重新运行，确认中断的 `queued / sending` 消息恢复为可点击重试的 `failed`，而不是永久卡住。

如果只做一次验收，优先证明两件事：失败重试不新增重复消息，学习进度 reset 不会删除 Messenger 消息。前者对应消息身份，后者对应业务数据和学习数据的边界。

逐步断点、Call Stack、冷启动恢复和 reset 边界见 [Guided Learning](docs/guided-learning.md)。

## 第一个类型实验

1. 切到 `Learn`，搜索 `UIView` 或进入第 11 课。
2. 在 [Type Explorer](https://estelledc.github.io/SwiftMessengerLab/#types) 或离线 `docs/index.html` 找到 `UIView`，指出它是 `class`，再选一个属性和一个方法。
3. 点击搜索结果会直接进入实验；先核对页面唯一的 `Source` cue 与 `Xcode` action。
4. 在 App 中改变 `alpha / backgroundColor / isHidden`，观察预览和日志。
5. 搜索 [操作卡](docs/experiment-cards.md) 中的 `type.UIView`，按卡片给出的 LLDB 命令修改当前实例。
6. 修改指定源码默认值并重新运行，解释为什么源码改值会影响新实例。

App 控制台只保留一句 Goal、真实 Code cue、一个 Xcode action、docs 短路径、控件状态和操作日志；课程列表、搜索结果和入口按钮只显示标题，预期结果不提前渲染。完整机制、属性、方法、所有权、LLDB、Reset、边界和思考题位于 70 个独立 Markdown 学习卡。只有真实执行目标 workload 并产生 `target-evidence:<ID>` 的入口才记录“已操作”；关联观察会明确标名且不写入进度。`Reset Experiment`、`Reset Learning Progress` 和 Messenger JSON Cache 相互独立。

## 52 张类型卡

- Swift 与业务基础：属性、方法、值/引用、Optional、enum、protocol、closure 与 ARC。
- Swift / Foundation：常用集合、UUID、Date、URL、Data、FileManager、Task 与 Result。
- UIKit：应用与 scene 链、view/layout、controller/navigation、展示控件、输入与列表。
- IM 映射：AppEnvironment、Repository、Transport、Cache、Message、Snapshot 和发送状态。

非类型的语法机制使用独立的 `LanguageConcept`，不会伪装成 `struct`。每个真实类型在全局 `TypeCatalog` 中只有一个 ID，课程只保存引用。

公开页的 [Type Explorer](https://estelledc.github.io/SwiftMessengerLab/#types) 可展开查看全部 52 张卡的模块、类型种类、用途、类比、精选属性与方法、关系、关联课程和仓库内观察入口。页面数据由 Swift 目录确定性导出为 `docs/assets/type-catalog.json`；Core 测试会逐字段比对，防止网页与 App 只保持数量相同却内容漂移。

网页只负责公开知识元数据。App 控件、LLDB、源码改值和编译器样本仍需在本地运行；共享 renderer 会明确标为实验族，不等同于 52 套独立的目标类型实现。

## 70 个学习卡

[experiment-cards.md](docs/experiment-cards.md) 由 Swift `ExperimentCatalog` 确定性生成，按稳定 ID 覆盖 `52 type + 18 concept`。系统审计把它们分成 `51 direct workload + 19 related observation`，文件顶部提供 20 Session 与 13 个 renderer family 索引；每张卡都有独立目标、机制、真实 `file + symbol`、App 操作、Xcode/LLDB、预期证据、Reset、边界和思考题。

多个 ID 可以共享 renderer，但文档会明确区分“共享交互模型证据”和“目标类型/概念的专属运行证据”。`Dictionary`、`MessageRepository.enqueueOutgoing` 与 `MessageTransport.send` 有独立可测 workload；未直测的目标统一命名为 `Related Observation`，不会虚构 70 套独立 workload。

## 编译器显微镜

```bash
make compiler-lab SAMPLE=property-access
make compiler-lab SAMPLE=method-dispatch MODE=optimized
make compiler-test
```

五个小于等于 20 行的纯 Swift 样本分别观察：属性访问、值与引用、方法派发、闭包捕获、enum 状态机。命令会生成 SILGen、canonical SIL、LLVM IR、Debug/Optimized ARM64 汇编和 demangle 片段；生成物位于忽略目录。

## 项目结构

```text
SwiftMessengerLab/
├── SwiftMessengerLab/
│   ├── App/                    # Scene 与依赖组装
│   ├── Core/                   # Foundation-only 模型、目录、仓库、传输、缓存
│   ├── Features/               # Inbox 与 Chat
│   └── Learning/               # 搜索、紧凑控制台和白名单实验 renderer
├── CompilerLab/Samples/        # 5 个最小编译器样本
├── Tools/TypeCatalogExporter/  # Swift 目录 → Pages JSON
├── Tools/ExperimentCardExporter/ # Swift catalog → 70 个 Markdown 学习卡
├── Tests/                      # 17 个 Core 测试场景
├── SwiftMessengerLabUITests/   # 19 个真实 UI 场景
├── docs/                       # 课程文档与 GitHub Pages
└── scripts/                    # compiler / public / showcase 门禁
```

## 固定命令

```bash
make test              # 17 个 Core 场景
make test-ui           # 19 个 Simulator UI 场景
make type-cards        # 从 Swift 源目录刷新公开 JSON
make verify-type-cards # 检查公开 JSON 未漂移
make experiment-cards  # 从 Swift catalog 刷新 70 个 Markdown 学习卡
make verify-experiment-cards # 检查 70 卡与 catalog 未漂移
make compiler-test     # 5 个编译器样本
make build             # iOS Simulator build
make verify-showcase   # Pages 资源、Jason DS、指标、链接和 action pin
make public-scan       # 公开边界扫描
make check             # 不含 UI 的日常门禁
make release-check     # Core + UI + 真正的 Release Simulator build
make run-fresh         # 清空消息/学习状态后启动确定性基线
```

## 公开边界与限制

- 只使用公开 API、公开资料和原创实现。
- 不包含内部源码、接口、类型名、文档标识、凭证或本机路径。
- 不逆向 UIKit 二进制；底层观察只针对仓库中的最小 Swift 样本。
- 1.0.0 不覆盖真实后端、账号、附件、推送、加密、动画、手势、多媒体、SwiftUI 或 Objective-C 混编。
- 发布物是源码和 GitHub Pages，不提供 IPA，也不进入 App Store/TestFlight。

完整约束见 [Public Research Boundary](docs/public-research-boundary.md)。贡献方式见 [CONTRIBUTING.md](CONTRIBUTING.md)，安全问题见 [SECURITY.md](SECURITY.md)。
