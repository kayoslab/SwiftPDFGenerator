## Description
Generates a PDF directly from interface builder with Auto-layouted views! Swift Version of [UIView_2_PDF](https://github.com/RobertAPhillips/UIView_2_PDF).

## Installation
In Xcode, select 'Add Files To Project', and select SwiftPdfGenerator.swift

## Usage
#### 1. Make a xib file. 
Your xib file should only consist of UILabels and/or UIImageViews and/or other UIView subviews. Use views that are 1 pixel high or wide to create lines. Set the tag of a UIView to 1 to have it draw filled or zero to draw as just a 1 pixel bordered box.

#### 2. Load your xib like this
```swift
let pageOneView = NSBundle.mainBundle().loadNibNamed("PageOneView", owner: self, options: nil).last as! PageOneView
let pageTwoView = NSBundle.mainBundle().loadNibNamed("PageTwoView", owner: self, options: nil).last as! UIView
```

#### 3. Then generate your PDF like this
```swift
let tempFilePath = SwiftPdfGenerator.generatePDFWithPages(pages)
```

See demo project for details.

## License
swift-pdf is released under the MIT license. See 'LICENCE.md' for details.
