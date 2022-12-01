//
//  TogglGoalsApp.swift
//  TogglGoals
//
//  Created by Cristian Rojas on 29/11/2022.
//

import SwiftUI

@main
struct TogglGoalsApp: App {
  let persistenceController = PersistenceController.shared
  
  var body: some Scene {
    WindowGroup {
      MainView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
    
    .windowStyle(HiddenTitleBarWindowStyle())
  }
}
