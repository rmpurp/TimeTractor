//
//  EditModelView.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/24/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import SwiftUI

struct EditProjectView: View {
  @State var modelName: String
  var body: some View {
    Form {
      Section(header: Text("Project Name")) {
        TextField("Hello", text: $modelName)
      }
    }
    .navigationBarItems(trailing: Button("Save", action: {}))
    .navigationBarTitle("Create Project", displayMode: .inline)
  }
}

struct EditModelView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      EditProjectView(modelName: "")
    }
  }
}
