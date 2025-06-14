//
//  Model.swift
//  TextEditorAssgn
//
//  Created by Mayank Jangid on 6/11/25.
//

import SwiftUI

struct DocumentModel {
    var content: String = ""
    var fontName: String = "Helvetica Neue"
    var fontSize: CGFloat = 11.0
    var isBold: Bool = false
    var isItalic: Bool = false
    var isUnderline: Bool = false
    var isStrikethrough: Bool = false
    var textColor: Color = .black
    var lineSpacing: CGFloat = 1.0
    var paragraphSpacingBefore: CGFloat = 0.0
    var paragraphSpacingAfter: CGFloat = 0.0
    var textAlignment: TextAlignment = .leading
    var characterStyle: CharacterStyle = .none
    var paragraphStyle: ParagraphStyle = .body
}

enum TextAlignment: String, CaseIterable {
    case leading = "Leading"
    case center = "Center"
    case trailing = "Trailing"
    case justified = "Justified"
    
    var nsTextAlignment: NSTextAlignment {
        switch self {
        case .leading: return .left
        case .center: return .center
        case .trailing: return .right
        case .justified: return .justified
        }
    }
}

enum CharacterStyle: String, CaseIterable {
    case none = "None"
    case emphasis = "Emphasis"
    case strong = "Strong"
    case code = "Code"
    case quote = "Quote"
}

enum ParagraphStyle: String, CaseIterable {
    case body = "Body"
    case title = "Title"
    case heading = "Heading"
    case subheading = "Subheading"
    case caption = "Caption"
    
    var fontSize: CGFloat {
        switch self {
        case .body: return 11
        case .title: return 24
        case .heading: return 18
        case .subheading: return 14
        case .caption: return 10
        }
    }
    
    var isBold: Bool {
        switch self {
        case .body, .caption: return false
        case .title, .heading, .subheading: return true
        }
    }
}
