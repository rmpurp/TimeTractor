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

class ViewController: UIViewController {
  enum Section {
    case CurrentlyRunning
    case ProjectList
  }

  enum Item: Hashable {
    case project(Project)
    case runningTimer(RunningTimerInfo)
  }

  private func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map { _ in letters.randomElement()! })
  }

  var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
  var collectionView: UICollectionView! = nil
  var bottomBar: UIView!

  var displayLink: CADisplayLink!
  var subscriptions = Set<AnyCancellable>()

  var timeRecordController: TimeRecordController! = nil

  var currentTimeRecord: RunningTimerInfo? = nil

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.view.backgroundColor = .white
    configureHierarchy()
    configureDataSource()
    configureBottomBar()

    setupDebugFunctionality()
  }

  func setupDebugFunctionality() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add, target: self, action: #selector(debugAddProject))
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(debugPrintAllTimeEvents ))
  }
  
  @objc func debugPrintAllTimeEvents() {
    try! dbQueue.read { db -> [TimeRecordInfo] in
      let request = TimeRecord.including(required: TimeRecord.project)
      return try TimeRecordInfo.fetchAll(db, request)
    }.forEach {
      print($0.timeRecord, $0.project.name)
    }
  }

  @objc func debugAddProject() {
    try! dbQueue.write { db in
      var project = Project(name: randomString(length: 10))
      try! project.insert(db)
    }
  }

  func configureBottomBar() {
    bottomBar = UIView()
    bottomBar.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(bottomBar)
    bottomBar.backgroundColor = UIColor(displayP3Red: 0, green: 1, blue: 0, alpha: 0.5)
    NSLayoutConstraint.activate([
      bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      bottomBar.heightAnchor.constraint(equalToConstant: 100),
    ])
  }
}

// MARK: - Collection View Layout
extension ViewController {
  func createLayout() -> UICollectionViewLayout {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(44))
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitems: [item])

    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20)
    let layout = UICollectionViewCompositionalLayout(section: section)

    return layout
  }

  func configureHierarchy() {
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    view.addSubview(collectionView)
    collectionView.backgroundColor = .systemBackground

    collectionView.register(
      ProjectListCell.self, forCellWithReuseIdentifier: ProjectListCell.reuseIdentifier)
    collectionView.register(
      CurrentlyRunningTimeRecordCell.self,
      forCellWithReuseIdentifier: CurrentlyRunningTimeRecordCell.reuseIdentifier)
    collectionView.dragInteractionEnabled = true
  }
}

// MARK: - Collection View Data Sourcing
extension ViewController {
  private func setUpCurrentlyRunningSubscription() {
    self.timeRecordController
      .getRunningTimerPublisher()
      .sink(receiveCompletion: { _ in }) {
        var snapshot = self.dataSource.snapshot()
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .CurrentlyRunning))
        if let currentTimeRecord = $0 {
          snapshot.appendItems(
            [Item.runningTimer(currentTimeRecord)], toSection: .CurrentlyRunning)
        }

        self.currentTimeRecord = $0
        self.dataSource.apply(snapshot)
      }
      .store(in: &subscriptions)
  }

  //
  //  private func setUpProjectListCellSubscription(
  //    _ projectListCell: ProjectListCell, with project: Project
  //  ) {
  //    projectListCell.subscriptions.removeAll()
  //    self.timeRecordController.getProjectInfoPublisher(for: project.id)
  //      .sink(receiveCompletion: { _ in
  //      }) { count in
  //        projectListCell.label.text = "\(project.name) \(count)"
  //    }.store(in: &projectListCell.subscriptions)
  //  }

  private func setUpProjectsSubscription() {
    self.timeRecordController.getAllProjectsPublisher()
      .sink(receiveCompletion: { _ in }) { [unowned self] projects in
        var snapshot = self.dataSource.snapshot()
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .ProjectList))
        snapshot.appendItems(projects.map { Item.project($0) }, toSection: .ProjectList)
        self.dataSource.apply(snapshot)
      }.store(in: &subscriptions)
  }

  private func configureDataSource() {
    self.timeRecordController = TimeRecordController()

    self.dataSource = UICollectionViewDiffableDataSource(
      collectionView: collectionView,
      cellProvider: { [unowned self] (collectionView, indexPath, item) in
        switch item {
        case .project(let project):
          let cell =
            collectionView.dequeueReusableCell(
              withReuseIdentifier: ProjectListCell.reuseIdentifier, for: indexPath)
            as! ProjectListCell

          cell.label.text = project.name
          cell.delegate = self
          return cell
        case .runningTimer(let timeRecord):
          let cell =
            collectionView.dequeueReusableCell(
              withReuseIdentifier: CurrentlyRunningTimeRecordCell.reuseIdentifier, for: indexPath)
            as! CurrentlyRunningTimeRecordCell
          cell.label.text = timeRecord.project.name
          cell.delegate = self
          self.displayLink = CADisplayLink(target: self, selector: #selector(self.tick))
          self.displayLink.preferredFramesPerSecond = 1
          self.displayLink.add(to: .main, forMode: .common)
          return cell
        }

        //        self?.setUpProjectListCellSubscription(cell, with: project)

      })
    
    var snapshot = self.dataSource.snapshot()
    snapshot.appendSections([.CurrentlyRunning, .ProjectList])
    dataSource.apply(snapshot)
    setUpProjectsSubscription()
    setUpCurrentlyRunningSubscription()
  }

}

extension ViewController {
  @objc func tick() {
    if let currentTimeRecord = self.currentTimeRecord {
      if let indexPath = self.dataSource.indexPath(
        for: Item.runningTimer(currentTimeRecord))
      {
        if let cell = self.collectionView.cellForItem(at: indexPath) {
          let elapsedTime = Date().timeIntervalSince(currentTimeRecord.runningTimer.startTime)
          (cell as! CurrentlyRunningTimeRecordCell).label.text =
            "\(currentTimeRecord.project.name) \(Int(elapsedTime)) seconds"
        }

      }

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
      try TimeRecord.filter(Column("currentlyRunning") == true).deleteAll(db)
      try RunningTimer.filter(Column("isActive") == true).updateAll(db, Column("isActive").set(to: false))
      var runningTimer = RunningTimer(startTime: Date(), isActive: true, projectId: project.id)
      try! runningTimer.insert(db)
    }
  }

}

extension ViewController: CurrentlyRunningTimeRecordCellDelegate {
  func buttonWasPressed(inCurrentlyRunningTimeRecordCell: CurrentlyRunningTimeRecordCell) {
    guard let indexPath = collectionView.indexPath(for: inCurrentlyRunningTimeRecordCell) else { return }
    guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
    guard case Item.runningTimer(let runningTimerInfo) = item else { return }
    self.timeRecordController.complete(runningTimer: runningTimerInfo.runningTimer, at: Date())
  }
}
