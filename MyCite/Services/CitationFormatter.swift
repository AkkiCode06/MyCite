//
//  CitationFormatter.swift
//  MyCite
//
//  Created by Akshat Barjatya on 23/02/2026.
//

import Foundation

nonisolated struct CitationFormatter {

    // MARK: - Public

    static func format(source: Source, style: CitationStyle, index: Int = 1) -> String {
        switch style {
        case .harvard:
            return formatHarvard(source)
        case .apa7:
            return formatAPA7(source)
        case .mla9:
            return formatMLA9(source)
        case .chicago:
            return formatChicago(source)
        case .ieee:
            return formatIEEE(source, index: index)
        case .vancouver:
            return formatVancouver(source, index: index)
        }
    }

    // MARK: - Author Formatting Helpers

    /// Last, F. format for a single author
    private static func lastFirst(_ author: String) -> String {
        let parts = author.trimmingCharacters(in: .whitespaces).split(separator: " ")
        guard parts.count >= 2 else { return author }
        let last = parts.last!
        let initials = parts.dropLast().map { "\($0.prefix(1))." }.joined(separator: " ")
        return "\(last), \(initials)"
    }

    /// F. Last format
    private static func firstLast(_ author: String) -> String {
        let parts = author.trimmingCharacters(in: .whitespaces).split(separator: " ")
        guard parts.count >= 2 else { return author }
        let last = parts.last!
        let initials = parts.dropLast().map { "\($0.prefix(1))." }.joined(separator: " ")
        return "\(initials) \(last)"
    }

    /// Full name, no transformation
    private static func fullName(_ author: String) -> String {
        author.trimmingCharacters(in: .whitespaces)
    }

    /// Join multiple authors with commas and "and" / "&"
    private static func joinAuthors(_ authors: [String], transform: (String) -> String, conjunction: String = "and") -> String {
        let transformed = authors.map(transform)
        switch transformed.count {
        case 0: return ""
        case 1: return transformed[0]
        case 2: return "\(transformed[0]) \(conjunction) \(transformed[1])"
        default:
            let allButLast = transformed.dropLast().joined(separator: ", ")
            return "\(allButLast) \(conjunction) \(transformed.last!)"
        }
    }

    /// Format the access date
    private static func formattedAccessDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }

    private static func formattedAccessDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }

    // MARK: - Year helper

    private static func yearString(_ source: Source) -> String {
        source.year.isEmpty ? "n.d." : source.year
    }

    private static func dateString(_ source: Source) -> String {
        var parts: [String] = []
        if !source.year.isEmpty { parts.append(source.year) }
        if !source.month.isEmpty { parts.append(source.month) }
        if !source.day.isEmpty { parts.append(source.day) }
        return parts.isEmpty ? "n.d." : parts.joined(separator: ", ")
    }

    // MARK: - Harvard

    private static func formatHarvard(_ s: Source) -> String {
        let author = s.authors.isEmpty ? "Unknown" : joinAuthors(s.authors, transform: lastFirst)
        let year = yearString(s)

        switch s.sourceType {
        case .website:
            var citation = "\(author) (\(year)) '\(s.title)'."
            if !s.publisher.isEmpty { citation += " \(s.publisher)." }
            if !s.url.isEmpty {
                citation += " Available at: \(s.url)"
                citation += " (Accessed: \(formattedAccessDate(s.accessDate)))."
            }
            return citation

        case .book:
            var citation = "\(author) (\(year)) \(s.title)."
            if !s.edition.isEmpty { citation += " \(s.edition) edn." }
            if !s.city.isEmpty || !s.publisher.isEmpty {
                let place = [s.city, s.publisher].filter { !$0.isEmpty }.joined(separator: ": ")
                citation += " \(place)."
            }
            return citation

        case .journalArticle:
            var citation = "\(author) (\(year)) '\(s.title)'."
            if !s.journalName.isEmpty { citation += " \(s.journalName)" }
            if !s.volume.isEmpty { citation += ", \(s.volume)" }
            if !s.issue.isEmpty { citation += "(\(s.issue))" }
            if !s.pages.isEmpty { citation += ", pp. \(s.pages)" }
            citation += "."
            if !s.doi.isEmpty { citation += " doi: \(s.doi)." }
            return citation

        case .newspaperArticle:
            var citation = "\(author) (\(year)) '\(s.title)'."
            if !s.journalName.isEmpty { citation += " \(s.journalName)" }
            let date = dateString(s)
            if date != "n.d." { citation += ", \(date)" }
            if !s.pages.isEmpty { citation += ", p. \(s.pages)" }
            citation += "."
            return citation
        }
    }

    // MARK: - APA 7th

    private static func formatAPA7(_ s: Source) -> String {
        let author = s.authors.isEmpty ? "Unknown" : joinAuthors(s.authors, transform: lastFirst, conjunction: "&")
        let year = yearString(s)

        switch s.sourceType {
        case .website:
            var citation = "\(author). (\(year)). \(s.title)."
            if !s.publisher.isEmpty { citation += " \(s.publisher)." }
            if !s.url.isEmpty { citation += " \(s.url)" }
            return citation

        case .book:
            var citation = "\(author). (\(year)). \(s.title)"
            if !s.edition.isEmpty { citation += " (\(s.edition) ed.)" }
            citation += "."
            if !s.publisher.isEmpty { citation += " \(s.publisher)." }
            if !s.doi.isEmpty { citation += " \(s.doi)" }
            return citation

        case .journalArticle:
            var citation = "\(author). (\(year)). \(s.title)."
            if !s.journalName.isEmpty { citation += " \(s.journalName)" }
            if !s.volume.isEmpty { citation += ", \(s.volume)" }
            if !s.issue.isEmpty { citation += "(\(s.issue))" }
            if !s.pages.isEmpty { citation += ", \(s.pages)" }
            citation += "."
            if !s.doi.isEmpty { citation += " \(s.doi)" }
            return citation

        case .newspaperArticle:
            var citation = "\(author). (\(year), \(s.month) \(s.day)). \(s.title)."
            if !s.journalName.isEmpty { citation += " \(s.journalName)" }
            if !s.pages.isEmpty { citation += ", \(s.pages)" }
            citation += "."
            if !s.url.isEmpty { citation += " \(s.url)" }
            return citation
        }
    }

    // MARK: - MLA 9th

    private static func formatMLA9(_ s: Source) -> String {
        // MLA uses full first name, last name first for first author
        let author: String
        if s.authors.isEmpty {
            author = ""
        } else if s.authors.count == 1 {
            author = lastFirst(s.authors[0])
        } else {
            author = "\(lastFirst(s.authors[0])), et al."
        }

        switch s.sourceType {
        case .website:
            var citation = ""
            if !author.isEmpty { citation += "\(author) " }
            citation += "\"\(s.title).\""
            if !s.publisher.isEmpty { citation += " \(s.publisher)," }
            let date = dateString(s)
            if date != "n.d." { citation += " \(date)," }
            if !s.url.isEmpty { citation += " \(s.url)." }
            return citation

        case .book:
            var citation = ""
            if !author.isEmpty { citation += "\(author) " }
            citation += "\(s.title)."
            if !s.edition.isEmpty { citation += " \(s.edition) ed.," }
            if !s.publisher.isEmpty { citation += " \(s.publisher)," }
            let year = yearString(s)
            citation += " \(year)."
            return citation

        case .journalArticle:
            var citation = ""
            if !author.isEmpty { citation += "\(author) " }
            citation += "\"\(s.title).\""
            if !s.journalName.isEmpty { citation += " \(s.journalName)" }
            if !s.volume.isEmpty { citation += ", vol. \(s.volume)" }
            if !s.issue.isEmpty { citation += ", no. \(s.issue)" }
            let year = yearString(s)
            citation += ", \(year)"
            if !s.pages.isEmpty { citation += ", pp. \(s.pages)" }
            citation += "."
            if !s.doi.isEmpty { citation += " \(s.doi)." }
            return citation

        case .newspaperArticle:
            var citation = ""
            if !author.isEmpty { citation += "\(author) " }
            citation += "\"\(s.title).\""
            if !s.journalName.isEmpty { citation += " \(s.journalName)" }
            let date = dateString(s)
            if date != "n.d." { citation += ", \(date)" }
            if !s.pages.isEmpty { citation += ", pp. \(s.pages)" }
            citation += "."
            if !s.url.isEmpty { citation += " \(s.url)." }
            return citation
        }
    }

    // MARK: - Chicago (Author-Date)

    private static func formatChicago(_ s: Source) -> String {
        let author = s.authors.isEmpty ? "Unknown" : joinAuthors(s.authors, transform: lastFirst)
        let year = yearString(s)

        switch s.sourceType {
        case .website:
            var citation = "\(author). \(year). \"\(s.title).\""
            if !s.publisher.isEmpty { citation += " \(s.publisher)." }
            if !s.url.isEmpty {
                citation += " \(s.url)."
            }
            return citation

        case .book:
            var citation = "\(author). \(year). \(s.title)."
            if !s.edition.isEmpty { citation += " \(s.edition) ed." }
            if !s.city.isEmpty || !s.publisher.isEmpty {
                let place = [s.city, s.publisher].filter { !$0.isEmpty }.joined(separator: ": ")
                citation += " \(place)."
            }
            return citation

        case .journalArticle:
            var citation = "\(author). \(year). \"\(s.title).\""
            if !s.journalName.isEmpty { citation += " \(s.journalName)" }
            if !s.volume.isEmpty { citation += " \(s.volume)" }
            if !s.issue.isEmpty { citation += ", no. \(s.issue)" }
            if !s.pages.isEmpty { citation += ": \(s.pages)" }
            citation += "."
            if !s.doi.isEmpty { citation += " \(s.doi)." }
            return citation

        case .newspaperArticle:
            var citation = "\(author). \(year). \"\(s.title).\""
            if !s.journalName.isEmpty { citation += " \(s.journalName)" }
            let date = dateString(s)
            if date != "n.d." { citation += ", \(date)" }
            citation += "."
            if !s.url.isEmpty { citation += " \(s.url)." }
            return citation
        }
    }

    // MARK: - IEEE

    private static func formatIEEE(_ s: Source, index: Int) -> String {
        let author = s.authors.isEmpty ? "Unknown" : joinAuthors(s.authors, transform: firstLast)
        let year = yearString(s)

        switch s.sourceType {
        case .website:
            var citation = "[\(index)] \(author), \"\(s.title),\""
            if !s.publisher.isEmpty { citation += " \(s.publisher)," }
            citation += " \(year)."
            if !s.url.isEmpty {
                citation += " [Online]. Available: \(s.url)."
                citation += " [Accessed: \(formattedAccessDateShort(s.accessDate))]."
            }
            return citation

        case .book:
            var citation = "[\(index)] \(author), \(s.title)"
            if !s.edition.isEmpty { citation += ", \(s.edition) ed" }
            citation += "."
            if !s.city.isEmpty || !s.publisher.isEmpty {
                let place = [s.city, s.publisher].filter { !$0.isEmpty }.joined(separator: ": ")
                citation += " \(place),"
            }
            citation += " \(year)."
            return citation

        case .journalArticle:
            var citation = "[\(index)] \(author), \"\(s.title),\""
            if !s.journalName.isEmpty { citation += " \(s.journalName)" }
            if !s.volume.isEmpty { citation += ", vol. \(s.volume)" }
            if !s.issue.isEmpty { citation += ", no. \(s.issue)" }
            if !s.pages.isEmpty { citation += ", pp. \(s.pages)" }
            citation += ", \(year)."
            if !s.doi.isEmpty { citation += " doi: \(s.doi)." }
            return citation

        case .newspaperArticle:
            var citation = "[\(index)] \(author), \"\(s.title),\""
            if !s.journalName.isEmpty { citation += " \(s.journalName)" }
            let date = dateString(s)
            citation += ", \(date)"
            if !s.pages.isEmpty { citation += ", pp. \(s.pages)" }
            citation += "."
            return citation
        }
    }

    // MARK: - Vancouver

    private static func formatVancouver(_ s: Source, index: Int) -> String {
        let author = s.authors.isEmpty ? "Unknown" : joinAuthors(s.authors, transform: lastFirst, conjunction: "")
        let year = yearString(s)

        switch s.sourceType {
        case .website:
            var citation = "\(index). \(author). \(s.title) [Internet]."
            if !s.publisher.isEmpty { citation += " \(s.publisher);" }
            citation += " \(year)"
            if !s.url.isEmpty {
                citation += ". Available from: \(s.url)"
            }
            return citation

        case .book:
            var citation = "\(index). \(author). \(s.title)."
            if !s.edition.isEmpty { citation += " \(s.edition) ed." }
            if !s.city.isEmpty || !s.publisher.isEmpty {
                let place = [s.city, s.publisher].filter { !$0.isEmpty }.joined(separator: ": ")
                citation += " \(place);"
            }
            citation += " \(year)."
            return citation

        case .journalArticle:
            var citation = "\(index). \(author). \(s.title)."
            if !s.journalName.isEmpty { citation += " \(s.journalName)." }
            citation += " \(year)"
            if !s.volume.isEmpty { citation += ";\(s.volume)" }
            if !s.issue.isEmpty { citation += "(\(s.issue))" }
            if !s.pages.isEmpty { citation += ":\(s.pages)" }
            citation += "."
            if !s.doi.isEmpty { citation += " doi: \(s.doi)." }
            return citation

        case .newspaperArticle:
            var citation = "\(index). \(author). \(s.title)."
            if !s.journalName.isEmpty { citation += " \(s.journalName)." }
            let date = dateString(s)
            citation += " \(date)"
            if !s.pages.isEmpty { citation += ":\(s.pages)" }
            citation += "."
            return citation
        }
    }
}
