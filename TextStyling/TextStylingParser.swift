//
//  TextStylingParser.swift
//  TextStyling
//
//  Created by Richard Zito on 04/04/2015.
//  Copyright (c) 2015 Touchpress. All rights reserved.
//

import Foundation

class TextStyleParser : NSObject
{
    private let xmlParser: NSXMLParser!
    
    private unowned let style: TextStyle
    
    private var domIdentifierStack: [(TextStyle.DOMElementName, TextStyle.DOMElementClass)] = []
    private var inParagraph = true
    private var anchorAttributes: [String:String]?

    private let attributedString = NSMutableAttributedString()

    private init?(xml: String, style: TextStyle)
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
    @objc func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject])
    {
        self.inParagraph = self.inParagraph || self.style.elementIsParagraph(elementName)
        let className = (attributeDict["class"] as? String) ?? ""
        self.domIdentifierStack.append((elementName, className))
        
        // if we're in an anchor, store the attributes so we can add them to the string
        if elementName == "a"
        {
            self.anchorAttributes = attributeDict as? [String:String]
        }
        
    }
    
    @objc func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        
        // if we've exited a paragraph, add the paragraph break character
        if self.style.elementIsParagraph(elementName)
        {
            self.inParagraph = false
            
            let attributes = self.style.attributesForDOMStack(self.domIdentifierStack)
            
            let paragraphBreak = NSAttributedString(string: "\u{2029}", attributes: attributes)
            self.attributedString.appendAttributedString(paragraphBreak)
        }
        
        if elementName == "a"
        {
            self.anchorAttributes = nil
        }

        self.domIdentifierStack.removeLast()
    }
    
    @objc func parser(parser: NSXMLParser, foundCharacters string: String?)
    {
        // characters shouldn't be added outside of paragraphs - eg whitespace at root level.
        if !self.inParagraph
        {
            return
        }
        
        if let string = string
        {
            var attributes = self.style.attributesForDOMStack(self.domIdentifierStack)
            if let anchorAttributes = self.anchorAttributes
            {
                attributes[TextStyle.AnchorAttributeName] = anchorAttributes
            }
            
            let attributedCharacters = NSAttributedString(string: string, attributes: attributes)
        
            self.attributedString.appendAttributedString(attributedCharacters)
        }
    }
    
}