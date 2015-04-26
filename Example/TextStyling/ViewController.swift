//
//  ViewController.swift
//  TextStyling
//
//  Created by Richard Zito on 03/04/2015.
//  Copyright (c) 2015 Richard Zito. All rights reserved.
//

/*
TODO:

- attachments?
- more general css parsing? eg using specificity to support arbitrary depth rules.

*/

import UIKit

class ViewController: UIViewController {

    private var textView: UITextView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        let stylesheet: TextStyle.Stylesheet = [
            "*" : [
                .FontName("Avenir-Book"),
                .FontSize(12),
                .ForegroundColor(UIColor.blackColor())
            ],
            "h1" : [
                .FontName("Avenir-Black"),
                .FontSize(18),
                .ParagraphSpacing(25),
                .ForegroundColor(UIColor.redColor())
            ],
            "h2" : [
                .FontName("Avenir-Heavy"),
                .ParagraphSpacing(18),
                .FontSize(16),
                .ForegroundColor(UIColor.blueColor())
            ],
            "i" : [
                .FontName("Avenir-BookOblique"),
            ],
            "i.red" : [
                .ForegroundColor(UIColor.redColor())
            ],
            "p" : [
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
        ]
        
        let path = NSBundle.mainBundle().pathForResource("Moby Dick", ofType: "xml")!
        let xml = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil) as! String
        
        let attributedString = NSAttributedString.attributedStringFromXML(xml, stylesheet: stylesheet)
        
        self.textView = UITextView(frame: self.view.bounds)
        self.textView.attributedText = attributedString
        self.textView.editable = false
        self.textView.contentInset.top = 20
        self.view.addSubview(self.textView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        self.textView.addGestureRecognizer(tapGesture)
        
    }

    func handleTap(gestureRecogniser: UITapGestureRecognizer)
    {
        let tapLocation = gestureRecogniser.locationInView(self.textView)
        var anchorRect: CGRect?
        let anchorAttributes = self.textView.anchorAttributesAtPoint(tapLocation, anchorRect: &anchorRect)
        println("\(anchorAttributes) in \(anchorRect)")
    }
    
}


