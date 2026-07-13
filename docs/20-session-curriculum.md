# 20 节零基础短课

课程可以自由查看，但建议按顺序推进。每节 30–45 分钟，一次只验收一个能力；App 的“已操作/已回答”不是“已掌握”。

每节都按同一循环进行：

```text
先回答检索题 -> 写下预测 -> App 控件改值 -> LLDB 改值
-> 源码改默认值 -> 解释因果 -> Reset -> 只进入下一节
```

| 节 | 主题 | 本节唯一验收 |
|---|---|---|
| 01 | `let / var`、局部变量、类型推断 | 预测一次赋值能否通过编译 |
| 02 | 存储属性、计算属性、`lazy`、`didSet` | 区分值存在哪里与何时计算 |
| 03 | 方法、`init`、`self`、参数、访问控制 | 从签名说清输入、输出和副作用 |
| 04 | `struct` 与 `class`、复制、共享、`===` | 用身份证明复制或共享 |
| 05 | `Optional`、`enum`、`switch`、错误 | 穷尽处理消息状态 |
| 06 | `protocol`、delegate、closure、`weak`、ARC | 画出回调与引用关系 |
| 07 | `String / Array / Set / Dictionary` | 为数据选择正确集合 |
| 08 | `UUID / Date / URL / Data / Codable / FileManager` | 编码并持久化一个业务值 |
| 09 | `Task / async / await / throws / Result` | 追踪异步成功与失败两条路径 |
| 10 | `UIResponder → UIApplication → UIScene → UIWindow` | 从进程入口找到首屏 |
| 11 | `UIView` 几何、外观、层级 | 三层改变 `alpha/backgroundColor/isHidden` |
| 12 | Auto Layout、anchor、constraint、stack view | 写出不冲突的最小约束组 |
| 13 | `UIViewController` 属性、生命周期、呈现 | 区分创建、加载、出现、离开 |
| 14 | `UINavigationController` 栈、push、pop | 预测栈和页面对象身份 |
| 15 | `UILabel / UIImageView` | 选择文字和图片的高频展示属性 |
| 16 | `UIButton / UIControl`、configuration、target-action | 证明禁用时用户 action 不触发 |
| 17 | `UITextField / UITextView`、delegate、第一响应者 | 复述输入与键盘日志顺序 |
| 18 | `UIScrollView / UICollectionView / Cell` | 区分可见 cell、复用实例和数据 |
| 19 | data source、delegate、diffable snapshot、identity | 用稳定 id 刷新且不重复 |
| 20 | Environment、Repository、Transport、Cache、重试 | 从按钮追到缓存并证明重试不换 id |

具体属性、方法、断点与检索题以 App 的 Learn 类型卡为源真相。52 张类型卡只在全局 `TypeCatalog` 定义一次，课程保存类型 ID；`let / var` 等非类型机制由 `LanguageConcept` 表达。目录模型位于 `SwiftMessengerLab/Core/LearningCatalog.swift`，单元测试检查数量、引用、类型种类和前置关系。
