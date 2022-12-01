//
//  ApiProject.swift
//  TogglGoals
//
//  Created by Cristian Rojas on 01/12/2022.
//

typealias ProjectResponse = [ApiProject]

struct ApiProject: Identifiable, Decodable {
  let id: Int
  let name: String
  let active: Bool
  let actualHours: Int
  let workspaceId: Int
  
  enum CodingKeys: String, CodingKey {
    case id
    case name
    case active
    case actualHours = "actual_hours"
    case workspaceId = "workspace_id"
  }
}

struct ApiProjectSummary: Decodable {
  let seconds: Int
}

// MARK: - Active Record methids
import Foundation

// Methods to populate the ui
extension ApiProject {
  
  static func getAll() async throws -> ProjectResponse {
    guard let apiToken = UserDefaults.standard.string(forKey: .apiToken) else {
      throw ApiError.noApiToken
    }
    
    return try await ApiProject.getAll(with: apiToken)
  }
  
  func makeProject() async throws -> Project {
    guard let apiToken = UserDefaults.standard.string(forKey: .apiToken) else {
      throw ApiError.noApiToken
    }
    return try await makeProject(apiToken: apiToken)
  }
}

// Main abstractable to its own lib methods
extension ApiProject {
  
  /// Get toggl projects from API
  public static func getAll(with apiToken: String) async throws -> ProjectResponse {

    var request = URLRequest(url: TogglApi.projects.url!)
    request.httpMethod = "GET"
    
    let authData = (apiToken + ":" + "api_token").data(using: .utf8)!.base64EncodedString()
    
    request.addValue("Basic \(authData)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    if
      let httpResponse = response as? HTTPURLResponse,
      httpResponse.statusCode == 403
    {
     throw ApiError.wrongApiToken
    }
    
    return try jsonDecoder.decode(ProjectResponse.self, from: data)
  }
  
  func makeProject(apiToken: String) async throws -> Project {
    var request = URLRequest(url: TogglApi.projectSummary(id: id, workspaceId: workspaceId).url!)
    request.httpMethod = "POST"
    
    let authData = (apiToken + ":" + "api_token").data(using: .utf8)!.base64EncodedString()
    
    request.addValue("Basic \(authData)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    if
      let httpResponse = response as? HTTPURLResponse,
      httpResponse.statusCode == 403
    {
     throw ApiError.wrongApiToken
    }
    
    let seconds = try jsonDecoder.decode(ApiProjectSummary.self, from: data).seconds
    
    return Project(
      id: id,
      name: name,
      seconds: seconds
    )
  }
}

