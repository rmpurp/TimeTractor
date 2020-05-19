//
//  DebugViewController.swift
//  CollectionViewTest
//
//  Created by Ryan Purpura on 3/5/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import UIKit

class DebugViewController: UIViewController {

  enum State {
    case normal
    case debug
  }

  private var state: State = .normal

  private var normalConstraints: [NSLayoutConstraint] = []
  private var debugConstraints: [NSLayoutConstraint] = []

  private var rootViewController: UIViewController!

  func setRootController(_ viewController: UIViewController) {
    addChild(viewController)
    view.addSubview(viewController.view)
    viewController.view.translatesAutoresizingMaskIntoConstraints = false

    normalConstraints = [
      viewController.view.widthAnchor.constraint(equalTo: view.widthAnchor),
      viewController.view.heightAnchor.constraint(equalTo: view.heightAnchor),
      viewController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      viewController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    ]

    debugConstraints = [
      viewController.view.widthAnchor.constraint(equalToConstant: 320),
      viewController.view.heightAnchor.constraint(equalToConstant: 568 - 20),
      viewController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      viewController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    ]
    let gr = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
    gr.numberOfTouchesRequired = 2
    gr.numberOfTapsRequired = 3

    viewController.view.addGestureRecognizer(gr)
    viewController.view.isUserInteractionEnabled = true
    rootViewController = viewController
    updateConstraints()
  }

  func updateConstraints() {
    print("UPDATING")
    switch self.state {
    case .normal:
      NSLayoutConstraint.deactivate(self.debugConstraints)
      NSLayoutConstraint.activate(self.normalConstraints)
    case .debug:
      NSLayoutConstraint.deactivate(self.normalConstraints)
      NSLayoutConstraint.activate(self.debugConstraints)
    }

  }

  @objc func handleTap(sender: UITapGestureRecognizer) {
    if sender.state == .ended {
      switch state {
      case .normal:
        state = .debug
      case .debug:
        state = .normal
      }
      updateConstraints()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.isUserInteractionEnabled = true

    // Do any additional setup after loading the view.
  }

}
