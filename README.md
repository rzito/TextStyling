# Introduction

Text styling on iOS (and Mac OS) is done using `NSAttributedString`, where 'attributes' are 
text style modifiers to be applied over a subrange of the string. Creating an `NSAttributedString` with 
complex styles can be a tedious process. 

One way of creating an attributed string might be, for example:
```Swift
let redHello = NSAttributedString(string: "Hello", attributes: [ NSFontAttributeName : someFont, NSForegroundColorAttributeName : UIColor.redColor()])
let blueWorld = NSAttributedString(string: " World", attributes: [ NSFontAttributeName : someFont, NSForegroundColorAttributeName : UIColor.blueColor()])

let attributedString = NSMutableAttributedString()
attributedString.appendAttributedString(redHello)
attributedString.appendAttributedString(blueWorld)
```

This project aims to make text styling easier by allowing text to be written in a simple XML format, with styles defined 
separately in a stylesheet. This is similar to the familiar HTML/CSS approach, with the important difference that styles are defined in code as a dictionary of style tags & values, rather than in plain text. This has many advantages, such as being able to decide certain elements at runtime - eg selecting a font based on an app setting.
Styles cascade, as with CSS, but for simplicity don't support the full level of inheritance complexities available with CSS. See 'Styles' section for details.

## Styles

The available style values are listed in the `TextStyle.Style` enum, and mirror the list of attributes provided by `NSAttributedString`.
Attributes which are usually accessible through `NSParagraphStyle` have been promoted to top level attributes. This enables simpler 
paragraph style inheritance, without having to maintain NSParagraphStyle objects. Swift enum associated values have been used to elegantly ensure style values are of the correct type.

Styles keys can be of the following types, in increasing order of inheritance:
- *Default* – "*": This is the default set of styles, inherited by all elements.
- *Element name* - eg "p": These styles are applied to all elements of that name
- *Class name* - eg ".red": These styles are applied to all elements with the attribute 'class' matching the given name
- *Element name* + *Class name* - eg "p.red": These styles are applied to all elements with both the given element name, and the 
given class attribute value.
- *Parent/child* - eg "p span": These styles are applied to the contents of the second element, when contained within the first element.

Certain XML element names need to exist at the top level, in order for text to be added to the attributed string. These are currently `p`, `h1`, `h2`, `h3`. A future update may make this customisable.

## Text Anchors

The element `a` is reserved for defining text which is part of a text anchor. Text anchors are primarily used for 
identifying touchable areas of text. An extension to UITextView has been provided, which makes it easy to identify which anchor (or rather, the attributes of the anchor) 
exists at a given point.

# Examples

## Text Styling
```Swift
let xmlText = "<p><red>Hello</red> <blue>World</blue></p>"
let stylesheet: TextStyle.Stylesheet = [
  "red" : [
    .ForegroundColor(UIColor.redColor())
  ],
  "blue" : [
   .ForegroundColor(UIColor.blueColor())
  ]
];
let styledText = NSAttributedString.attributedStringFromXML(xmlText, stylesheet: stylesheet)
```

For a more complex styling example, see the project included in this repository.

## Anchor hit testing

```Swift
func handleTap(gestureRecogniser: UITapGestureRecognizer)
{
  let tapLocation = gestureRecogniser.locationInView(self.textView)
  var anchorRect: CGRect?
  let anchorAttributes = self.textView.anchorAttributesAtPoint(tapLocation, anchorRect: &anchorRect)
  println("\(anchorAttributes) in \(anchorRect)")
}
```
