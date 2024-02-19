//
//  Epic_Fail_CalculatorApp.swift
//  Epic Fail Calculator
//
//  Created by Shrish Deshpande on 19/02/24.
//

import SwiftUI
import SwiftData

@main
struct Epic_Fail_CalculatorApp: App {
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
//            ContentView()
            GPACalculatorView()
        }
//        .modelContainer(sharedModelContainer)
    }
}
