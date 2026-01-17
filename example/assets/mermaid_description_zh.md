# Mermaid 图表支持

此页面演示 markdown_widget 中的 Mermaid 图表渲染支持。

## 功能特性

- **多种图表类型**：支持各种 Mermaid 图表类型，包括流程图、时序图、状态图、ER 图等。
- **主题支持**：根据应用设置自动切换明暗主题。
- **交互式**：点击切换按钮可在以下模式间切换：
  - **代码**：查看原始 Mermaid 代码
  - **图表**：仅查看渲染的图表
  - **两者**：并排查看代码和图表
- **缓存**：图表会在内存中缓存以加快后续渲染速度。
- **防抖**：编辑时自动防抖（500ms），防止过多的 API 调用。
- **全屏查看器**：点击任何渲染的图表即可在全屏图像查看器中查看。
- **水平滚动**：宽图表可以独立于代码块进行水平滚动。

## 使用方法

### 基本用法

使用 `createMermaidWrapper` 函数配合你的 `PreConfig`：

```dart
final preConfig = PreConfig(
  wrapper: createMermaidWrapper(
    config: const MermaidConfig(),
    isDark: isDark,
    preConfig: preConfig,
  ),
);

MarkdownWidget(
  data: markdown,
  config: config.copy(configs: [preConfig]),
)
```

### 自定义配置

您可以使用 `MermaidConfig` 自定义渲染行为：

```dart
MermaidConfig(
  displayMode: MermaidDisplayMode.codeAndDiagram,
  diagramBackgroundColor: Colors.grey.withValues(alpha: 0.1),
  diagramPadding: EdgeInsets.all(16.0),
  showLoadingIndicator: true,
  loadingWidget: CustomLoadingWidget(),
  stateBuilder: (state) => CustomStateWidget(state),
)
```

### 显示模式

- `MermaidDisplayMode.codeOnly`：仅显示代码块
- `MermaidDisplayMode.diagramOnly`：仅显示渲染的图表
- `MermaidDisplayMode.codeAndDiagram`：同时显示两者（默认）

### 配置选项

| 参数 | 类型 | 默认值 | 描述 |
|-----|------|-------|-----|
| `displayMode` | `MermaidDisplayMode` | `codeAndDiagram` | 初始显示模式 |
| `diagramBackgroundColor` | `Color?` | `null` | 错误状态的背景颜色 |
| `diagramPadding` | `EdgeInsetsGeometry` | `EdgeInsets.all(16.0)` | 图表周围的填充 |
| `showLoadingIndicator` | `bool` | `true` | 渲染时显示加载指示器 |
| `loadingWidget` | `Widget?` | `null` | 自定义加载组件 |
| `stateBuilder` | `Widget Function(MermaidDiagramState)?` | `null` | 自定义状态构建器 |

## 工作原理

1. `createMermaidWrapper` 创建一个 `CodeWrapper`，拦截 `language="mermaid"` 的代码块
2. 提取 Mermaid 代码并发送到 Kroki.io API
3. API 返回图表的 PNG 图像
4. 图表以以下状态显示：
   - **加载中**：渲染时显示加载指示器
   - **就绪**：显示渲染的图表（可点击查看全屏）
   - **错误**：显示错误消息并带有重试按钮

## 技术细节

- **API**：使用 [Kroki.io](https://kroki.io) 渲染图表
- **输出格式**：PNG 图像
- **请求超时**：15 秒
- **缓存**：内存缓存，无条目限制
- **防抖**：500ms 延迟，防止过多 API 调用
- **缓存键**：`code|themeName` 用于高效查找

## 支持的图表类型

- 流程图（`graph`）
- 时序图（`sequenceDiagram`）
- 状态图（`stateDiagram-v2`）
- 实体关系图（`erDiagram`）
- 用户旅程（`journey`）
- Git 图（`gitGraph`）
- 思维导图（`mindmap`）
- 时间线（`timeline`）
- 以及更多...

有关支持的 Mermaid 图表类型的完整列表，请参阅 [Mermaid 文档](https://mermaid.js.org/intro/)。

## 图像查看器功能

- **全屏查看**：点击任何渲染的图表即可全屏查看
- **平移和缩放**：使用 `InteractiveViewer` 平移和缩放图表
- **Hero 动画**：打开/关闭查看器时平滑过渡
- **关闭按钮**：点击任意位置或使用关闭按钮退出

## 错误处理

该实现包含全面的错误处理：
- 网络超时检测（15 秒）
- HTTP 错误处理，提供描述性消息
- 失败渲染的重试功能
- 出错时优雅回退到仅代码视图
