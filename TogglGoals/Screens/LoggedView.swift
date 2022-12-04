//
//  LoggedView.swift
//  TogglGoals
//
//  Created by Cristian Rojas on 01/12/2022.
//

import SwiftUI

struct LoggedView: View {
  
  @AppStorage(.apiToken) var apiToken: String?
  @State var state: ViewState = .idle
  
  var body: some View {
    Group {
      switch state {
      case .idle, .loading: ProgressView().onAppear { load() }
      case .success(let projects, _): successView(projects)
      case .empty: Text("No projects")
      case .error(let error): errorView(error)
      }
    }
  }
  
  
  func load(foreground: Bool = true) {
    
    if foreground {
      state = .loading
    } else {
      if let projects = state.projects {
        state = .success(model: projects, reloading: true)
      }
    }
    
    Task {
      do {
        
       let projects = try await ApiProject.getAll().asyncMap {
          try await $0.makeProject()
        }
        
        state = projects.count > 0
        ? .success(model: projects)
        : .empty
        
      } catch ApiError.wrongApiToken {
        state = .error(.wrongToken)
      } catch {
        state = .error(.unknownError(error.localizedDescription))
      }
    }
  }
  
  func successView(_ projects: Projects) -> some View {
  
    ScrollView(showsIndicators: false) {
      LazyVStack(alignment: .leading) {
        HStack {
          logoutButton
          Spacer()
          reloadButton
        }
        
        ForEach(projects) { project in
          HStack {
            Text(project.name)
            Spacer()
            Text(project.time)
          }
          .padding(.vertical, 4)
        }
      }
      .padding(.horizontal, 8)
    }
  }
  

  func errorView(_ error: ErrorState) -> some View {
    VStack {
      Text(error.message).foregroundColor(.red)
      Button(
        action: {
          switch error {
          case .unknownError: state = .idle
          case .wrongToken: apiToken = nil
          }
          
        },
        label: { Text(error.buttonLabel) }
      )
    }
  }
  
  var reloadButton: some View {
    Button {
      load(foreground: false)
    } label: {
      if state.reloading {
        ReloadingAnimatedIcon()
      } else {
        Image(systemName: "repeat")
      }
    }
  }
  
  var logoutButton: some View {
    Button {
      apiToken = nil
    } label: {
      Text("Logout")
    }
  }
}


// MARK: - State
extension LoggedView {
  
  enum ViewState {
    case idle
    case loading
    case success(model: Projects, reloading: Bool = false)
    case empty
    case error(ErrorState)
    
    var reloading: Bool {
      switch self {
      case .success(_, let reloading): return reloading
      default: return false
      }
    }
    
    var projects: Projects? {
      switch self {
      case .success(let model, _): return model
      default: return nil
      }
    }
  }
  
  enum ErrorState {
    case wrongToken
    case unknownError(String)
    
    var message: String {
      switch self {
      case .wrongToken: return "Wrong Token"
      case .unknownError(let m): return m
      }
    }
    
    var buttonLabel: String {
      switch self {
      case .wrongToken: return "Ok"
      case .unknownError: return "Retry"
      }
    }
  }
}

struct ReloadingAnimatedIcon: View {
  @State var isRotating = false
  
  var body: some View {
    Image(systemName: "repeat")
      .rotationEffect(Angle.degrees(isRotating ? 360 : 0))
      .animation(.easeOut.repeatForever(), value: isRotating)
      .onAppear(perform: { isRotating = true })
  }
}


struct LoggedView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      LoggedView(state: .idle)
      LoggedView(state: .loading)
      LoggedView(state: .success(model: [
        Project(
          id: 0,
          name: "Guitar",
          seconds: 69372
        )
      ]))
      LoggedView(state: .empty)
      LoggedView(state: .error(.unknownError("Unknown")))
    }
  }
}
