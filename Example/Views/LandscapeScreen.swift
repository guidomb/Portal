//
//  LandscapeScreen.swift
//  PortalExample
//
//  Created by Guido Marucci Blas on 6/10/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Portal

enum LandscapeScreen {
    
    typealias Action = Portal.Action<Route, Message>
    typealias View = Portal.View<Route, Message, Navigator>
    
    static func view(text: String, count: UInt) -> View {
        let modalButtonStyleSheet = buttonStyleSheet { base, button in
            base.backgroundColor = .green
            button.textColor = .white
        }
        return View(
            navigator: .other,
            root: .simple,
            orientation: .landscape,
            component: container(
                children: [
                    button(
                        text: "Close",
                        onTap: .dismissNavigator(thenSend: .none),
                        style: modalButtonStyleSheet
                    ),
                    button(
                        text: "Increment!",
                        onTap: .sendMessage(.increment),
                        style: modalButtonStyleSheet
                    ),
                    label(text: text),
                    label(text: "Count \(count)")
                ],
                style: styleSheet() {
                    $0.backgroundColor = .red
                },
                layout: layout() {
                    $0.flex = flex() {
                        $0.grow = .one
                    }
                }
            )
        )
    }
    
}
