//
//  ProjectViewModel.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/17/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import Foundation

struct ProjectViewModel {
  private let project: Project
  //  private var seconds: Double

  var statusMessage: String
  var name: String { project.name }
  var id: UUID { project.id }

  init(project: Project, statusMessage: String) {
    self.project = project
    self.statusMessage = statusMessage
  }
}

extension ProjectViewModel: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: ProjectViewModel, rhs: ProjectViewModel) -> Bool {
    return lhs.id == rhs.id
  }
}
