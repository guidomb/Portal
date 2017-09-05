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
            textView(),
            image(),
            map(),
            progress(),
            segment(),
            spinner()
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
        return defaultCell(text: "Collection", route: .collectionExample)
    }
    
    fileprivate static func textView() -> TableItemProperties<Action> {
        return defaultCell(text: "Text View", route: .textViewExample)
    }
    
    fileprivate static func textField() -> TableItemProperties<Action> {
        return defaultCell(text: "Text Field", route: .textFieldExample)
    }
    
    fileprivate static func image() -> TableItemProperties<Action> {
        return defaultCell(text: "Image", route: .imageExample)
    }
    
    fileprivate static func map() -> TableItemProperties<Action> {
        return defaultCell(text: "Map", route: .mapExample)
    }
    
    fileprivate static func progress() -> TableItemProperties<Action> {
        return defaultCell(text: "Progress", route: .progressExample)
    }
    
    fileprivate static func segment() -> TableItemProperties<Action> {
        return defaultCell(text: "Segment", route: .segmentedExample)
    }
    
    fileprivate static func spinner() -> TableItemProperties<Action> {
        return defaultCell(text: "Spinner", route: .spinnerExample)
    }
    
    fileprivate static func defaultCell(text: String, route: Route) -> TableItemProperties<Action> {
        return tableItem(height: 50, onTap: .navigate(to: route), selectionStyle: .none) { index in
            TableItemRender(
                component: container (
                    children: [
                        container(
                            children: [
                                label(text: text)
                            ],
                            style: styleSheet {
                                $0.backgroundColor = .blue
                            },
                            layout: layout {
                                $0.flex = flex { $0.grow = .one }
                                $0.height = Dimension(value: 50)
                                $0.alignment = alignment { $0.items = .center }
                                $0.justifyContent = .center
                                $0.margin = .by(edge: Edge(bottom: 5))
                            }
                        )
                    ],
                    style: styleSheet {
                        $0.backgroundColor = .green
                    }
                ),
                typeIdentifier: text
            )
        }
    }
    
}
