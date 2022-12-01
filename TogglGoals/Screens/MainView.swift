//
//  ContentView.swift
//  TogglGoals
//
//  Created by Cristian Rojas on 29/11/2022.
//

import SwiftUI
import CoreData

struct MainView: View {
  @AppStorage(.apiToken) var savedToken: String?
  @State var apiToken: String = ""
  @State var errorMessage: String?
  
  var body: some View {
    Group {
      if let _ = savedToken {
        LoggedView()
      } else {
        unloggedView
      }
    }
    .frame(width: 300)
    .frame(height: 300)
  }
  
  @ViewBuilder
  var unloggedView: some View {
    SecureField("Api token", text: $apiToken)
    
    if let error = errorMessage {
      Text(error)
      Button(action: { errorMessage = nil}, label: { Text("ok") })
    }
    
    Button(action: saveApiToken, label: { Text("Save") })
  }
  
  func saveApiToken() {
    guard !apiToken.isEmpty else {
      errorMessage = "Token shouldn't be empty"
      return
    }
    
    savedToken = apiToken
  }
}
