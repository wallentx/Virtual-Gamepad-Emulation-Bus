#!/bin/bash
# CodeQL prebuild script for Windows C++ analysis
# This script prepares the build environment for CodeQL analysis

echo "CodeQL prebuild script for Windows C++ analysis"

# Check if we're running on Windows (Git Bash/MSYS2)
if [[ "$RUNNER_OS" == "Windows" ]]; then
    echo "Applying DMF patches for CodeQL analysis..."
    
    # Apply DMF patches if they haven't been applied yet
    if [ -d "DMF" ] && [ -d "patches" ]; then
        cd DMF
        
        # Check if patches are already applied by looking for a marker
        if [ ! -f ".patches_applied" ]; then
            # Apply patches
            for patch in ../patches/*.diff; do
                if [ -f "$patch" ]; then
                    echo "Applying patch: $patch"
                    git apply --ignore-whitespace "$patch" || echo "Warning: Failed to apply $patch"
                fi
            done
            
            # Create marker file
            touch .patches_applied
            echo "DMF patches applied successfully"
        else
            echo "DMF patches already applied"
        fi
        
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