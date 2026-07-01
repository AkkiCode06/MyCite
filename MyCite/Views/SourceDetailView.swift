//
//  SourceDetailView.swift
//  MyCite
//
//  Created by Akshat Barjatya on 23/02/2026.
//

import SwiftUI
import SwiftData

struct SourceDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let project: Project
    let existingSource: Source?
    let citationStyle: CitationStyle

    // Form state
    @State private var sourceType: SourceType = .website
    @State private var title = ""
    @State private var authors: [String] = []
    @State private var newAuthor = ""
    @State private var year = ""
    @State private var month = ""
    @State private var day = ""
    @State private var useCurrentDate = true
    @State private var url = ""
    @State private var publisher = ""
    @State private var journalName = ""
    @State private var volume = ""
    @State private var issue = ""
    @State private var pages = ""
    @State private var edition = ""
    @State private var city = ""
    @State private var doi = ""
    @State private var accessDate = Date()
    @State private var notes = ""

    @State private var copiedToClipboard = false

    private var isEditing: Bool { existingSource != nil }

    init(project: Project, existingSource: Source? = nil, citationStyle: CitationStyle) {
        self.project = project
        self.existingSource = existingSource
        self.citationStyle = citationStyle
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text(isEditing ? "Edit Source" : "Add Source")
                    .font(.title.bold())

                // Citation preview
                citationPreview

                Divider()

                // Source type
                sectionHeader("Source Type")
                Picker("Type", selection: $sourceType) {
                    ForEach(SourceType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)

                // Core fields
                sectionHeader("Title")
                TextField("Title of the work", text: $title)
                    .textFieldStyle(.roundedBorder)

                // Authors
                authorsSection

                // Date
                dateSection

                Divider()

                // Type-specific fields
                typeSpecificFields

                Divider()

                // Notes
                sectionHeader("Notes")
                TextEditor(text: $notes)
                    .font(.body)
                    .frame(minHeight: 60)
                    .border(Color.gray.opacity(0.3))

                // Actions
                HStack {
                    Spacer()
                    Button("Cancel") { dismiss() }
                        .keyboardShortcut(.cancelAction)
                    Button(isEditing ? "Save" : "Add Source") { save() }
                        .keyboardShortcut(.defaultAction)
                        .buttonStyle(.borderedProminent)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .padding(24)
        }
        .frame(minWidth: 500, minHeight: 600)
        .onAppear { loadExistingSource() }
    }

    // MARK: - Citation Preview

    private var citationPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Citation Preview")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                Button(action: copyCitation) {
                    HStack(spacing: 4) {
                        Image(systemName: copiedToClipboard ? "checkmark" : "doc.on.doc")
                        Text(copiedToClipboard ? "Copied!" : "Copy")
                    }
                    .font(.caption)
                }
                .buttonStyle(.bordered)
            }

            Text(currentCitation)
                .font(.system(.body, design: .serif))
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
        }
    }

    private var currentCitation: String {
        let tempSource = Source(
            sourceType: sourceType,
            title: title,
            authors: authors,
            year: effectiveYear,
            month: effectiveMonth,
            day: effectiveDay,
            url: url,
            publisher: publisher,
            journalName: journalName,
            volume: volume,
            issue: issue,
            pages: pages,
            edition: edition,
            city: city,
            doi: doi,
            accessDate: accessDate,
            notes: notes
        )
        return CitationFormatter.format(source: tempSource, style: citationStyle)
    }

    // MARK: - Authors Section

    private var authorsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Authors")

            ForEach(Array(authors.enumerated()), id: \.offset) { index, author in
                HStack {
                    Text(author)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button(action: { authors.remove(at: index) }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 2)
            }

            HStack {
                TextField("Author full name (e.g. John Smith)", text: $newAuthor)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { addAuthor() }
                Button("Add") { addAuthor() }
                    .disabled(newAuthor.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    // MARK: - Date Section

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Date")

            Toggle("Use current date", isOn: $useCurrentDate)
                .onChange(of: useCurrentDate) { _, newValue in
                    if newValue {
                        let now = Date()
                        let cal = Calendar.current
                        year = String(cal.component(.year, from: now))
                        month = cal.monthSymbols[cal.component(.month, from: now) - 1]
                        day = String(cal.component(.day, from: now))
                    }
                }

            if !useCurrentDate {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Year").font(.caption)
                        TextField("2026", text: $year)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                    }
                    VStack(alignment: .leading) {
                        Text("Month").font(.caption)
                        TextField("February", text: $month)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 120)
                    }
                    VStack(alignment: .leading) {
                        Text("Day").font(.caption)
                        TextField("23", text: $day)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                    }
                }
            }

            sectionHeader("Access Date")
            DatePicker("Accessed on", selection: $accessDate, displayedComponents: .date)
                .labelsHidden()
        }
    }

    // MARK: - Type-Specific Fields

    @ViewBuilder
    private var typeSpecificFields: some View {
        switch sourceType {
        case .website:
            websiteFields
        case .book:
            bookFields
        case .journalArticle:
            journalFields
        case .newspaperArticle:
            newspaperFields
        }
    }

    private var websiteFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Website Details")
            labeledField("URL", text: $url, placeholder: "https://example.com")
            labeledField("Publisher / Website Name", text: $publisher, placeholder: "BBC News")
        }
    }

    private var bookFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Book Details")
            labeledField("Publisher", text: $publisher, placeholder: "Oxford University Press")
            labeledField("City", text: $city, placeholder: "New York")
            labeledField("Edition", text: $edition, placeholder: "3rd")
            labeledField("DOI", text: $doi, placeholder: "10.1000/xyz123")
        }
    }

    private var journalFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Journal Details")
            labeledField("Journal Name", text: $journalName, placeholder: "Nature")
            HStack {
                labeledField("Volume", text: $volume, placeholder: "12")
                labeledField("Issue", text: $issue, placeholder: "3")
                labeledField("Pages", text: $pages, placeholder: "45-67")
            }
            labeledField("DOI", text: $doi, placeholder: "10.1000/xyz123")
        }
    }

    private var newspaperFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Newspaper Details")
            labeledField("Newspaper Name", text: $journalName, placeholder: "The Guardian")
            labeledField("Pages", text: $pages, placeholder: "A1")
            labeledField("URL", text: $url, placeholder: "https://example.com/article")
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(.primary)
    }

    private func labeledField(_ label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            TextField(placeholder, text: text)
                .textFieldStyle(.roundedBorder)
        }
    }

    private func addAuthor() {
        let name = newAuthor.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        authors.append(name)
        newAuthor = ""
    }

    private var effectiveYear: String {
        if useCurrentDate {
            return String(Calendar.current.component(.year, from: Date()))
        }
        return year
    }

    private var effectiveMonth: String {
        if useCurrentDate {
            let m = Calendar.current.component(.month, from: Date())
            return Calendar.current.monthSymbols[m - 1]
        }
        return month
    }

    private var effectiveDay: String {
        if useCurrentDate {
            return String(Calendar.current.component(.day, from: Date()))
        }
        return day
    }

    private func copyCitation() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(currentCitation, forType: .string)
        copiedToClipboard = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copiedToClipboard = false
        }
    }

    private func save() {
        if let source = existingSource {
            // Update existing
            source.sourceType = sourceType
            source.title = title
            source.authors = authors
            source.year = effectiveYear
            source.month = effectiveMonth
            source.day = effectiveDay
            source.url = url
            source.publisher = publisher
            source.journalName = journalName
            source.volume = volume
            source.issue = issue
            source.pages = pages
            source.edition = edition
            source.city = city
            source.doi = doi
            source.accessDate = accessDate
            source.notes = notes
        } else {
            // Create new
            let source = Source(
                sourceType: sourceType,
                title: title,
                authors: authors,
                year: effectiveYear,
                month: effectiveMonth,
                day: effectiveDay,
                url: url,
                publisher: publisher,
                journalName: journalName,
                volume: volume,
                issue: issue,
                pages: pages,
                edition: edition,
                city: city,
                doi: doi,
                accessDate: accessDate,
                notes: notes
            )
            source.project = project
            modelContext.insert(source)
        }
        dismiss()
    }

    private func loadExistingSource() {
        guard let s = existingSource else {
            // Default to current date
            if useCurrentDate {
                let now = Date()
                let cal = Calendar.current
                year = String(cal.component(.year, from: now))
                month = cal.monthSymbols[cal.component(.month, from: now) - 1]
                day = String(cal.component(.day, from: now))
            }
            return
        }
        sourceType = s.sourceType
        title = s.title
        authors = s.authors
        year = s.year
        month = s.month
        day = s.day
        url = s.url
        publisher = s.publisher
        journalName = s.journalName
        volume = s.volume
        issue = s.issue
        pages = s.pages
        edition = s.edition
        city = s.city
        doi = s.doi
        accessDate = s.accessDate
        notes = s.notes
        useCurrentDate = false
    }
}
