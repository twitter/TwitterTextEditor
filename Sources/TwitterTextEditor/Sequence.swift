//
//  Sequence.swift
//  TwitterTextEditor
//
//  Created on 3/26/20.
//  Copyright © 2020 Twitter, Inc. All rights reserved.
//

import Foundation

/**
 A response of each `body` called asynchronously.

 - SeeAlso:
   - `Sequence.forEach(queue:completion:_)`
 */
enum SequenceForEachNextAction {
    /**
     Continue the enumeration.
     */
    case `continue`
    /**
     End the enumeration and call `completion` if it's there.
     */
    case `break`
}

extension Sequence {
    typealias Next = (SequenceForEachNextAction) -> Void

    /**
     Enumerate elements one by one asynchronously.

     - Parameters:
       - queue: A dispatch queue to enumerate each element. It _MUST BE_ a serial queue or behavior is undefined.
         iteration is always executed on this queue. It's caller's responsibility to not modify the sequence
         simultaneously while the enumeration or the behavior is undefined.
       - completion: An optional block that is called at the end of enumeration.
       - body: A block called with each element and a `Next` block.
         It's caller's responsibility to call given `Next` block eventually with one of `SequenceForEachNextAction`,
         either `.continue` or `.break`.
         Otherwise, the enumeration will never end, and the `completion` block will never be called.
     */
    func forEach(queue: DispatchQueue,
                 completion: (() -> Void)? = nil,
                 _ body: @escaping (Element, @escaping Next) -> Void)
    {
        var iterator = makeIterator()
        var next: Next!
        let final = {
            next = nil
            completion?()
        }
        next = { action in
            queue.async {
                switch action {
                case .continue:
                    if let element = iterator.next() {
                        body(element, next)
                    } else {
                        final()
                    }
                case .break:
                    final()
                }
            }
        }
        next(.continue)
    }
}
