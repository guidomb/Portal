//
//  ZipList.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 4/6/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation

public struct ZipList<Element>: Collection, CustomDebugStringConvertible {
    
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return count
    }
    
    public var count: Int {
        return left.count + right.count + 1
    }
    
    public var centerIndex: Int {
        return left.count
    }
    
    public var debugDescription: String {
        return "ZipList(\n\tleft: \(left)\n\tcenter: \(center)\n\tright: \(right))"
    }
    
    fileprivate let left: [Element]
    public let center: Element
    fileprivate let right: [Element]
    
    public init(element: Element) {
        self.init(left: [], center: element, right: [])
    }
    
    public init(left: [Element], center: Element, right: [Element]) {
        self.left = left
        self.center = center
        self.right = right
    }
    
    public subscript(index: Int) -> Element {
        precondition(index >= 0 && index < count, "Index of out bounds")
        if index < left.count {
            return left[index]
        } else if index == left.count {
            return center
        } else {
            return right[index - left.count - 1]
        }
    }
    
    public func index(after index: Int) -> Int {
        return index + 1
    }
    
    public func shiftLeft(count: UInt) -> ZipList<Element>? {
        guard count <= UInt(right.count) else { return .none }
        if count == 0 { return self }
        let newLeft = left + [center] + Array(right.dropLast(right.count + 1 - Int(count)))
        let newRight = Array(right.dropFirst(Int(count)))
        return ZipList(left: newLeft, center: right[Int(count) - 1], right: newRight)
    }
    
    public func shiftRight(count: UInt) -> ZipList<Element>? {
        guard count <= UInt(left.count) else { return .none }
        if count == 0 { return self }
        let newLeft = Array(left.dropLast(Int(count)))
        let newRight = Array(left.dropFirst(left.count + 1 - Int(count))) + [center] + right
        return ZipList(left: newLeft, center: left[left.count - Int(count)], right: newRight)
    }
    
}

extension ZipList {
    
    public func map<NewElement>(_ transform: @escaping (Element) -> NewElement) -> ZipList<NewElement> {
        return ZipList<NewElement>(left: left.map(transform), center: transform(center), right: right.map(transform))
    }
    
}
