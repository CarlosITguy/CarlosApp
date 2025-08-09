//
//  CarlosVApp.swift
//  CarlosV
//
//  Created by Carlos Valderrama on 2/8/25.
//

import SwiftUI
import SwiftData

@main
struct CarlosVApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
//          CordeDataTest()
            TabBarView()
        }
        .modelContainer(sharedModelContainer)
    }
}
