# FloatingPlaceholderTextField

<!--[![CI Status](https://img.shields.io/travis/cheisesu/FloatingPlaceholderTextField.svg?style=flat)](https://travis-ci.org/cheisesu/FloatingPlaceholderTextField)-->
[![Version](https://img.shields.io/cocoapods/v/FloatingPlaceholderTextField.svg?style=flat)](https://cocoapods.org/pods/FloatingPlaceholderTextField)
[![License](https://img.shields.io/cocoapods/l/FloatingPlaceholderTextField.svg?style=flat)](https://cocoapods.org/pods/FloatingPlaceholderTextField)
[![Platform](https://img.shields.io/cocoapods/p/FloatingPlaceholderTextField.svg?style=flat)](https://cocoapods.org/pods/FloatingPlaceholderTextField)

Custom implementation of UITextField for floating placeholder with its animation.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS version 12.0 and upper
- Swift 5.0 and upper

## Usage

You can use this text field implementation as via Interface Builder as in code. 

First here is cases of states:

- **default** - state when the field is not a first responder or not disabled, or without text
- **active** - state that indicates whether the field is first responder.
- **filled** - state when the field has not empty text
- **disabled** - state of disabled field

Combination of them allows you to customize lot of states of the text field.
> Combination of **active** with **disabled** states is incorrect and not used

For customizing the appearance you have next methods to set or get placeholder attributes or bottom line for each state:

```swift
func setPlaceholderAttributes(_ attributes: Attributes?, for state: State)
func setLineColor(_ color: UIColor?, for state: State)
```



## Installation

FloatingPlaceholderTextField is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FloatingPlaceholderTextField'
```

## Author

Dmitry Shelonin, cheisesu@gmail.com

## License

FloatingPlaceholderTextField is available under the MIT license. See the LICENSE file for more info.
