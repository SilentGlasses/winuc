# Contributing to Windows Ultimate Configurator

Thank you for your interest in contributing! We're building a tool that helps people keep their hardware running longer and gives users control over their own computers. Every contribution helps extend the useful life of computers and reduces unnecessary e-waste.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Versioning](#versioning)
- [Pull Request Process](#pull-request-process)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Features](#suggesting-features)
- [Questions](#questions)

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for all contributors.

## 5 Step Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/winuc.git`
3. Create a new branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Push to your fork and submit a pull request

## How to Contribute

We welcome contributions in many forms:

- **Bug fixes**: Fix registry modifications, GUI issues, or script errors
- **New tweaks**: Add new Windows bypasses, privacy settings, or optimizations
- **Documentation**: Improve README, add usage examples, or clarify settings
- **Testing**: Test on different Windows versions and hardware configurations
- **UI improvements**: Enhance the GUI layout, theme detection, or user experience
- **Code quality**: Improve PowerShell script structure and readability

## Development Setup

### Prerequisites

- Windows 10 or Windows 11
- PowerShell 5.1 or later
- Administrator privileges _(required for testing registry changes)_
- A test environment _(VM recommended for testing system modifications)_
    - [VMware Desktop Hypervisor](https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion) _(not affiliated)_
    - [VirtualBox](https://www.virtualbox.org/) is free _(not affiliated)_

### Installation

No installation needed - it's a standalone PowerShell script

- Clone the repository
```powershell
git clone https://github.com/your-username/winuc.git
cd winuc
```
- Test the script (run as Administrator)
```powershell
.\winuc.ps1
```

### Testing Your Changes

**IMPORTANT**: Always test in a safe environment first!

1. **Use a Virtual Machine**: Test all registry changes in a VM before submitting!
2. **Fresh Windows Install**: Test on clean Windows 10 and Windows 11 installations!
3. **Verify Reversibility**: Ensure changes can be undone if needed!
4. **Test New Functions**: Test both "Apply" and "Generate" functionality for new options!
5. **Verify Themes**: Test GUI rendering with both light and dark Windows themes!
6. **Document Side Effects**: Note any unexpected behavior, system restarts, or requirements!

## Coding Standards

### Style Guide

- Follow PowerShell best practices and conventions
- Use descriptive variable names with proper casing (e.g., `$registryPath`, `$optionName`)
- Add comments explaining what each registry key does and why
- Keep enhancement options organized by category
- Write user-facing descriptions in plain English (no jargon)

### Formatting

- Indentation: 4 spaces (standard PowerShell convention)
- Maximum line length: 120 characters for readability
- Place opening braces on the same line as the statement
- Use consistent spacing around operators and parameters

## Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```
feat(privacy): add option to disable Windows Recall

- Add registry modification to disable Recall feature
- Update privacy category in GUI
- Add plain English description
- Tested on Windows 11 24H2

Closes #123
```

```
fix(bypass): correct TPM bypass registry path

- Fix incorrect registry path for TPM 2.0 bypass
- Verify on fresh Windows 11 install

Fixes #45
```

## Versioning

This project follows [Semantic Versioning](https://semver.org/) (SemVer). Version numbers use the format `MAJOR.MINOR.PATCH`:

### Version Format: `MAJOR.MINOR.PATCH`

- **MAJOR** version: Incompatible changes or major feature overhauls
    - Example: Complete UI redesign, removal of deprecated features, breaking changes to autounattend.xml format
    - `1.0.0` → `2.0.0`
- **MINOR** version: New features or enhancements in a backwards-compatible manner
    - Example: New privacy options, additional bypass methods, new optimization categories
    - `1.0.0` → `1.1.0`
- **PATCH** version: Bug fixes and minor improvements that don't add new features
    - Example: Fixed registry path, corrected GUI rendering issue, typo fixes
    - `1.0.0` → `1.0.1`

### What Triggers a Version Bump?

| Change Type | Version Impact | Examples |
|-------------|----------------|----------|
| Breaking changes | MAJOR | Changing command-line interface, removing options, restructuring `autounattend.xml` format |
| New tweaks/options | MINOR | Adding new privacy settings, bypass methods, or optimization categories |
| New features | MINOR | Adding export/import functionality, new GUI themes, command-line parameters |
| Bug fixes | PATCH | Fixing incorrect registry paths, GUI rendering issues, error handling |
| Documentation | PATCH | README updates, comment improvements (no code changes) |
| Refactoring | PATCH | Code cleanup without changing functionality |

### Version Tagging

- Versions are tagged in Git using the format `vMAJOR.MINOR.PATCH` (e.g., `v1.2.3`)
- Each release should have a corresponding Git tag
- Release notes should document all changes since the previous version

### Updating the Version

Maintainers will handle version updates when merging PRs. Contributors should:

1. **Not manually update version numbers** in their PRs
2. **Indicate if the change is breaking** in the PR description
3. **Use conventional commit messages** to help determine version impact

### Pre-release Versions

For testing and development:

- **Alpha**: `1.0.0-alpha.1` - Early testing, features may be incomplete
- **Beta**: `1.0.0-beta.1` - Feature-complete, testing for bugs
- **Release Candidate**: `1.0.0-rc.1` - Final testing before stable release

## Pull Request Process

**IMPORTANT**: Please follow these steps **before** submitting a PR

1. **Test Thoroughly**: Verify changes in a VM with clean Windows install
2. **Update Documentation**: Update README.md if adding new options
3. **Verify Both Modes**: Test both "Apply" (immediate) and "Generate" (`autounattend.xml`)
4. **Check GUI**: Ensure new options display correctly in the interface
5. **Link Issues**: Reference related issues in PR description
6. **Provide Context**: Explain why the change is needed and what it does
7. **Address Feedback**: Respond to review comments promptly

### PR Template

When opening a PR, include:

- **Description**: What does this PR do?
- **Category**: Which category does this affect? (Bypass/Privacy/Security/Performance/Gaming/Network/Cleanup/Appearance)
- **Testing**: How was this tested? (Windows version, VM setup, results)
- **Registry Changes**: What registry keys are modified?
- **Reversible**: Can this change be easily undone?
- **Side Effects**: Any known limitations or requirements?
- **Screenshots**: If UI changes are included
- **Related Issues**: Fixes #(issue number)

## Reporting Bugs

### Before Submitting

- **Always** check for existing issues to avoid duplicates
- Verify the bug in the latest version
- Collect relevant information

### Bug Report Template

```markdown
**Description**
A clear description of the bug.

**Steps to Reproduce**
1. Step one
2. Step two
3. Step three

**Expected Behavior**
What should happen.

**Actual Behavior**
What actually happens.

**Environment**
- Windows Version: [e.g., Windows 11 23H2, Windows 10 22H2]
- PowerShell Version: [e.g., 5.1, 7.3]
- Hardware: [If relevant, e.g., TPM status, CPU generation]
- winuc Version: [e.g., commit hash or release version]

**Additional Context**
Any other relevant information.
```

## Suggesting Features

### Feature Request Template

```markdown
**Feature Description**
Clear description of the feature.

**Use Case**
Why is this feature needed?

**Proposed Solution**
How should this work?

**Alternatives Considered**
Other approaches you've thought about.

**Additional Context**
Any other relevant information.
```

## Adding New Enhancement Options

If you want to add a new registry tweak or system modification:

1. **Locate the options array**: Find `$Global:enhancementOptions` in `winuc.ps1`
2. **Add your option**: Follow the existing structure:
```powershell
@{
    Name = "Your Option Name"
    Description = "Plain English description of what this does and why"
    Category = "Privacy"  # or Bypass, Security, Performance, etc.
    RegistryPath = "HKLM:\SOFTWARE\Path\To\Key"
    RegistryName = "ValueName"
    RegistryValue = 1
    RegistryType = "DWORD"  # or "String"
}
```
3. **Test thoroughly**: Verify in a VM before submitting
4. **Document the change**: Update README.md if it's a significant addition

## Questions

If you have questions:

- Check the [README.md](README.md) for usage instructions
- Search existing [GitHub Issues](https://github.com/SilentGlasses/winuc/issues)
- Open a new issue for bugs or feature requests
- Start a discussion for general questions

## License

By contributing, you agree that your contributions will be licensed under the MIT License, the same license as this project. See [LICENSE](LICENSE) for details.

## Recognition

Contributors will be recognized in:

- Release notes for version updates
- Git commit history
- Special mentions in README.md for significant contributions

## Remember

Every contribution to this project helps:

- Extend the usable life of existing hardware!
- Reduce unnecessary e-waste and environmental impact!
- Give users control over their own computers!
- Push back against artificial obsolescence!

Thank you for contributing!
