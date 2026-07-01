//
//  Source.swift
//  MyCite
//
//  Created by Akshat Barjatya on 23/02/2026.
//

import Foundation
import SwiftData

@Model
nonisolated final class Source {
    var id: UUID
    var sourceType: SourceType
    var title: String
    var authors: [String]
    var year: String
    var month: String
    var day: String
    var url: String
    var publisher: String
    var journalName: String
    var volume: String
    var issue: String
    var pages: String
    var edition: String
    var city: String
    var doi: String
    var accessDate: Date
    var notes: String
    var createdDate: Date

    var project: Project?

    init(
        sourceType: SourceType = .website,
        title: String = "",
        authors: [String] = [],
        year: String = "",
        month: String = "",
        day: String = "",
        url: String = "",
        publisher: String = "",
        journalName: String = "",
        volume: String = "",
        issue: String = "",
        pages: String = "",
        edition: String = "",
        city: String = "",
        doi: String = "",
        accessDate: Date = Date(),
        notes: String = ""
    ) {
        self.id = UUID()
        self.sourceType = sourceType
        self.title = title
        self.authors = authors
        self.year = year
        self.month = month
        self.day = day
        self.url = url
        self.publisher = publisher
        self.journalName = journalName
        self.volume = volume
        self.issue = issue
        self.pages = pages
        self.edition = edition
        self.city = city
        self.doi = doi
        self.accessDate = accessDate
        self.notes = notes
        self.createdDate = Date()
    }
}
