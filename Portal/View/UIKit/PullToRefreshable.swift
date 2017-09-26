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
    
    func configure(pullToRefresh properties: RefreshProperties<ActionType>)
    
    func removePullToRefresh()
    
}

extension PullToRefreshable where Self : UIScrollView {
    
    var scrollView: UIScrollView {
        return self
    }
    
}

extension PullToRefreshable where Self : UIView {
    
    func configure(pullToRefresh properties: RefreshProperties<ActionType>) {
        scrollView.refreshControl?.endRefreshing()
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = properties.title
        scrollView.refreshControl = refreshControl
        
        switch properties.state {
            
        case .searching:
            scrollView.contentOffset = CGPoint(x: 0, y: -refreshControl.frame.size.height)
            refreshControl.beginRefreshing()
            
        case .idle(let message):
            let refreshControlMailbox = refreshControl.on(event: .valueChanged, dispatch: message)
            refreshControlMailbox.forward(to: mailbox)
        }
    }
    
    func removePullToRefresh() {
        scrollView.refreshControl = .none
    }
    
}

extension UIRefreshControl: MessageProducer { }
