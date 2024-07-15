# SCEPKit

SCEPKit is a Swift package designed to simplify the management of typical iOS app workflows. This package provides tools for handling splash screens, onboarding processes, paywalls, settings screens, tracking premium status, and more. By integrating SCEPKit, you can streamline your app development process and ensure a consistent user experience.

## Features

- **Splash Screen**: Easily configure and display a splash screen.
- **Onboarding**: Manage the onboarding process for new users.
- **Paywalls**: Implement paywalls to handle in-app purchases and subscriptions.
- **Settings Screen**: Provide a customizable settings screen for users.
- **Premium Status Tracking**: Track and manage user premium status.
- **Firebase Integration**: Seamlessly integrate Firebase for tracking and analytics.

## Installation

To install SCEPKit using Swift Package Manager, add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SCEPKit.git", from: "1.0.0")
]
```

Alternatively, you can add SCEPKit directly through Xcode:
1. Open your project in Xcode.
2. Go to `File > Add Packages...`.
3. Enter the URL `https://github.com/yourusername/SCEPKit.git`.
4. Choose the version and click `Add Package`.

## Configuration

### 1. Configure `SCEPKit.plist`

Create a `SCEPKit.plist` file in your project and configure it according to your app's requirements. This file will contain various settings used by SCEPKit.

### 2. Add Custom Fonts to Project

To use custom fonts in your project, follow these steps:

1. Add your font files (e.g., `.ttf` or `.otf`) to your Xcode project.
2. Ensure the font files are included in the `Copy Bundle Resources` build phase.
3. Update your `Info.plist` file to include the fonts:

```xml
<key>UIAppFonts</key>
<array>
    <string>YourCustomFont-Regular.ttf</string>
    <string>YourCustomFont-Bold.ttf</string>
</array>
```

### 3. Add `SCEPKit.xcassets`

Add the `SCEPKit.xcassets` asset catalog to your project. This catalog should contain any images or other assets used by SCEPKit.

1. Drag and drop the `SCEPKit.xcassets` folder into your Xcode project.
2. Ensure the assets are included in the `Copy Bundle Resources` build phase.

### 4. Add Firebase Configuration

To integrate Firebase, add the `GoogleService-Info.plist` file to your project:

1. Download the `GoogleService-Info.plist` file from the Firebase Console.
2. Add the `GoogleService-Info.plist` file to your Xcode project.
3. Ensure the file is included in the `Copy Bundle Resources` build phase.

## Contributing

Contributions are welcome! If you have any ideas, suggestions, or bug reports, please create an issue or submit a pull request.

## License

SCEPKit is released under the MIT License.

---

Thank you for using SCEPKit! We hope it makes your iOS app development experience smoother and more enjoyable. If you have any questions or need further assistance, please don't hesitate to reach out.
