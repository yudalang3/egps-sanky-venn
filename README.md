# egps-sanky-venn

eGPS2 Swing modules for Sankey and Venn plots, directly using `egps-shell` and `egps-base`. See [中文说明](README_zh.md).

## Build

Requires JDK 25, Bash, and the JARs in `dependency-egps/`. Set `JAVA_HOME` to the JDK root or put JDK 25 on `PATH`. Linux/macOS/WSL use native Unix Java; run these commands from Bash or zsh without PowerShell.

```bash
bash compile.sh
jar --create --file egps-sanky-venn-0.0.1.jar -C out/production/egps-sanky-venn .
```

Compilation excludes `src/test/`, copies all non-Java resources, and replaces output only after success. Previous output remains under `out/build-egps-sanky-venn.*/backup_egps-sanky-venn`.

For freshly compiled platform sources, replace local base/shell JARs on the compilation classpath:

```bash
bash compile.sh --base-classes /path/to/base/classes --shell-classes /path/to/shell/classes
```

The optional maintainer-only `build_jar_and_move.sh` is Git-ignored. It packages existing output, keeps the local JAR, and backs up old JARs. It deploys only when existing destination directories are explicitly supplied as arguments.

## Integration

Add `egps-sanky-venn-0.0.1.jar` to the eGPS2 host classpath, then enable discovered modules in the module manager. This is a classpath module collection, not a standalone program or a plugin archive with plugin metadata. Use the host's current JVM access arguments.

Source and resources are in `src/`; dependencies are in `dependency-egps/`; output is in `out/production/egps-sanky-venn/`. The plotting modules do not require `egps-pathway.browser-0.0.1.jar`.
