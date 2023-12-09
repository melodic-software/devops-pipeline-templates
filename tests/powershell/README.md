# PowerShell Testing Environment Setup

This document provides instructions on how to set up your local environment for running PowerShell tests in the `tests/powershell` directory.

## Prerequisites

Before running the tests, ensure that you have PowerShell Core (pwsh) installed on your machine. The scripts and tests in this directory are designed to run with PowerShell Core.

## Installing Pester

[Pester](https://github.com/pester/Pester) is the PowerShell testing framework used for our scripts. To run the tests, you must have Pester installed, specifically version 4.0.2 or higher.

### Automated Pester Installation Script

A `ensure-pester-version.ps1` script has been provided to automatically check and install the required version of Pester. To run this script:

1. Open PowerShell.
2. Navigate to the `scripts/powershell` directory.
3. Execute the script:

   ```powershell
   .\ensure-pester-version.ps1

### Manually Running Tests

You can manually run tests in VS Code if you have the PowerShell extension installed. Otherwise, you can update the `run-specific-test.ps1` script and point it towards the test script you want to run.

You may need to run `Install-Module -Name Pester -Force -SkipPublisherCheck -MinimumVersion 5.5.0` in the PowerShell extension terminal so it uses the correct version of Pester.