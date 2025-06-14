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
    //@State private var textContent = "Start typing your document here..."
    
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
                        
                        VStack(spacing: 30) {
//                            PaginatedTextEditor(viewModel: viewModel)
//                                .padding(50)
//                                .background(Color.white)
                            RichTextEditor(viewModel: viewModel)
                                .padding(50)
                                .background(Color.white)
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



//// MARK: - Rich Text Editor View
struct RichTextEditor: NSViewRepresentable {
    @ObservedObject var viewModel: DocumentViewModel

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = false
        scrollView.borderType = .noBorder
        scrollView.backgroundColor = .white

        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: 400, height: 600))
        textView.autoresizingMask = [.width]
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.isRichText = true
        textView.usesFontPanel = true
        textView.usesRuler = true
        textView.drawsBackground = true
        textView.backgroundColor = NSColor.white
        textView.textColor = NSColor.black
        textView.font = NSFont.systemFont(ofSize: 13)

        if viewModel.attributedString.length == 0 {
            viewModel.attributedString = NSMutableAttributedString(string: "Welcome to RichTextEditor!", attributes: [
                .foregroundColor: NSColor.black,
                .font: NSFont.systemFont(ofSize: 13)
            ])
        }

        textView.textStorage?.setAttributedString(viewModel.attributedString)

        viewModel.setTextView(textView)

        scrollView.documentView = textView
        return scrollView
    }


    func updateNSView(_ nsView: NSScrollView, context: Context) {
        // handled via delegate
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: RichTextEditor

        init(_ parent: RichTextEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }

            DispatchQueue.main.async {
                self.parent.viewModel.document.content = textView.string
                self.parent.viewModel.attributedString = NSMutableAttributedString(attributedString: textView.attributedString())
            }
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }

            DispatchQueue.main.async {
                self.parent.viewModel.selectedRange = textView.selectedRange()
                self.parent.viewModel.updateFormattingFromSelection()
            }
        }
    }
}
