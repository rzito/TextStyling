//
//  ViewController.swift
//  TextStyling
//
//  Created by Richard Zito on 03/04/2015.
//  Copyright (c) 2015 Touchpress. All rights reserved.
//

import UIKit
import TPCore

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        let stylesheet: TextStyle.Stylesheet = [
            "*" : [
                .FontName("Courier"),
                .FontSize(12)
            ],
            "h1" : [
                .FontName("Courier-Bold"),
                .FontSize(18),
                .ParagraphSpacing(25)
            ],
            "h1 i" : [
                .FontName("Courier-BoldOblique"),
                .ForegroundColor(UIColor.greenColor())
            ],
            "p" : [
                .FontSize(14),
                .ParagraphSpacing(10)
            ],
            "a" : [
                .ForegroundColor(UIColor.redColor())
            ],
            "i" : [
                .FontName("Courier-Oblique"),
            ],
            "b" : [
                .FontName("Courier-Bold")
            ]
        ]
        
        let path = NSBundle.mainBundle().pathForResource("en", ofType: "xml")!
        let xml = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil) as! String
//        let xml = "<h1>This <i>italic</i> header</h1><p><b>blah</b> text paragraph <i>italic</i></p>"
        
        let tStart1 = CFAbsoluteTimeGetCurrent()
        let attributedString = NSAttributedString.attributedStringFromXML(xml, stylesheet: stylesheet)
        println("New parser took \(CFAbsoluteTimeGetCurrent() - tStart1)s")

        let label = UITextView(frame: self.view.bounds)
        label.attributedText = attributedString
        label.editable = false
        label.contentInset.top = 20
        self.view.addSubview(label)
        
//        println(attributedString)
        /*
        let oldStyle : [NSString:[NSString:AnyObject!]] = [
            "*" : [
                TPTextAttributeFont : UIFont(name: "Courier", size: 10),
                TPTextAttributeFontSize : 12
            ],
            "h1" : [
                TPTextAttributeFont : UIFont(name: "Courier-Bold", size: 10),
                TPTextAttributeFontSize : 18
            ],
            "h1 i" : [
                TPTextAttributeFont : UIFont(name: "Courier-BoldOblique", size: 10),
                TPTextAttributeForegroundColour : UIColor.greenColor()
            ],
            "p" : [
                TPTextAttributeFontSize : 14,
                TPTextAttributeParagraphSpacing : 10
            ],
            "a" : [
                TPTextAttributeForegroundColour : UIColor.redColor()
            ],
            "i" : [
                TPTextAttributeFont : UIFont(name: "Courier-Oblique", size: 10),
            ],
            "b" : [
                TPTextAttributeFont : UIFont(name: "Courier-Bold", size: 10),
            ]
        ]

        let tStart = CFAbsoluteTimeGetCurrent()
        let attrStr = NSAttributedString(styledText: xml, styleDictionary: oldStyle)
        println("Old parser took \(CFAbsoluteTimeGetCurrent() - tStart)s")
*/
    }

    
}

