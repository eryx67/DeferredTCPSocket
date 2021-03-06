//
//  Support.swift
//  ChatClient
//
//  Created by John Gallagher on 9/15/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import Foundation
import Result
import DeferredTCPSocket
import Deferred

func first<S: SequenceType>(sequence: S) -> S.Generator.Element? {
    var generator = sequence.generate()
    return generator.next()
}

func startsWithReturningIndex<C: CollectionType, S: SequenceType where C.Generator.Element == S.Generator.Element, C.Generator.Element: Equatable>(c: C, prefix: S) -> C.Index? {
    var cIndex = c.startIndex
    for element in prefix {
        if cIndex == c.endIndex {
            return nil
        }
        if c[cIndex++] != element {
            return nil
        }
    }
    return cIndex
}

func resultToDeferred<T,U>(r: Result<T>, f: T -> Deferred<Result<U>>) -> Deferred<Result<U>> {
    switch r {
    case let .Success(value):
        return f(value.value)

    case let .Failure(error):
        return Deferred(value: .Failure(error))
    }
}

func userFacingDescription(error: ErrorType) -> String {
    switch error {
    case let serverError as ServerError:
        return serverError.description

    case let libcError as LibCError:
        if let errnoString = String(UTF8String: strerror(libcError.errno)) {
            return "Error: \(libcError.functionName) failed with \(errnoString)"
        }

    default:
        break
    }

    return "Unknown Error"
}

extension UIAlertController {
    convenience init(error: ErrorType, handler: (Void -> Void)?) {
        self.init(title: "Error", message: userFacingDescription(error), preferredStyle: .Alert)

        let title = "OK"
        if let h = handler {
            addAction(UIAlertAction(title: title, style: .Default, handler: { _ in h() }))
        } else {
            addAction(UIAlertAction(title: title, style: .Default, handler: { [weak self] _ in
                self?.dismissViewControllerAnimated(true, completion: nil)
                return
            }))
        }
    }
}