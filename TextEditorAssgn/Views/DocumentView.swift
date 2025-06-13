//
//  DocumentView.swift
//  TextEditorAssgn
//
//  Created by Mayank Jangid on 6/12/25.
//

import SwiftUI
import AppKit

struct DocumentView: View {
    @ObservedObject var viewModel: DocumentViewModel
    @State private var textContent = "Start typing your document here..."
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Spacer(minLength: 40)
                    
                    // Document Paper
                    ZStack {
                        Rectangle()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                        
                        VStack {
                            TextEditor(text: $textContent)
                                .font(documentFont)
                                .foregroundColor(viewModel.document.textColor)
                                .lineSpacing(viewModel.document.lineSpacing * 3)
                                .padding(50)
                                .background(Color.white)
                                .scrollContentBackground(.hidden)
                                .onChange(of: textContent) { newValue in
                                    viewModel.updateContent(newValue)
                                }
                        }
                    }
                    .frame(width: 609, height: 860) // A4 size at 72 DPI
                   // .frame(width: 767, height: 991) // exact size for -- 125 zoom
                    
                    Spacer(minLength: 40)
                }
                .frame(maxWidth: .infinity)
            }
//            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        }
    }
    
    private var documentFont: Font {
        var font = Font.custom(viewModel.document.fontName, size: viewModel.document.fontSize)
        
        if viewModel.document.isBold {
            font = font.bold()
        }
        if viewModel.document.isItalic {
            font = font.italic()
        }
        
        return font
    }
    
    private var swiftUIAlignment: TextAlignment {
        switch viewModel.document.textAlignment {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        case .justified: return .leading
        }
    }
}

struct DocumentView_Previews: PreviewProvider { static var previews: some View { DocumentView(viewModel: DocumentViewModel()) } }
