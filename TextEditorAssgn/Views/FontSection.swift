//
//  FontSection.swift
//  TextEditorAssgn
//
//  Created by Mayank Jangid on 6/12/25.
//

import SwiftUI
import AppKit

struct FontSection: View {
    @ObservedObject var viewModel: DocumentViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Font")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
            
            // Font Name Dropdown
            Menu {
                ForEach(viewModel.availableFonts, id: \.self) { font in
                    Button(font) {
                        viewModel.updateFontName(font)
                    }
                }
            } label: {
                HStack {
                    Text(viewModel.document.fontName)
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
            
            // Font Weight and Size
            HStack(spacing: 8) {
                Menu {
                    ForEach(viewModel.fontWeights, id: \.self) { weight in
                        Button(weight) {
                            viewModel.updateFontWeight(weight)
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.selectedFontWeight)
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
                
                // Font Size
                HStack(spacing: 4) {
                    TextField("Size", text: Binding(
                        get: { String(format: "%.0f", viewModel.document.fontSize) },
                        set: { newValue in
                            if let fontSize = Float(newValue) {
                                viewModel.updateFontSize(CGFloat(fontSize))
                            }
                        }
                    ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 40)
                    
                    Text("pt")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 1) {
                        Button(action: { viewModel.updateFontSize(viewModel.document.fontSize + 1) }) {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 8))
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Button(action: { viewModel.updateFontSize(viewModel.document.fontSize - 1) }) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 8))
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
            
            // Style Buttons
            HStack(spacing: 4) {
                StyleButton(icon: "bold", isActive: viewModel.document.isBold) {
                    viewModel.toggleBold()
                }
                StyleButton(icon: "italic", isActive: viewModel.document.isItalic) {
                    viewModel.toggleItalic()
                }
                StyleButton(icon: "underline", isActive: viewModel.document.isUnderline) {
                    viewModel.toggleUnderline()
                }
                StyleButton(icon: "strikethrough", isActive: viewModel.document.isStrikethrough) {
                    viewModel.toggleStrikethrough()
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(6)
                .background(Color(NSColor.controlColor))
                .cornerRadius(4)
            }
            
            // Character Styles
            VStack(alignment: .leading, spacing: 8) {
                Text("Character Styles")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                
                Menu {
                    ForEach(CharacterStyle.allCases, id: \.self) { style in
                        Button(style.rawValue) {
                            viewModel.updateCharacterStyle(style)
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.document.characterStyle.rawValue)
                            .font(.system(size: 12))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundColor(.secondary)
                            .font(.system(size: 10))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(NSColor.controlColor))
                    .cornerRadius(4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Paragraph Styles
            VStack(alignment: .leading, spacing: 8) {
                Text("Paragraph Styles")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                
                Menu {
                    ForEach(ParagraphStyle.allCases, id: \.self) { style in
                        Button(style.rawValue) {
                            viewModel.updateParagraphStyle(style)
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.document.paragraphStyle.rawValue)
                            .font(.system(size: 12))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundColor(.secondary)
                            .font(.system(size: 10))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(NSColor.controlColor))
                    .cornerRadius(4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Text Color
            HStack {
                Text("Text Color")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                ColorPicker("", selection: Binding(
                    get: { viewModel.document.textColor },
                    set: { newColor in
                        viewModel.updateTextColor(newColor)
                    }
                ), supportsOpacity: false)
            }
            
            // Alignment Buttons
            HStack(spacing: 4) {
                AlignmentButton(alignment: .leading, currentAlignment: viewModel.document.textAlignment) {
                    viewModel.updateTextAlignment(.leading)
                }
                AlignmentButton(alignment: .center, currentAlignment: viewModel.document.textAlignment) {
                    viewModel.updateTextAlignment(.center)
                }
                AlignmentButton(alignment: .trailing, currentAlignment: viewModel.document.textAlignment) {
                    viewModel.updateTextAlignment(.trailing)
                }
                AlignmentButton(alignment: .justified, currentAlignment: viewModel.document.textAlignment) {
                    viewModel.updateTextAlignment(.justified)
                }
            }
            
            // Indent buttons
            HStack(spacing: 4) {
                Button(action: {}) {
                    Image(systemName: "increase.indent")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(BorderlessButtonStyle())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color(NSColor.controlColor))
                .cornerRadius(4)
                
                Button(action: {}) {
                    Image(systemName: "decrease.indent")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(BorderlessButtonStyle())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color(NSColor.controlColor))
                .cornerRadius(4)
            }
        }
    }
}


struct FontSection_Previews: PreviewProvider { static var previews: some View { FontSection(viewModel: DocumentViewModel()) } }
