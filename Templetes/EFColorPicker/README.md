![](https://raw.githubusercontent.com/EyreFree/EFColorPicker/master/assets/EFColorPicker.png)

<p align="center">
<a href="https://travis-ci.org/EyreFree/EFColorPicker"><img src="http://img.shields.io/travis/EyreFree/EFColorPicker.svg"></a>
<a href="http://cocoapods.org/pods/EFColorPicker"><img src="https://img.shields.io/cocoapods/v/EFColorPicker.svg?style=flat"></a>
<a href="http://cocoapods.org/pods/EFColorPicker"><img src="https://img.shields.io/cocoapods/p/EFColorPicker.svg?style=flat"></a>
<a href="https://github.com/apple/swift"><img src="https://img.shields.io/badge/language-swift-orange.svg"></a>
<a href="https://raw.githubusercontent.com/EyreFree/EFColorPicker/master/LICENSE"><img src="https://img.shields.io/cocoapods/l/EFColorPicker.svg?style=flat"></a>
<a href="https://twitter.com/EyreFree777"><img src="https://img.shields.io/badge/twitter-@EyreFree777-blue.svg?style=flat"></a>
<a href="http://weibo.com/eyrefree777"><img src="https://img.shields.io/badge/weibo-@EyreFree-red.svg?style=flat"></a>
<img src="https://img.shields.io/badge/made%20with-%3C3-orange.svg">
</p>

EFColorPicker is a lightweight color picker in Swift, inspired by [MSColorPicker](https://github.com/sgl0v/MSColorPicker).

> [中文介绍](https://github.com/EyreFree/EFColorPicker/blob/master/README_CN.md)

## Overview

Color picker component for iOS. It allows the user to select a color with color components. Key features:

- iPhone & iPad support
- Adaptive User Interface
- Supports RGB and HSB color models
- Well-documented
- Compatible with iOS 8.0 (iPhone &amp; iPad) and higher

## Preview

| iPhone |   | iPad |
|:---------------------:|:---------------------:|:---------------------:|
![](https://raw.githubusercontent.com/EyreFree/EFColorPicker/master/assets/sample_iphone.png)|![](https://raw.githubusercontent.com/EyreFree/EFColorPicker/master/assets/sample_iphone.gif)|![](https://raw.githubusercontent.com/EyreFree/EFColorPicker/master/assets/sample_ipad.gif)   

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Then build and run `EFColorPicker.xcworkspace` in Xcode, the demo shows how to use and integrate the EFColorPicker into your project.

## Requirements

- iOS 8.0+
- Xcode 9.0+
- Swift 4.0+

## Installation

EFColorPicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'EFColorPicker'
```

## Use

1. First, include EFColorPicker in your project:

```swift
import EFColorPicker
```

2. Next, we can call EFColorPicker with pure code:

```swift
let colorSelectionController = EFColorSelectionViewController()
let navCtrl = UINavigationController(rootViewController: colorSelectionController)
navCtrl.navigationBar.backgroundColor = UIColor.white
navCtrl.navigationBar.isTranslucent = false
navCtrl.modalPresentationStyle = UIModalPresentationStyle.popover
navCtrl.popoverPresentationController?.delegate = self
navCtrl.popoverPresentationController?.sourceView = sender
navCtrl.popoverPresentationController?.sourceRect = sender.bounds
navCtrl.preferredContentSize = colorSelectionController.view.systemLayoutSizeFitting(
    UILayoutFittingCompressedSize
)

colorSelectionController.delegate = self
colorSelectionController.color = self.view.backgroundColor ?? UIColor.white

if UIUserInterfaceSizeClass.compact == self.traitCollection.horizontalSizeClass {
    let doneBtn: UIBarButtonItem = UIBarButtonItem(
        title: NSLocalizedString("Done", comment: ""),
        style: UIBarButtonItemStyle.done,
        target: self,
        action: #selector(ef_dismissViewController(sender:))
    )
    colorSelectionController.navigationItem.rightBarButtonItem = doneBtn
}
self.present(navCtrl, animated: true, completion: nil)
```

Also we can use EFColorPicker in Storyboard:

```swift
if "showPopover" == segue.identifier {
	guard let destNav: UINavigationController = segue.destination as? UINavigationController else {
	    return
	}
	if let size = destNav.visibleViewController?.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize) {
	    destNav.preferredContentSize = size
	}
	destNav.popoverPresentationController?.delegate = self
	if let colorSelectionController = destNav.visibleViewController as? EFColorSelectionViewController {
	    colorSelectionController.delegate = self
	    colorSelectionController.color = self.view.backgroundColor ?? UIColor.white

	    if UIUserInterfaceSizeClass.compact == self.traitCollection.horizontalSizeClass {
	        let doneBtn: UIBarButtonItem = UIBarButtonItem(
	            title: NSLocalizedString("Done", comment: ""),
	            style: UIBarButtonItemStyle.done,
	            target: self,
	            action: #selector(ef_dismissViewController(sender:))
	        )
	        colorSelectionController.navigationItem.rightBarButtonItem = doneBtn
	    }
	}
}
```

You can control the visibility of color textField by change the `isColorTextFieldHidden` property of `EFColorSelectionViewController`, for example:

| isColorTextFieldHidden: true |   | isColorTextFieldHidden: false |   |
|:---------------------:|:---------------------:|:---------------------:|:---------------------:|
![](https://raw.githubusercontent.com/EyreFree/EFColorPicker/master/assets/sample_iphone1.png)|![](https://raw.githubusercontent.com/EyreFree/EFColorPicker/master/assets/sample_iphone2.png)|![](https://raw.githubusercontent.com/EyreFree/EFColorPicker/master/assets/sample_iphone3.png)|![](https://raw.githubusercontent.com/EyreFree/EFColorPicker/master/assets/sample_iphone4.png)   

For more detail, please see the demo.

3. Last but not the least, you should implement `EFColorSelectionViewControllerDelegate` so you can sense the color changes:

```swift
// MARK:- EFColorSelectionViewControllerDelegate
func colorViewController(colorViewCntroller: EFColorSelectionViewController, didChangeColor color: UIColor) {
    self.view.backgroundColor = color

    // TODO: You can do something here when color changed.
   //print("New color: " + color.debugDescription)
}
```

## PS

The first version of [EFColorPicker](https://github.com/EyreFree/EFColorPicker/releases/tag/0.0.1) is converted from [MSColorPicker](https://github.com/sgl0v/MSColorPicker/commit/b15f6cfabf4e406368f730f3f66f823bf1593293), thanks for [sgl0v](https://github.com/sgl0v)'s work!

## Author

EyreFree, eyrefree@eyrefree.org

## License

![](https://upload.wikimedia.org/wikipedia/commons/thumb/f/f8/License_icon-mit-88x31-2.svg/128px-License_icon-mit-88x31-2.svg.png)

EFColorPicker is available under the MIT license. See the LICENSE file for more info.
