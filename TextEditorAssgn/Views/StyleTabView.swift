//
//  StyleTabView.swift
//  TextEditorAssgn
//
//  Created by Mayank Jangid on 6/12/25.
//

import SwiftUI
import AppKit

struct StyleTabView: View {
    @ObservedObject var viewModel: DocumentViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Font Section
                FontSection(viewModel: viewModel)
                
                Divider()
                    .padding(.horizontal)
                
                // Spacing Section
                SpacingSection(viewModel: viewModel)
            }
            .padding(16)
        }
    }
}

struct StyleTabView_Previews: PreviewProvider { static var previews: some View { StyleTabView(viewModel: DocumentViewModel()) } }
