//
//  Mailbox.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 1/27/17.
//
//

import Foundation

// This type needs to have reference semantics
// due to how container components are rendered.
//
// All child components' mailboxes of a container component
// are forwared to the container's mailbox thus the need to 
// have a single mailbox reference. Keep in mind that a Mailbox
// is a mutable type. Subscribers can be added anytime thus the need
// for a reference type because any object that gets a reference to 
// a mailbox should be able to send a message to all its subscribers
// no matter when subscribers where added to the mailbox.
//
// See how the `forward` method is implemented.
public final class Mailbox<MessageType> {
    
    fileprivate var subscribers: [(MessageType) -> Void] = []
    
    public func subscribe(subscriber: @escaping (MessageType) -> Void) {
        subscribers.append(subscriber)
    }
    
}

extension Mailbox {
    
    internal func dispatch(message: MessageType) {
        subscribers.forEach { $0(message) }
    }
    
    internal func forward(to mailbox: Mailbox<MessageType>) {
        subscribe { mailbox.dispatch(message: $0) }
    }
    
    internal func forwardMap<NewMessageType>(
        to mailbox: Mailbox<NewMessageType>,
        _ transform: @escaping (MessageType) -> NewMessageType) {
        subscribe { mailbox.dispatch(message: transform($0)) }
    }
    
    internal func filterMap<NewMessageType>(
        _ transform: @escaping (MessageType) -> NewMessageType?) -> Mailbox<NewMessageType> {
        let mailbox = Mailbox<NewMessageType>()
        subscribe { message in
            if let transformedMessage = transform(message) {
                mailbox.dispatch(message: transformedMessage)
            }
        }
        return mailbox
    }
    
}

extension Mailbox: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        let address = Unmanaged.passUnretained(self).toOpaque()
        return "<\(type(of: self)): \(address)> - Subscribers \(subscribers.count)"
    }
    
}
