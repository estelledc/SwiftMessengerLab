# Contributing

SwiftMessengerLab 优先接受能让零基础学习者“操作并解释”的小改动，而不是继续堆叠 API 百科。

## 开始前

1. 新建分支并保持一个改动只解决一个教学或工程问题。
2. 类型必须是真实的 `class / struct / enum / protocol`；语法机制放入 `LanguageConcept`。
3. 新类型卡必须写明真实属性、方法、所有权和 App / LLDB / 源码实验。
4. 示例只能使用虚构数据、公开 API 和可公开引用的资料。
5. `docs/assets/type-catalog.json` 是生成物，不手工编辑；修改类型卡或课程后运行 `make type-cards`。

## 本地验证

```bash
make check
make test-ui
git diff --check
```

若修改 Pages、workflow 或发布指标，还需运行：

```bash
make verify-showcase
make public-scan
```

Pull request 请写清学习者能获得的单一能力、操作步骤、验证证据和未覆盖范围。
