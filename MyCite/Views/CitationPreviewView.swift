//
//  CitationPreviewView.swift
//  MyCite
//
//  Created by Akshat Barjatya on 23/02/2026.
//

import SwiftUI

struct CitationPreviewView: View {
    let source: Source
    @Binding var citationStyle: CitationStyle
    let index: Int

    @State private var copied = false

    private var citation: String {
        CitationFormatter.format(source: source, style: citationStyle, index: index)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Source info header
            HStack {
                Image(systemName: iconForSourceType(source.sourceType))
                    .font(.title2)
                    .foregroundStyle(.orange)
                VStack(alignment: .leading) {
                    Text(source.title.isEmpty ? "Untitled" : source.title)
                        .font(.title3.bold())
                    if !source.authors.isEmpty {
                        Text(source.authors.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }

            Divider()

            // Style picker
            HStack {
                Text("Citation Style:")
                    .font(.subheadline.bold())
                Picker("", selection: $citationStyle) {
                    ForEach(CitationStyle.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .labelsHidden()
                .frame(maxWidth: 200)
            }

            // Citation output
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Generated Citation")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button(action: copyToClipboard) {
                        HStack(spacing: 4) {
                            Image(systemName: copied ? "checkmark.circle.fill" : "doc.on.doc")
                            Text(copied ? "Copied!" : "Copy")
                        }
                        .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .tint(copied ? .green : .accentColor)
                }

                Text(citation)
                    .font(.system(.body, design: .serif))
                    .textSelection(.enabled)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                    )
            }

            // Source details
            Divider()

            Text("Source Details")
                .font(.headline)

            detailGrid

            Spacer()
        }
        .padding(20)
    }

    // MARK: - Detail Grid

    private var detailGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !source.url.isEmpty { detailRow("URL", source.url) }
            if !source.publisher.isEmpty { detailRow("Publisher", source.publisher) }
            if !source.journalName.isEmpty { detailRow("Journal/Paper", source.journalName) }
            if !source.volume.isEmpty { detailRow("Volume", source.volume) }
            if !source.issue.isEmpty { detailRow("Issue", source.issue) }
            if !source.pages.isEmpty { detailRow("Pages", source.pages) }
            if !source.edition.isEmpty { detailRow("Edition", source.edition) }
            if !source.city.isEmpty { detailRow("City", source.city) }
            if !source.doi.isEmpty { detailRow("DOI", source.doi) }
            if !source.year.isEmpty { detailRow("Year", source.year) }
            if !source.notes.isEmpty { detailRow("Notes", source.notes) }
        }
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .trailing)
            Text(value)
                .font(.callout)
                .textSelection(.enabled)
        }
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

    private func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(citation, forType: .string)
        copied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copied = false
        }
    }
}
