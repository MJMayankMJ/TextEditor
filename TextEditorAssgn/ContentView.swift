//
//  ContentView.swift
//  TextEditorAssgn
//
//  Created by Mayank Jangid on 6/6/25.
//


import SwiftUI
import AppKit

// MARK: - Models
struct DocumentModel {
    var content: String = ""
    var fontName: String = "Helvetica Neue"
    var fontSize: CGFloat = 11.0
    var isBold: Bool = false
    var isItalic: Bool = false
    var isUnderline: Bool = false
    var isStrikethrough: Bool = false
    var textColor: Color = .black
    var lineSpacing: CGFloat = 1.0
    var paragraphSpacingBefore: CGFloat = 0.0
    var paragraphSpacingAfter: CGFloat = 0.0
    var textAlignment: TextAlignment = .leading
}

enum TextAlignment: String, CaseIterable {
    case leading = "Leading"
    case center = "Center"
    case trailing = "Trailing"
    case justified = "Justified"
    
    var nsTextAlignment: NSTextAlignment {
        switch self {
        case .leading: return .left
        case .center: return .center
        case .trailing: return .right
        case .justified: return .justified
        }
    }
}

// MARK: - ViewModel
class DocumentViewModel: ObservableObject {
    @Published var document = DocumentModel()
    
    let availableFonts = [
        "Helvetica Neue",
        "Times New Roman",
        "Arial",
        "Courier New",
        "Georgia",
        "Verdana",
        "Trebuchet MS",
        "Impact"
    ]
    
    let fontWeights = ["Regular", "Medium", "Bold", "Light"]
    
    func updateContent(_ content: String) {
        document.content = content
    }
    
    func updateFontName(_ fontName: String) {
        document.fontName = fontName
    }
    
    func updateFontSize(_ size: CGFloat) {
        document.fontSize = max(8, min(72, size))
    }
    
    func toggleBold() {
        document.isBold.toggle()
    }
    
    func toggleItalic() {
        document.isItalic.toggle()
    }
    
    func toggleUnderline() {
        document.isUnderline.toggle()
    }
    
    func toggleStrikethrough() {
        document.isStrikethrough.toggle()
    }
    
    func updateTextColor(_ color: Color) {
        document.textColor = color
    }
    
    func updateLineSpacing(_ spacing: CGFloat) {
        document.lineSpacing = max(0.5, min(3.0, spacing))
    }
    
    func updateParagraphSpacingBefore(_ spacing: CGFloat) {
        document.paragraphSpacingBefore = max(0, min(100, spacing))
    }
    
    func updateParagraphSpacingAfter(_ spacing: CGFloat) {
        document.paragraphSpacingAfter = max(0, min(100, spacing))
    }
    
    func updateTextAlignment(_ alignment: TextAlignment) {
        document.textAlignment = alignment
    }
}

// MARK: - Views
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
        .background(Color(NSColor.windowBackgroundColor))
    }
}

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
                    .frame(width: 595, height: 842) // A4 size at 72 DPI
                    
                    Spacer(minLength: 40)
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
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
        case .justified: return .leading // SwiftUI doesn't have justified
        }
    }
}

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

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color.clear)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

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

struct FontSection: View {
    @ObservedObject var viewModel: DocumentViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Font")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
            
            // Font Name Dropdown
            Menu {
                ForEach(viewModel.availableFonts, id: \.self) { font in
                    Button(font) {
                        viewModel.updateFontName(font)
                    }
                }
            } label: {
                HStack {
                    Text(viewModel.document.fontName)
                        .font(.system(size: 12))
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .foregroundColor(.orange)
                        .font(.system(size: 10))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(NSColor.controlColor))
                .cornerRadius(4)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Font Weight and Size
            HStack(spacing: 8) {
                Menu {
                    ForEach(viewModel.fontWeights, id: \.self) { weight in
                        Button(weight) {
                            // Handle font weight
                        }
                    }
                } label: {
                    HStack {
                        Text("Regular")
                            .font(.system(size: 12))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundColor(.orange)
                            .font(.system(size: 10))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(NSColor.controlColor))
                    .cornerRadius(4)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity)
                
                // Font Size
                HStack(spacing: 4) {
                    TextField("Size", value: .constant(viewModel.document.fontSize), format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 40)
                    
                    Text("pt")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 1) {
                        Button(action: { viewModel.updateFontSize(viewModel.document.fontSize + 1) }) {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 8))
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Button(action: { viewModel.updateFontSize(viewModel.document.fontSize - 1) }) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 8))
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
            
            // Style Buttons
            HStack(spacing: 4) {
                StyleButton(icon: "bold", isActive: viewModel.document.isBold) {
                    viewModel.toggleBold()
                }
                StyleButton(icon: "italic", isActive: viewModel.document.isItalic) {
                    viewModel.toggleItalic()
                }
                StyleButton(icon: "underline", isActive: viewModel.document.isUnderline) {
                    viewModel.toggleUnderline()
                }
                StyleButton(icon: "strikethrough", isActive: viewModel.document.isStrikethrough) {
                    viewModel.toggleStrikethrough()
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(6)
                .background(Color(NSColor.controlColor))
                .cornerRadius(4)
            }
            
            // Character Styles
            VStack(alignment: .leading, spacing: 8) {
                Text("Character Styles")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                
                Menu {
                    Button("None") {}
                    Button("Title") {}
                    Button("Heading") {}
                    Button("Subheading") {}
                } label: {
                    HStack {
                        Text("None")
                            .font(.system(size: 12))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundColor(.secondary)
                            .font(.system(size: 10))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(NSColor.controlColor))
                    .cornerRadius(4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Text Color
            HStack {
                Text("Text Color")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                ColorPicker("", selection: $viewModel.document.textColor, supportsOpacity: false)
                    .labelsHidden()
                    .frame(width: 30, height: 20)
            }
            
            // Alignment Buttons
            HStack(spacing: 4) {
                AlignmentButton(alignment: .leading, currentAlignment: viewModel.document.textAlignment) {
                    viewModel.updateTextAlignment(.leading)
                }
                AlignmentButton(alignment: .center, currentAlignment: viewModel.document.textAlignment) {
                    viewModel.updateTextAlignment(.center)
                }
                AlignmentButton(alignment: .trailing, currentAlignment: viewModel.document.textAlignment) {
                    viewModel.updateTextAlignment(.trailing)
                }
                AlignmentButton(alignment: .justified, currentAlignment: viewModel.document.textAlignment) {
                    viewModel.updateTextAlignment(.justified)
                }
            }
            
            // Indent buttons
            HStack(spacing: 4) {
                Button(action: {}) {
                    Image(systemName: "increase.indent")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(BorderlessButtonStyle())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color(NSColor.controlColor))
                .cornerRadius(4)
                
                Button(action: {}) {
                    Image(systemName: "decrease.indent")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(BorderlessButtonStyle())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color(NSColor.controlColor))
                .cornerRadius(4)
            }
        }
    }
}

struct SpacingSection: View {
    @ObservedObject var viewModel: DocumentViewModel
    @State private var isExpanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.system(size: 10))
                    
                    Text("Spacing")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    // Line Spacing
                    HStack {
                        Menu {
                            Button("Single") { viewModel.updateLineSpacing(1.0) }
                            Button("1.5") { viewModel.updateLineSpacing(1.5) }
                            Button("Double") { viewModel.updateLineSpacing(2.0) }
                        } label: {
                            HStack {
                                Text("Lines")
                                    .font(.system(size: 12))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.up.chevron.down")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 10))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(NSColor.controlColor))
                            .cornerRadius(4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(maxWidth: .infinity)
                        
                        HStack(spacing: 4) {
                            TextField("", value: .constant(viewModel.document.lineSpacing), format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 40)
                            
                            VStack(spacing: 1) {
                                Button(action: { viewModel.updateLineSpacing(viewModel.document.lineSpacing + 0.1) }) {
                                    Image(systemName: "chevron.up")
                                        .font(.system(size: 8))
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                
                                Button(action: { viewModel.updateLineSpacing(viewModel.document.lineSpacing - 0.1) }) {
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 8))
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                    
                    // Before Paragraph
                    HStack {
                        Text("Before Paragraph")
                            .font(.system(size: 12))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 4) {
                            TextField("", value: .constant(viewModel.document.paragraphSpacingBefore), format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 40)
                            
                            Text("pt")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 1) {
                                Button(action: { viewModel.updateParagraphSpacingBefore(viewModel.document.paragraphSpacingBefore + 1) }) {
                                    Image(systemName: "chevron.up")
                                        .font(.system(size: 8))
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                
                                Button(action: { viewModel.updateParagraphSpacingBefore(viewModel.document.paragraphSpacingBefore - 1) }) {
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 8))
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                    
                    // After Paragraph
                    HStack {
                        Text("After Paragraph")
                            .font(.system(size: 12))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 4) {
                            TextField("", value: .constant(viewModel.document.paragraphSpacingAfter), format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 40)
                            
                            Text("pt")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 1) {
                                Button(action: { viewModel.updateParagraphSpacingAfter(viewModel.document.paragraphSpacingAfter + 1) }) {
                                    Image(systemName: "chevron.up")
                                        .font(.system(size: 8))
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                
                                Button(action: { viewModel.updateParagraphSpacingAfter(viewModel.document.paragraphSpacingAfter - 1) }) {
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 8))
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                }
            }
        }
    }
}

struct StyleButton: View {
    let icon: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(isActive ? .white : .primary)
                .font(.system(size: 12, weight: .medium))
        }
        .buttonStyle(BorderlessButtonStyle())
        .frame(width: 28, height: 24)
        .background(isActive ? Color.accentColor : Color(NSColor.controlColor))
        .cornerRadius(4)
    }
}

struct AlignmentButton: View {
    let alignment: TextAlignment
    let currentAlignment: TextAlignment
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: alignmentIcon)
                .foregroundColor(currentAlignment == alignment ? .orange : .secondary)
                .font(.system(size: 12))
        }
        .buttonStyle(BorderlessButtonStyle())
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(currentAlignment == alignment ? Color.orange.opacity(0.2) : Color(NSColor.controlColor))
        .cornerRadius(4)
    }
    
    private var alignmentIcon: String {
        switch alignment {
        case .leading: return "text.alignleft"
        case .center: return "text.aligncenter"
        case .trailing: return "text.alignright"
        case .justified: return "text.justify"
        }
    }
}

// MARK: - App
@main
struct PagesCloneApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(DefaultWindowStyle())
    }
}
