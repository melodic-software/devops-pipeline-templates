# PowerShell Scripts for .NET SDK Version Extraction

This directory contains a series of PowerShell scripts designed to extract and determine the highest .NET SDK version being used across various `.csproj` files in a given path.

## Table of Contents

1. [Overview](#overview)
2. [Scripts](#scripts)
   - [ConvertTo-SystemVersion](#convertto-systemversion)
   - [Find-ProjectFiles](#find-projectfiles)
   - [Get-HighestSdkVersion](#get-highestsdkversion)
   - [ParseProjectFile](#parseprojectfile)
   - [Resolve-ProjectPath & Resolve-WildcardPath](#resolve-projectpath--resolve-wildcardpath)
   - [ValidateInputs](#validateinputs)
3. [Main Script: extract-dotnet-version.ps1](#main-script-extract-dotnet-versionps1)
4. [Usage](#usage)
5. [Edge Cases and Handling](#edge-cases-and-handling)

## Overview

This collection of scripts facilitates the identification of the highest .NET SDK version across one or more .NET projects. The scripts enable:

- Efficient parsing of `.csproj` files to retrieve their .NET SDK versions.
- Wildcard path handling to target specific projects or a range of projects.
- Identification of the highest version among all parsed projects.

## Scripts

### ConvertTo-SystemVersion

Transforms a version string into a `System.Version` object, replacing any wildcard version qualifiers ("x") in the string with '0'.

### Find-ProjectFiles

Searches for all `.csproj` files within a given directory. This function becomes particularly useful when only a directory path is provided without specific `.csproj` file details or wildcards.

### Get-HighestSdkVersion

After compiling a list of `.csproj` files, this script identifies the highest .NET SDK version among them. It utilizes multiple helper functions to ensure accurate version extraction and comparison.

### ParseProjectFile

Extracts the .NET SDK version from the provided `.csproj` file content. It's designed to identify both the older 'netcoreappX.X' format and the newer .NET 5+ 'netX.X' format.

### Resolve-ProjectPath & Resolve-WildcardPath

These functions focus on addressing paths with wildcards. They decipher the genuine path(s) based on the given input and ensure the path's validity. Both single (`*`) and double wildcard (`**`) patterns are supported.

### ValidateInputs

Ensures that a provided `ProjectPath` is non-empty and checks the format of the `FallbackDotNetVersion`. This function is vital for averting typical input-related errors.

## Main Script: extract-dotnet-version.ps1

This primary script serves as the executor for all other utility scripts, managing their sequence and eventually outputting the most elevated .NET SDK version found.

## Usage

1. Adjust the `$ProjectPath` variable to point to the `.csproj` file or desired directory.
2. Execute the `extract-dotnet-version.ps1` script.
3. The script will return the highest .NET SDK version identified in the provided path.

## Edge Cases and Handling

1. **Fallback Version**: Should no `.csproj` files be located, or if there's an error during parsing, the script defaults to a predetermined fallback version (defaults to '8.x' if not supplied).
2. **Wildcard Handling**: Supports paths containing single (`*`) or double (`**`) wildcards, leading to the corresponding directory or file.
3. **Missing Paths**: Non-existent paths or files will result in an error, terminating the script.