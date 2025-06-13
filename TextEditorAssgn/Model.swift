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
