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

import UIKit

class DisplayController: UIViewController {
    @IBOutlet var contentView: UIWebView!
    var url:NSURL?

    // MARK: - Controller Implementation
    func configureView() {
        // Update the user interface for the detail item.
        if let url = self.url {
            if let contentView = self.contentView {
                print(url)
                contentView.loadRequest(NSURLRequest(URL: url))
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelButtonTouched")
        let shareButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "shareButtonTouched")
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = shareButton
        self.configureView()
    }

    func cancelButtonTouched() {
        self.dismissViewControllerAnimated(true, completion: {});
    }

    func shareButtonTouched() {
        let objectsToShare: Array<AnyObject> = [NSData(contentsOfURL: url!)!]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
}