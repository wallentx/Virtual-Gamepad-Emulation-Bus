#!/bin/bash
# CodeQL prebuild script for Windows C++ analysis

echo "CodeQL prebuild script for Windows C++ analysis"

# Check if we're running on Windows (Git Bash/MSYS2)
if [[ "$RUNNER_OS" == "Windows" ]]; then
    echo "Applying DMF patches for CodeQL analysis..."
    
    # Apply DMF patches if they haven't been applied yet
    if [ -d "DMF" ] && [ -d "patches" ]; then
        cd DMF
        
        # Apply patches
        for patch in ../patches/*.diff; do
            if [ -f "$patch" ]; then
                echo "Applying patch: $patch"
                git apply --ignore-whitespace "$patch" || echo "Warning: Failed to apply $patch"
            fi
        done
        
        cd ..
    else
        echo "Warning: DMF or patches directory not found"
    fi
    
    # Set environment variables for build
    export DmfRootPath="$(pwd)/DMF"
    echo "Set DmfRootPath to: $DmfRootPath"
    
    echo "CodeQL prebuild completed successfully"
else
    echo "Skipping prebuild - not running on Windows"
fi