//
//  MyCiteApp.swift
//  MyCite
//
//  Created by Akshat Barjatya on 23/02/2026.
//

import SwiftUI
import SwiftData

@main
struct MyCiteApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Project.self, Source.self])
    }
}
