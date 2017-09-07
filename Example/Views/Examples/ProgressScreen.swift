//
//  ProgressScreen.swift
//  PortalExample
//
//  Created by Argentino Ducret on 8/31/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Portal

enum ProgressScreen {
    
    typealias Action = Portal.Action<Route, Message>
    typealias View = Portal.View<Route, Message, Navigator>
    
    static func view() -> View {
        return View(
            navigator: .main,
            root: .stack(ExampleApplication.navigationBar(title: "Progress")),
            component: container(
                children: [
                    progress(
                        progress: ProgressCounter(partial: 5, total: 10)! ,
                        style: progressStyleSheet { base, progress in
                            base.backgroundColor = .white
                            progress.progressStyle = .color(.red)
                            progress.trackStyle = .color(.blue)
                        },
                        layout: layout {
                            $0.flex = flex { $0.grow = .one }
                            $0.margin = .by(edge: Edge(left: 25, top: 50, right: 25))
                        }
                    )
                ],
                style: styleSheet {
                    $0.backgroundColor = .black
                },
                layout: layout {
                    $0.flex = flex() { $0.grow = .one }
                }
            )
        )
    }
    
}
