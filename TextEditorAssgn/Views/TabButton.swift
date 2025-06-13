//
//  TabButton.swift
//  TextEditorAssgn
//
//  Created by Mayank Jangid on 6/12/25.
//
//

import SwiftUI
import AppKit

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color.clear)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TabButton_Previews: PreviewProvider { static var previews: some View { TabButton(title:"Style", isSelected:true) {} } }
