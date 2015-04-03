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
    class func attributedStringFromXML(xml: String, stylesheet: TextStyle.Stylesheet) -> NSAttributedString?
    {
        let textStyle = TextStyle(stylesheet: stylesheet)
        return textStyle.attributedStringFromXML(xml)
    }
}

// Styles are equal if they're of the same type. Hash type is based on type.
func ==(style1: TextStyle.Style, style2: TextStyle.Style) -> Bool
{
    return style1.hashValue == style2.hashValue
}

class TextStyle
{
    typealias Stylesheet = [TextStyle.DOMIdentifier:Set<TextStyle.Style>]
    typealias DOMIdentifier = String
    
    enum Style : Printable, Hashable
    {
        case FontName(String)
        case FontSize(CGFloat)
        case ForegroundColor(UIColor)
        case ParagraphSpacing(CGFloat)
        
        // style hashes/equality isn't based on value, just type.
        var hashValue: Int {
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
            }
        }
        
        var description: String {
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
            case .FontSize(let size):
                fontSize = size
            case .FontName(let name):
                fontName = name
            case .ParagraphSpacing(let spacing):
                paragraphStyle.paragraphSpacing = spacing
            }
        }
        
        // Font size and name specified separately until this point. Put them back together, as expected by NSParagraphStyleAttributeName.
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
        
        if let styles = self.stylesCache[stackHash]
        {
            return styles
        }

        if domStack.count == 1
        {
            return self.stylesheet["*"] ?? []
        }

        var prefixDOMIdentifiers = domStack
        let lastDOMIdentifier = prefixDOMIdentifiers.removeLast()
        let baseStyles = self.stylesForDOMStack(prefixDOMIdentifiers)
        
        var newStyles = stylesheet[lastDOMIdentifier] ?? []
        
        // combine style with base styles
        let styles = baseStyles.subtract(newStyles).union(newStyles)
        
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
