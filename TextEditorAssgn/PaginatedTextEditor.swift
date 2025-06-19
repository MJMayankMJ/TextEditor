//
//  PaginatedTextEditor.swift
//  TextEditorAssgn
//
//  Created by Mayank Jangid on 6/14/25.
//



import SwiftUI
import AppKit

// MARK: - Page View
struct PageView: NSViewRepresentable {
    let layoutManager: NSLayoutManager
    let textContainer: NSTextContainer
    let viewModel: DocumentViewModel
    
    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView(frame: .zero, textContainer: textContainer)
        textView.isVerticallyResizable = false
        textView.isHorizontallyResizable = false
        textView.textContainerInset = .zero
        textView.backgroundColor = .white
        textView.isEditable = true
        textView.isSelectable = true
        textView.delegate = context.coordinator
        textView.textContainer?.lineFragmentPadding = 10
        
        // Set the text view in the view model for formatting operations
        viewModel.setTextView(textView)
        
        return textView
    }
    
    func updateNSView(_ nsView: NSTextView, context: Context) {
        // Ensure the text view is properly connected
        if nsView.textStorage != layoutManager.textStorage {
            nsView.layoutManager?.removeTextContainer(at: 0)
            nsView.textContainer = textContainer
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        let parent: PageView
        
        init(_ parent: PageView) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            // Update the view model content
            parent.viewModel.updateContent(textView.string)
            
            // Update formatting based on current selection
            parent.viewModel.updateFormattingFromSelection()
            
            // Trigger page count recalculation
            DispatchQueue.main.async {
                self.parent.viewModel.objectWillChange.send()
            }
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            // Update formatting when selection changes
            parent.viewModel.updateFormattingFromSelection()
        }
    }
}

// MARK: - Dynamic Paging Manager
final class DynamicPagingManager: ObservableObject {
    @Published var textContainers: [NSTextContainer] = []
    
    let textStorage: NSTextStorage
    let layoutManager: NSLayoutManager
    private let pageSize = CGSize(width: 612 - 72, height: 792 - 72)
    private var minimumPages: Int
    
    init(attributedString: NSAttributedString, minimumPages: Int = 1) {
        self.minimumPages = minimumPages
        
        // Initialize TextKit stack
        textStorage = NSTextStorage(attributedString: attributedString)
        layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        // Create initial containers
        createContainers(count: minimumPages)
        
        // Set up observation for text changes
        setupTextStorageObservation()
    }
    
    private func setupTextStorageObservation() {
        NotificationCenter.default.addObserver(
            forName: NSTextStorage.didProcessEditingNotification,
            object: textStorage,
            queue: .main
        ) { [weak self] _ in
            self?.adjustPageCountIfNeeded()
        }
    }
    
    private func createContainers(count: Int) {
        // Remove existing containers
        textContainers.forEach { container in
            if let index = layoutManager.textContainers.firstIndex(of: container) {
                layoutManager.removeTextContainer(at: index)
            }
        }
        textContainers.removeAll()
        
        // Create new containers
        for _ in 0..<count {
            let container = NSTextContainer(size: pageSize)
            container.widthTracksTextView = true
            container.heightTracksTextView = false
            layoutManager.addTextContainer(container)
            textContainers.append(container)
        }
    }
    
    private func adjustPageCountIfNeeded() {
        let requiredPages = calculateRequiredPages()
        let currentPages = textContainers.count
        
        if requiredPages != currentPages {
            DispatchQueue.main.async {
                self.createContainers(count: requiredPages)
            }
        }
    }
    
    private func calculateRequiredPages() -> Int {
            // Force layout to complete for all containers
            for container in textContainers {
                layoutManager.ensureLayout(for: container)
            }
            
            // Check if we have overflow in any container
            var requiredPages = minimumPages
            
            for (index, container) in textContainers.enumerated() {
                let glyphRange = layoutManager.glyphRange(for: container)
                let usedRect = layoutManager.usedRect(for: container)
                
                // Check if this container is nearly full or has overflow
                if usedRect.height > pageSize.height * 0.9 {
                    requiredPages = max(requiredPages, index + 2) // Need at least one more page
                }
                
                // If this container has text, we need at least this many pages
                if glyphRange.length > 0 {
                    requiredPages = max(requiredPages, index + 1)
                }
            }
        
        // Check for any remaining text that doesn't fit
        let totalGlyphRange = NSRange(location: 0, length: layoutManager.numberOfGlyphs)
        var coveredRange = NSRange(location: 0, length: 0)
        
        for container in textContainers {
            let containerRange = layoutManager.glyphRange(for: container)
            coveredRange = NSUnionRange(coveredRange, containerRange)
        }
        
        // If we haven't covered all text, we need more pages
        if coveredRange.length < totalGlyphRange.length {
            requiredPages += 1
        }
        
        return max(minimumPages, requiredPages)
    }
    
    func updateContent(_ newString: NSAttributedString) {
        textStorage.setAttributedString(newString)
        // Page adjustment will happen automatically via the notification observer
    }
    
    func updateMinimumPages(_ count: Int) {
        minimumPages = max(1, count)
        adjustPageCountIfNeeded()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
// 3) The SwiftUI view that lays out pages once, then updates
struct PaginatedDocumentView: View {
    @ObservedObject var viewModel: DocumentViewModel
    @StateObject private var pagingManager: DynamicPagingManager
    
    init(viewModel: DocumentViewModel) {
        self.viewModel = viewModel
        _pagingManager = StateObject(wrappedValue:
            DynamicPagingManager(
                attributedString: viewModel.attributedString,
                minimumPages: 1
            )
        )
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack(spacing: 20) {
                ForEach(pagingManager.textContainers.indices, id: \.self) { index in
                    ZStack {
                        // Simple page background
                        Rectangle()
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.3), radius: 4, x: 2, y: 2)
                        
                        // Page content
                        PageView(
                            layoutManager: pagingManager.layoutManager,
                            textContainer: pagingManager.textContainers[index],
                            viewModel: viewModel
                        )
                        .padding(20)
                    }
                    .frame(width: 612, height: 792)
                }
            }
            .padding(20)
        }
        .background(Color.gray.opacity(0.2))
        .onChange(of: viewModel.attributedString) { newValue in
            pagingManager.updateContent(newValue)
        }
    }
}
