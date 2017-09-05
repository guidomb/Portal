//
//  RefreshControl.swift
//  Portal
//
//  Created by Cristian Ames on 9/5/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

class RefreshController<MessageType> {
    
    var refreshAction: () -> Void
    
    init(
        properties: RefreshProperties<MessageType>,
        scroll: UIScrollView,
        tintColor: Color,
        dispatch: @escaping (MessageType) -> Void) {
        let control = UIRefreshControl()
        scroll.refreshControl = control
        control.tintColor = tintColor.asUIColor
        control.attributedTitle = properties.title
        
        switch properties.state {
            
        case .searching:
            refreshAction = { _ in }
            beginRefreshing(scroll)
            
        case .idle(searchAction: let message):
            refreshAction = { dispatch(message) }
            control.addTarget(
                self,
                action: #selector(refreshControlAction),
                for: UIControlEvents.valueChanged
            )
            
        }
    }
    
    private func beginRefreshing(_ scroll: UIScrollView) {
        if let refreshControl = scroll.refreshControl {
            scroll.contentOffset = CGPoint(x:0, y:-refreshControl.frame.size.height)
            refreshControl.beginRefreshing()
        }
    }
    
    private dynamic func refreshControlAction() {
        refreshAction()
    }

    
}

public enum RefreshState<MessageType> {
    
    case idle(searchAction: MessageType)
    case searching
    
}

public struct RefreshProperties<MessageType> {
    
    public var state: RefreshState<MessageType>
    public var title: NSAttributedString?
    
    fileprivate init(
        state: RefreshState<MessageType>,
        title: NSAttributedString? = .none) {
        self.state = state
        self.title = title
    }
    
    public func map<NewMessageType>(
        _ transform: @escaping (MessageType) -> NewMessageType) -> RefreshProperties<NewMessageType> {
        let newState: RefreshState<NewMessageType>
        if case .idle(let message) = state {
            newState = .idle(searchAction: transform(message))
        } else {
            newState = .searching
        }
        return RefreshProperties<NewMessageType>(
            state: newState,
            title: self.title
        )
    }
    
}


public func properties<MessageType>(
    state: RefreshState<MessageType>,
    configure: ((inout RefreshProperties<MessageType>) -> Void)? = .none) -> RefreshProperties<MessageType> {
    var properties = RefreshProperties(state: state)
    configure?(&properties)
    return properties
}
