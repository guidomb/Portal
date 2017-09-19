//
//  PullToRefreshable.swift
//  Portal
//
//  Created by Argentino Ducret on 9/11/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal protocol PullToRefreshable {
    
    associatedtype ActionType
    
    var scrollView: UIScrollView { get }
    
    var mailbox: Mailbox<ActionType> { get }
    
    func configure(pullToRefresh properties: RefreshProperties<ActionType>, offset: CGPoint)
    
    func removePullToRefresh()
    
}

extension PullToRefreshable where Self : UIScrollView {
    
    var scrollView: UIScrollView {
        return self
    }
    
}

extension PullToRefreshable where Self : UIView {
    
    func configure(pullToRefresh properties: RefreshProperties<ActionType>, offset: CGPoint) {
        scrollView.refreshControl?.endRefreshing()
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = properties.title
        scrollView.refreshControl = refreshControl
        
        switch properties.state {
            
        case .searching:
            scrollView.contentOffset = CGPoint(x: 0, y: -refreshControl.frame.size.height)
            refreshControl.beginRefreshing()
            
        case .idle(let message):
            let dispatcher = MessageDispatcher(mailbox: mailbox, message: message)
            self.register(dispatcher: dispatcher)
            _ = refreshControl.dispatch(message: message, for: .valueChanged, with: mailbox)
        }
    }
    
    func removePullToRefresh() {
        scrollView.refreshControl = .none
    }
    
}

extension UIRefreshControl {
    
    fileprivate func dispatch<MessageType>(
        message: MessageType,
        for event: UIControlEvents,
        with mailbox: Mailbox<MessageType> = Mailbox()) -> Mailbox<MessageType> {
        
        let dispatcher = MessageDispatcher(mailbox: mailbox, message: message)
        self.register(dispatcher: dispatcher)
        self.addTarget(dispatcher, action: dispatcher.selector, for: event)
        return dispatcher.mailbox
    }
    
}
