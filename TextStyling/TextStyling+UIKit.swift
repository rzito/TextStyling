//
//  TextStyling+UIKit.swift
//  TextStyling
//
//  Created by Richard Zito on 04/04/2015.
//  Copyright (c) 2015 Touchpress. All rights reserved.
//

import UIKit


extension NSAttributedString
{
    public class func attributedStringFromXML(xml: String, stylesheet: TextStyle.Stylesheet) -> NSAttributedString?
    {
        let textStyle = TextStyle(stylesheet: stylesheet)
        return textStyle.attributedStringFromXML(xml)
    }
    
}

extension UITextView
{
    
    public func anchorAttributesAtPoint(tapPoint: CGPoint, inout anchorRect: CGRect?) -> [String:String]?
    {
        let tapPointText = CGPointMake(tapPoint.x - self.textContainerInset.left, tapPoint.y - self.textContainerInset.top);
        
        var tappedAnchor: [String:String]?
        var closestAnchor: [String:String]?
        var closestAnchorDy = CGFloat.max
        var tappedAnchorRect = CGRectNull
        var closestAnchorRect = CGRectNull
        
        self.attributedText.enumerateAttribute(TextStyle.AnchorAttributeName, inRange: NSMakeRange(0, self.attributedText.length), options:NSAttributedStringEnumerationOptions.allZeros, usingBlock: { (attributes, range, var stopAnchors) in
            
            if let anchorAttributes = attributes as? [String:String]
            {
                
                let glyphRange = self.layoutManager.glyphRangeForCharacterRange(range, actualCharacterRange:nil)
                
                self.layoutManager.enumerateEnclosingRectsForGlyphRange(glyphRange, withinSelectedGlyphRange:NSMakeRange(NSNotFound, 0), inTextContainer:self.textContainer, usingBlock: { (enclosingRect, var stopEnclosing) in
                    
                    if CGRectContainsPoint(enclosingRect, tapPointText)
                    {
                        tappedAnchor = anchorAttributes
                        tappedAnchorRect = enclosingRect
                        stopAnchors.initialize(true)
                        stopEnclosing.initialize(true)
                        return
                    }
                    else if (tapPointText.x >= CGRectGetMinX(enclosingRect) && tapPointText.x <= CGRectGetMaxX(enclosingRect))
                    {
                        let dy = abs( tapPointText.y - CGRectGetMidY(enclosingRect) )
                        if dy < closestAnchorDy
                        {
                            closestAnchorDy = dy;
                            closestAnchor = anchorAttributes;
                            closestAnchorRect = enclosingRect;
                        }
                    }
                    
                })
            }
        })
        
        let anchorTapToleranceY: CGFloat = 30.0
        if tappedAnchor == nil
        {
            if closestAnchorDy < anchorTapToleranceY
            {
                tappedAnchor = closestAnchor;
                tappedAnchorRect = closestAnchorRect;
            }
        }
        
        if tappedAnchor != nil
        {
            tappedAnchorRect.origin.x += self.textContainerInset.left;
            tappedAnchorRect.origin.y += self.textContainerInset.top;
            
            anchorRect = tappedAnchorRect;
            
        }
        
        return tappedAnchor;
    }
    
}
