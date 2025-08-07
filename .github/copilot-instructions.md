# ViGEmBus - Virtual Gamepad Emulation Bus Driver

**ALWAYS follow these instructions first and fallback to additional search and context gathering only when the information in these instructions is incomplete or found to be in error.**

## Project Overview

ViGEmBus is a Windows kernel-mode driver that emulates well-known USB game controllers (Xbox 360 Controller and Sony DualShock 4). This project is **officially retired** but still widely used. The codebase consists of:

- **Driver (`sys/`)**: Windows kernel-mode driver source code
- **SDK (`sdk/`)**: ViGEmClient library for applications  
- **App (`app/`)**: Test application demonstrating driver usage
- **Build System**: NUKE-based build automation using .NET Core 3.1

## CRITICAL LIMITATIONS

**This project builds ONLY on Windows with specific development tools.** Do NOT attempt to build on Linux/macOS.

## Prerequisites (Windows Only)

### Required Development Environment
1. **Windows 10 or Windows 11** (Server versions NOT supported)
2. **Visual Studio 2019** with C++ development tools
3. **Windows Driver Kit (WDK) for Windows 10, version 2004 or later**
4. **Driver Module Framework (DMF)** - must be cloned and built separately

### .NET Requirements
- **.NET Core 3.1** runtime (will be auto-downloaded by build scripts)
- Build system uses NUKE with .NET Core 3.1 (project targets `netcoreapp3.1`)

## Repository Setup

### Clone DMF Dependency
```cmd
cd /path/to/parent-directory
git clone https://github.com/microsoft/DMF.git
```

**CRITICAL**: DMF must be cloned in the **same parent directory** as ViGEmBus, not inside it.

### Build DMF First
```cmd
cd DMF
# Build for all required platforms and configurations
msbuild Dmf.sln /p:Configuration=Debug /p:Platform=Win32
msbuild Dmf.sln /p:Configuration=Debug /p:Platform=x64
msbuild Dmf.sln /p:Configuration=Release /p:Platform=Win32  
msbuild Dmf.sln /p:Configuration=Release /p:Platform=x64
# For ARM64 support (if building ARM64 ViGEmBus)
msbuild Dmf.sln /p:Configuration=Debug /p:Platform=ARM64
msbuild Dmf.sln /p:Configuration=Release /p:Platform=ARM64
```

**NEVER CANCEL**: DMF build takes 15-45 minutes depending on configuration. Set timeout to 60+ minutes.

## Building ViGEmBus

### Build Commands (Windows)
```cmd
# Using PowerShell (recommended)
.\build.ps1

# Using Command Prompt  
.\build.cmd

# Using Bash (if available)
.\build.sh
```

**NEVER CANCEL**: Complete build takes 10-30 minutes. Set timeout to 45+ minutes.

### Build Process Details
1. **Downloads .NET Core 3.1 SDK** if not already installed (5-10 minutes)
2. **Builds NUKE build project** (`build/_build.csproj`) using .NET Core 3.1 (2-5 minutes)
3. **Builds DMF dependencies** for target platform (10-20 minutes)
4. **Builds ViGEmBus solution** (`ViGEmBus.sln`) in all configurations (10-15 minutes)

### Expected Build Artifacts
```
bin/
├── Debug/
│   ├── x64/
│   │   ├── ViGEmBus/
│   │   │   ├── ViGEmBus.sys    # Driver binary
│   │   │   ├── ViGEmBus.inf    # Driver installation file  
│   │   │   └── ViGEmBus.pdb    # Debug symbols
│   │   ├── ViGEmClient/
│   │   │   ├── ViGEmClient.lib # Static library
│   │   │   └── ViGEmClient.dll # Dynamic library
│   │   └── app/
│   │       └── app.exe         # Test application
│   ├── Win32/
│   │   └── [same structure]
│   └── ARM64/
│       └── [same structure]
└── Release/
    └── [same structure for production builds]
```

### Platform Support
- **x86 (Win32)**: 32-bit Windows applications
- **x64**: 64-bit Windows applications  
- **ARM64**: ARM64 Windows devices

## Testing and Validation

**WARNING**: Driver testing requires Administrator privileges and test signing enabled.

### Enable Test Signing (Required for Development)
```cmd
# Run as Administrator
bcdedit /set testsigning on
# Reboot required
shutdown /r /t 0
```

### Install Driver for Testing
```cmd
# Navigate to build output directory
cd bin\Debug\x64\ViGEmBus
# Install driver (requires Administrator)
pnputil /add-driver ViGEmBus.inf /install
```

### Test Application Usage
```cmd
cd bin\Debug\x64\app
.\app.exe
```

**Expected Behavior**: Application connects to ViGEmBus driver and creates a DualShock 4 controller, displaying output reports in hex format.

### Manual Validation Scenarios
After building and installing:

1. **Driver Installation Test**:
   ```cmd
   # Verify driver is loaded
   driverquery /v | findstr ViGEmBus
   ```

2. **Device Creation Test**:
   - Run `app.exe` 
   - Check Device Manager for new "Wireless Controller" under "Xbox 360 Controller for Windows"

3. **Uninstall Test**:
   ```cmd
   # Remove driver
   pnputil /delete-driver ViGEmBus.inf /uninstall /force
   ```

## Development Workflow

### Code Navigation
- **`sys/ViGEmBus.vcxproj`**: Main driver project
- **`sys/Driver.cpp`**: Driver entry point and core functionality
- **`sys/XusbPdo.cpp`**: Xbox 360 controller emulation
- **`sys/Ds4Pdo.cpp`**: DualShock 4 controller emulation  
- **`sdk/src/ViGEmClient.vcxproj`**: Client SDK library
- **`app/app.cpp`**: Test application demonstrating SDK usage

### Making Changes
1. **Always build DMF first** after pulling updates
2. **Build entire solution** for comprehensive testing
3. **Test with both Debug and Release configurations**
4. **Validate on all target platforms** (x86, x64, ARM64 if available)

### Common Build Issues

**"DMF not found"**: Ensure DMF is cloned in parent directory and built
```cmd
# Check DMF location  
dir ..\DMF\Dmf.sln
# Verify DMF build output
dir ..\DMF\Debug\x64\lib\DmfK\DmfK.lib
```

**".NET Core 3.1 not found"**: Let build script auto-install or manually install
```cmd
# Manual installation
dotnet --list-sdks | findstr 3.1
```

**"Certificate required"**: For production use, driver must be properly signed
```cmd
# Development only - enable test signing
bcdedit /set testsigning on
```

## CI/CD Information

### AppVeyor Configuration
- **Build triggers**: All commits except documentation-only changes
- **Platforms**: x86, x64, ARM64
- **Artifacts**: Driver binaries (`.sys`, `.inf`), test applications, PDB files
- **Signed CAB files**: Generated for distribution

### Build Time Expectations
- **DMF build**: 15-45 minutes (NEVER CANCEL)
- **ViGEmBus build**: 10-30 minutes (NEVER CANCEL)  
- **Total CI build**: 45-90 minutes per platform
- **Signing and packaging**: 5-10 minutes

## Non-Windows Development

**DO NOT attempt to build this project on Linux or macOS.** This is a Windows kernel driver that requires:
- Windows-specific APIs and headers
- Windows Driver Kit (WDK) 
- Microsoft C++ compiler with kernel-mode support

### What CAN be done on non-Windows:
- **Code review and analysis**
- **Documentation updates**
- **Issue triage and planning**
- **SDK header analysis** (read-only)

### What CANNOT be done on non-Windows:
- **Building the driver or SDK**
- **Testing driver functionality**  
- **Running the test application**
- **Driver installation or debugging**

## SDK Usage for Developers

Include ViGEmClient SDK in your applications:
```cpp
#include <ViGEm/Client.h>
#pragma comment(lib, "ViGEmClient.lib")

// Basic usage example
const auto client = vigem_alloc();
vigem_connect(client);
const auto controller = vigem_target_x360_alloc();
vigem_target_add(client, controller);
```

Refer to `app/app.cpp` for complete working examples.

## Known Limitations

1. **Windows-only**: No cross-platform support possible for kernel driver
2. **Administrator required**: Driver installation needs elevated privileges  
3. **Test signing**: Development builds require test signing enabled
4. **Visual Studio dependency**: Cannot build with other compilers
5. **DMF dependency**: Must maintain separate DMF clone and build

Always reference this document first before attempting builds or making changes to save time and avoid common pitfalls.

## Common Directories and Files Reference

### Repository Structure (ls -la .)
```
.git/              # Git repository data
.github/           # GitHub workflows and documentation
.gitmodules        # Git submodule configuration
.nuke              # NUKE build configuration (points to ViGEmBus.sln)
.vscode/           # VS Code settings
ViGEmBus.sln       # Main Visual Studio solution
appveyor.yml       # AppVeyor CI/CD configuration  
build/             # NUKE build system (.NET Core)
build.cmd          # Windows batch build script
build.ps1          # PowerShell build script (recommended)
build.sh           # Bash build script (cross-platform entry)
sys/               # Kernel driver source code
sdk/               # ViGEmClient SDK (currently empty in this repo)
app/               # Test application
drivers/           # Signed driver binaries (for releases)
stage0.ps1         # Release automation script
```

### Key Files for Development
```
# Build configuration
build/Build.cs                    # NUKE build targets and logic
build/_build.csproj               # .NET Core 3.1 build project

# Driver source
sys/ViGEmBus.vcxproj              # Driver project file
sys/ViGEmBus.inf                  # Driver installation manifest
sys/Driver.cpp                    # Main driver entry point
sys/XusbPdo.cpp                   # Xbox 360 controller emulation
sys/Ds4Pdo.cpp                    # DualShock 4 controller emulation
sys/Dmf.props                     # DMF integration properties

# Test application
app/app.vcxproj                   # Test app project
app/app.cpp                       # Test app source (SDK usage example)

# Platform-specific cabinet definitions
ViGEmBus_x64.ddf                  # x64 cabinet definition
ViGEmBus_x86.ddf                  # x86 cabinet definition  
ViGEmBus_ARM64.ddf                # ARM64 cabinet definition
```