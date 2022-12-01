//
//  Project.swift
//  TogglGoals
//
//  Created by Cristian Rojas on 01/12/2022.
//

typealias Projects = [Project]

struct Project: Identifiable {
  let id: Int
  let name: String
  let seconds: Int
  
  var time: String {
    let minutes = Double(seconds) / 60
    let hours = Int(minutes) / 60
    let _remaining = Int(minutes) % 60
    let remaining = _remaining < 10 ? "0\(_remaining)" : _remaining.description
    return "\(hours)h\(remaining)"
  }
}
