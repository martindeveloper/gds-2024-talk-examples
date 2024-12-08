#!/usr/bin/env pwsh

# Stop on errors
$ErrorActionPreference = 'Stop'

# Determine the script root directory
$SCRIPT_ROOT = Split-Path -Parent $PSCommandPath

# Initialize variables
$ZIG_PATH = ""
$ZIG_VERSION = ""
$ODIN_PATH = ""
$ODIN_VERSION = ""

Write-Host "GDS 2024 Sample Code Repository"
Write-Host ""

Write-Host "[Zig] Building"

# Check if zig is installed
if (-not (Get-Command zig -ErrorAction SilentlyContinue)) {
    Write-Host "[FATAL] zig is not installed!"
    exit 1
} else {
    $ZIG_VERSION = (zig version).Trim()
    $ZIG_PATH = (Get-Command zig).Source
}

Write-Host "[Zig] Path: $ZIG_PATH"
Write-Host "[Zig] Version: $ZIG_VERSION"

# Find all directories under $SCRIPT_ROOT/src/zig and build if build.zig exists
Get-ChildItem -Directory -Recurse -Path (Join-Path $SCRIPT_ROOT "src/zig") | ForEach-Object {
    $PROJECT = $_.FullName
    if (Test-Path (Join-Path $PROJECT "build.zig")) {
        Write-Host " - Building at '$PROJECT'"
        Push-Location $PROJECT
        zig build -freference-trace
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[ERROR] Error building project: $PROJECT"
            Pop-Location | Out-Null
            return
        }
        Pop-Location | Out-Null
    }
}

Write-Host "[Zig] Done"
Write-Host ""

Write-Host "[Odin] Building"

# Check if odin is installed
if (-not (Get-Command odin -ErrorAction SilentlyContinue)) {
    Write-Host "[FATAL] odin is not installed!"
    exit 1
} else {
    $ODIN_VERSION = (odin version).Trim()
    $ODIN_PATH = (Get-Command odin).Source
}

Write-Host "[Odin] Path: $ODIN_PATH"
Write-Host "[Odin] Version: $ODIN_VERSION"

# Find all directories under $SCRIPT_ROOT/src/odin and build if main.odin exists
Get-ChildItem -Directory -Recurse -Path (Join-Path $SCRIPT_ROOT "src/odin") | ForEach-Object {
    $PROJECT = $_.FullName
    if (Test-Path (Join-Path $PROJECT "main.odin")) {
        Write-Host " - Building at '$PROJECT'"
        Push-Location $PROJECT

        $FOLDER_BASE_NAME = Split-Path $PROJECT -Leaf
        $OUT_FOLDER = Join-Path $PROJECT "odin-out"
        $OUT_FILEPATH = Join-Path $OUT_FOLDER $FOLDER_BASE_NAME
        if ($IsWindows) {
            $OUT_FILEPATH += ".exe"
        }

        Write-Host " - mkdir if not exists: $OUT_FOLDER"
        if (-not (Test-Path $OUT_FOLDER)) {
            New-Item -ItemType Directory $OUT_FOLDER | Out-Null
        }

        Write-Host " - output file: $OUT_FILEPATH"

        odin build . -build-mode:exe -out:"$OUT_FILEPATH" -debug
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[ERROR] Error building project: $PROJECT"
            Pop-Location | Out-Null
            return
        }

        Pop-Location | Out-Null
    }
}

Write-Host "[Odin] Done"
exit 0
