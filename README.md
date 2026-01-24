# VneCMake

Reusable CMake modules for VertexNova projects.

## Modules

| Module | Description |
|--------|-------------|
| `ProjectSetup.cmake` | Default build type, output directories, LTO settings |
| `ProjectWarnings.cmake` | Compiler-specific warning flags |
| `CCache.cmake` | Compiler cache integration (ccache/sccache) |
| `ClangTidy.cmake` | Clang-Tidy static analysis integration |
| `CppCheck.cmake` | Cppcheck static analysis integration |
| `FindCoverage.cmake` | Code coverage configuration |
| `Backends.cmake` | Graphics backend detection and configuration |
| `Doxygen.cmake` | Documentation generation |
| `Emscripten.cmake` | WebAssembly/Emscripten toolchain |
| `GitSubmodule.cmake` | Git submodule management utilities |
| `HeaderSetup.cmake` | Header file organization |
| `Windows.cmake` | Windows-specific configuration |
| `Swift.cmake` | Swift interoperability |
| `Entt.cmake` | EnTT ECS library integration |
| `FindNlohmannJson.cmake` | nlohmann/json library finder |
| `FindQt.cmake` | Qt library finder |
| `Zlib.cmake` | Zlib compression library |
| `DebugConfig.cmake` | Debug build configuration |

## Usage

Add as a submodule to your project:

```bash
git submodule add git@github.com:vertexnova/vnecmake.git libs/cmake
```

Then in your `CMakeLists.txt`:

```cmake
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/libs/cmake")

include(ProjectSetup)
include(ProjectWarnings)
include(CCache)
# ... include other modules as needed
```

## License

Apache License 2.0 - See [LICENSE](LICENSE) for details.
