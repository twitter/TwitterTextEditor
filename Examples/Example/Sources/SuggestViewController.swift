//
//  SuggestViewController.swift
//  Example
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

protocol SuggestViewControllerDelegate: AnyObject {
    func suggestViewController(_ viewController: SuggestViewController, didSelectSuggestedString suggestString: String)
}

final class SuggestViewController: UIViewController {
    weak var delegate: SuggestViewControllerDelegate?

    private var tableView: UITableView?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    var suggests: [String] = [] {
        didSet {
            guard oldValue != suggests else {
                return
            }
            tableView?.reloadData()
        }
    }

    private let suggestedStringCellReuseIdentifier = "suggestedStringCellReuseIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .defaultBackground

        var constraints = [NSLayoutConstraint]()
        defer {
            NSLayoutConstraint.activate(constraints)
        }

        let tableView = UITableView()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: suggestedStringCellReuseIdentifier)

        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(tableView.topAnchor.constraint(equalTo: view.topAnchor))
        constraints.append(tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        constraints.append(tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        constraints.append(tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor))
    }
}

// MARK: - UITableViewDataSource

extension SuggestViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        suggests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: suggestedStringCellReuseIdentifier, for: indexPath)
        let suggestedString = suggests[indexPath.row]
        cell.textLabel?.text = suggestedString
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SuggestViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let suggestedString = suggests[indexPath.row]
        delegate?.suggestViewController(self, didSelectSuggestedString: suggestedString)
    }
}
