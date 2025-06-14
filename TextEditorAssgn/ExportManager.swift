//
//  ExportManager.swift
//  TextEditorAssgn
//
//  Created by Mayank Jangid on 6/14/25.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

// MARK: - Export Manager
class ExportManager: ObservableObject {
    @Published var isShowingExportAlert = false
    @Published var exportSuccessMessage = ""
    @Published var exportErrorMessage = ""

    // MARK: - Public Export Triggers

    /// Prepares to export the content of a text view as a PDF file.
    func exportToPDF(textView: NSTextView?) {
        presentSavePanel(
            textView: textView,
            for: .pdf,
            defaultName: "Document.pdf",
            title: "Export PDF"
        ) { url, textView in
            self.createPDF(textView: textView, at: url)
        }
    }

    /// Prepares to export the content of a text view as an RTF file.
    func exportToRTF(textView: NSTextView?) {
        presentSavePanel(
            textView: textView,
            for: .rtf,
            defaultName: "Document.rtf",
            title: "Export RTF Document"
        ) { url, textView in
            self.createRTF(textView: textView, at: url)
        }
    }

    /// Prepares to export the content of a text view as an HTML file.
    func exportToHTML(textView: NSTextView?) {
        presentSavePanel(
            textView: textView,
            for: .html,
            defaultName: "Document.html",
            title: "Export HTML Document"
        ) { url, textView in
            self.createHTML(textView: textView, at: url)
        }
    }

    /// Prepares to export the content of a text view as a plain text file.
    func exportToPlainText(textView: NSTextView?) {
        presentSavePanel(
            textView: textView,
            for: .plainText,
            defaultName: "Document.txt",
            title: "Export Plain Text"
        ) { url, textView in
            self.createPlainText(textView: textView, at: url)
        }
    }

    // MARK: - Private Generic Save Panel Handler

    /// Presents a configured NSSavePanel and executes a completion handler with the chosen URL.
    /// - Parameters:
    ///   - textView: The source text view for the content.
    ///   - type: The UTType for the file to be saved.
    ///   - defaultName: The default file name in the save panel.
    ///   - title: The title of the save panel window.
    ///   - onSave: A closure that performs the file writing operation.
    private func presentSavePanel(
        textView: NSTextView?,
        for type: UTType,
        defaultName: String,
        title: String,
        onSave: @escaping (URL, NSTextView) -> Void
    ) {
        guard let textView = textView else {
            self.showExportError(message: "Cannot export because the text view is not available.")
            return
        }

        DispatchQueue.main.async {
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [type]
            savePanel.nameFieldStringValue = defaultName
            savePanel.title = title

            savePanel.begin { response in
                if response == .OK, let url = savePanel.url {
                    // Call the specific save handler provided in the closure
                    onSave(url, textView)
                }
            }
        }
    }


    // MARK: - Private File Creation Methods

    private func createPDF(textView: NSTextView, at url: URL) {
        // Generates PDF data from the view's printable area.
        let pdfData = textView.dataWithPDF(inside: textView.bounds)

        do {
            try pdfData.write(to: url)
            DispatchQueue.main.async {
                self.showExportSuccess(format: "PDF", url: url)
            }
        } catch {
            DispatchQueue.main.async {
                self.showExportError(error: error)
            }
        }
    }

    private func createRTF(textView: NSTextView, at url: URL) {
        guard let textStorage = textView.textStorage else {
            DispatchQueue.main.async {
                self.showExportError(message: "Could not access text storage for RTF export.")
            }
            return
        }

        let range = NSRange(location: 0, length: textStorage.length)

        do {
            // Generate RTF data from the attributed string.
            let rtfData = try textStorage.data(from: range, documentAttributes: [
                .documentType: NSAttributedString.DocumentType.rtf
            ])

            try rtfData.write(to: url)
            DispatchQueue.main.async {
                self.showExportSuccess(format: "RTF", url: url)
            }
        } catch {
            DispatchQueue.main.async {
                self.showExportError(error: error)
            }
        }
    }

    private func createHTML(textView: NSTextView, at url: URL) {
        guard let textStorage = textView.textStorage else {
            DispatchQueue.main.async {
                self.showExportError(message: "Could not access text storage for HTML export.")
            }
            return
        }

        let range = NSRange(location: 0, length: textStorage.length)

        do {
            // Generate HTML data from the attributed string.
            let htmlData = try textStorage.data(from: range, documentAttributes: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ])

            try htmlData.write(to: url)
            DispatchQueue.main.async {
                self.showExportSuccess(format: "HTML", url: url)
            }
        } catch {
            DispatchQueue.main.async {
                self.showExportError(error: error)
            }
        }
    }

    private func createPlainText(textView: NSTextView, at url: URL) {
        // The `string` property provides the plain text representation of the content.
        let plainText = textView.string

        do {
            try plainText.write(to: url, atomically: true, encoding: .utf8)
            DispatchQueue.main.async {
                self.showExportSuccess(format: "Plain Text", url: url)
            }
        } catch {
            DispatchQueue.main.async {
                self.showExportError(error: error)
            }
        }
    }

    // MARK: - Helper Methods for Alerts

    private func showExportSuccess(format: String, url: URL) {
        exportSuccessMessage = "\(format) exported successfully to \(url.lastPathComponent)"
        exportErrorMessage = ""
        isShowingExportAlert = true
    }

    private func showExportError(error: Error) {
        exportErrorMessage = "Export failed: \(error.localizedDescription)"
        exportSuccessMessage = ""
        isShowingExportAlert = true
    }
    
    private func showExportError(message: String) {
        exportErrorMessage = message
        exportSuccessMessage = ""
        isShowingExportAlert = true
    }
}
