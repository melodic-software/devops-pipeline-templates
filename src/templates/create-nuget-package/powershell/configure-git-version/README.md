# PowerShell Scripts for Dynamic GitVersion Configuration Management

This repository contains PowerShell scripts designed to make dynamic changes to a GitVersion configuration file.

## Table of Contents

- [Overview](#overview)
- [Scripts and Configuration](#scripts-and-configuration)
  - [configure-git-version.ps1](#configure-git-versionps1)
  - [functions](#functions)
    - [download-yaml-module.ps1](#download-yaml-moduleps1)
    - [ensure-yaml-module.ps1](#ensure-yaml-moduleps1)
    - [set-pre-release-tag.ps1](#set-pre-release-tagps1)
    - [append-ignore-sha-config.ps1](#append-ignore-sha-configps1)
  - [config.psd1](#configpsd1)
- [Usage](#usage)
- [Error Handling and Edge Cases](#error-handling-and-edge-cases)
- [Documentation and Maintenance](#documentation-and-maintenance)

## Overview

The scripts in this repository provide a robust solution for dynamic updates to a GitVersion config file within a PowerShell environment. Emphasis is placed on maintainability, error handling, and ensuring necessary prerequisites such as the `powershell-yaml` module.

## Scripts and Configuration

### configure-git-version.ps1

The core script, responsible for orchestrating the workflow. It leverages helper scripts to achieve its tasks in the correct sequence.

### functions

A designated directory containing essential helper scripts that offer various functionalities to the main script:

#### download-yaml-module.ps1

Handles the process of fetching and installing the `powershell-yaml` module from a designated URL. Integrated retry mechanisms ensure that transient network issues are gracefully navigated.

#### ensure-yaml-module.ps1

Verifies the presence of the `powershell-yaml` module in the current session. If missing, it initiates an installation attempt from the PowerShell Gallery. If this attempt fails, it defaults to downloading using a URL from the config.

#### set-pre-release-tag.ps1

Central to the management of dynamic pre-release tags in the GitVersion configuration. Especially useful for scenarios with parallel feature branches, it ensures specific branches are given a unique pre-release tag based on its name.

#### append-ignore-sha-config.ps1

Adds functionality to append repository-specific ignore SHA configurations to the GitVersion configuration. This script allows for dynamic customization of the GitVersion configuration based on repository-specific needs.

### config.psd1

A configuration file containing essential parameters, including URLs used by the scripts. Notably, it houses the download URL for the `powershell-yaml` module.

## Usage

1. Navigate to the directory containing `configure-git-version.ps1`.
2. Adjust parameters or paths in `config.psd1` as required.
3. Execute the `configure-git-version.ps1` script.
4. The script will ensure all dependencies are loaded and will make the necessary adjustments to the GitVersion configuration.

## Error Handling and Edge Cases

- **Fallback Download**: In cases where installation of the `powershell-yaml` module from the PowerShell Gallery fails, the script will use the designated download URL in `config.psd1`.
- **Retry Logic**: The download mechanism incorporates retries to handle temporary network interruptions.
- **Module Verification**: Scripts proactively check for the presence of required modules in the session before any installation actions are taken.

## Documentation and Maintenance

- Always ensure to back up your configuration or maintain it under source control before leveraging these scripts for modifications.
- Periodically review and update the scripts to cater to evolving requirements or changes in the ecosystem.