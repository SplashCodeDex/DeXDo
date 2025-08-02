# DeXDo: The To-Do App that gets things done!

DeXDo is a simple and intuitive to-do application designed to help you stay organized and productive.

## Features

*   **Create and Manage Tasks:** Easily add, edit, and delete tasks.
*   **Due Dates:** Assign due dates to your tasks to stay on track.
*   **Sort by Due Date:** Sort your tasks by due date to prioritize your work.
*   **Intuitive UI:** A clean and user-friendly interface for a seamless experience.

This repository contains the source code for the DeXDo mobile application, built with Flutter.

## Architectural Overview

DeXDo is built on a modern and robust architecture to ensure scalability, performance, and maintainability.

*   **Database:** We use the **Isar Database**, a fast, transactional, and queryable NoSQL database for local data persistence.
*   **State Management:** We use **Riverpod** for state management, providing a clean and efficient way to manage application state and separate UI from business logic.
*   **Code Generation:** We use `build_runner` to generate necessary files for Isar. If you make changes to the data models in `lib/models/`, you must run the code generator.

For a detailed explanation of the project's architecture and its evolution, please see the [RELEASE_MANUSCRIPT.md](RELEASE_MANUSCRIPT.md).

## Getting Started

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/SplashCodeDex/DeXDo.git
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the code generator:**
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
4.  **Run the app:**
    ```bash
    flutter run
    ```

## Contributing

We welcome contributions to DeXDo! If you'd like to contribute, please read our [CONTRIBUTING.md](CONTRIBUTING.md) file for guidelines on how to get started.

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.

