//
//  ContentView.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/27/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import SwiftUI

struct Card: ViewModifier {
  func body(content: Content) -> some View {
    HStack(alignment: .center, spacing: 0) {
      content
      Spacer()
    }
    .padding()
    .background(Color(.secondarySystemGroupedBackground))
    .mask(RoundedRectangle(cornerRadius: 15, style: .continuous))
    .shadow(color: Color(UIColor.black.withAlphaComponent(0.1)), radius: 5)
  }
}

struct ContentView: View {
  @EnvironmentObject var ttvm: TimeTractorViewModel
  @State var taskName: String = ""
  
  init() {
    UITableView.appearance().separatorStyle = .none
    UITableViewCell.appearance().backgroundColor = .clear
    UITableView.appearance().backgroundColor = .systemGroupedBackground
    UITableView.appearance().allowsSelection = false
    UITableViewCell.appearance().selectionStyle = .none
  }
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .center, spacing: 10) {
          if ttvm.runningTimer != nil {
            VStack {
              self.body(for: ttvm.runningTimer!)
              Divider()
            }.transition(.slide)
            
          }
          body(for: ttvm.projects)
        }
        .modifier(Card())
      }
      .navigationBarTitle("Time Tractor")
      .navigationBarItems(leading: Button("Leading") {}, trailing: Button("Trailing") {})
    }
  }
  
  func body(for runningTimer: RunningTimerViewModel) -> some View {
    HStack {
      Button("STOP") {
        self.ttvm.complete(runningTimerId: runningTimer.id, at: Date())
      }
      VStack(alignment: .leading, spacing: 5) {
        Text(runningTimer.projectName)
          .font(.headline)
        TextField("Task Name", text: $taskName)
      }
      Spacer()
      Text(runningTimer.timeDisplay(at: Date()))
        .font(.title)
    }
  }
  
  func body(for projects: [ProjectViewModel]) -> some View {
    return VStack {
      ForEach(ttvm.projects) { project in
        HStack(alignment: .center, spacing: 0) {
          Text(project.name)
          Spacer()
          Button(action: {self.ttvm.start(project: project)}) {
            Image(systemName: "ellipsis.circle.fill")
          }.padding(.vertical)
          
        }
        
      }
    }
  }
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .environmentObject(MockTimeTractorViewModel() as TimeTractorViewModel)
  }
}

class MockTimeTractorViewModel: TimeTractorViewModel {
//  let project = ProjectViewModel(project: Project(id: UUID(), name: "CS 195"), statusMessage: "15")
//  let myId = UUID()
//  
//  override var runningTimer: RunningTimerViewModel? {
//    let x = RunningTimer(id: myId, taskName: nil, startTime: Date(), isActive: true, projectId: project.id)
//    return RunningTimerViewModel(runningTimerInfo: RunningTimerInfo(runningTimer: x, project: project.project))
//  }
//  
//  override var projects: [ProjectViewModel] { [
//    project,
//    ProjectViewModel(project: Project(id: UUID(), name: "EE 120"), statusMessage: "abc\nedfg"),
//    ProjectViewModel(project: Project(id: UUID(), name: "CS 010"), statusMessage: "cde\nfdsx")
//    ]
//  }
}
