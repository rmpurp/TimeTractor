//
//  EditProjectView.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/24/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import SwiftUI

struct EditProjectView: View {
  let projectViewModel: ProjectViewModel
  @State var projectName: String
  @State var actionSheetPresented: Bool = false
  
  let dismissCallback: (ProjectViewModel?) -> Void
  let deleteCallback: (ProjectViewModel) -> Void

  init(project: ProjectViewModel, onDismiss: @escaping (ProjectViewModel?) -> Void, onDelete: @escaping (ProjectViewModel) -> Void) {
    projectViewModel = project
    dismissCallback = onDismiss
    deleteCallback = onDelete
    _projectName = State(initialValue: project.name)
  }
    
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Project Name")) {
          TextField("Project Name", text: $projectName)
        }
        Section(header: Text("Project Management")) {
          Button("Archive") {
            print("Not implemented yet")
          }
          
          Button("Delete") {
            self.actionSheetPresented = true
          }.foregroundColor(.red)
            .actionSheet(isPresented: $actionSheetPresented) {
              ActionSheet(title: Text("Are you sure you want to delete?"), message: nil, buttons: [
                .destructive(Text("Delete")) { self.deleteCallback(self.projectViewModel) },
                .default(Text("Cancel")) { self.actionSheetPresented = false },
              ])
          }
        }
      }
      .navigationBarItems(leading: Button("Cancel", action: {
        self.dismissCallback(nil)
      }), trailing: Button("Save", action: {
        var editedProject = self.projectViewModel
        editedProject.name = self.projectName
        self.dismissCallback(editedProject)
      }).disabled(projectName == "" || projectName == projectViewModel.name))
        .navigationBarTitle("Edit Project", displayMode: .inline)
        .navigationViewStyle(StackNavigationViewStyle())
    }
  }
}

struct EditProjectView_Previews: PreviewProvider {
  static var previews: some View {
    let project = Project(id: UUID(), name: "Project Name")
    let projectViewModel = ProjectViewModel(project: project, referenceDate: Date(), recentTimeRecords: [])
    return EditProjectView(project: projectViewModel, onDismiss: {_ in }, onDelete: {_ in} )
  }
}
