//
//  SideBarView.swift
//  TextEditorAssgn
//
//  Created by Mayank Jangid on 6/12/25.
//

import SwiftUI
import AppKit

struct SidebarView: View {
    @ObservedObject var viewModel: DocumentViewModel
    @State private var selectedTab = 0
    
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
                TabButton(title: "More", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
            }
            .background(Color(NSColor.windowBackgroundColor))
            
            // Content area
            if selectedTab == 0 {
                StyleTabView(viewModel: viewModel)
            } else {
                VStack {
                    Spacer()
                    Text("Other tabs coming soon...")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct SidebarView_Previews: PreviewProvider { static var previews: some View { SidebarView(viewModel: DocumentViewModel()) } }
