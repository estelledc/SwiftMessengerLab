# 类型实验室使用方法

## 一张类型卡怎么看

先只回答四件事：

1. 它是 `class / struct / enum / protocol` 中哪一种？
2. 一个属性的类型、读写权限和默认值是什么？
3. 一个方法的输入、输出、副作用和触发方是谁？
4. 谁创建、谁持有、什么时候释放？

卡片只列当前层真实且高频的属性和方法，不试图成为 UIKit 百科。某些 protocol 或 enum 没有合适的实例属性时会明确说明，不为凑数量虚构 API。

## 三层改值

### 1. App 控件

Learn → 搜索或课程 → 类型卡 → Open Type Experiment。只有白名单属性有控件；`get-only` 属性不伪装成可写，而是改变它依赖的输入，再观察重新计算的结果。

### 2. LLDB

在 `InteractiveExperimentViewController.recordOperation(_:)` 设置断点：

```lldb
po experimentState
expr experimentState.step += 1
po experimentState.step
```

对于 UIKit 课程，可在当前控制器里继续观察 `view`、`navigationController` 和 `navigationController?.viewControllers`。LLDB 改值只影响本次进程内的当前实例。

### 3. 源码

按类型卡给出的源码路径修改真实业务类型、目录配置或 `ExperimentSnapshot` 的一个默认值，再重新构建并比较。源码修改影响后续新实例，这与 LLDB 临时修改当前内存不同。

## Reset 与证据

- `Reset Experiment`：只恢复当前实验的不可变默认快照。
- `Reset Learning Progress`：二次确认后只清除已操作/已回答记录。
- Messenger 消息缓存不被两种 Reset 改动。
- 真正掌握需要你亲自说出类型、属性、方法和一段底层证据；App 不自动宣称掌握。
