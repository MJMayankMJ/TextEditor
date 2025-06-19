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
    @StateObject private var pagingManager: DynamicPagingManager
    
    init(viewModel: DocumentViewModel) {
        self.viewModel = viewModel
        _pagingManager = StateObject(wrappedValue:
            DynamicPagingManager(
                attributedString: viewModel.attributedString,
                minimumPages: max(1, viewModel.pageCount)
            )
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            Color(red: 0.95, green: 0.95, blue: 0.95)
                .ignoresSafeArea()
                .overlay(
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVStack(spacing: 30) {
                            ForEach(pagingManager.textContainers.indices, id: \.self) { index in
                                pageView(at: index)
                            }
                        }
                        .padding(.vertical, 40)
                    }
                )
        }
        .onChange(of: viewModel.attributedString) { newValue in
            pagingManager.updateContent(newValue)
        }
        .onChange(of: viewModel.pageCount) { newCount in
            pagingManager.updateMinimumPages(newCount)
        }
    }
    
    private func pageView(at index: Int) -> some View {
        ZStack {
            // Paper background with shadow
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            
            // Page content
            PageView(
                layoutManager: pagingManager.layoutManager,
                textContainer: pagingManager.textContainers[index],
                viewModel: viewModel
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(EdgeInsets(top: 72, leading: 72, bottom: 72, trailing: 72))
        }
        .frame(width: 612, height: 792)
    }
}
struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView(viewModel: DocumentViewModel())
    }
}



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
