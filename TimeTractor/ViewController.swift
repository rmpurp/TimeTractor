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

  var displayLink: CADisplayLink!
  var subscriptions = Set<AnyCancellable>()

  var timeRecordController: TimeRecordController! = nil

  var currentTimeRecord: RunningTimerInfo? = nil

  private var firstRender = true

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.title = "Time Tractor"
    self.navigationController?.navigationBar.prefersLargeTitles = true
    configureHierarchy()
    configureDataSource()

    setupDebugFunctionality()
  }

  func setupDebugFunctionality() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add, target: self, action: #selector(debugAddProject))

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

  @objc func debugAddProject() {
    try! dbQueue.write { db in
      var project = Project(name: randomString(length: 10))
      try! project.insert(db)
    }
  }

  //  func configureBottomBar() {
  //    bottomBar = UIView()
  //    bottomBar.translatesAutoresizingMaskIntoConstraints = false
  //    view.addSubview(bottomBar)
  //    bottomBar.backgroundColor = UIColor(displayP3Red: 0, green: 1, blue: 0, alpha: 0.5)
  //    NSLayoutConstraint.activate([
  //      bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
  //      bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
  //      bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
  //      bottomBar.heightAnchor.constraint(equalToConstant: 100),
  //    ])
  //  }
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
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    view.addSubview(collectionView)
    collectionView.backgroundColor = .systemGroupedBackground

    collectionView.register(
      ProjectListCell.self, forCellWithReuseIdentifier: ProjectListCell.reuseIdentifier)
    collectionView.register(
      CurrentlyRunningTimeRecordCell.self,
      forCellWithReuseIdentifier: CurrentlyRunningTimeRecordCell.reuseIdentifier)
    collectionView.register(
      TitleSupplementaryView.self,
      forSupplementaryViewOfKind: ViewController.sectionHeaderElementKind,
      withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)

    collectionView.allowsSelection = true
  }
}

// MARK: - Collection View Data Sourcing
extension ViewController {
  private func setUpCurrentlyRunningSubscription() {
    self.timeRecordController
      .getRunningTimerPublisher()
      .sink(receiveCompletion: { _ in }) {
        var snapshot = self.dataSource.snapshot()

        if let currentTimeRecord = $0 {

          if snapshot.sectionIdentifiers.contains(.CurrentlyRunning) {
            snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .CurrentlyRunning))
          } else if snapshot.sectionIdentifiers.contains(.ProjectList) {
            snapshot.insertSections([.CurrentlyRunning], beforeSection: .ProjectList)
          } else {
            snapshot.appendSections([.CurrentlyRunning])
          }

          self.currentTimeRecord = currentTimeRecord
          snapshot.appendItems(
            [Item.runningTimer(currentTimeRecord)], toSection: .CurrentlyRunning)
        } else {
          snapshot.deleteSections([.CurrentlyRunning])
        }

        self.dataSource.apply(snapshot)
        guard let currentTimeRecord = self.currentTimeRecord else { return }
        guard let indexPath = self.dataSource.indexPath(for: .runningTimer(currentTimeRecord))
        else { return }
        self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
      }
      .store(in: &subscriptions)
  }

  private func setUpProjectsSubscription() {
    self.timeRecordController.getAllProjectsPublisher()
      .sink(receiveCompletion: { _ in }) { [unowned self] projects in
        var snapshot = self.dataSource.snapshot()
        if !snapshot.sectionIdentifiers.contains(.ProjectList) {
          snapshot.appendSections([.ProjectList])
        }
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .ProjectList))
        snapshot.appendItems(
          projects.sorted(by: \.name).map { Item.project($0) }, toSection: .ProjectList)
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
        case .runningTimer(let runningTimerInfo):
          let cell =
            collectionView.dequeueReusableCell(
              withReuseIdentifier: CurrentlyRunningTimeRecordCell.reuseIdentifier, for: indexPath)
            as! CurrentlyRunningTimeRecordCell
          cell.label.text = self.getFormattedText(for: runningTimerInfo, at: Date())
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
      case .runningTimer:
        title = "Running Timer"
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

    setUpCurrentlyRunningSubscription()
    setUpProjectsSubscription()
  }

}

extension ViewController {
  private func getFormattedText(for runningTimerInfo: RunningTimerInfo, at date: Date) -> String {
    let elapsedTime = date.timeIntervalSince(runningTimerInfo.runningTimer.startTime)
    return "\(runningTimerInfo.project.name) \(Int(elapsedTime)) seconds"
  }

  @objc func tick() {
    guard let currentTimeRecord = self.currentTimeRecord else { return }
    guard let indexPath = self.dataSource.indexPath(for: Item.runningTimer(currentTimeRecord))
    else { return }
    guard let cell = self.collectionView.cellForItem(at: indexPath) else { return }

    (cell as! CurrentlyRunningTimeRecordCell).label.text = getFormattedText(
      for: currentTimeRecord, at: Date())
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
      try RunningTimer.filter(Column("isActive") == true).updateAll(
        db, Column("isActive").set(to: false))
      var runningTimer = RunningTimer(startTime: Date(), isActive: true, projectId: project.id)
      try! runningTimer.insert(db)
    }
  }

}

extension ViewController: CurrentlyRunningTimeRecordCellDelegate {
  func buttonWasPressed(inCurrentlyRunningTimeRecordCell: CurrentlyRunningTimeRecordCell) {
    guard let indexPath = collectionView.indexPath(for: inCurrentlyRunningTimeRecordCell) else {
      return
    }
    guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
    guard case Item.runningTimer(let runningTimerInfo) = item else { return }
    self.timeRecordController.complete(runningTimer: runningTimerInfo.runningTimer, at: Date())
  }
}
