//
//  ImagePreviewViewController.swift
//  Example
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

final class ImagePreviewViewController: UIViewController {
    private let image: UIImage
    private let action: (() -> Void)?

    private var titleLabel: UILabel?

    init(image: UIImage, action: (() -> Void)? = nil) {
        self.image = image
        self.action = action

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        view.backgroundColor = .clear

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewDidTap(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)

        var constraints = [NSLayoutConstraint]()
        defer {
            NSLayoutConstraint.activate(constraints)
        }

        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        view.addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(blurView.topAnchor.constraint(equalTo: view.topAnchor))
        constraints.append(blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        constraints.append(blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        constraints.append(blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor))

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 18.0)
        blurView.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        constraints.append(titleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20.0))
        constraints.append(titleLabel.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor))
        self.titleLabel = titleLabel

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        blurView.contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20.0))
        constraints.append(imageView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor))
        constraints.append(imageView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor))
        constraints.append(imageView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor))
    }

    override var title: String? {
        didSet {
            self.titleLabel?.text = title
        }
    }

    // MARK: - Action

    @objc
    public func viewDidTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
        action?()
    }
}
