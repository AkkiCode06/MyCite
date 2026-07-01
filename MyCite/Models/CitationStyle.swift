//
//  CitationStyle.swift
//  MyCite
//
//  Created by Akshat Barjatya on 23/02/2026.
//

import Foundation

nonisolated enum CitationStyle: String, CaseIterable, Identifiable, Codable {
    case harvard = "Harvard"
    case apa7 = "APA 7th Edition"
    case mla9 = "MLA 9th Edition"
    case chicago = "Chicago (Author-Date)"
    case ieee = "IEEE"
    case vancouver = "Vancouver"

    var id: String { rawValue }
}
