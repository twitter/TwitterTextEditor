//
//  DelegateForwarder.swift
//  
//
//  Created by tarunon on 2021/01/27.
//

import Foundation

private class Weakbox {
    weak var object: NSObjectProtocol?
    init(_ object: NSObjectProtocol) {
        self.object = object
    }
}

class DelegateForwarder: NSObject {
    private var delegates: [Selector: Weakbox]

    init(forwardTargets: [(delegate: NSObjectProtocol, selectors: [Selector])]) {
        delegates = Dictionary(
            uniqueKeysWithValues: forwardTargets.flatMap { target in
                target.selectors.map { ($0, Weakbox(target.delegate)) }
            }
        )
    }

    func setDelegate(delegate: NSObjectProtocol?, for selectors: [Selector]) {
        if let delegate = delegate {
            selectors.forEach { selector in
                self.delegates[selector] = Weakbox(delegate)
            }
        } else {
            selectors.forEach { selector in
                self.delegates.removeValue(forKey: selector)
            }
        }
    }

    override func responds(to aSelector: Selector!) -> Bool {
        return delegates[aSelector]?.object?.responds(to: aSelector) ?? super.responds(to: aSelector)
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return delegates[aSelector]?.object ?? super.forwardingTarget(for: aSelector)
    }
}
