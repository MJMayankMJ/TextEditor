//
//  ConteneView.swift
//  TextEditorAssgn
//
//  Created by Mayank Jangid on 6/12/25.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var viewModel = DocumentViewModel()
    
    var body: some View {
        HStack(spacing: 0) {
            // Main Document Area
            DocumentView(viewModel: viewModel)
                .frame(minWidth: 400)
            
            // Sidebar
            SidebarView(viewModel: viewModel)
                .frame(width: 300)
        }
        //.background(Color.black)
    }
}

#Preview {
    ContentView()
}
