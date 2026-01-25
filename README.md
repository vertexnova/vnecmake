# VneCMake

<p align="center">
  <a href="https://github.com/vertexnova/vnecmake">
    <img src="https://img.shields.io/badge/CMake-3.16%2B-blue.svg" alt="CMake"/>
  </a>
  <img src="https://img.shields.io/badge/license-Apache%202.0-green.svg" alt="License"/>
</p>

Shared CMake modules for VertexNova projects. Contains only common modules used by most libraries.

## Modules

| Module | Description |
|--------|-------------|
| `ProjectSetup.cmake` | Default build type, output directories, LTO settings |
| `ProjectWarnings.cmake` | Compiler-specific warning flags |
| `CCache.cmake` | Compiler cache integration (ccache/sccache) |
| `ClangTidy.cmake` | Clang-Tidy static analysis integration |
| `CppCheck.cmake` | Cppcheck static analysis integration |
| `FindCoverage.cmake` | Code coverage configuration |
| `Doxygen.cmake` | Documentation generation |
| `DebugConfig.cmake` | Debug build configuration |
| `HeaderSetup.cmake` | Header file organization |

## Usage

Add as a submodule inside your project's `cmake/` directory:

```bash
git submodule add git@github.com:vertexnova/vnecmake.git cmake/vnecmake
```

Then in your `CMakeLists.txt`:

```cmake
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/vnecmake/cmake")

include(ProjectSetup)
include(ProjectWarnings)
include(CCache)
# ... include other modules as needed
```

## Library-Specific Modules

Modules for specific third-party libraries (EnTT, Qt, nlohmann/json, etc.) or platform-specific configurations (Emscripten, Swift, Windows) should be placed in each project's own `cmake/` directory, not in vnecmake.

## License

Apache License 2.0 - See [LICENSE](LICENSE) for details.
