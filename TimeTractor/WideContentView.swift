//
//  ContentView.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/27/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import SwiftUI


struct WideContentView: View {
  @EnvironmentObject var ttvm: TimeTractorViewModel
  @State var taskName: String = ""
  
  init() {
//    UITableView.appearance().separatorStyle = .none
//    UITableViewCell.appearance().backgroundColor = .clear
    //      UITableView.appearance().backgroundColor = .systemGroupedBackground
    UITableView.appearance().allowsSelection = false
    UITableViewCell.appearance().selectionStyle = .none
  }
  
  var body: some View {
    GeometryReader { geo in
      
      HStack(spacing: 0) {
        self.body(for: self.ttvm.projects)
          .padding(.top, geo.safeAreaInsets.top)
          .frame(width: geo.size.width / 3, height: nil)
        Divider()
        VStack(spacing: 0) {
          self.body(for: self.ttvm.runningTimer)
            .padding()
          Divider()
          Text("3")
          Spacer()
        }.padding(.top, geo.safeAreaInsets.top)
      }.edgesIgnoringSafeArea(.top)
    }
    
    //    VStack(spacing: 0) {
    //      if ttvm.runningTimer != nil {
    //        VStack {
    //          self.body(for: ttvm.runningTimer!)
    //          Divider()
    //        }
    //      }
    //      GeometryReader { geo in
    //        NavigationView {
    //          self.body(for: self.ttvm.projects)
    //        }
    //        .padding(.leading, geo.size.width < geo.size.height ? 0.25 : 0)
    //      }
    //      .navigationViewStyle(DoubleColumnNavigationViewStyle())
    //    }
  }
  
  func body(for runningTimer: RunningTimerViewModel?) -> some View {
    HStack {
      Button("STOP") {
        if let runningTimer = runningTimer {
          self.ttvm.complete(runningTimerId: runningTimer.id, at: Date())
        }
      }
      Spacer()
      VStack(alignment: .center, spacing: 5) {
        Text(runningTimer?.projectName ?? "No timer running")
          .font(.headline)
        TextField("Task Name", text: $taskName)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .frame(width: 300, height: nil)
          .disabled(runningTimer == nil)
        }.padding()
        .border(Color.black, width: 1)
      .background(Color(UIColor.systemGroupedBackground))
      Spacer()
      Text(runningTimer?.timeDisplay(at: Date()) ?? "")
        .font(.title)
    }
  }
  
  func body(for projects: [ProjectViewModel]) -> some View {
    return List {
      Section(header: Text("PROJECTS")) {
        ForEach(projects) { project in
          HStack(alignment: .center) {
            Button(action: {self.ttvm.start(project: project)}) {
              Image("run")
                .padding(5)
                .background(Color.red)
              .clipShape(Circle())
            }
            .foregroundColor(.white)
            Text(project.name)
            Spacer()
            Button(action: {self.ttvm.start(project: project)}) {
             Image(systemName: "play.circle.fill")
              .font(.title)
            }
            .shadow(radius: 2)


            
          }.padding(.vertical)
        }
      }
    }.listStyle(GroupedListStyle())
    
  }
  
}


struct WideContentView_Previews: PreviewProvider {
  static var previews: some View {
    WideContentView()
      .environmentObject(MockTimeTractorViewModel() as TimeTractorViewModel)
//      .previewLayout(.fixed(width: 768, height: 1024))
      .previewLayout(.fixed(width: 1024, height: 768))

  }
}

