//
//  Team_BuilderApp.swift
//  Team Builder
//
//  Created by David Storey on 3/27/24.
//

import SwiftUI
import CoreData

@main
struct Team_BuilderApp: App {
    
    @StateObject private var coreDataStack = CoreDataStack.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataStack.persistentContainer.viewContext)
                .onAppear{ setenv("CG_NUMERICS_SHOW_BACKTRACE", "TRUE", 1)}
        }
    }
}
