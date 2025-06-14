//
//  PaginatedTextEditor.swift
//  TextEditorAssgn
//
//  Created by Mayank Jangid on 6/14/25.
//


import SwiftUI
import AppKit

/// A SwiftUI wrapper for a paginated NSTextView editor with seamless multi-page scrolling.
//struct PaginatedTextEditor: NSViewRepresentable {
//    @ObservedObject var viewModel: DocumentViewModel
//
//    func makeNSView(context: Context) -> NSScrollView {
//        let scrollView = NSScrollView()
//        scrollView.hasVerticalScroller = true
//        scrollView.hasHorizontalScroller = false
//        scrollView.borderType = .noBorder
//        scrollView.drawsBackground = false
//
//        let container = NSView()
//        scrollView.documentView = container
//
//        context.coordinator.containerView = container
//        context.coordinator.setupTextStorage(using: viewModel.attributedString)
//        context.coordinator.initialLayout()
//
//        return scrollView
//    }
//
//    func updateNSView(_ nsView: NSScrollView, context: Context) {
//        context.coordinator.updateTextStorage(with: viewModel.attributedString)
//        context.coordinator.checkAndAddPagesIfNeeded()
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, NSTextViewDelegate {
//        let parent: PaginatedTextEditor
//        var containerView: NSView?
//
//        private let layoutManager = NSLayoutManager()
//        private var textStorage: NSTextStorage!
//
//        private var textContainers: [NSTextContainer] = []
//        private var pageScrolls: [NSScrollView] = []
//
//        /// A4 at 72 DPI
//        private let pageSize = NSSize(width: 609, height: 860)
//        private let pageSpacing: CGFloat = 40
//        private let pagePadding: CGFloat = 20
//
//        init(_ parent: PaginatedTextEditor) {
//            self.parent = parent
//            super.init()
//        }
//
//        func setupTextStorage(using attributed: NSAttributedString) {
//            textStorage = NSTextStorage(attributedString: attributed)
//            textStorage.addLayoutManager(layoutManager)
//        }
//
//        func updateTextStorage(with attributed: NSAttributedString) {
//            layoutManager.textStorage?.setAttributedString(attributed)
//        }
//
//        /// Initial single-page setup
//        func initialLayout() {
//            guard let container = containerView else { return }
//            // create first page
//            addPage(at: 0)
//            // size container
//            layoutContainer()
//        }
//
//        /// Checks last page for overflow; if there are more glyphs than fit, append a new page
//        func checkAndAddPagesIfNeeded() {
//            guard let lastContainer = textContainers.last else { return }
//            // Range of glyphs in last page
//            let glyphRange = layoutManager.glyphRange(for: lastContainer)
//            // Total glyphs in document
//            let totalGlyphs = layoutManager.numberOfGlyphs
//            // If there are glyphs not yet on a page, add another
//            if glyphRange.upperBound < totalGlyphs {
//                addPage(at: textContainers.count)
//                layoutContainer()
//            }
//        }
//
//        /// Add a new page at given index, offset vertically
//        private func addPage(at index: Int) {
//            guard let container = containerView else { return }
//            let yOffset = CGFloat(index) * (pageSize.height + pageSpacing)
//
//            let textContainer = NSTextContainer(size: pageSize)
//            textContainer.lineFragmentPadding = pagePadding
//            layoutManager.addTextContainer(textContainer)
//            textContainers.append(textContainer)
//
//            let textView = NSTextView(frame: NSRect(origin: .zero, size: pageSize), textContainer: textContainer)
//            textView.isEditable = true
//            textView.isSelectable = true
//            textView.delegate = self
//            textView.drawsBackground = true
//            textView.backgroundColor = .white
//            textView.font = NSFont.systemFont(ofSize: parent.viewModel.document.fontSize)
//
//            let pageScroll = NSScrollView(frame: NSRect(x: 0, y: yOffset,
//                                                        width: pageSize.width,
//                                                        height: pageSize.height))
//            pageScroll.hasVerticalScroller = false
//            pageScroll.hasHorizontalScroller = false
//            pageScroll.drawsBackground = false
//            pageScroll.documentView = textView
//
//            pageScroll.wantsLayer = true
//            pageScroll.layer?.backgroundColor = NSColor.white.cgColor
//            pageScroll.layer?.shadowColor = NSColor.black.withAlphaComponent(0.15).cgColor
//            pageScroll.layer?.shadowRadius = 8
//            pageScroll.layer?.shadowOffset = CGSize(width: 0, height: -4)
//            pageScroll.layer?.shadowOpacity = 1
//
//            container.addSubview(pageScroll)
//            pageScrolls.append(pageScroll)
//
//            parent.viewModel.setTextView(textView)
//
//            Task { @MainActor in
//                await Task.yield()
//                textView.window?.makeFirstResponder(textView)
//            }
//        }
//
//        /// Resize container to fit all pages
//        private func layoutContainer() {
//            guard let container = containerView else { return }
//            let height = CGFloat(pageScrolls.count) * (pageSize.height + pageSpacing) - pageSpacing
//            container.frame = NSRect(x: 0,
//                                     y: 0,
//                                     width: pageSize.width,
//                                     height: height)
//        }
//
//        // MARK: - NSTextViewDelegate
//        func textDidChange(_ notification: Notification) {
//            guard let textView = notification.object as? NSTextView else { return }
//            parent.viewModel.attributedString = NSMutableAttributedString(attributedString: textView.attributedString())
//            parent.viewModel.document.content = textView.string
//            checkAndAddPagesIfNeeded()
//        }
//
//        func textViewDidChangeSelection(_ notification: Notification) {
//            guard let textView = notification.object as? NSTextView else { return }
//            Task { @MainActor in
//                await Task.yield()
//                parent.viewModel.selectedRange = textView.selectedRange()
//                parent.viewModel.updateFormattingFromSelection()
//            }
//        }
//    }
//}


/// A SwiftUI wrapper for a paginated NSTextView editor with seamless multi-page scrolling.
struct PaginatedTextEditor: NSViewRepresentable {
    @ObservedObject var viewModel: DocumentViewModel

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false

        // Post frame change notifications to detect when view is in window
        scrollView.postsFrameChangedNotifications = true
        NotificationCenter.default.addObserver(
            forName: NSView.frameDidChangeNotification,
            object: scrollView,
            queue: nil
        ) { _ in
            // Once the scrollView is laid out in a window, focus the first text view
            guard let firstTV = context.coordinator.firstTextView else { return }
            Task { @MainActor in
                await Task.yield()
                firstTV.window?.makeFirstResponder(firstTV)
            }
        }

        let container = NSView()
        scrollView.documentView = container

        context.coordinator.containerView = container
        // Initialize placeholder if needed
if viewModel.attributedString.length == 0 {
    viewModel.attributedString = NSMutableAttributedString(string: "Welcome to RichTextEditor!", attributes: [
        .foregroundColor: NSColor.black,
        .font: NSFont.systemFont(ofSize: 13)
    ])
}
context.coordinator.setupTextStorage(using: viewModel.attributedString)
        context.coordinator.initialLayout()

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        context.coordinator.updateTextStorage(with: viewModel.attributedString)
        context.coordinator.checkAndAddPagesIfNeeded()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        let parent: PaginatedTextEditor
        var containerView: NSView?
        var firstTextView: NSTextView?  // to track for initial focus

        private let layoutManager = NSLayoutManager()
        private var textStorage: NSTextStorage!

        private var textContainers: [NSTextContainer] = []
        private var pageScrolls: [NSScrollView] = []

        /// A4 at 72 DPI
        private let pageSize = NSSize(width: 609, height: 860)
        private let pageSpacing: CGFloat = 40
        private let pagePadding: CGFloat = 20

        init(_ parent: PaginatedTextEditor) {
            self.parent = parent
            super.init()
        }

        func setupTextStorage(using attributed: NSAttributedString) {
            textStorage = NSTextStorage(attributedString: attributed)
            textStorage.addLayoutManager(layoutManager)
        }

        func updateTextStorage(with attributed: NSAttributedString) {
            layoutManager.textStorage?.setAttributedString(attributed)
        }

        /// Initial single-page setup
        func initialLayout() {
            addPage(at: 0)
            layoutContainer()
        }

        /// Checks last page for overflow; if there are more glyphs than fit, append a new page
        func checkAndAddPagesIfNeeded() {
            guard let lastContainer = textContainers.last else { return }
            let glyphRange = layoutManager.glyphRange(for: lastContainer)
            let totalGlyphs = layoutManager.numberOfGlyphs
            if glyphRange.upperBound < totalGlyphs {
                addPage(at: textContainers.count)
                layoutContainer()
            }
        }

        /// Add a new page at given index, offset vertically
        private func addPage(at index: Int) {
            guard let container = containerView else { return }
            let yOffset = CGFloat(index) * (pageSize.height + pageSpacing)

            let textContainer = NSTextContainer(size: pageSize)
            textContainer.lineFragmentPadding = pagePadding
            layoutManager.addTextContainer(textContainer)
            textContainers.append(textContainer)

            let textView = NSTextView(frame: NSRect(origin: .zero, size: pageSize), textContainer: textContainer)
            textView.autoresizingMask = [.width, .height]
            textView.delegate = self
            textView.isEditable = true
            textView.isSelectable = true
            textView.allowsUndo = true
            textView.isRichText = true
            textView.usesFontPanel = true
            textView.usesRuler = true
            textView.drawsBackground = true
            textView.backgroundColor = .white
            textView.textColor = .black
            textView.font = NSFont(name: parent.viewModel.document.fontName,
                                   size: parent.viewModel.document.fontSize)
                         ?? .systemFont(ofSize: parent.viewModel.document.fontSize)

            // Track the first page's textView
            if index == 0 {
                firstTextView = textView
            }

            let pageScroll = NSScrollView(frame: NSRect(x: 0, y: yOffset,
                                                        width: pageSize.width,
                                                        height: pageSize.height))
            pageScroll.hasVerticalScroller = false
            pageScroll.hasHorizontalScroller = false
            pageScroll.drawsBackground = false
            pageScroll.documentView = textView

            pageScroll.wantsLayer = true
            pageScroll.layer?.backgroundColor = NSColor.white.cgColor
            pageScroll.layer?.shadowColor = NSColor.black.withAlphaComponent(0.15).cgColor
            pageScroll.layer?.shadowRadius = 8
            pageScroll.layer?.shadowOffset = CGSize(width: 0, height: -4)
            pageScroll.layer?.shadowOpacity = 1

            container.addSubview(pageScroll)
            pageScrolls.append(pageScroll)

            parent.viewModel.setTextView(textView)
        }

        /// Resize container to fit all pages
        private func layoutContainer() {
            guard let container = containerView else { return }
            let height = CGFloat(pageScrolls.count) * (pageSize.height + pageSpacing) - pageSpacing
            container.frame = NSRect(x: 0,
                                     y: 0,
                                     width: pageSize.width,
                                     height: height)
        }

        // MARK: - NSTextViewDelegate
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.viewModel.attributedString = NSMutableAttributedString(attributedString: textView.attributedString())
            parent.viewModel.document.content = textView.string
            checkAndAddPagesIfNeeded()
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            Task { @MainActor in
                await Task.yield()
                parent.viewModel.selectedRange = textView.selectedRange()
                parent.viewModel.updateFormattingFromSelection()
            }
        }
    }
}
