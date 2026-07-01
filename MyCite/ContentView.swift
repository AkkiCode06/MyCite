//
//  ContentView.swift
//  MyCite
//
//  Created by Akshat Barjatya on 23/02/2026.
//

import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

enum ActiveSheet: Identifiable {
    case addSource(Project)
    case editSource(Project, Source)

    var id: String {
        switch self {
        case .addSource(let project):
            return "add-\(project.id)"
        case .editSource(_, let source):
            return "edit-\(source.id)"
        }
    }
}

struct ContentView: View {
    @State private var selectedProject: Project?
    @State private var selectedSource: Source?
    @State private var citationStyle: CitationStyle = .harvard
    @State private var activeSheet: ActiveSheet?
    @State private var showingAddSource: Bool = false

    var body: some View {
        ZStack {
            // Adaptive background that respects system appearance and accent
            LinearGradient(
                gradient: Gradient(colors: [
                    {
                        #if canImport(UIKit)
                        Color(UIColor.systemBackground)
                        #elseif canImport(AppKit)
                        Color(nsColor: NSColor.windowBackgroundColor)
                        #else
                        Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
                        #endif
                    }().opacity(1.0),
                    Color.accentColor.opacity(0.10)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Subtle paper texture via material blur
            Rectangle()
                .fill(.ultraThinMaterial)
                .blur(radius: 20)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Glasmorphic header with logo
                HStack(spacing: 12) {
#if canImport(UIKit)
                    if let uiImage = UIImage(named: "akkiLogo") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                    } else {
                        Image(systemName: "book.circle.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.tint)
                    }
                    #elseif canImport(AppKit)
                    if let nsImage = NSImage(named: "akkiLogo") {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                    } else {
                        Image(systemName: "book.circle.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.tint)
                    }
                    #else
                    Image(systemName: "book.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.tint)
                    #endif
                    Text("MyCite")
                        .font(.headline)
                        .fontDesign(.serif)
                        .textCase(nil)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 8)

                // Book-styled container
                ZStack {
                    // Book pages background
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.regularMaterial)
                        .overlay(
                            // Center spine
                            Rectangle()
                                .fill(Color.primary.opacity(0.08))
                                .frame(width: 1)
                                .blendMode(.multiply)
                        )
                        .overlay(
                            // Page edge highlights
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.10), radius: 18, x: 0, y: 10)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)

                    // Actual content split view
                    NavigationSplitView {
                        ProjectListView(selectedProject: $selectedProject)
                    } content: {
                        if let project = selectedProject {
                            SourceListView(
                                project: project,
                                selectedSource: $selectedSource,
                                citationStyle: $citationStyle,
                                showingAddSource: Binding(get: {
                                    activeSheet != nil && {
                                        if case .addSource(let p) = activeSheet { return selectedProject?.id == p.id }
                                        return false
                                    }()
                                }, set: { newValue in
                                    if newValue {
                                        if let project = selectedProject { activeSheet = .addSource(project) }
                                    } else {
                                        if case .addSource = activeSheet { activeSheet = nil }
                                    }
                                })
                            )
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "folder.badge.plus")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.secondary)
                                Text("Select or create a project")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } detail: {
                        if let source = selectedSource {
                            CitationPreviewView(
                                source: source,
                                citationStyle: $citationStyle,
                                index: sourceIndex(for: source)
                            )
                            .toolbar {
                                ToolbarItem {
                                    Button("Edit") {
                                        if let project = selectedProject {
                                            activeSheet = .editSource(project, source)
                                        }
                                    }
                                }
                            }
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.secondary)
                                Text("Select a source to view its citation")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onChange(of: selectedProject) {
                        selectedSource = nil
                    }
                    .navigationSplitViewColumnWidth(min: 200, ideal: 250)
                    .sheet(item: $activeSheet) { sheet in
                        switch sheet {
                        case .addSource(let project):
                            SourceDetailView(
                                project: project,
                                citationStyle: citationStyle
                            )
                        case .editSource(let project, let source):
                            SourceDetailView(
                                project: project,
                                existingSource: source,
                                citationStyle: citationStyle
                            )
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
            }
        }
    }

    private func sourceIndex(for source: Source) -> Int {
        guard let project = selectedProject else { return 1 }
        let sorted = project.sources.sorted { $0.createdDate < $1.createdDate }
        return (sorted.firstIndex(where: { $0.id == source.id }) ?? 0) + 1
    }
}

