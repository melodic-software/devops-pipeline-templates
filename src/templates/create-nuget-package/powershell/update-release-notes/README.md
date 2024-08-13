# PowerShell Functions for Updating Release Notes in .NET Project Files

This folder contains PowerShell functions designed to update the release notes of `.csproj` files.

## Table of Contents

1. [Overview](#overview)
2. [Functions](#functions)
   - [Add-ReleaseNotesToCsproj](#add-releasenotestocsproj)
   - [Remove-ReleaseNotesFromCsproj](#remove-releasenotesfromcsproj)
   - [Update-ReleaseNotesInCsproj](#update-releasenotesincsproj)
   - [Update-ReleaseNotes](#update-releasenotes)
3. [Usage](#usage)
4. [Edge Cases and Handling](#edge-cases-and-handling)

## Overview

The functions in this collection are tailored to manage the `PackageReleaseNotes` node in `.csproj` files. This includes adding, updating, or removing the node based on the provided release notes.

## Functions

### Add-ReleaseNotesToCsproj

If the `PackageReleaseNotes` node doesn't exist in the `.csproj` file, this function creates and populates it with the specified release notes.

### Remove-ReleaseNotesFromCsproj

Targets and removes the `PackageReleaseNotes` node from the `.csproj` file, if present.

### Update-ReleaseNotesInCsproj

Updates the content of an existing `PackageReleaseNotes` node with new release notes. If the node is absent, it defers to the `Add-ReleaseNotesToCsproj` function to create it.

### Update-ReleaseNotes

Serves as the chief function, tying in all utility functions to provide an efficient way to update the release notes in a `.csproj` file. If release notes are not provided or specified as "N/A", the function will remove the `PackageReleaseNotes` node.

## Usage

1. Set the `$ReleaseNotes` variable to the desired release note text.
2. Adjust the `$ProjectPath` variable to point to the `.csproj` file.
3. Run the `UpdateReleaseNotes.ps1` script.
4. The release notes in the specified `.csproj` file will be updated accordingly.

## Edge Cases and Handling

1. **No Release Notes**: If no release notes are provided or if they are marked as "N/A", the `PackageReleaseNotes` node will be removed from the `.csproj` file.
2. **Path Errors**: If the specified path is not found, the function will halt with an error.
3. **Missing PackageReleaseNotes Node**: In scenarios where the node doesn't exist and release notes are provided, the node will be created and populated.
