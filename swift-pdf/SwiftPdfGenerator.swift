/*
*
* Copyright (C) Kayos UG (haftungsbeschränkt) - All Rights Reserved
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
*
* NOTICE:  All information contained herein is, and remains
* the property of Kayos UG (haftungsbeschränkt) and its suppliers,
* if any. The intellectual and technical concepts contained
* herein are proprietary to Kayos UG (haftungsbeschränkt)
* and its suppliers and are protected by trade secret or copyright law.
* Dissemination of this information or reproduction of this material
* is strictly forbidden unless prior written permission is obtained
* from Kayos UG (haftungsbeschränkt).
*
* Written by Simon Christian Krüger <krueger.s@kayos.eu>, February 2016
*
*/

import Foundation
import UIKit

class PdfFileGenerator {

    static func generatePDFWithPages(pages:Array<UIView>) -> String {
        let filePath:String = NSTemporaryDirectory().stringByAppendingPathComponent("report").stringByAppendingPathExtension("pdf")!
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
                if let image = imageView.image {
                    if (imageView.contentMode == .ScaleAspectFit) {
                        if (image.size.width > imageView.frame.size.width || image.size.height > imageView.frame.size.height) {
                            if (image.size.width < image.size.height) {
                                let maxHeight = imageView.frame.size.height
                                let ratio = maxHeight / image.size.height
                                let ratioWidth = image.size.width * ratio
                                if (ratioWidth > imageView.frame.size.width) {
                                    let correctedMaxWidth = imageView.frame.size.width
                                    let correctedRatio = correctedMaxWidth / image.size.width
                                    let correctedRatioHeight = image.size.height * correctedRatio
                                    imageView.image?.drawInRect(CGRect(x: imageView.frame.origin.x, y: imageView.frame.origin.y + (imageView.frame.height / 2) - (correctedRatio / 2), width: correctedMaxWidth, height: correctedRatioHeight))
                                } else {
                                    imageView.image?.drawInRect(CGRect(x: imageView.frame.origin.x + (imageView.frame.width / 2) - (ratioWidth / 2), y: imageView.frame.origin.y, width: ratioWidth, height: maxHeight))
                                }

                            } else {
                                let maxWidth = imageView.frame.size.width
                                let ratio = maxWidth / image.size.width
                                let ratioHeight = image.size.height * ratio
                                if (ratioHeight > imageView.frame.size.height) {
                                    let correctedMaxHeight = imageView.frame.size.height
                                    let correctedRatio = correctedMaxHeight / image.size.height
                                    let correctedRatioWidth = image.size.width * correctedRatio
                                    imageView.image?.drawInRect(CGRect(x: imageView.frame.origin.x + (imageView.frame.width / 2) - (correctedRatioWidth / 2), y: imageView.frame.origin.y, width: correctedRatioWidth, height: correctedMaxHeight))
                                } else {
                                    imageView.image?.drawInRect(CGRect(x: imageView.frame.origin.x, y: imageView.frame.origin.y + (imageView.frame.height / 2) - (ratioHeight / 2), width: maxWidth, height: ratioHeight))
                                }
                            }
                        } else {
                            image.drawInRect(imageView.frame)
                        }
                    } else {
                        image.drawInRect(imageView.frame)
                    }
                }
            } else if (subview.isKindOfClass(UILabel)) {
                let label:UILabel = subview as! UILabel
                let paragraphStyle:NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
                paragraphStyle.lineBreakMode = label.lineBreakMode
                paragraphStyle.alignment = label.textAlignment

                NSString(string: label.text!).drawInRect(label.frame, withAttributes: [NSFontAttributeName:label.font, NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName:label.textColor])
            } else if (subview.isKindOfClass(UITextView)) {
                self.drawLinesUsingUIView(subview, thickness: 0.5, context: context, fillView: (subview.tag==1 ? true : false))
                let textView:UITextView = subview as! UITextView
                let textViewFrame:CGRect = CGRect(x: textView.frame.origin.x + 8, y: textView.frame.origin.y + 8, width: textView.frame.size.width - 16, height: textView.frame.size.height - 16)

                let paragraphStyle:NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
                paragraphStyle.lineBreakMode = .ByWordWrapping
                paragraphStyle.alignment = textView.textAlignment
                if let font = textView.font, let textColor = textView.textColor {
                    NSString(string: textView.text).drawInRect(textViewFrame, withAttributes: [NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName:textColor])
                } else {
                    NSString(string: textView.text).drawInRect(textViewFrame, withAttributes: [NSFontAttributeName:UIFont.systemFontOfSize(10), NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName:UIColor(red: 70.0/255.0, green: 74.0/255.0, blue: 72.0/255.0, alpha: 1.0)])
                }
            } else if (subview.isKindOfClass(UIView)) {
                self.drawLinesUsingUIView(subview, thickness: 0.5, context: context, fillView: (subview.tag==1 ? true : false))
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
        } else {
            print("0x0 view")
        }
        CGContextRestoreGState(context)
    }

    private static func allSubViewsForPage(page:UIView) -> Array<UIView> {
        var returnArray:Array<UIView> = []
        returnArray.append(page)
        for subview:UIView in page.subviews {
            if subview.hidden == false {
                if (subview.isKindOfClass(UILabel)) {
                    let label:UILabel = subview as! UILabel
                    label.sizeToFit()
                    label.layoutIfNeeded()
                }
                let origin:CGPoint = (subview.superview?.convertPoint(subview.frame.origin, toView: subview.superview?.superview))!
                subview.frame = CGRect(x: origin.x, y: origin.y, width: subview.frame.size.width, height: subview.frame.size.height)
                returnArray.appendContentsOf(self.allSubViewsForPage(subview))
            }
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