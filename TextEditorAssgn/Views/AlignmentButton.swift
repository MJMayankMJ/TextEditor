//
//  AlignmentButton.swift
//  TextEditorAssgn
//
//  Created by Mayank Jangid on 6/12/25.
//

import SwiftUI
import AppKit

struct AlignmentButton: View {
    let alignment: TextAlignment
    let currentAlignment: TextAlignment
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: alignmentIcon)
                .foregroundColor(currentAlignment == alignment ? .orange : .secondary)
                .font(.system(size: 12))
        }
        .buttonStyle(BorderlessButtonStyle())
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(currentAlignment == alignment ? Color.orange.opacity(0.2) : Color(NSColor.controlColor))
        .cornerRadius(4)
    }
    
    private var alignmentIcon: String {
        switch alignment {
        case .leading: return "text.alignleft"
        case .center: return "text.aligncenter"
        case .trailing: return "text.alignright"
        case .justified: return "text.justify"
        }
    }
}

struct AlignmentButton_Previews: PreviewProvider { static var previews: some View { AlignmentButton(alignment:.leading, currentAlignment:.leading) {} } }
