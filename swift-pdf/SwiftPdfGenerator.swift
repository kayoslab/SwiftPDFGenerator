/*
* The MIT License (MIT)
*
* Copyright (c) 2016 cr0ss
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

import Foundation
import UIKit

class SwiftPdfGenerator {

    static func generatePDFWithPages(pages:Array<UIView>) -> String {
        let filePath:String = NSTemporaryDirectory().stringByAppendingPathComponent("temp").stringByAppendingPathExtension("pdf")!
        UIGraphicsBeginPDFContextToFile(filePath, CGRect.zero, nil)
        let context = UIGraphicsGetCurrentContext()

        for page:UIView in pages {
            self.drawPageWithContext(page, context: context!)
        }
        UIGraphicsEndPDFContext()
        return filePath
    }

    private static func drawPageWithContext(page:UIView, context: CGContextRef) {
        UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0.0, y: 0.0, width: page.bounds.size.width, height: page.bounds.size.height), nil)
        for subview:UIView in self.allSubViewsForPage(page) {
            if (subview.isKindOfClass(UIImageView)) {
                let imageView:UIImageView = subview as! UIImageView
                imageView.image?.drawInRect(imageView.frame)
            } else if (subview.isKindOfClass(UILabel)) {
                let label:UILabel = subview as! UILabel
                let paragraphStyle:NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
                paragraphStyle.lineBreakMode = label.lineBreakMode
                paragraphStyle.alignment = label.textAlignment

                NSString(string: label.text!).drawInRect(label.frame, withAttributes: [NSFontAttributeName:label.font, NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName:label.textColor])

            } else if (subview.isKindOfClass(UIView)) {
                self.drawLinesUsingUIView(subview, thickness: 1.0, context: context, fillView: (subview.tag==1 ? true : false))
            }
        }
    }

    private static func drawLinesUsingUIView(view:UIView, thickness:CGFloat, context:CGContextRef, fillView:Bool) {
        CGContextSaveGState(context)
        CGContextSetStrokeColorWithColor(context, view.backgroundColor?.CGColor)
        CGContextSetFillColorWithColor(context, view.backgroundColor?.CGColor)
        CGContextSetLineWidth(context, thickness)

        if (view.frame.size.width > 1 && view.frame.size.height == 1) {
            CGContextMoveToPoint(context, view.frame.origin.x-0.5, view.frame.origin.y)
            CGContextAddLineToPoint(context, view.frame.origin.x+view.frame.size.width-0.5, view.frame.origin.y)
            CGContextStrokePath(context)
        } else if (view.frame.size.width == 1 && view.frame.size.height > 1) {
            CGContextMoveToPoint(context, view.frame.origin.x, view.frame.origin.y-0.5)
            CGContextAddLineToPoint(context, view.frame.origin.x, view.frame.origin.y+view.frame.size.height+0.5)
            CGContextStrokePath(context)
        } else if (view.frame.size.width > 1 && view.frame.size.height > 1) {
            if (fillView) {
                CGContextSetFillColorWithColor(context, view.backgroundColor!.CGColor)
                CGContextFillRect(context, view.frame)
            }
            CGContextStrokeRect(context, view.frame)
        }
        CGContextRestoreGState(context)
    }

    private static func allSubViewsForPage(page:UIView) -> Array<UIView> {
        var returnArray:Array<UIView> = []
        returnArray.append(page)
        for subview:UIView in page.subviews {
            if (subview.isKindOfClass(UILabel)) {
                let label:UILabel = subview as! UILabel
                label.sizeToFit()
                label.layoutIfNeeded()
            }
            let origin:CGPoint = (subview.superview?.convertPoint(subview.frame.origin, toView: subview.superview?.superview))!
            subview.frame = CGRect(x: origin.x, y: origin.y, width: subview.frame.size.width, height: subview.frame.size.height)
            returnArray.appendContentsOf(self.allSubViewsForPage(subview))
        }
        return returnArray
    }
}

extension String {
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.stringByAppendingPathComponent(path)
    }

    func stringByAppendingPathExtension(ext: String) -> String? {
        let nsSt = self as NSString
        return nsSt.stringByAppendingPathExtension(ext)
    }
}