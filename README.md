# renaming

一个功能强大的文件重命名工具，支持批量重命名操作和自定义规则。

## 项目结构

本项目采用模块化设计，包含以下三个子项目：

- **renaming_share** - 核心共享库，包含重命名逻辑和规则引擎
- **renaming_gui** - Flutter GUI应用程序，提供直观的图形界面
- **renaming_cli** - 命令行工具，适用于脚本和自动化场景

## 功能特性

### 核心功能
- 🔄 批量文件重命名
- 📝 自定义重命名规则
- 🎯 模式匹配和替换
- 📁 支持文件夹拖拽
- 💾 规则配置保存和加载
- 🔍 实时预览重命名结果

### 支持的重命名规则
- 添加前缀/后缀
- 删除指定内容
- 替换文本模式
- 位置插入/删除
- 范围操作
- 分隔符处理

## 快速开始

### 环境要求
- Dart SDK 3.5.0+
- Flutter 3.5.0+ (仅GUI版本)

### 安装依赖

```bash
# 安装共享库依赖
cd renaming_share
dart pub get

# 安装GUI应用依赖
cd ../renaming_gui
flutter pub get

# 安装CLI工具依赖
cd ../renaming_cli
dart pub get