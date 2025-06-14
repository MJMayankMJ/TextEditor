//
//  SideBarView.swift
//  TextEditorAssgn
//
//  Created by Mayank Jangid on 6/12/25.
//

import SwiftUI
import AppKit

import SwiftUI

struct SidebarView: View {
    @ObservedObject var viewModel: DocumentViewModel
    @StateObject private var exportManager = ExportManager()
    @State private var selectedTab = 0
    @State private var showingExportMenu = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Top tab bar
            HStack(spacing: 0) {
                TabButton(title: "Style", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                TabButton(title: "Layout", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                TabButton(title: "Export", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
            }
            .background(Color(NSColor.windowBackgroundColor))
            
            // Content area
            if selectedTab == 0 {
                StyleTabView(viewModel: viewModel)
            } else if selectedTab == 1 {
                LayoutTabView(viewModel: viewModel)
            } else if selectedTab == 2 {
                ExportTabView(viewModel: viewModel, exportManager: exportManager)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .alert("Export Status", isPresented: $exportManager.isShowingExportAlert) {
            Button("OK") { }
        } message: {
            Text(exportManager.exportSuccessMessage.isEmpty ? exportManager.exportErrorMessage : exportManager.exportSuccessMessage)
        }
    }
}

// MARK: - Export Tab View
struct ExportTabView: View {
    @ObservedObject var viewModel: DocumentViewModel
    @ObservedObject var exportManager: ExportManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Export Document")
                    .font(.headline)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                
                VStack(spacing: 12) {
                    ExportButton(
                        title: "Export as PDF",
                        description: "Portable Document Format",
                        icon: "doc.richtext",
                        action: {
                            exportManager.exportToPDF(textView: viewModel.textView)
                        }
                    )
                    
                    ExportButton(
                        title: "Export as RTF",
                        description: "Rich Text Format",
                        icon: "doc.text",
                        action: {
                            exportManager.exportToRTF(textView: viewModel.textView)
                        }
                    )
                    
                    ExportButton(
                        title: "Export as HTML",
                        description: "Web Document",
                        icon: "globe",
                        action: {
                            exportManager.exportToHTML(textView: viewModel.textView)
                        }
                    )
                    
                    ExportButton(
                        title: "Export as Plain Text",
                        description: "Text File",
                        icon: "doc.plaintext",
                        action: {
                            exportManager.exportToPlainText(textView: viewModel.textView)
                        }
                    )
                }
                .padding(.horizontal, 16)
                
                Spacer()
            }
        }
    }
}

// MARK: - Export Button Component
struct ExportButton: View {
    let title: String
    let description: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                    Text(description)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { isHovering in
            // Add hover effect if needed
        }
    }
}

// MARK: - Layout Tab View (Placeholder)
struct LayoutTabView: View {
    @ObservedObject var viewModel: DocumentViewModel
    
    var body: some View {
        VStack {
            Spacer()
            Text("Layout options coming soon...")
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView(viewModel: DocumentViewModel())
    }
}
