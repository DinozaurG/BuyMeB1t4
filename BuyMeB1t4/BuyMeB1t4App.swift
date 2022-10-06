//
//  BuyMeB1t4App.swift
//  BuyMeB1t4
//
//  Created by Алексей Шумейко on 06.10.2022.
//

import SwiftUI

@main
struct BuyMeB1t4App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
