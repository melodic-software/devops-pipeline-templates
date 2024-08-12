## Introduction

This repository is dedicated to advancing continuous integration and deployment across a wide range of technologies, with a special focus on .NET projects and Angular applications. By centralizing key build templates and tools, we aim to create a consistent and efficient development and deployment pipeline. Among its assets are PowerShell scripts designed for several operational functionalities, including but not limited to .NET SDK version detection, updating `GitConfig.yaml` settings, and dynamic updates to project files.

## Getting Started

1. **Clone**: Begin by cloning the repository to a directory of your choice.
2. **Directory Structure**: Review the repository's organized layout. Please note, external repositories are intended to only interact with the templates found in the `src/entry-points` directory. Primary templates are organized in aptly named directories, such as `create-nuget-package`. The individual, more granular template files are stored within `src/templates`.
3. **Configuration**: To get acquainted with the core configurations that drive the CI/CD processes, refer to the `global-variables.yaml` file in the `src/templates/shared/variables` directory.

## Build and Test

In the realm of modern software development, having resilient and streamlined CI/CD pipelines is imperative. This repository offers a selection of YAML files, PowerShell scripts, etc. that have been methodically sorted into specific and shared categories. Before deploying these tools in a live setting or integrating them into a CI/CD framework, it's advisable to rigorously review and test them.

## Contribute

Collaboration lies at the heart of our repository's continued success. We welcome insights, improvements, and direct contributions from all members of our team. As you contribute, kindly adhere to established Git methodologies and ensure that any alterations are well-documented and communicated to the rest of the team.

---

For a comprehensive guide on crafting impactful README files, please refer to the [Azure DevOps guide](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-a-readme?view=azure-devops).
