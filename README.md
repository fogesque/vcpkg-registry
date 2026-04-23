# vcpkg-registry

Private vcpkg registry for the [fogesque](https://github.com/fogesque) C++ packages.

## Ports

| Port | Version | Description |
|------|---------|-------------|
| [errors](ports/errors/) | 1.0.2 | C++ errors library inspired by Go's error concept |
| [kvalog](ports/kvalog/) | 0.2.0 | Unified logging wrapper for different formats and targets |
| [inflare](ports/inflare/) | 0.2.2 | RDMA streaming library targeting NVIDIA ConnectX SmartNICs via DOCA SDK |

## Usage

Add this registry to your project's `vcpkg-configuration.json`:

```json
{
    "default-registry": {
        "kind": "git",
        "baseline": "<microsoft-vcpkg-baseline>",
        "repository": "https://github.com/microsoft/vcpkg"
    },
    "registries": [
        {
            "kind": "git",
            "repository": "https://github.com/fogesque/vcpkg-registry.git",
            "baseline": "<registry-commit-sha>",
            "packages": ["errors", "kvalog", "inflare"]
        }
    ]
}
```

Then declare dependencies in your `vcpkg.json`:

```json
{
    "dependencies": ["inflare"]
}
```

For the GPU variant of inflare:

```json
{
    "dependencies": [
        { "name": "inflare", "features": ["gpunetio"] }
    ]
}
```

Then in CMake:

```cmake
find_package(inflare REQUIRED)
target_link_libraries(my_target PRIVATE inflare::inflare)
```

## Notes

- `inflare` requires the [NVIDIA DOCA SDK](https://developer.nvidia.com/networking/doca) installed on the system — it is a hardware SDK that vcpkg cannot install.
- The `gpunetio` feature additionally requires CUDA 13+ and a DOCA GPUNetIO-capable NIC.
