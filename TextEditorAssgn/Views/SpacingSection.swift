//
//  SpacingSection.swift
//  TextEditorAssgn
//
//  Created by Mayank Jangid on 6/12/25.
//

import SwiftUI
import AppKit

struct SpacingSection: View {
    @ObservedObject var viewModel: DocumentViewModel
    @State private var isExpanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.system(size: 10))
                    
                    Text("Spacing")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    // Line Spacing
                    HStack {
                        Menu {
                            Button("Single") { viewModel.updateLineSpacing(1.0) }
                            Button("1.5") { viewModel.updateLineSpacing(1.5) }
                            Button("Double") { viewModel.updateLineSpacing(2.0) }
                        } label: {
                            HStack {
                                Text("Lines")
                                    .font(.system(size: 12))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.up.chevron.down")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 10))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(NSColor.controlColor))
                            .cornerRadius(4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(maxWidth: .infinity)
                        
                        HStack(spacing: 4) {
                            TextField("", value: .constant(viewModel.document.lineSpacing), format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 40)
                            
                            VStack(spacing: 1) {
                                Button(action: { viewModel.updateLineSpacing(viewModel.document.lineSpacing + 0.1) }) {
                                    Image(systemName: "chevron.up")
                                        .font(.system(size: 8))
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                
                                Button(action: { viewModel.updateLineSpacing(viewModel.document.lineSpacing - 0.1) }) {
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 8))
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                    
                    // Before Paragraph
                    HStack {
                        Text("Before Paragraph")
                            .font(.system(size: 12))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 4) {
                            TextField("", value: .constant(viewModel.document.paragraphSpacingBefore), format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 40)
                            
                            Text("pt")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 1) {
                                Button(action: { viewModel.updateParagraphSpacingBefore(viewModel.document.paragraphSpacingBefore + 1) }) {
                                    Image(systemName: "chevron.up")
                                        .font(.system(size: 8))
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                
                                Button(action: { viewModel.updateParagraphSpacingBefore(viewModel.document.paragraphSpacingBefore - 1) }) {
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 8))
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                    
                    // After Paragraph
                    HStack {
                        Text("After Paragraph")
                            .font(.system(size: 12))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 4) {
                            TextField("", value: .constant(viewModel.document.paragraphSpacingAfter), format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 40)
                            
                            Text("pt")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 1) {
                                Button(action: { viewModel.updateParagraphSpacingAfter(viewModel.document.paragraphSpacingAfter + 1) }) {
                                    Image(systemName: "chevron.up")
                                        .font(.system(size: 8))
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                
                                Button(action: { viewModel.updateParagraphSpacingAfter(viewModel.document.paragraphSpacingAfter - 1) }) {
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 8))
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                }
            }
        }
    }
}
struct SpacingSection_Previews: PreviewProvider { static var previews: some View { SpacingSection(viewModel: DocumentViewModel()) } }
