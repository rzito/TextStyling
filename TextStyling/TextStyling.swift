//
//  TextStyling.swift
//  TextStyling
//
//  Created by Richard Zito on 03/04/2015.
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

// Styles are equal if they're of the same type. Hash type is based on type.
public func ==(style1: TextStyle.Style, style2: TextStyle.Style) -> Bool
{
    return style1.hashValue == style2.hashValue
}

public class TextStyle
{
    public typealias Stylesheet = [TextStyle.DOMIdentifier:Set<TextStyle.Style>]
    public typealias DOMIdentifier = String
    
    public enum Style : Printable, Hashable
    {
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
    
    init(stylesheet: Stylesheet)
    {
        self.stylesheet = stylesheet
    }
    
    private func elementIsParagraph(element: String) -> Bool
    {
        return element == "p" || element == "h1" || element == "h2" || element == "h3"
    }
    
    private func attributedStringFromXML(xml: String) -> NSAttributedString?
    {
        return TextStyleParser.attributedStringForXML(xml, style: self)
    }
    
    private func attributesForDOMStack(domStack: [TextStyle.DOMIdentifier]) -> [String:AnyObject]
    {
        let styles = self.stylesForDOMStack(domStack)
        
        let stackHash = domStack.reduce("", combine: { $0 + "/" + $1 })
        
        // check cache
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
    
    private func stylesForDOMStack(domStack: [TextStyle.DOMIdentifier]) -> Set<Style>
    {
        
        let stackHash = domStack.reduce("", combine: { $0 + "/" + $1 })
        
        // attempt to fetch from cache
        if let styles = self.stylesCache[stackHash]
        {
            return styles
        }

        // if we've reached the bottom of the stack - return default styles
        if domStack.count == 1
        {
            return self.stylesheet["*"] ?? []
        }

        // get base styles recursively from first n-1 DOM identifiers
        var prefixDOMIdentifiers = domStack
        let lastDOMIdentifier = prefixDOMIdentifiers.removeLast()
        var styles = self.stylesForDOMStack(prefixDOMIdentifiers)
        
        // new styles to add are just the current identifier (for now) - 
        // TODO: update this to support combined styles: "h1 i" vs "i" for example.
        let newStyles = self.stylesheet[lastDOMIdentifier] ?? []
        
        // combine style with base styles - can be done by subtract + union of same set: hashes have been defined as equal for the same style with different values
        styles.subtractInPlace(newStyles)
        styles.unionInPlace(newStyles)
        
        self.stylesCache[stackHash] = styles

        return styles
        
    }
    
}

private class TextStyleParser : NSObject
{
    let xmlParser: NSXMLParser!
    
    unowned let style: TextStyle
    
    var domIdentifierStack: [TextStyle.DOMIdentifier] = []
    var inParagraph = true

    let attributedString = NSMutableAttributedString()

    init?(xml: String, style: TextStyle)
    {
        self.style = style
        
        // wrap xml in root node
        let xmlWrapped = "<root>\(xml)</root>"
        if let data = xmlWrapped.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        {
            self.xmlParser = NSXMLParser(data: data)
        }
        else
        {
            self.xmlParser = nil
        }
        
        super.init()
        
        if self.xmlParser == nil
        {
            return nil
        }
        
        self.xmlParser.delegate = self
        
    }
    
    class func attributedStringForXML(xml: String, style: TextStyle) -> NSAttributedString?
    {
        if let parser = TextStyleParser(xml: xml, style: style)
        {
            parser.xmlParser.parse()
            return (parser.attributedString.copy() as! NSAttributedString)
        }
        
        return nil
    }
    
}

extension TextStyleParser : NSXMLParserDelegate
{
    @objc private func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject])
    {
        self.inParagraph = self.inParagraph || self.style.elementIsParagraph(elementName)
        self.domIdentifierStack.append(elementName)
    }
    
    @objc private func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        
        // if we've exited a paragraph, add the paragraph break character
        if self.style.elementIsParagraph(elementName)
        {
            self.inParagraph = false

            let attributes = self.style.attributesForDOMStack(self.domIdentifierStack)
            
            let paragraphBreak = NSAttributedString(string: "\u{2029}", attributes: attributes)
            self.attributedString.appendAttributedString(paragraphBreak)
        }
        
        self.domIdentifierStack.removeLast()
    }
    
    @objc private func parser(parser: NSXMLParser, foundCharacters string: String?)
    {
        // characters shouldn't be added outside of paragraphs - eg whitespace at root level.
        if !self.inParagraph
        {
            return
        }
        
        if let string = string
        {
            let attributes = self.style.attributesForDOMStack(self.domIdentifierStack)

            let attributedCharacters = NSAttributedString(string: string, attributes: attributes)
            self.attributedString.appendAttributedString(attributedCharacters)
        }
    }

}
