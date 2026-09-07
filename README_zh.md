# egps-sanky-venn

eGPS2 的Sankey 图和 Venn 图 Swing 模块，直接使用 `egps-shell` 和 `egps-base`。参见 [English README](README.md)。

## 编译

需要 JDK 25、Bash 和 `dependency-egps/` 中的 JAR。将 `JAVA_HOME` 指向 JDK 根目录，或将 JDK 25 加入 `PATH`。Linux/macOS/WSL 使用原生 Unix Java，在 Bash 或 zsh 中执行下列命令，无需 PowerShell。

```bash
bash compile.sh
jar --create --file egps-sanky-venn-0.0.1.jar -C out/production/egps-sanky-venn .
```

编译排除 `src/test/`，复制所有非 Java 资源，仅在成功后替换输出。旧输出保存在 `out/build-egps-sanky-venn.*/backup_egps-sanky-venn`。

使用当前平台源码重新编译的类时，在编译 classpath 中替换本地 base/shell JAR：

```bash
bash compile.sh --base-classes /path/to/base/classes --shell-classes /path/to/shell/classes
```

可选的维护者本地脚本 `build_jar_and_move.sh` 被 Git 忽略，不随仓库提供。它打包已有输出，保留本地 JAR，并备份旧 JAR；只有显式传入已有目标目录参数时才部署。

## 集成

将 `egps-sanky-venn-0.0.1.jar` 加入 eGPS2 宿主 classpath，再在模块管理器中启用发现的模块。这是 classpath 模块集合，不是独立程序，也不是带插件元数据的插件归档。JVM 访问参数以当前宿主为准。

源码和资源位于 `src/`，依赖位于 `dependency-egps/`，输出位于 `out/production/egps-sanky-venn/`。绘图模块不需要 `egps-pathway.browser-0.0.1.jar`。
