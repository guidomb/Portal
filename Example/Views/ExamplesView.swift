//
//  ExamplesView.swift
//  PortalExample
//
//  Created by Argentino Ducret on 8/31/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Portal

enum ExamplesScreen {
    
    typealias Action = Portal.Action<Route, Message>
    typealias View = Portal.View<Route, Message, Navigator>
    
    static func view() -> View {
        let items: [TableItemProperties<Action>] = [
            collection(),
            textField(),
            textView()
        ]
        
        return View(
            navigator: .main,
            root: .stack(ExampleApplication.navigationBar(title: "Collection")),
            component: table(
                items: items,
                style: tableStyleSheet { base, table in
                    base.backgroundColor = .green
                },
                layout: layout {
                    $0.flex = flex { $0.grow = .one }
                }
            )
        )
        
    }
    
}

fileprivate extension ExamplesScreen {
    
    fileprivate static func collection() -> TableItemProperties<Action> {
        return tableItem(height: 50, onTap: .navigate(to: .collectionExample), selectionStyle: .none) { index in
            TableItemRender(
                component: container(
                    children: [
                        container(
                            children: [
                                label(text: "Collection")
                            ],
                            style: styleSheet {
                                $0.backgroundColor = .blue
                            },
                            layout: layout {
                                $0.flex = flex { $0.grow = .one }
                                $0.height = Dimension(value: 50)
                                $0.alignment = Alignment(items: .center)
                                $0.justifyContent = .center
                                $0.margin = .by(edge: Edge(bottom: 5))
                            }
                        )
                    ],
                    style: styleSheet {
                        $0.backgroundColor = .green
                    }
                ),
                typeIdentifier: "CollectionCell")
        }
    }
    
    fileprivate static func textView() -> TableItemProperties<Action> {
        return tableItem(height: 50, onTap: .navigate(to: .textViewExample), selectionStyle: .none) { index in
            TableItemRender(
                component:
                container(
                    children: [
                        container(
                            children: [
                                label(text: "Text View")
                            ],
                            style: styleSheet {
                                $0.backgroundColor = .blue
                            },
                            layout: layout {
                                $0.flex = flex { $0.grow = .one }
                                $0.height = Dimension(value: 50)
                                $0.alignment = Alignment(items: .center)
                                $0.justifyContent = .center
                                $0.margin = .by(edge: Edge(bottom: 5))
                            }
                        )
                    ],
                    style: styleSheet {
                        $0.backgroundColor = .green
                    }
                ),
                typeIdentifier: "TextView"
            )
        }
    }
    
    fileprivate static func textField() -> TableItemProperties<Action> {
        return tableItem(height: 50, onTap: .navigate(to: .textFieldExample), selectionStyle: .none) { index in
            TableItemRender(
                component: container (
                    children: [
                        container(
                            children: [
                                label(text: "Text Field")
                            ],
                            style: styleSheet {
                                $0.backgroundColor = .blue
                            },
                            layout: layout {
                                $0.flex = flex { $0.grow = .one }
                                $0.height = Dimension(value: 50)
                                $0.alignment = Alignment(items: .center)
                                $0.justifyContent = .center
                                $0.margin = .by(edge: Edge(bottom: 5))
                            }
                        )
                    ],
                    style: styleSheet {
                        $0.backgroundColor = .green
                    }
                ),
                typeIdentifier: "TextField")
        }
    }
    
}
