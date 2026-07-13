# Swift 编译器显微镜

## 目标

不要从 UIKit 整页汇编起步。这里用 5 个不超过 20 行的纯 Swift 样本，沿同一条管线观察：

```text
Swift 源码 -> SILGen -> canonical SIL -> LLVM IR -> ARM64 assembly
```

- SILGen：接近源码语义，适合找 getter/setter、`class_method`、`witness_method`。
- canonical SIL：完成基础规范化，适合比较 ARC 的 `strong_retain/strong_release` 和优化前控制流。
- LLVM IR：更接近通用后端，不再保留全部 Swift 语法外观。
- ARM64：最终机器指令；先找函数边界、调用与分支，不逐行硬啃。

## 命令

```bash
make compiler-lab SAMPLE=property-access
make compiler-lab SAMPLE=method-dispatch MODE=optimized
make compiler-test
```

生成物位于 `.artifacts/compiler-lab/`，已被 Git 忽略。每个样本同时生成 SILGen、canonical SIL、LLVM IR、`-Onone` 汇编、`-O` 汇编、demangled symbols 和目标附近 excerpt。

## 5 个样本的观察点

| 样本 | 先找什么 | 要回答的问题 |
|---|---|---|
| `property-access` | getter、setter、`didSet` | 一次 `doubled += 4` 调了哪些访问器？ |
| `value-and-reference` | `alloc_ref`、retain/release | struct copy 与 class reference 在 SIL 中哪里分叉？ |
| `method-dispatch` | `class_method`、`witness_method`、`function_ref` | 为什么 `final`、可覆写 class、protocol 的派发不同？ |
| `closure-capture` | `partial_apply`、strong/weak storage | 强捕获和 weak 捕获各产生什么所有权操作？ |
| `enum-state-machine` | `switch_enum`、优化后的分支 | 穷尽 switch 到底层后还剩什么？ |

## ARM64 只先认这些

- `bl`：带返回地址的函数调用。
- `b` / `b.eq` / `b.ne`：无条件或条件分支。
- `ldr` / `str`：从内存读或写。
- `add` / `sub`：整数或地址运算。
- `ret`：从函数返回。

不要对具体偏移做结论；编译器和 Xcode 版本变化会改变寄存器分配与指令布局。稳定证据是目标符号存在、关键 SIL 操作存在，以及 Debug/Optimized 结构差异。
