//
//  TogglApi.swift
//  TogglGoals
//
//  Created by Cristian Rojas on 01/12/2022.
//

import Foundation

enum TogglApi {
  case authentication
  case projects
  case projectSummary(id: Int, workspaceId: Int)
  
  var path: String {
    switch self {
    case .authentication:
      return "https://api.track.toggl.com/api/v9/me"
    case .projects:
      return "https://api.track.toggl.com/api/v9/me/projects"
    case .projectSummary(let id, let workspaceId):
      return "https://track.toggl.com/reports/api/v3/workspace/\(workspaceId)/projects/\(id)/summary"
    }
  }
  
  var url: URL? {
    switch self {
    default: return URL(string: self.path)
    }
  }
}
