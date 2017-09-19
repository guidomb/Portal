//
//  Effects.swift
//  PortalExample
//
//  Created by Guido Marucci Blas on 6/10/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Portal

enum IgniteSubscription: Equatable {
    
    case foo
    
}

enum Command {
    
    case search
    
}

final class ExampleSubscriptionManager: Portal.SubscriptionManager {
    
    func add(subscription: IgniteSubscription, dispatch: @escaping (ExampleApplication.Action) -> Void) {
        
    }
    
    func remove(subscription: IgniteSubscription) {
        
    }
    
}

final class ExampleCommandExecutor: Portal.CommandExecutor {
    
    let loadState: () -> State?
    
    init(loadState: @escaping () -> State? = { .none }) {
        self.loadState = loadState
    }
    
    func execute(command: Command, dispatch: @escaping (ExampleApplication.Action) -> Void) {
        switch command {
        
        case .search:
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                dispatch(.sendMessage(.searchComplete))
            }
            
        }
    }
    
}
