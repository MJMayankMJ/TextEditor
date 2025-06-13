//
//  StyleTabView.swift
//  TextEditorAssgn
//
//  Created by Mayank Jangid on 6/12/25.
//

import SwiftUI
import AppKit


struct StyleButton: View {
    let icon: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(isActive ? .white : .primary)
                .font(.system(size: 12, weight: .medium))
        }
        .buttonStyle(BorderlessButtonStyle())
        .frame(width: 28, height: 24)
        .background(isActive ? Color.accentColor : Color(NSColor.controlColor))
        .cornerRadius(4)
    }
}

struct StyleTabView_Previews: PreviewProvider { static var previews: some View { StyleTabView(viewModel: DocumentViewModel()) } }
