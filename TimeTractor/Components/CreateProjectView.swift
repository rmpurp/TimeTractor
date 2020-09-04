//
//  EditModelView.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/24/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import SwiftUI

struct CreateProjectView: View {
  @State var projectName: String

  let dismissCallback: (String?) -> Void
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Project Name")) {
          TextField("Hello", text: $projectName)
        }
      }
      .navigationBarItems(leading: Button("Cancel", action: {
        self.dismissCallback(nil)
      }), trailing: Button("Save", action: {
        self.dismissCallback(self.projectName)
      }).disabled(projectName == ""))
        .navigationBarTitle("Create Project", displayMode: .inline)
    }
  }
}

struct CreateModelView_Previews: PreviewProvider {
  static var previews: some View {
    CreateProjectView(projectName: "", dismissCallback: {_ in })
  }
}
