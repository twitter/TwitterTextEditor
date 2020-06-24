//
//  ViewController.swift
//  Example
//
//  Created on 3/26/20.
//  Copyright © 2020 Twitter, Inc. All rights reserved.
//

import Foundation
import UIKit

final class ViewController: UIViewController {
    private struct Section {
        var title: String
        var description: String?
        var items: [Item]
    }

    private struct Item {
        var title: String
        var description: String?
        var action: (ViewController) -> Void
    }

    private var sections = [Section]()

    init() {
        super.init(nibName: nil, bundle: nil)

        title = "TwitterTextEditor"

        var exampleItems = [Item]()
        exampleItems.append(Item(title: "Swift example", description: "Basic example of TwitterTextKit usage") { (viewController) in
            let swiftViewController = SwiftViewController()
            swiftViewController.delegate = viewController
            // See `Settings.bundle`.
            swiftViewController.useCustomDropInteraction = UserDefaults.standard.bool(forKey: "use_custom_drop_interaction")

            let navigationController = UINavigationController(rootViewController: swiftViewController)
            viewController.present(navigationController, animated: true, completion: nil)
        })
        exampleItems.append(Item(title: "Objective-C example", description: "Objective-C API usage") { (viewController) in
            let objcViewController = ObjcViewController()
            objcViewController.delegate = viewController

            let navigationController = UINavigationController(rootViewController: objcViewController)
            viewController.present(navigationController, animated: true, completion: nil)
        })
        sections.append(Section(title: "Examples", description: "Try examples in each language implementation.", items: exampleItems))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - UIViewController

    private static let itemCellIdentifier = "itemCellIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()

        let tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }
}

// MARK: - SwiftViewControllerDelegate

extension ViewController: SwiftViewControllerDelegate {
    func swiftViewControllerDidTapDone(_ swiftViewController: SwiftViewController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - ObjcViewControllerDelegate

extension ViewController: ObjcViewControllerDelegate {
    func objcViewControllerDidTapDone(_ objcViewController: ObjcViewController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sections[section].description
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewController.itemCellIdentifier) ??
            UITableViewCell(style: .subtitle, reuseIdentifier: ViewController.itemCellIdentifier)
        let item = sections[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.description
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = sections[indexPath.section].items[indexPath.row]
        item.action(self)
    }
}
