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
    case CategoryList
  }

  private func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map { _ in letters.randomElement()! })
  }

  var dataSource: UICollectionViewDiffableDataSource<Section, Project>! = nil
  var collectionView: UICollectionView! = nil
  var bottomBar: UIView!
  var subscriptions = Set<AnyCancellable>()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.view.backgroundColor = .white
    configureHierarchy()
    configureDataSource()
    configureBottomBar()

    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add, target: self, action: #selector(debugAddProject))
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
      ProjectListCell.self, forCellWithReuseIdentifier: ProjectListCell.resuseIdentifier)
    collectionView.dragInteractionEnabled = true
  }

  private func setUpProjectListCellSubscription(
    _ projectListCell: ProjectListCell, with project: Project
  ) {
    projectListCell.subscriptions.removeAll()
    let timeRecordObservation = ValueObservation.tracking { db in
      return try! TimeRecord.filter(Column("projectId") == project.id).fetchCount(db)
    }

    timeRecordObservation.publisher(in: dbQueue)
      .sink(receiveCompletion: { _ in
        }) { count in
        projectListCell.label.text = "\(project.name) \(count)"
      }.store(in: &projectListCell.subscriptions)
  }

  private func configureDataSource() {
    self.dataSource = UICollectionViewDiffableDataSource(
      collectionView: collectionView,
      cellProvider: { [weak self] (collectionView, indexPath, project) in
        let cell =
          collectionView.dequeueReusableCell(
            withReuseIdentifier: ProjectListCell.resuseIdentifier, for: indexPath)
          as! ProjectListCell

        cell.label.text = project.name + " ?"
        cell.delegate = self
        self?.setUpProjectListCellSubscription(cell, with: project)

        return cell
      })

    let observation = ValueObservation.tracking(value: Project.fetchAll)
    observation.publisher(in: dbQueue)
      .sink(receiveCompletion: { _ in }) { [unowned self] projects in
        var snapshot = NSDiffableDataSourceSnapshot<Section, Project>()
        snapshot.appendSections([Section.CategoryList])
        snapshot.appendItems(projects)
        self.dataSource.apply(snapshot)
      }.store(in: &subscriptions)
  }

}

extension ViewController: ProjectListCellDelegate {
  func buttonWasPressed(in projectListCell: ProjectListCell) {
    guard let indexPath = collectionView.indexPath(for: projectListCell) else { return }
    guard let project = dataSource.itemIdentifier(for: indexPath) else { return }

    try! dbQueue.write { db in
      var timeRecord = TimeRecord(
        taskName: nil, startTime: Date(), endTime: nil, projectId: project.id)
      try! timeRecord.insert(db)
    }
  }

}
