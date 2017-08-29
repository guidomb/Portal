//
//  CollectionScreen.swift
//  Portal
//
//  Created by Argentino Ducret on 8/29/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Portal

enum CollectionScreen {
    
    typealias Action = Portal.Action<Route, Message>
    typealias View = Portal.View<Route, Message, Navigator>
    
    static func view() -> View {
        return View(
            navigator: .main,
            root: .stack(ExampleApplication.navigationBar(title: "Collection")),
            component: container(
                children: [
                    collection(
                        properties: properties(
                            itemsWidth: 150,
                            itemsHeight: 150
                        ) {
                            let item: CollectionItemProperties<Action> = collectionItem(onTap: .none, identifier: "aIdentifier") {
                                return container(
                                    children: [
                                        label(text: "test!")
                                    ],
                                    style: styleSheet { $0.backgroundColor = .red },
                                    layout: layout {
                                        $0.height = Dimension(value: 150)
                                        $0.width = Dimension(value: 150)
                                    }
                                )
                            }
                            
                            $0.items = [item, item, item, item, item, item, item, item, item]
                            $0.minimumLineSpacing = 5
                            $0.minimumInteritemSpacing = 5
                            $0.scrollDirection = .horizontal
                        },
                        style: styleSheet {
                            $0.backgroundColor = .black
                        },
                        layout: layout {
                            $0.flex = flex { $0.grow = .one }
                        }
                    )
                ],
                style: styleSheet() {
                    $0.backgroundColor = .green
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
