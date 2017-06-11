//
//  Shared.swift
//  PortalExample
//
//  Created by Guido Marucci Blas on 6/10/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Portal

extension ExampleApplication {
    
    static func navigationBar(title: String) -> NavigationBar<Action> {
        return Portal.navigationBar(
            properties: properties() {
                $0.title = .text(title)
                $0.hideBackButtonTitle = false
                $0.rightButtonItems = [
                    .textButton(title: "Hello", onTap: .sendMessage(.pong("Hello!"))),
                ]
            },
            style: navigationBarStyleSheet() { base, navBar in
                navBar.titleTextColor = .red
                navBar.isTranslucent = false
                navBar.tintColor = .red
                navBar.separatorHidden = true
                base.backgroundColor = .white
            }
        )
    }
    
}
