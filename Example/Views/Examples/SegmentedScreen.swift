//
//  SegmentedScreen.swift
//  PortalExample
//
//  Created by Argentino Ducret on 9/1/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Portal

enum SegmentedScreen {
    
    typealias Action = Portal.Action<Route, Message>
    typealias View = Portal.View<Route, Message, Navigator>
    
    static func view(selected index: UInt) -> View {
        return View(
            navigator: .main,
            root: .stack(ExampleApplication.navigationBar(title: "Segmented")),
            component: container(
                children: [createSegmentedComponent(selected: index)],
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

fileprivate extension SegmentedScreen {
    
    static func createSegmentedComponent(selected index: UInt) -> Component<Action> {
        let elements = (0...5).map {
            segment(title: "\($0)", onTap: Action.sendMessage(.segmentSelected($0)), isEnabled: true)
        }
        guard let segments = ZipList<SegmentProperties<Action>>(of: elements, selected: index) else { return container() }
        
        return segmented(
            segments: segments,
            style: segmentedStyleSheet { base, segmented in
                base.backgroundColor = .white
                segmented.textFont = Font(name: "Helvetica")
                segmented.textSize = 20
                segmented.textColor = .red
                segmented.borderColor = .green
            }
        )
    }
    
}
