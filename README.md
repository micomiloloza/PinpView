# PinpView

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Description
PinpView Library is a custom Swift class that allows you to create floating views similar to WhatsApp's Picture-in-Picture (PiP) feature. With this library, you can easily add floating views with various interactive elements to your iOS applications.

## Features
- Create a floating view with a child view, exit button, activity indicator, and pullout button.
- Customize the appearance of the child view to fit your design requirements.
- Adjust the size and position of the floating view on the screen.
- Enable user interaction with the floating view and its child view.
- Minimize the floating view to a pullout button for a less intrusive display.

## Usage
1. Create a child view that you want to display inside the floating view. Customize the child view based on your requirements.

2. Instantiate the `PinpView` class with the desired frame, indicator color, child view, and pullout icon.

   ```swift
   let childView = UIView() // Create your custom child view
   let pulloutIcon = UIImage(named: "pulloutIcon") // Provide the pullout button icon image
   
   let pinpView = PinpView(frame: CGRect(x: 0, y: 0, width: 200, height: 200), indicatorColor: .gray, childView: childView, pulloutIcon: pulloutIcon)

3. Add the pinpView to your desired superview to make it visible on the screen.
   ```swift
    superview.addSubview(pinpView)
    
## Installation
You can integrate the PinpView Library into your project using Swift Package Manager. Simply add the following dependency to your Package.swift file:

    ```swift

    dependencies: [
        .package(url: "https://github.com/your-username/pinpView.git", from: "1.0.0")
    ]
    
## Contributing
Contributions are welcome! If you have any ideas, suggestions, or bug reports, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License.
