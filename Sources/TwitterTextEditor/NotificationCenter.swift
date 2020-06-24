//
//  NotificationCenter.swift
//  TwitterTextEditor
//
//  Created on 3/26/20.
//  Copyright © 2020 Twitter, Inc. All rights reserved.
//

import Foundation

final class NotificationObserverToken {
    private weak var notificationCenter: NotificationCenter?
    private var token: NSObjectProtocol?

    fileprivate init(notificationCenter: NotificationCenter, token: NSObjectProtocol) {
        self.notificationCenter = notificationCenter
        self.token = token
    }

    func remove() {
        guard let token = token else {
            return
        }
        notificationCenter?.removeObserver(token)
        self.token = nil
    }

    deinit {
        remove()
    }
}

extension NotificationCenter {
    func addObserver(forName name: NSNotification.Name?,
                     object: Any?,
                     queue: OperationQueue?,
                     using block: @escaping (Notification) -> Void) -> NotificationObserverToken
    {
        // Notification center strongly holds this return value until you remove the observer registration.
        let token: NSObjectProtocol = addObserver(forName: name, object: object, queue: queue, using: block)

        return NotificationObserverToken(notificationCenter: self, token: token)
    }
}
