//
//  SourceType.swift
//  MyCite
//
//  Created by Akshat Barjatya on 23/02/2026.
//

import Foundation

nonisolated enum SourceType: String, CaseIterable, Identifiable, Codable {
    case website = "Website"
    case book = "Book"
    case journalArticle = "Journal Article"
    case newspaperArticle = "Newspaper Article"

    var id: String { rawValue }
}
