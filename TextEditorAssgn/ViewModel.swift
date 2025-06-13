//
//  ViewModel.swift
//  TextEditorAssgn
//
//  Created by Mayank Jangid on 6/11/25.
//

import SwiftUI

class DocumentViewModel: ObservableObject {
    @Published var document = DocumentModel()
    
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
    
    let fontWeights = ["Regular", "Medium", "Bold", "Light"]
    
    func updateContent(_ content: String) {
        document.content = content
    }
    
    func updateFontName(_ fontName: String) {
        document.fontName = fontName
    }
    
    func updateFontSize(_ size: CGFloat) {
        document.fontSize = max(8, min(72, size))
    }
    
    func toggleBold() {
        document.isBold.toggle()
    }
    
    func toggleItalic() {
        document.isItalic.toggle()
    }
    
    func toggleUnderline() {
        document.isUnderline.toggle()
    }
    
    func toggleStrikethrough() {
        document.isStrikethrough.toggle()
    }
    
    func updateTextColor(_ color: Color) {
        document.textColor = color
    }
    
    func updateLineSpacing(_ spacing: CGFloat) {
        document.lineSpacing = max(0.5, min(3.0, spacing))
    }
    
    func updateParagraphSpacingBefore(_ spacing: CGFloat) {
        document.paragraphSpacingBefore = max(0, min(100, spacing))
    }
    
    func updateParagraphSpacingAfter(_ spacing: CGFloat) {
        document.paragraphSpacingAfter = max(0, min(100, spacing))
    }
    
    func updateTextAlignment(_ alignment: TextAlignment) {
        document.textAlignment = alignment
    }
}
