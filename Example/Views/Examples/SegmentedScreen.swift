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
    
    static func view(selected: UInt) -> View {
        let elements = (0...5).map {
            segment(title: "\($0)", onTap: Action.sendMessage(.segmentSelected($0)), isEnabled: true)
        }
        
        var left: [SegmentProperties<Action>] = []
        var center: SegmentProperties<Action>!
        var right: [SegmentProperties<Action>] = []
        for i in 0..<elements.count {
            if i == selected {
                center = elements[i]
            } else if i < selected {
                left.append(elements[i])
            } else {
                right.append(elements[i])
            }
        }
        
        let segments = ZipList(left: left, center: center!, right: right)
    
        return View(
            navigator: .main,
            root: .stack(ExampleApplication.navigationBar(title: "Segmented")),
            component: container(
                children: [
                    segmented(
                        segments: segments,
                        style: segmentedStyleSheet { base, segmented in
                            base.backgroundColor = .white
                            segmented.textFont = Font(name: "Helvetica")
                            segmented.textSize = 20
                            segmented.textColor = .red
                            segmented.borderColor = .green
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
