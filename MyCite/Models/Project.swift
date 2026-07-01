//
//  Project.swift
//  MyCite
//
//  Created by Akshat Barjatya on 23/02/2026.
//

import Foundation
import SwiftData

@Model
nonisolated final class Project {
    var id: UUID
    var name: String
    var createdDate: Date

    @Relationship(deleteRule: .cascade, inverse: \Source.project)
    var sources: [Source]

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdDate = Date()
        self.sources = []
    }
}
