# Entry-Points Directory

The "entry-points" directory serves as the top-level interface for our CI/CD pipelines. It is designed to simplify and streamline the integration process by providing centralized, high-level templates that other pipelines can readily use. These templates, such as "create-nuget-package", encapsulate complex pipeline workflows by referencing a variety of nested templates, scripts, and resources.

## Key Concepts

### 1. **Centralized Integration Point**
By isolating high-level templates in the "entry-points" directory, we offer a unified integration point. This ensures consistency and reduces the chance of errors by limiting direct interactions to the other templates that are prone to functional and organization change.

### 2. **Modularity**
Each template within this directory is crafted to serve a specific purpose. This modular approach makes it easier to maintain, update, and scale our CI/CD processes.

### 3. **Encapsulation**
The templates in this directory abstract away the intricacies of underlying workflows. Users or other pipelines don't need to know the internal details, ensuring a smoother and more intuitive experience.

## ⚠ Warning - Modifying Templates

The templates within the "entry-points" directory, along with their related templates, scripts, and resources, have widespread implications. Changes to these files can affect multiple pipelines and workflows.

Before making changes:

1. **Communicate**: Communicate with the team so everybody is aware of the desired change. Consult with a senior team member if needed.
1. **Understand the Implications**: Ensure you grasp the extent of the impact your changes might have.
2. **Testing**: Always test your changes thoroughly (if possible) in an isolated environment before merging.
3. **Versioning**: If your changes might break existing workflows, consider introducing versioning for your templates. This allows pipelines to specify which version of a template they want to use. Versioning can be applied by using a folder like "v1", "v2" and so on.
4. **Tagging**: Whenever a significant change is made, tag the repository. This provides a clear history of changes and allows for easy rollbacks if needed. Also, existing repositories can reference a tag associated with this repo, which forces the consuming repos to update versions manually.
5. **Documentation**: Update all relevant documentation to reflect your changes. This ensures that users are aware of any new features or modifications.
6. **Review**: Always have another team member review your changes before merging to ensure quality and that no unintentional disruptions occur.

## Usage

To use a template from the "entry-points" directory:

1. Reference the desired template in your pipeline by declaring it as a repository resource.
2. Provide the required parameters as detailed in the specific template's documentation.
3. Let the template handle the rest!

## Contributing

When adding a new high-level template to this directory:

1. Ensure it serves a broad, reusable purpose.
2. Clearly document the expected parameters and any other prerequisites.
3. Test the template in isolation and as part of integrated workflows.
4. Update this README to reflect the addition.

## Available Templates

- **create-nuget-package**: A pipeline template for creating NuGet packages, encompassing steps for preprocessing, building, testing, and packaging.

(Add more templates as they become available)

For detailed information about a specific template, refer to its dedicated documentation.

## Feedback & Questions

For any feedback, questions, or issues, please reach out to a senior team member. Your input helps ensure that the "entry-points" directory remains effective and user-friendly.