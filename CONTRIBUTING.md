# Contributing to DeXDo

First off, thank you for considering contributing to DeXDo! It's people like you that make open source such a great community.

This document provides guidelines for contributing to the project. Please read it carefully to ensure a smooth and effective contribution process.

## How Can I Contribute?

*   **Reporting Bugs:** If you find a bug, please open an issue and provide a detailed description, including steps to reproduce it.
*   **Suggesting Enhancements:** If you have an idea for a new feature or an improvement to an existing one, please open an issue to discuss it.
*   **Pull Requests:** We welcome pull requests for bug fixes, new features, and improvements.

## Development Setup

1.  **Fork the repository** on GitHub.
2.  **Clone your fork** to your local machine:
    ```bash
    git clone https://github.com/YOUR_USERNAME/DeXDo.git
    ```
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run the code generator:** Our project uses `build_runner` to generate files for the Isar database. You must run this command after any changes to the `lib/models/` directory:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

## Branching Strategy

We use a simple branching strategy:

*   **`main`:** This is the main branch, and it should always be stable and deployable.
*   **Feature Branches:** All new features should be developed in a separate branch, prefixed with `feat/`. For example: `feat/cloud-sync`.
*   **Bugfix Branches:** All bug fixes should be developed in a separate branch, prefixed with `fix/`. For example: `fix/login-error`.

## Pull Request Process

1.  Ensure that your code adheres to the project's code style. We use the lints defined in `analysis_options.yaml`.
2.  Make sure all tests pass.
3.  Update the `README.md` and `RELEASE_MANUSCRIPT.md` if your changes affect the architecture or add new features.
4.  Create a pull request from your feature/bugfix branch to the `main` branch.
5.  Provide a clear and descriptive title and description for your pull request.

## Code Style

We follow the official [Effective Dart](https://dart.dev/effective-dart) style guide. Please ensure your code is formatted with `dart format`.

Thank you for your contribution!
