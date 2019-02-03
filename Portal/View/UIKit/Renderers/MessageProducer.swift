//
//  MessageProducer.swift
//  Portal
//
//  Created by Argentino Ducret on 8/23/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

private var messageDispatcherAssociationKey = 0
private var mailboxAssociationKey = 1

protocol MessageForwarder {
    
    func getMailbox<MessageType>() -> Mailbox<MessageType>
    
}

protocol MessageProducer where Self: UIControl {
    
    func getDispatcher<MessageType>(for event: UIControl.Event) -> MessageDispatcher<MessageType>?
    
    func on<MessageType>(event: UIControl.Event, dispatch message: MessageType) -> Mailbox<MessageType>
    
    func on<MessageType>(
        event: UIControl.Event,
        sender2Message: @escaping (Any) -> MessageType?) -> Mailbox<MessageType>
    
    func stopDispatchingMessages<MessageType>(for event: UIControl.Event) -> MessageDispatcher<MessageType>?
    
    func stopDispatchingMessagesForAllEvents<MessageType>() -> [(UIControl.Event, MessageDispatcher<MessageType>)]
    
    func register<MessageType>(dispatcher: MessageDispatcher<MessageType>, for event: UIControl.Event)
    
    func unregisterDispatcher<MessageType>(for event: UIControl.Event) -> MessageDispatcher<MessageType>?
        
}

extension UIView: MessageForwarder {
    
    func getMailbox<MessageType>() -> Mailbox<MessageType> {
        let associatedObject = objc_getAssociatedObject(self, &mailboxAssociationKey)
        let mailbox: Mailbox<MessageType>
        if associatedObject == nil {
            mailbox = Mailbox()
            objc_setAssociatedObject(self, &mailboxAssociationKey, mailbox, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        } else {
            assert(associatedObject is Mailbox<MessageType>,
                   "Associated Mailbox's message type does not match '\(MessageType.self)'")
            mailbox = associatedObject as! Mailbox<MessageType> // swiftlint:disable:this force_cast
        }
        return mailbox
    }
    
}

extension MessageProducer {
    
    func on<MessageType>(event: UIControl.Event, dispatch message: MessageType) -> Mailbox<MessageType> {
        if let oldDispatcher = getDispatcher(for: event) as MessageDispatcher<MessageType>? {
            self.removeTarget(oldDispatcher, action: oldDispatcher.selector, for: event)
        }
        
        let mailbox: Mailbox<MessageType> = getMailbox()
        let dispatcher = MessageDispatcher(mailbox: mailbox, message: message)
        self.register(dispatcher: dispatcher, for: event)
        self.addTarget(dispatcher, action: dispatcher.selector, for: event)
        
        return mailbox
    }
    
    func on<MessageType>(
        event: UIControl.Event,
        sender2Message: @escaping (Any) -> MessageType?) -> Mailbox<MessageType> {
        
        if let oldDispatcher = getDispatcher(for: event) as MessageDispatcher<MessageType>? {
            self.removeTarget(oldDispatcher, action: oldDispatcher.selector, for: event)
        }
        
        let mailbox: Mailbox<MessageType> = getMailbox()
        let dispatcher = MessageDispatcher(mailbox: mailbox, sender2Message: sender2Message)
        self.register(dispatcher: dispatcher, for: event)
        self.addTarget(dispatcher, action: dispatcher.selector, for: event)
        
        return mailbox
    }
    
    func stopDispatchingMessages<MessageType>(for event: UIControl.Event) -> MessageDispatcher<MessageType>? {
        guard let dispatcher = unregisterDispatcher(for: event) as MessageDispatcher<MessageType>? else {
            fatalError("Dispatcher could not be unregistered, MessageDispatcher's MessageType is incorrect")
        }
        self.removeTarget(dispatcher, action: dispatcher.selector, for: event)
        return dispatcher
    }
    
    func stopDispatchingMessagesForAllEvents<MessageType>() -> [(UIControl.Event, MessageDispatcher<MessageType>)] {
        let dispatcherByEvent: [UInt : MessageDispatcher<MessageType>] = unregisterAllDispatchers()
        for (eventRawValue, dispatcher) in dispatcherByEvent {
            let event = UIControl.Event(rawValue: eventRawValue)
            self.removeTarget(dispatcher, action: dispatcher.selector, for: event)
        }
        return dispatcherByEvent.keys.map { (UIControl.Event(rawValue: $0), dispatcherByEvent[$0]!) }
    }
    
    func getDispatcher<MessageType>(for event: UIControl.Event) -> MessageDispatcher<MessageType>? {
        let dispatchers = objc_getAssociatedObject(self, &messageDispatcherAssociationKey)
            as? [UInt : MessageDispatcher<MessageType>] ?? [:]
        return dispatchers[event.rawValue]
    }
    
    func register<MessageType>(dispatcher: MessageDispatcher<MessageType>, for event: UIControl.Event) {
        var dispatchers = objc_getAssociatedObject(self, &messageDispatcherAssociationKey)
            as? [UInt : MessageDispatcher<MessageType>] ?? [:]
        dispatchers[event.rawValue] = dispatcher
        objc_setAssociatedObject(self, &messageDispatcherAssociationKey,
                                 dispatchers, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func unregisterDispatcher<MessageType>(for event: UIControl.Event) -> MessageDispatcher<MessageType>? {
        guard var dispatchers = objc_getAssociatedObject(self, &messageDispatcherAssociationKey)
            as? [UInt : MessageDispatcher<MessageType>] else { return .none }
        let dispatcher = dispatchers.removeValue(forKey: event.rawValue)
        objc_setAssociatedObject(self, &messageDispatcherAssociationKey,
                                 dispatchers, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return dispatcher
    }
    
}

fileprivate extension MessageProducer {
    
    fileprivate func unregisterAllDispatchers<MessageType>() -> [UInt : MessageDispatcher<MessageType>] {
        guard let dispatcherByEvent = objc_getAssociatedObject(self, &messageDispatcherAssociationKey)
            as? [UInt : MessageDispatcher<MessageType>] else { return [:] }
        objc_setAssociatedObject(self, &messageDispatcherAssociationKey,
                                 nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return dispatcherByEvent
    }
    
}
