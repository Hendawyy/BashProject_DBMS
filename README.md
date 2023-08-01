# BashProject_DBMS

## Description

## Installation

## Usage

## Supported Commands

## Data Storage

## Limitations

## Acknowledgments

## Project Status

## Active Development.

## Getting Started

### GUI Considerations

When starting this project, I considered using a GUI to provide a more user-friendly interface for managing the database engine. After conducting some research, I found several GUI tools that were potential candidates for integration:

1. **dialog**: dialog is a utility for creating text-based dialog boxes and interactive menus in the Linux terminal. It is often used to build simple user interfaces for shell scripts. It uses the ncurses library to display text-based windows with buttons, input fields, and other interactive elements.

2. **zenity**: zenity is an improvement over dialog, providing graphical user interfaces (GUIs) in the form of popup windows. It uses the GTK+ toolkit to create windows with buttons, input boxes, message boxes, and more. zenity allows you to create basic GUIs in shell scripts and is a step up from pure text-based interfaces offered by dialog.

3. **yad (Yet Another Dialog)**: yad is an extension of zenity and is designed to offer even more features and flexibility for creating graphical user interfaces in shell scripts. It also uses the GTK+ toolkit like zenity but provides additional capabilities, including built-in support for tables, forms, and more complex GUI elements. With yad, you can create rich, interactive interfaces with buttons, checkboxes, dropdown lists, and custom forms.

To summarize, the progression is from text-based interfaces (dialog) to basic graphical interfaces (zenity) and finally to more feature-rich and complex graphical interfaces (yad). Each tool offers different levels of functionality and complexity, and you can choose the one that best suits your needs when creating GUIs in bash or other shell scripts.

### Comparison of GUI Tools

| Feature                 | dialog                             | zenity                                | yad                                  |
| ----------------------- | ---------------------------------- | ------------------------------------ | ------------------------------------ |
| Availability            | Pre-installed on many Linux systems | May require installation on some systems | May require installation on some systems |
| Language Support        | Text-based interface (ncurses)     | GTK-based GUI                        | GTK-based GUI                        |
| Table Handling          | Limited or no direct support for tables | Limited support for tables           | Built-in support for tables and forms |
| Table Functionality     | N/A                                | Display tables with text-info        | Display tables with --list or --table |
| Customization Options   | Limited customization              | Some customization options           | Highly customizable with many options |
| Interactivity           | Basic user interactions (menus, forms) | Basic user interactions (message boxes, input boxes) | Rich interactivity with buttons, forms, etc. |
| Script Complexity       | Suitable for simple scripts        | Suitable for basic GUIs              | Suitable for complex GUIs and interactions |
| Learning Curve          | Easy to learn and use              | Easy to learn and use                | May require some learning for advanced features |
| Output Format           | Text-based interface               | Popup windows                        | Popup windows or embedded in terminal |
| Documentation           | Well-documented with examples       | Decent documentation available       | Documentation available but may be limited |
| HTML & CSS Support      | NO                                 | NO                                   | YES                                  |
