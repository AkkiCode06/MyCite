//
//  SourceListView.swift
//  MyCite
//
//  Created by Akshat Barjatya on 23/02/2026.
//

import SwiftUI
import SwiftData

struct SourceListView: View {
    @Environment(\.modelContext) private var modelContext
    let project: Project
    @Binding var selectedSource: Source?
    @Binding var citationStyle: CitationStyle
    @Binding var showingAddSource: Bool

    @State private var searchText = ""

    private var filteredSources: [Source] {
        let sources = project.sources.sorted { $0.createdDate > $1.createdDate }
        if searchText.isEmpty { return sources }
        return sources.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.authors.joined(separator: " ").localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Citation style picker
            HStack {
                Text("Format:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Picker("", selection: $citationStyle) {
                    ForEach(CitationStyle.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .labelsHidden()
                .frame(maxWidth: 200)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Source list
            List(selection: $selectedSource) {
                ForEach(Array(filteredSources.enumerated()), id: \.element.id) { index, source in
                    sourceRow(source, index: index + 1)
                        .tag(source)
                        .contextMenu {
                            Button("Copy Citation") {
                                let citation = CitationFormatter.format(
                                    source: source,
                                    style: citationStyle,
                                    index: index + 1
                                )
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(citation, forType: .string)
                            }
                            Divider()
                            Button("Delete", role: .destructive) {
                                deleteSource(source)
                            }
                        }
                }
            }
            .listStyle(.inset)
            .searchable(text: $searchText, prompt: "Search sources")
        }
        .navigationTitle(project.name)
        .toolbar {
            ToolbarItem {
                Button(action: { showingAddSource = true }) {
                    Label("Add Source", systemImage: "plus")
                }
            }

            ToolbarItem {
                Button(action: copyAllCitations) {
                    Label("Copy All", systemImage: "doc.on.doc")
                }
                .help("Copy all citations to clipboard")
                .disabled(project.sources.isEmpty)
            }
        }
    }

    // MARK: - Source Row

    @ViewBuilder
    private func sourceRow(_ source: Source, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: iconForSourceType(source.sourceType))
                    .foregroundStyle(.orange)
                Text(source.title.isEmpty ? "Untitled" : source.title)
                    .font(.headline)
                    .lineLimit(1)
            }

            if !source.authors.isEmpty {
                Text(source.authors.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            // Citation preview
            Text(CitationFormatter.format(source: source, style: citationStyle, index: index))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .padding(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helpers

    private func iconForSourceType(_ type: SourceType) -> String {
        switch type {
        case .website: return "globe"
        case .book: return "book.fill"
        case .journalArticle: return "doc.text.fill"
        case .newspaperArticle: return "newspaper.fill"
        }
    }

    private func deleteSource(_ source: Source) {
        if selectedSource == source {
            selectedSource = nil
        }
        modelContext.delete(source)
    }

    private func copyAllCitations() {
        let sorted = project.sources.sorted { $0.createdDate < $1.createdDate }
        let citations = sorted.enumerated().map { index, source in
            CitationFormatter.format(source: source, style: citationStyle, index: index + 1)
        }
        let text = citations.joined(separator: "\n\n")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}
