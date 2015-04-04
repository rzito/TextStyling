//
//  TextStyling.swift
//  TextStyling
//
//  Created by Richard Zito on 03/04/2015.
//  Copyright (c) 2015 Touchpress. All rights reserved.
//

import UIKit

// Styles are equal if they're of the same type. Hash type is based on type.
public func ==(style1: TextStyle.Style, style2: TextStyle.Style) -> Bool
{
    return style1.hashValue == style2.hashValue
}

public class TextStyle
{
    static let AnchorAttributeName = "TextStyleAnchor"

    public typealias Stylesheet = [String:Set<TextStyle.Style>]
    
    public enum Style : Printable, Hashable
    {
        // character-based styles
        case FontName(String)
        case FontSize(CGFloat)
        case ForegroundColor(UIColor)
        case BackgroundColor(UIColor)
        case Ligatures(Bool)
        case Kerning(CGFloat)
        case Strikethrough(Bool)
        case StrikethroughColor(UIColor)
        case UnderlineStyle(NSUnderlineStyle, NSUnderlineStyle)
        case UnderlineColor(UIColor)
        case StrokeColor(UIColor)
        case StrokeWidth(CGFloat)
        case Shadow(NSShadow)
        case BaselineOffset(CGFloat)
        
        // paragraph-based styles
        case LineSpacing(CGFloat)
        case ParagraphSpacing(CGFloat)
        case Alignment(NSTextAlignment)
        case FirstLineHeadIndent(CGFloat)
        case HeadIndent(CGFloat)
        case TailIndent(CGFloat)
        case LineBreakMode(NSLineBreakMode)
        case MinimumLineHeight(CGFloat)
        case MaximumLineHeight(CGFloat)
        case BaseWritingDirection(NSWritingDirection)
        case LineHeightMultiple(CGFloat)
        case ParagraphSpacingBefore(CGFloat)
        case HyphenationFactor(Float)
        case TabDefaultWidth(CGFloat)
        case TabStops([NSTextTab])
        
        // style hashes/equality isn't based on value, just type. All values should be unique.
        public var hashValue: Int {
            switch self
            {
            case .FontName:
                return 1
            case .FontSize:
                return 2
            case .ForegroundColor:
                return 3
            case .ParagraphSpacing:
                return 4
            case .ForegroundColor:
                return 5
            case .BackgroundColor:
                return 6
            case .Ligatures:
                return 7
            case .Kerning:
                return 8
            case .Strikethrough:
                return 9
            case .UnderlineStyle:
                return 10
            case .UnderlineColor:
                return 11
            case .StrokeColor:
                return 12
            case .StrokeWidth:
                return 13
            case .Shadow:
                return 14
            case .BaselineOffset:
                return 17
            case .LineSpacing:
                return 18
            case .ParagraphSpacing:
                return 19
            case .Alignment:
                return 20
            case .FirstLineHeadIndent:
                return 21
            case .HeadIndent:
                return 22
            case .TailIndent:
                return 23
            case .LineBreakMode:
                return 24
            case .MinimumLineHeight:
                return 25
            case .MaximumLineHeight:
                return 26
            case .BaseWritingDirection:
                return 27
            case .LineHeightMultiple:
                return 28
            case .ParagraphSpacingBefore:
                return 29
            case .HyphenationFactor:
                return 30
            case .TabDefaultWidth:
                return 31
            case .TabStops:
                return 32
            case .StrikethroughColor:
                return 33
            }
        }
        
        public var description: String {
            switch self
            {
            case .FontName(let name):
                return "Font(\(name))"
            case .FontSize(let size):
                return "FontSize(\(size))"
            case .ForegroundColor(let color):
                return "ForegroundColor(\(color))"
            case .ParagraphSpacing(let spacing):
                return "ParagraphSpacing(\(spacing))"
            default:
                return "Unnamed Style!"
            }
        }

    }
    
    private let stylesheet: Stylesheet
    
    private var stylesCache = [String:Set<Style>]()
    private var attributesCache = [String:[String:AnyObject]]()
    
    typealias DOMElementName = String
    typealias DOMElementClass = String
    
    init(stylesheet: Stylesheet)
    {
        self.stylesheet = stylesheet
    }
    
    public func attributedStringFromXML(xml: String) -> NSAttributedString?
    {
        return TextStyleParser.attributedStringForXML(xml, style: self)
    }
    
    // Paragraph elements decide when characters are added to the string, and when paragraph breaks are inserted.
    // TODO: allow client control - eg pass to init, or as a style parameter
    func elementIsParagraph(element: DOMElementName) -> Bool
    {
        return element == "p" || element == "h1" || element == "h2" || element == "h3"
    }
    
    func attributesForDOMStack(domStack: [(DOMElementName, DOMElementClass)]) -> [String:AnyObject]
    {
        let styles = self.stylesForDOMStack(domStack)
        
        let stackHash = domStack.reduce("", combine: { $0 + "/\($1.0).\($1.1)" })
        
        // check cache for already-computed attributes
        // TODO: Ideally we'd hash the styles, rather than the stack. But that's tricky as it depends on their values too.
        if let attributes = self.attributesCache[stackHash]
        {
            return attributes
        }
        
        var attributes = [String:AnyObject]()
        
        var fontSize: CGFloat?
        var fontName: String?
        let paragraphStyle = NSMutableParagraphStyle()
        attributes[NSParagraphStyleAttributeName] = paragraphStyle

        for style in styles
        {
            switch style
            {
            case .ForegroundColor(let color):
                attributes[NSForegroundColorAttributeName] = color
            case .BackgroundColor(let color):
                attributes[NSBackgroundColorAttributeName] = color
            case .FontSize(let size):
                fontSize = size
            case .FontName(let name):
                fontName = name
            case .Ligatures(let on):
                attributes[NSLigatureAttributeName] = on
            case .Kerning(let value):
                attributes[NSKernAttributeName] = value
            case .Strikethrough(let on):
                attributes[NSStrikethroughStyleAttributeName] = on
            case .StrikethroughColor(let color):
                attributes[NSStrikethroughColorAttributeName] = color
            case .UnderlineStyle(let style1, let style2):
                attributes[NSUnderlineStyleAttributeName] = style1.rawValue | style2.rawValue
            case .UnderlineColor(let color):
                attributes[NSUnderlineColorAttributeName] = color
            case .StrokeColor(let color):
                attributes[NSStrokeColorAttributeName] = color
            case .StrokeWidth(let width):
                attributes[NSStrokeWidthAttributeName] = width
            case .Shadow(let shadow):
                attributes[NSShadowAttributeName] = shadow
            case .BaselineOffset(let offset):
                attributes[NSBaselineOffsetAttributeName] = offset
                
            case .LineSpacing(let spacing):
                paragraphStyle.lineSpacing = spacing
            case .ParagraphSpacing(let spacing):
                paragraphStyle.paragraphSpacing = spacing
            case .Alignment(let alignment):
                paragraphStyle.alignment = alignment
            case .FirstLineHeadIndent(let indent):
                paragraphStyle.firstLineHeadIndent = indent
            case .HeadIndent(let indent):
                paragraphStyle.headIndent = indent
            case .TailIndent(let indent):
                paragraphStyle.tailIndent = indent
            case .LineBreakMode(let mode):
                paragraphStyle.lineBreakMode = mode
            case .MinimumLineHeight(let height):
                paragraphStyle.minimumLineHeight = height
            case .MaximumLineHeight(let height):
                paragraphStyle.maximumLineHeight = height
            case .BaseWritingDirection(let direction):
                paragraphStyle.baseWritingDirection = direction
            case .LineHeightMultiple(let multiple):
                paragraphStyle.lineHeightMultiple = multiple
            case .ParagraphSpacingBefore(let spacing):
                paragraphStyle.paragraphSpacingBefore = spacing
            case .HyphenationFactor(let factor):
                paragraphStyle.hyphenationFactor = factor
            case .TabDefaultWidth(let width):
                paragraphStyle.defaultTabInterval = width
            case .TabStops(let tabs):
                paragraphStyle.tabStops = tabs
            }
        }
        
        // Font size and name specified separately until this point. Put them back together, as expected by NSFontAttributeName.
        if let fontName = fontName, fontSize = fontSize
        {
            attributes[NSFontAttributeName] = UIFont(name: fontName, size: fontSize)
        }
        else if let fontName = fontName
        {
            attributes[NSFontAttributeName] = UIFont(name: fontName, size: UIFont.systemFontSize())
        }
        else if let fontSize = fontSize
        {
            attributes[NSFontAttributeName] = UIFont.systemFontOfSize(fontSize)
        }
        
        // store in cache
        self.attributesCache[stackHash] = attributes
        
        return attributes
        
    }
    
    private func stylesForDOMStack(domStack: [(DOMElementName, DOMElementClass)]) -> Set<Style>
    {
        
        let stackHash = domStack.reduce("", combine: { $0 + "/\($1.0).\($1.1)" })
        
        // attempt to fetch from cache
        if let styles = self.stylesCache[stackHash]
        {
            return styles
        }

        // if we've reached the bottom of the stack (root) - return default styles
        if domStack.count == 1
        {
            return self.stylesheet["*"] ?? []
        }
        
        // get base styles recursively from first n-1 DOM identifiers
        var prefixDOMStack = domStack
        let lastDOMItem = prefixDOMStack.removeLast()
        var styles = self.stylesForDOMStack(prefixDOMStack)
        
        // override with progressively more specific new styles

        // elementName
        styles.unionInPlace(self.stylesheet[lastDOMItem.0] ?? [])

        // .className
        styles.unionInPlace(self.stylesheet["." + lastDOMItem.1] ?? [])
        
        // elementName.className
        styles.unionInPlace(self.stylesheet[lastDOMItem.0 + "." + lastDOMItem.1] ?? [])

        // also add two-level nested styles
        // e.g. <h1><i>XXX</i></h1> with style specifier "h1 i"
        if let prevDOMItem = prefixDOMStack.last
        {
            // elementName1 elementName2
            styles.unionInPlace(self.stylesheet[prevDOMItem.0 + " " + lastDOMItem.0] ?? [])

            // TODO: Add more general two-level support, eg elementName1.class elementName2
        }
                
        self.stylesCache[stackHash] = styles

        return styles
        
    }
    
}

