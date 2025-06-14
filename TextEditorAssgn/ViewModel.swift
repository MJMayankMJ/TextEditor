//
//  ViewModel.swift
//  TextEditorAssgn
//
//  Created by Mayank Jangid on 6/11/25.
//

import SwiftUI

class DocumentViewModel: ObservableObject {
    @Published var document = DocumentModel()
    @Published var selectedRange = NSRange(location: 0, length: 0)
    @Published var attributedString = NSMutableAttributedString()
    @Published var textView: NSTextView?
    
    let availableFonts = [
        "Helvetica Neue",
        "Times New Roman",
        "Arial",
        "Courier New",
        "Georgia",
        "Verdana",
        "Trebuchet MS",
        "Impact"
    ]
    
    let fontWeights = ["Light", "Regular", "Medium", "Bold"]
    @Published var selectedFontWeight = "Regular"
    
    init() {
        attributedString = NSMutableAttributedString(string: "Start typing your document here...")
        updateAttributedStringWithDefaultFormatting()
    }
    
    func setTextView(_ textView: NSTextView) {
        Task {
                await MainActor.run {
                    self.textView = textView
                }
            }
    }
    
    func updateContent(_ content: String) {
        document.content = content
        // Don't update attributed string here as it's handled by the text view
    }
    
    func updateFontName(_ fontName: String) {
        document.fontName = fontName
        applyFormattingToSelection()
    }
    
    func updateFontWeight(_ weight: String) {
        selectedFontWeight = weight
        switch weight {
        case "Light":
            document.isBold = false
        case "Regular":
            document.isBold = false
        case "Medium":
            document.isBold = false
        case "Bold":
            document.isBold = true
        default:
            break
        }
        applyFormattingToSelection()
    }
    
    func updateFontSize(_ size: CGFloat) {
        document.fontSize = max(8, min(72, size))
        applyFormattingToSelection()
    }
    
    func toggleBold() {
        document.isBold.toggle()
        selectedFontWeight = document.isBold ? "Bold" : "Regular"
        applyFormattingToSelection()
    }
    
    func toggleItalic() {
        document.isItalic.toggle()
        applyFormattingToSelection()
    }
    
    func toggleUnderline() {
        document.isUnderline.toggle()
        applyFormattingToSelection()
    }
    
    func toggleStrikethrough() {
        document.isStrikethrough.toggle()
        applyFormattingToSelection()
    }
    
    func updateTextColor(_ color: Color) {
        document.textColor = color
        applyFormattingToSelection()
    }
    
    func updateLineSpacing(_ spacing: CGFloat) {
        document.lineSpacing = max(0.5, min(3.0, spacing))
        applyFormattingToSelection()
    }
    
    func updateParagraphSpacingBefore(_ spacing: CGFloat) {
        document.paragraphSpacingBefore = max(0, min(100, spacing))
        applyFormattingToSelection()
    }
    
    func updateParagraphSpacingAfter(_ spacing: CGFloat) {
        document.paragraphSpacingAfter = max(0, min(100, spacing))
        applyFormattingToSelection()
    }
    
    func updateTextAlignment(_ alignment: TextAlignment) {
        document.textAlignment = alignment
        applyFormattingToSelection()
    }
    
    func updateCharacterStyle(_ style: CharacterStyle) {
        document.characterStyle = style
        
        // Reset formatting first
        document.isBold = false
        document.isItalic = false
        document.fontName = "Helvetica Neue"
        document.textColor = .black
        
        // Apply character style
        switch style {
        case .none:
            break
        case .emphasis:
            document.isItalic = true
        case .strong:
            document.isBold = true
            selectedFontWeight = "Bold"
        case .code:
            document.fontName = "Menlo"
        case .quote:
            document.isItalic = true
            document.textColor = .secondary
        }
        
        applyFormattingToSelection()
    }
    
    func updateParagraphStyle(_ style: ParagraphStyle) {
        document.paragraphStyle = style
        document.fontSize = style.fontSize
        document.isBold = style.isBold
        selectedFontWeight = style.isBold ? "Bold" : "Regular"
        applyFormattingToSelection()
    }
    
    // MARK: - Text Formatting Methods
    
    private func applyFormattingToSelection() {
        guard let textView = textView else { return }
        
        let range = textView.selectedRange()
        let targetRange: NSRange
        
        if range.length > 0 {
            // Apply to selected text
            targetRange = range
        } else {
            // No selection - set typing attributes for new text
            let attributes = createAttributes()
            textView.typingAttributes = attributes
            return
        }
        
        // Apply formatting to selected range
        let attributes = createAttributes()
        textView.textStorage?.addAttributes(attributes, range: targetRange)
        
        // Update typing attributes as well
        textView.typingAttributes = attributes
    }
    
    private func updateAttributedStringWithDefaultFormatting() {
        let attributes = createAttributes()
        attributedString.addAttributes(attributes, range: NSRange(location: 0, length: attributedString.length))
    }
    
    private func createAttributes() -> [NSAttributedString.Key: Any] {
        var font = NSFont(name: document.fontName, size: document.fontSize) ?? NSFont.systemFont(ofSize: document.fontSize)
        
        // Apply weight and style
        var traits: NSFontTraitMask = []
        if document.isBold {
            traits.insert(.boldFontMask)
        }
        if document.isItalic {
            traits.insert(.italicFontMask)
        }
        
        if !traits.isEmpty {
            let fontManager = NSFontManager.shared
            font = fontManager.convert(font, toHaveTrait: traits)
        }
        
        var attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor(document.textColor)
        ]
        
        // Add underline
        if document.isUnderline {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        
        // Add strikethrough
        if document.isStrikethrough {
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        }
        
        // Add paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = document.textAlignment.nsTextAlignment
        paragraphStyle.lineSpacing = document.lineSpacing * 2
        paragraphStyle.paragraphSpacingBefore = document.paragraphSpacingBefore
        paragraphStyle.paragraphSpacing = document.paragraphSpacingAfter
        
        attributes[.paragraphStyle] = paragraphStyle
        
        return attributes
    }
    
    // MARK: - Selection-based attribute reading
    func updateFormattingFromSelection() {
        guard let textView = textView else { return }
        
        let range = textView.selectedRange()
        guard range.location != NSNotFound, range.location < textView.textStorage?.length ?? 0 else { return }
        
        let effectiveRange = NSRange(location: range.location, length: max(1, range.length))
        guard let textStorage = textView.textStorage else { return }
        
        // Get attributes at selection
        let attributes = textStorage.attributes(at: range.location, effectiveRange: nil)
        
        // Update font properties
        if let font = attributes[.font] as? NSFont {
            document.fontName = font.fontName
            document.fontSize = font.pointSize
            
            let fontManager = NSFontManager.shared
            let traits = fontManager.traits(of: font)
            document.isBold = traits.contains(.boldFontMask)
            document.isItalic = traits.contains(.italicFontMask)
            selectedFontWeight = document.isBold ? "Bold" : "Regular"
        }
        
        // Update text color
        if let color = attributes[.foregroundColor] as? NSColor {
            document.textColor = Color(color)
        }
        
        // Update text decorations
        if let underlineStyle = attributes[.underlineStyle] as? Int {
            document.isUnderline = underlineStyle != 0
        } else {
            document.isUnderline = false
        }
        
        if let strikethroughStyle = attributes[.strikethroughStyle] as? Int {
            document.isStrikethrough = strikethroughStyle != 0
        } else {
            document.isStrikethrough = false
        }
        
        // Update paragraph style
        if let paragraphStyle = attributes[.paragraphStyle] as? NSParagraphStyle {
            switch paragraphStyle.alignment {
            case .left: document.textAlignment = .leading
            case .center: document.textAlignment = .center
            case .right: document.textAlignment = .trailing
            case .justified: document.textAlignment = .justified
            default: document.textAlignment = .leading
            }
            
            document.lineSpacing = paragraphStyle.lineSpacing / 2
            document.paragraphSpacingBefore = paragraphStyle.paragraphSpacingBefore
            document.paragraphSpacingAfter = paragraphStyle.paragraphSpacing
        }
    }
}
