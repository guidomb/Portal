//
//  Subscription.swift
//  PortalApplication
//
//  Created by Guido Marucci Blas on 4/4/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation

public enum Subscription<MessageType, RouteType: Route, CustomSubscriptionType: Equatable>: Equatable {
    
    static public func ==<MessageType, RouteType: Route, CustomSubscriptionType: Equatable>(
        lhs: Subscription<MessageType, RouteType, CustomSubscriptionType>,
        rhs: Subscription<MessageType, RouteType, CustomSubscriptionType>) -> Bool {
        switch (lhs, rhs) {
        case (.timer(let a), .timer(let b)):    return a == b
        case (.custom(let a), .custom(let b)):  return a == b
        default:                                return false
        }
    }
    
    case timer(Timer<MessageType, RouteType>)
    case custom(CustomSubscriptionType)
    
}

public protocol SubscriptionManager {
    
    associatedtype SubscriptionType: Equatable
    associatedtype RouteType: Route
    associatedtype MessageType
    
    func add(subscription: SubscriptionType, dispatch: @escaping (Action<RouteType, MessageType>) -> Void)
    
    func remove(subscription: SubscriptionType)
    
}

internal final class SubscriptionsManager<RouteType: Route, MessageType, CustomSubscriptionManager: SubscriptionManager>
    where CustomSubscriptionManager.RouteType == RouteType, CustomSubscriptionManager.MessageType == MessageType {
    
    typealias ActionType = Action<RouteType, MessageType>
    typealias SubscriptionType = Subscription<MessageType, RouteType, CustomSubscriptionManager.SubscriptionType>
    
    private let dispatch: (ActionType) -> Void
    private var currentSubscriptions: [SubscriptionType] = []
    
    fileprivate let subscriptionManager: CustomSubscriptionManager
    fileprivate let timerSubscriptionManager = TimerSubscriptionManager<MessageType, RouteType>()
    
    init(subscriptionManager: CustomSubscriptionManager, dispatch: @escaping (ActionType) -> Void) {
        self.subscriptionManager = subscriptionManager
        self.dispatch = dispatch
    }
    
    internal func manage(subscriptions: [SubscriptionType]) {
        for subscription in currentSubscriptions where !subscriptions.contains(subscription) {
            remove(subscription: subscription)
        }
        for subscription in subscriptions where !currentSubscriptions.contains(subscription) {
            add(subscription: subscription, dispatch: dispatch)
        }
        currentSubscriptions = subscriptions
    }
    
}

extension SubscriptionsManager: SubscriptionManager {
    
    func add(subscription: SubscriptionType, dispatch: @escaping (ActionType) -> Void) {
        switch subscription {
            
        case .timer(let timer):
            timerSubscriptionManager.add(subscription: timer, dispatch: dispatch)
        
        case .custom(let customSubscription):
            subscriptionManager.add(subscription: customSubscription, dispatch: dispatch)
        
        }
    }
    
    func remove(subscription: SubscriptionType) {
        switch subscription {
        
        case .timer(let timer):
            timerSubscriptionManager.remove(subscription: timer)
        
        case .custom(let customSubscription):
            subscriptionManager.remove(subscription: customSubscription)
        
        }
    }
    
}
