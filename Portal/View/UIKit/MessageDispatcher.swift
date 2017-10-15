//
//  ObjcMessageDispatcher.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation

internal final class MessageDispatcher<MessageType>: NSObject {
    
    internal let mailbox: Mailbox<MessageType>
    internal let sender2Message: (Any) -> MessageType?
    
    init(mailbox: Mailbox<MessageType> = Mailbox(), message: MessageType) {
        self.mailbox = mailbox
        self.sender2Message = { _ in message }
    }
    
    init(mailbox: Mailbox<MessageType> = Mailbox(), sender2Message: @escaping (Any) -> MessageType?) {
        self.mailbox = mailbox
        self.sender2Message = sender2Message
    }
    
    @objc internal func dispatch(sender: Any) {
        guard let message = sender2Message(sender) else { return }
        mailbox.dispatch(message: message)
    }
    
}

extension MessageDispatcher {

    var selector: Selector {
        return #selector(MessageDispatcher<MessageType>.dispatch)
    }
    
}
