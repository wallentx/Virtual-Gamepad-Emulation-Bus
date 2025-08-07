# CI/CD Documentation

## GitHub Actions Workflows

This repository includes several GitHub Actions workflows for automated building, testing, and code quality checks.

### CI - Build Windows Driver (`ci.yml`)

The main CI workflow builds the ViGEmBus Windows kernel-mode driver for all supported platforms.

**Triggers:**
- Push to any branch (except dependabot branches)
- Pull requests to any branch (except dependabot branches)  
- Manual workflow dispatch

**Platforms Built:**
- x86 (32-bit)
- x64 (64-bit)
- ARM64

**Build Process:**
1. **Checkout**: Downloads repository code and submodules (DMF, ViGEmClient SDK)
2. **Apply DMF Patches**: Applies necessary patches to the Driver Module Framework
3. **Install WDK**: Downloads and installs Windows Driver Kit for driver compilation
4. **Verify Installation**: Validates WDK installation and required dependencies
5. **Build Driver**: Compiles the driver using the existing build system (`build.cmd`)
6. **Create CAB Packages**: Generates deployment packages for all platforms
7. **Upload Artifacts**: Makes build outputs available for download
8. **Generate Summary**: Provides detailed build report with success/failure status

**Build Artifacts:**
- Driver files (`.sys`)
- Installation files (`.inf`)
- Debug symbols (`.pdb`) 
- CAB deployment packages (`.cab`)

**Artifact Retention:** 30 days for regular builds, 90 days for combined artifacts

**Dependencies Installed:**
- Windows Driver Kit (WDK) - Latest stable version
- Visual Studio Build Tools (included with GitHub Actions Windows runner)
- Windows SDK (bundled with WDK)

### CodeQL Analysis (`codeql.yml`)

Performs automated security analysis on the codebase.

**Languages Analyzed:** C, C++, Actions workflows
**Schedule:** Weekly on Sundays
**Triggers:** Push/PR to any branch, scheduled runs

### Common Lint (`common-lint.yml`)

Runs common linting checks on pull requests.

**Triggers:** Pull requests to any branch

## Build Requirements

To build locally, you need:

1. **Windows 10/11** (for kernel-mode driver development)
2. **Visual Studio 2019/2022** with C++ build tools
3. **Windows Driver Kit (WDK)** - Version 10.0.19041.0 or later
4. **Git** with submodule support

## Local Build Instructions

```powershell
# Clone with submodules
git clone --recursive https://github.com/wallentx/Virtual-Gamepad-Emulation-Bus.git
cd Virtual-Gamepad-Emulation-Bus

# Apply DMF patches
cd DMF
git apply --ignore-whitespace ..\patches\*.diff
cd ..

# Build all platforms
.\build.cmd

# Create CAB packages
makecab.exe /f ViGEmBus_x64.ddf
makecab.exe /f ViGEmBus_x86.ddf  
makecab.exe /f ViGEmBus_ARM64.ddf
```

## Troubleshooting Build Issues

### Common Problems:

1. **WDK Installation Failures**
   - Ensure sufficient disk space (>10GB)
   - Run as administrator if installing locally
   - Check Windows version compatibility

2. **Build Errors**
   - Verify all submodules are properly initialized
   - Ensure DMF patches applied correctly
   - Check Visual Studio and WDK versions

3. **Missing Dependencies**
   - Install Visual Studio with C++ desktop development workload
   - Verify Windows SDK installation
   - Check environment variables (WDK paths)

### Getting Help:

- Check the Actions logs for detailed error messages
- Review build summaries for file-level issues
- Compare with successful builds in CI history
- Open an issue with build logs attached

## Workflow Configuration

The workflows are designed to be:

- **Robust**: Comprehensive error handling and retry logic
- **Informative**: Detailed logging and build summaries  
- **Efficient**: Optimized build times with caching where possible
- **Maintainable**: Well-documented steps with clear comments

For workflow modifications, ensure:
- YAML syntax validation
- Test on feature branches before merging
- Update documentation for any changes
- Maintain backwards compatibility where possible