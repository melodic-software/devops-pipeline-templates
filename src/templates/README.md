# Templates Directory

Welcome to the `src/templates` directory. This is the heart of our templating system, providing modular components that are orchestrated by our entry-point templates located in the `src/entry-points` directory.

## Overview

The structure of the `src/templates` directory is designed to offer granularity, reusability, and organization. It's filled with various resources, including PowerShell scripts, YAML templates (for stages, jobs, steps, and variables), and other essential components. Templates contained herein are categorized under specific named folders (e.g., `src/templates/create-nuget-package`). Additionally, we have a `src/templates/shared` folder containing templates and resources that are common across multiple workflows.

## Contents

- **PowerShell Scripts**: These scripts handle various automation tasks and are crucial for several pipeline operations. Make sure to thoroughly test any new or modified script to ensure it behaves as expected.

- **YAML Templates**: The backbone of our CI/CD processes. We have templates designed for:
  - **Stages**: Representing a phase in the pipeline.
  - **Jobs**: Individual units of work in a stage.
  - **Steps**: Sequential tasks within a job.
  - **Variables**: Configurations and values used throughout the pipeline.

- **Named Folders**: These folders (like `src/templates/create-nuget-package`) encapsulate templates related to a specific workflow or task. Each named folder might contain a series of related templates, scripts, and other necessary files that define and support that workflow.
  
- **Shared Folder (`src/templates/shared`)**: A repository of common templates and resources. Items in this folder might be referenced by multiple named template folders, ensuring we maintain a DRY (Don't Repeat Yourself) principle in our pipeline configurations.

## ⚠ Warning - Modifying Resources

The resources within the `src/templates` directory have widespread implications. Changes to these files can affect multiple pipelines and workflows across our infrastructure.

Before making changes:

1. **Understand the Implications**: Ensure you grasp the extent of the impact your changes might have.
2. **Testing**: Always test your changes thoroughly in an isolated environment before merging (if possible).
3. **Versioning**: If your changes might break existing workflows, consider introducing versioning for your templates. This allows pipelines to specify which version of a template they want to use.
4. **Tagging**: Whenever a significant change is made, tag the repository. This provides a clear history of changes and allows for easy rollbacks if needed.
5. **Documentation**: Update all relevant documentation to reflect your changes. This ensures that users are aware of any new features or modifications.
6. **Review**: Always have another team member review your changes before merging to ensure quality and that no unintentional disruptions occur.

## Usage

When constructing or updating a pipeline:

1. Check if the desired workflow or task already exists under a named folder.
2. Utilize templates from the `shared` directory for common tasks or components to avoid redundancy.
3. Reference the appropriate template in your pipeline or, if needed, in the `src/entry-points` templates.

## Contribution Guidelines

If you're looking to contribute:

1. Ensure that the template or resource you're adding doesn't already exist to avoid duplication.
2. Place your contribution in the corresponding folder based on its type (PowerShell script, stage template, etc.)
3. Always document your additions, so other team members can understand and use them with ease.
4. Test your templates thoroughly before pushing to ensure compatibility with existing systems.

## Feedback & Collaboration

Collaboration is the key to maintaining a healthy and efficient templating system. If you have questions, feedback, or suggestions, please reach out to a senior team member. Let's work together to keep our pipeline processes seamless and effective!