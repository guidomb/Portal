//
//  MessageHandler.swift
//  Portal
//
//  Created by Argentino Ducret on 8/23/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

protocol MessageHandler where Self : UIControl {
    
    func getMailbox<MessageType>(mailboxKey mailboxAssociationKey: inout Int) -> Mailbox<MessageType>
    
    func on<MessageType>(event: UIControlEvents,
                         dispatch message: MessageType,
                         dispatcherKey messageDispatcherAssociationKey: inout Int,
                         mailboxKey mailboxAssociationKey: inout Int) -> Mailbox<MessageType>
    
    func getDispatcher<MessageType>(for event: UIControlEvents,
                                    dispatcherKey messageDispatcherAssociationKey: inout Int) -> MessageDispatcher<MessageType>?
    
    func register<MessageType>(dispatcher: MessageDispatcher<MessageType>,
                               for event: UIControlEvents,
                               dispatcherKey messageDispatcherAssociationKey: inout Int)
    
    func unregisterDispatcher<MessageType>(for event: UIControlEvents,
                                           dispatcherKey messageDispatcherAssociationKey: inout Int) -> MessageDispatcher<MessageType>?
    
}

extension MessageHandler {
    
    func getMailbox<MessageType>(mailboxKey mailboxAssociationKey: inout Int) -> Mailbox<MessageType> {
        let associatedObject = objc_getAssociatedObject(self, &mailboxAssociationKey)
        let mailbox: Mailbox<MessageType>
        if associatedObject == nil {
            mailbox = Mailbox()
            objc_setAssociatedObject(self, &mailboxAssociationKey, mailbox, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        } else {
            assert(associatedObject is Mailbox<MessageType>, "Associated Mailbox's message type does not match '\(MessageType.self)'")
            mailbox = associatedObject as! Mailbox<MessageType> // swiftlint:disable:this force_cast
        }
        return mailbox
    }
    
    func on<MessageType>(event: UIControlEvents,
                         dispatch message: MessageType,
                         dispatcherKey messageDispatcherAssociationKey: inout Int,
                         mailboxKey mailboxAssociationKey: inout Int) -> Mailbox<MessageType> {
        
        if let oldDispatcher = getDispatcher(for: event, dispatcherKey: &messageDispatcherAssociationKey) as MessageDispatcher<MessageType>? {
            self.removeTarget(oldDispatcher, action: oldDispatcher.selector, for: event)
        }
        
        let mailbox: Mailbox<MessageType> = getMailbox(mailboxKey: &mailboxAssociationKey)
        let dispatcher = MessageDispatcher(mailbox: mailbox, message: message)
        self.register(dispatcher: dispatcher, for: event, dispatcherKey: &messageDispatcherAssociationKey)
        self.addTarget(dispatcher, action: dispatcher.selector, for: event)
        
        return mailbox
    }
    
    func getDispatcher<MessageType>(for event: UIControlEvents,
                                    dispatcherKey messageDispatcherAssociationKey: inout Int) -> MessageDispatcher<MessageType>? {
        
        let dispatchers = objc_getAssociatedObject(self, &messageDispatcherAssociationKey)
            as? [UInt : MessageDispatcher<MessageType>] ?? [:]
        return dispatchers[event.rawValue]
    }
    
    func register<MessageType>(dispatcher: MessageDispatcher<MessageType>,
                               for event: UIControlEvents,
                               dispatcherKey messageDispatcherAssociationKey: inout Int) {
        
        var dispatchers = objc_getAssociatedObject(self, &messageDispatcherAssociationKey)
            as? [UInt : MessageDispatcher<MessageType>] ?? [:]
        dispatchers[event.rawValue] = dispatcher
        objc_setAssociatedObject(self, &messageDispatcherAssociationKey, dispatchers, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func unregisterDispatcher<MessageType>(for event: UIControlEvents,
                                           dispatcherKey messageDispatcherAssociationKey: inout Int) -> MessageDispatcher<MessageType>? {
        
        guard var dispatchers = objc_getAssociatedObject(self, &messageDispatcherAssociationKey)
            as? [UInt : MessageDispatcher<MessageType>] else { return .none }
        let dispatcher = dispatchers.removeValue(forKey: event.rawValue)
        objc_setAssociatedObject(self, &messageDispatcherAssociationKey, dispatchers, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return dispatcher
    }
    
}
