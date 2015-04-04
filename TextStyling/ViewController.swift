//
//  ViewController.swift
//  TextStyling
//
//  Created by Richard Zito on 03/04/2015.
//  Copyright (c) 2015 Touchpress. All rights reserved.
//

/*
TODO:

- .classname
- anchors
- attachments?
- more general css parsing?

*/

import UIKit
import TPCore

class ViewController: UIViewController {

    private var textView: UITextView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        let stylesheet: TextStyle.Stylesheet = [
            "*" : [
                .FontName("Avenir-Book"),
                .FontSize(12)
            ],
            "h1" : [
                .FontName("Courier-Bold"),
                .FontSize(18),
                .ParagraphSpacing(25),
                .ForegroundColor(UIColor.blueColor())
            ],
            "h1.red" : [
                .ForegroundColor(UIColor.redColor())
            ],
            "h1 i" : [
                .FontName("Courier-BoldOblique"),
                .ForegroundColor(UIColor.blueColor())
            ],
            "p" : [
                .FontSize(14),
                .ParagraphSpacing(10),
                .FirstLineHeadIndent(20)
            ],
            "p.blockquote" : [
                .FirstLineHeadIndent(50),
                .HeadIndent(50),
                .TailIndent(-50)
            ],
            "a" : [
                .ForegroundColor(UIColor.redColor()),
                .UnderlineStyle(.StyleDouble, .PatternDashDotDot)
            ],
            "i" : [
                .FontName("Courier-Oblique"),
                .Kerning(5)
            ],
            "b" : [
                .FontName("Courier-Bold")
            ],
        ]
        
        let path = NSBundle.mainBundle().pathForResource("en", ofType: "xml")!
        let xml = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil) as! String
        
        let tStart1 = CFAbsoluteTimeGetCurrent()
        let attributedString = NSAttributedString.attributedStringFromXML(xml, stylesheet: stylesheet)
        println("New parser took \(CFAbsoluteTimeGetCurrent() - tStart1)s")

//        println(attributedString)
        
        self.textView = UITextView(frame: self.view.bounds)
        self.textView.attributedText = attributedString
        self.textView.editable = false
        self.textView.contentInset.top = 20
        self.view.addSubview(self.textView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        self.textView.addGestureRecognizer(tapGesture)
        
//        println(attributedString)
        
//        let oldStyle : [NSString:[NSString:AnyObject!]] = [
//            "*" : [
//                TPTextAttributeFont : UIFont(name: "Courier", size: 10),
//                TPTextAttributeFontSize : 12
//            ],
//            "h1" : [
//                TPTextAttributeFont : UIFont(name: "Courier-Bold", size: 10),
//                TPTextAttributeFontSize : 18
//            ],
//            "h1 i" : [
//                TPTextAttributeFont : UIFont(name: "Courier-BoldOblique", size: 10),
//                TPTextAttributeForegroundColour : UIColor.greenColor()
//            ],
//            "p" : [
//                TPTextAttributeFontSize : 14,
//                TPTextAttributeParagraphSpacing : 10
//            ],
//            "a" : [
//                TPTextAttributeForegroundColour : UIColor.redColor()
//            ],
//            "i" : [
//                TPTextAttributeFont : UIFont(name: "Courier-Oblique", size: 10),
//            ],
//            "b" : [
//                TPTextAttributeFont : UIFont(name: "Courier-Bold", size: 10),
//            ]
//        ]
//
//        let tStart = CFAbsoluteTimeGetCurrent()
//        let attrStr = NSAttributedString(styledText: xml, styleDictionary: oldStyle)
//        println("Old parser took \(CFAbsoluteTimeGetCurrent() - tStart)s")

    }

    func handleTap(gestureRecogniser: UITapGestureRecognizer)
    {
        let tapLocation = gestureRecogniser.locationInView(self.textView)
        var anchorRect: CGRect?
        let anchorAttributes = self.textView.anchorAttributesAtPoint(tapLocation, anchorRect: &anchorRect)
        println("\(anchorAttributes) in \(anchorRect)")
    }
    
}


