import UIKit

extension UILabel {
    
    enum TextType {
        case none
        case title
        case subtitle
        case italic
    }
    
    enum FontType: String, CaseIterable {
        case regular = ""
        case bold = "-Bold"
        case bolditalic = "-BoldItalic"
        case extrabold = "-Extrabold"
        case extrabolditalic = "-ExtraboldItalic"
        case italic = "-Italic"
        case light = "-Light"
        case semibold = "-Semibold"
        case semiboldItalic = "-SemiboldItalic"
    }
    
    enum TextAlignment {
        case center
        case left
        case right
    }
    
    func setTextAlignmnet(_ type: TextAlignment) {
        switch type {
        case .center:
            textAlignment = .center
        case .left:
            textAlignment = .left
        case .right:
            textAlignment = .right
        }
    }
    
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font as Any], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}
