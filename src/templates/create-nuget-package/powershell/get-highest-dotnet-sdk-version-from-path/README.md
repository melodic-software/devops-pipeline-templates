# PowerShell Functions for .NET SDK Version Extraction

This directory contains a series of PowerShell functions designed to extract and determine the highest .NET SDK version being used across various `.csproj` files in a given path.

## Table of Contents

1. [Overview](#overview)
2. [Functions](#functions)
   - [ConvertTo-SystemVersion](#convertto-systemversion)
   - [Convert-VersionPlaceholders](#convert-versionplaceholders)
   - [Get-DotNetSdkVersionFromProject](#get-dotnetsdkversionfromproject)
   - [Get-DotNetSdkVersionFromProjectContent](#get-dotnetsdkversionfromprojectcontent)
   - [Get-DotNetSdkVersionToReturn](#get-dotnetsdkversiontoreturn)
   - [Get-HighestDotNetSdkVersion](#get-highestdotnetsdkversion)
   - [Get-ProjectDotNetSdkVersion](#get-projectdotnetsdkversion)
   - [Get-ProjectFilePaths](#get-projectfilepaths)
   - [Test-NewDotNetSdkVersionIsHigher](#test-newdotnetsdkversionishigher)
3. [Main Function: Get-HighestDotNetSdkVersionFromPath](#main-function-get-highestdotnetsdkversionfrompath)
4. [Usage](#usage)
5. [Edge Cases and Handling](#edge-cases-and-handling)

## Overview

This collection of functions facilitates the identification of the highest .NET SDK version across one or more .NET projects. The functions enable:

- Efficient parsing of `.csproj` files to retrieve their .NET SDK versions.
- Wildcard path handling to target specific projects or a range of projects.
- Identification of the highest version among all parsed projects.

## Functions

### ConvertTo-SystemVersion

Transforms a version string into a `System.Version` object, replacing any wildcard version qualifiers ("x") in the string with '0'.

### Convert-VersionPlaceholders

Substitutes 'x' characters in a version string with '0'. This is often used to standardize version strings.

### Get-DotNetSdkVersionFromProject

Determines the SDK version from a project file and compares it with the current highest version.

### Get-DotNetSdkVersionFromProjectContent

Extracts the SDK version from a project file's content. It focuses on the TargetFramework(s) value to identify patterns indicative of .NET versions.

### Get-DotNetSdkVersionToReturn

Decides the version to return based on the SDK version and the current highest version.

### Get-HighestDotNetSdkVersion

Scans the provided project file paths, extracts the SDK version from each, and then identifies the highest version among them.

### Get-ProjectDotNetSdkVersion

Analyzes the project file content to determine the .NET SDK version used. If the content doesn't specify the SDK version, it returns a default version.

### Get-ProjectFilePaths

Locates `.csproj` files within the specified directory path, returning an array of file paths.

### Test-NewDotNetSdkVersionIsHigher

Checks if a new SDK version is higher than the current version, returning a boolean value.

## Main Function: Get-HighestDotNetSdkVersionFromPath

This primary function serves as the executor for all other utility functions, managing their sequence and eventually outputting the most elevated .NET SDK version found.

## Usage

1. Adjust the `$ProjectPath` variable to point to the `.csproj` file or desired directory.
2. Execute the `Get-HighestDotNetSdkVersionFromPath` function.
3. The function will return the highest .NET SDK version identified in the provided path.

## Edge Cases and Handling

1. **Fallback Version**: Should no `.csproj` files be located, or if there's an error during parsing, the function defaults to a predetermined fallback version (defaults to '8.x' if not supplied).
2. **Wildcard Handling**: Supports paths containing single (`*`) or double (`**`) wildcards, leading to the corresponding directory or file.
3. **Missing Paths**: Non-existent paths or files will result in an error, terminating the function.
