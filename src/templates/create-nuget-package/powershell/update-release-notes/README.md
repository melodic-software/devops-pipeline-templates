# PowerShell Scripts for Updating Release Notes in .NET Project Files

This repository contains PowerShell scripts designed to update the release notes of `.csproj` files.

## Table of Contents

1. [Overview](#overview)
2. [Scripts](#scripts)
   - [Resolve-ProjectPath](#resolve-projectpath)
   - [Add-PackageReleaseNotes](#add-packagereleasenotes)
   - [Remove-PackageReleaseNotes](#remove-packagereleasenotes)
   - [Update-PackageReleaseNotes](#update-packagereleasenotes)
3. [Main Script: update-release-notes.ps1](#main-script-update-release-notesps1)
4. [Usage](#usage)
5. [Edge Cases and Handling](#edge-cases-and-handling)

## Overview

The scripts in this collection are tailored to manage the `PackageReleaseNotes` node in `.csproj` files. This includes adding, updating, or removing the node based on the provided release notes.

## Scripts

### Resolve-ProjectPath

Resolves the provided path to the `.csproj` file. This function ensures that the path to the project file is accurate and can manage wildcard paths.

### Add-PackageReleaseNotes

If the `PackageReleaseNotes` node doesn't exist in the `.csproj` file, this function creates and populates it with the specified release notes.

### Remove-PackageReleaseNotes

Targets and removes the `PackageReleaseNotes` node from the `.csproj` file, if present.

### Update-PackageReleaseNotes

Updates the content of an existing `PackageReleaseNotes` node with new release notes. If the node is absent, it defers to the `Add-PackageReleaseNotes` function to create it.

## Main Script: update-release-notes.ps1

Serves as the chief script, tying in all utility functions to provide an efficient way to update the release notes in a `.csproj` file. If release notes are not provided or specified as "N/A", the script will remove the `PackageReleaseNotes` node.

## Usage

1. Set the `$ReleaseNotes` variable to the desired release note text.
2. Adjust the `$ProjectPath` variable to point to the `.csproj` file.
3. Run the `update-release-notes.ps1` script.
4. The release notes in the specified `.csproj` file will be updated accordingly.

## Edge Cases and Handling

1. **No Release Notes**: If no release notes are provided or if they are marked as "N/A", the `PackageReleaseNotes` node will be removed from the `.csproj` file.
2. **Path Errors**: If the specified path is not found, the script will halt with an error.
3. **Missing PackageReleaseNotes Node**: In scenarios where the node doesn't exist and release notes are provided, the node will be created and populated.