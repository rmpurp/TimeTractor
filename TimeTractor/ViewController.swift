//
//  ViewController.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 4/28/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import Combine
import GRDB
import GRDBCombine
import UIKit
import SwiftUI

final class ControlContainableCollectionView: UICollectionView {
  
  override func touchesShouldCancel(in view: UIView) -> Bool {
    if view is UIControl
      && !(view is UITextInput)
      && !(view is UISlider)
      && !(view is UISwitch)
    {
      return true
    }
    
    return super.touchesShouldCancel(in: view)
  }
}

class ViewController: UIViewController {
  enum Section {
    case CurrentlyRunning
    case ProjectList
  }
  
  enum Item: Hashable {
    case project(ProjectViewModel)
    case runningTimer(RunningTimerViewModel)
  }
  
  private func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map { _ in letters.randomElement()! })
  }
  
  var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
  var collectionView: UICollectionView! = nil
  
  var displayLink: CADisplayLink!
  var subscriptions = Set<AnyCancellable>()
  
  var timeRecordController: TimeRecordController! = nil
  
  var currentTimeRecord: RunningTimerViewModel? = nil
  
  private var firstRender = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Time Tractor"
    self.navigationController?.navigationBar.prefersLargeTitles = true
    configureHierarchy()
    configureDataSource()
    setupDebugFunctionality()
  }
  
  func setupDebugFunctionality() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add, target: self, action: #selector(addProject))
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .bookmarks, target: self, action: #selector(debugPrintAllTimeEvents))
  }
  
  @objc func debugPrintAllTimeEvents() {
    try! dbQueue.read { db -> [TimeRecordInfo] in
      let request = TimeRecord.including(required: TimeRecord.project)
      return try TimeRecordInfo.fetchAll(db, request)
    }.forEach {
      print($0.timeRecord, $0.project.name)
    }
  }
  
  func edit(project: ProjectViewModel) {
    let view = EditProjectView(project: project, onDismiss: { project in
      self.dismiss(animated: true) {
        guard let project = project else { return }
        self.timeRecordController.update(projectViewModel: project)
      }
    }, onDelete: { project in
      self.dismiss(animated: true) {
        self.timeRecordController.delete(projectViewModel: project)
      }
    })
    
    let controller = UIHostingController(rootView: view)
    controller.modalPresentationStyle = .automatic
    self.present(controller, animated: true)
  }
  
  @objc func addProject() {
    let view = CreateProjectView(projectName: "") { projectName in
      self.dismiss(animated: true) {
        guard let projectName = projectName else { return }
        
        try! dbQueue.write { db in
          var project = Project(name: projectName)
          try! project.insert(db)
        }
      }
    }
    
    let controller = UIHostingController(rootView: view)
    controller.modalPresentationStyle = .automatic
    self.present(controller, animated: true)
  }
  
}

// MARK: - Collection View Layout

extension ViewController {
  static let sectionBackgroundDecorationElementKind = "section-background-element-kind"
  static let sectionHeaderElementKind = "section-header-element-kind"
  
  func createLayout() -> UICollectionViewLayout {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(60))
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
    
    let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(
      elementKind: ViewController.sectionBackgroundDecorationElementKind)
    
    let headerSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(44))
    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: headerSize,
      elementKind: ViewController.sectionHeaderElementKind, alignment: .top)
    section.boundarySupplementaryItems = [sectionHeader]
    
    sectionBackgroundDecoration.contentInsets = NSDirectionalEdgeInsets(
      top: 0, leading: 20, bottom: 20, trailing: 20)
    section.decorationItems = [sectionBackgroundDecoration]
    
    let layout = UICollectionViewCompositionalLayout(section: section)
    
    layout.register(
      SectionBackgroundDecorationView.self,
      forDecorationViewOfKind: ViewController.sectionBackgroundDecorationElementKind)
    
    return layout
  }
  
  func configureHierarchy() {
    
    collectionView = ControlContainableCollectionView(
      frame: view.bounds, collectionViewLayout: createLayout())
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.contentInset = .zero
    collectionView.backgroundColor = .systemGroupedBackground
    
    view.addSubview(collectionView)
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      collectionView.widthAnchor.constraint(equalTo: view.widthAnchor),
    ])
    
    collectionView.register(
      ProjectListCell.self, forCellWithReuseIdentifier: ProjectListCell.reuseIdentifier)
    collectionView.register(
      RunningTimerCell.self,
      forCellWithReuseIdentifier: RunningTimerCell.reuseIdentifier)
    collectionView.register(
      TitleSupplementaryView.self,
      forSupplementaryViewOfKind: ViewController.sectionHeaderElementKind,
      withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)
    
    collectionView.allowsSelection = true
    collectionView.alwaysBounceVertical = true
    collectionView.bounces = true
  }
}

// MARK: - Collection View Data Sourcing
extension ViewController {
  private func setUpSubscription() {
    timeRecordController.getDataPublisher(date: Date())
      .sink(receiveCompletion: { (error) in
        
      }) {
        let (runningTimerViewModel, projects) = $0
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        self.currentTimeRecord = runningTimerViewModel
        
        if let runningTimerViewModel = runningTimerViewModel {
          snapshot.appendSections([.CurrentlyRunning])
          snapshot.appendItems(
            [Item.runningTimer(runningTimerViewModel)], toSection: .CurrentlyRunning)
        }
        snapshot.appendSections([.ProjectList])
        let projectsToAdd = projects.sorted(by: \.name).map { Item.project($0) }
        snapshot.appendItems(projectsToAdd, toSection: .ProjectList)
        
        self.dataSource.apply(snapshot, animatingDifferences: true) {
          snapshot.reloadItems(projectsToAdd)
          self.dataSource.apply(snapshot, animatingDifferences: false)
        }
        
    }.store(in: &subscriptions)
  }
  
  private func configureDataSource() {
    self.timeRecordController = TimeRecordController()
    
    self.dataSource = UICollectionViewDiffableDataSource(
      collectionView: collectionView,
      cellProvider: { [unowned self] (collectionView, indexPath, item) in
        switch item {
        case .project(let projectViewModel):
          let cell =
            collectionView.dequeueReusableCell(
              withReuseIdentifier: ProjectListCell.reuseIdentifier, for: indexPath)
              as! ProjectListCell
          
          cell.label.text = projectViewModel.name
          cell.subtitleLabel.text = projectViewModel.statusMessage
          cell.delegate = self
          cell.accessoryButtonPressed = {
            self.edit(project: projectViewModel)
          }
          
          return cell
          
        case .runningTimer(let runningTimerInfo):
          let cell =
            collectionView.dequeueReusableCell(
              withReuseIdentifier: RunningTimerCell.reuseIdentifier, for: indexPath)
              as! RunningTimerCell
          cell.label.text = runningTimerInfo.timeDisplay(at: Date())
          cell.delegate = self
          self.displayLink = CADisplayLink(target: self, selector: #selector(self.tick))
          self.displayLink.preferredFramesPerSecond = 1
          self.displayLink.add(to: .main, forMode: .common)
          return cell
        }
    })
    
    dataSource.supplementaryViewProvider = {
      (
      collectionView: UICollectionView,
      kind: String,
      indexPath: IndexPath
      ) -> UICollectionReusableView? in
      
      var title = "N/A"
      switch self.dataSource.itemIdentifier(for: indexPath) {
      case .project:
        title = "Projects"
      case .runningTimer(let runningTimer):
        title = runningTimer.projectName
      case nil:
        break
      }
      
      let supplementaryView =
        collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: TitleSupplementaryView.reuseIdentifier,
          for: indexPath) as! TitleSupplementaryView
      supplementaryView.label.text = title
      
      return supplementaryView
    }
    
    setUpSubscription()
  }
  
}

// MARK: - Update timer display
extension ViewController {
  @objc func tick() {
    guard let currentTimeRecord = self.currentTimeRecord else { return }
    guard let indexPath = self.dataSource.indexPath(for: Item.runningTimer(currentTimeRecord))
      else { return }
    guard let cell = self.collectionView.cellForItem(at: indexPath) else { return }
    guard let timerCell = (cell as? RunningTimerCell) else { fatalError() }
    
    timerCell.label.text = currentTimeRecord.timeDisplay(at: Date())
    timerCell.cancelButtonCallback = { _ in
      let alert = UIAlertController(
        title: "Are you sure you want to cancel this timer?", message: nil,
        preferredStyle: .actionSheet)
      alert.addAction(
        UIAlertAction(
          title: "Yes", style: .destructive,
          handler: { _ in
            self.timeRecordController.cancel(runningTimerId: currentTimeRecord.id)
        }))
      alert.addAction(
        UIAlertAction(
          title: "No", style: .default,
          handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
      
      self.present(alert, animated: true, completion: nil)
    }
    
  }
}

// MARK: - Project List Cell Delegate Conformance
extension ViewController: ProjectListCellDelegate {
  func buttonWasPressed(in projectListCell: ProjectListCell) {
    guard let indexPath = collectionView.indexPath(for: projectListCell) else { return }
    guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
    guard case Item.project(let project) = item else { return }
    
    try! dbQueue.write { db in
//      try TimeRecord.filter(Column("currentlyRunning") == true).deleteAll(db)
      try RunningTimer.filter(Column("isActive") == true).updateAll(
        db, Column("isActive").set(to: false))
      var runningTimer = RunningTimer(startTime: Date(), isActive: true, projectId: project.id)
      try! runningTimer.insert(db)
    }
  }
  
}

extension ViewController: RunningTimerCellDelegate {
  func buttonWasPressed(inCurrentlyRunningTimeRecordCell: RunningTimerCell) {
    guard let indexPath = collectionView.indexPath(for: inCurrentlyRunningTimeRecordCell) else {
      return
    }
    guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
    guard case Item.runningTimer(let runningTimerInfo) = item else { return }
    self.timeRecordController.complete(runningTimerId: runningTimerInfo.id, at: Date())
  }
}
