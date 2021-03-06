//
//  CarouselScreen.swift
//  PortalExample
//
//  Created by Argentino Ducret on 9/8/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Portal

enum CarouselScreen {
    
    typealias Action = Portal.Action<Route, Message>
    typealias View = Portal.View<Route, Message, Navigator>
    
    static func view(color: Color, selectedItem index: UInt) -> View {
        let elements = (0...1000).map { (index) -> CarouselItemProperties<Action> in
            carouselItem(onTap: .none, identifier: "\(index)") {
                container(
                    children: [
                        label(text: "Item \(index)")
                    ],
                    style: styleSheet { $0.backgroundColor = .red },
                    layout: layout {
                        $0.height = Dimension(value: 450)
                        $0.width = Dimension(value: 150)
                        $0.alignment = Alignment(items: .center)
                        $0.justifyContent = .center
                    }
                )
            }
        }
    
        let carouselProperties: CarouselProperties<Action> = properties(itemsWidth: 150, itemsHeight: 450, items: ZipList(of: elements, selected: index)!) {
            $0.isSnapToCellEnabled = true
            $0.minimumLineSpacing = 5
            $0.minimumInteritemSpacing = 5
            $0.showsScrollIndicator = true
            $0.onSelectionChange = { (operation: ZipListShiftOperation) -> Action in
                switch operation {
                    
                case .left:
                    let newIndex = index + 1 >= elements.count ? index : index + 1
                    return .sendMessage(.selectedItemChanged(newIndex))
                    
                case .right:
                    let newIndex = Int(index) - 1 < 0 ? 0 : index - 1
                    return .sendMessage(.selectedItemChanged(newIndex))
                }
            }
        }
        
        return View(
            navigator: .main,
            root: .stack(navigationBar()),
            component: container(
                children: [
                    carousel(
                        properties: carouselProperties,
                        style: styleSheet { $0.backgroundColor = color },
                        layout: layout {
                            $0.flex = flex { $0.grow = .one }
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
    
    static func navigationBar() -> NavigationBar<Action> {
        return Portal.navigationBar(
            properties: properties() {
                $0.title = .text("Carousel")
                $0.backButtonTitle = "test"
                $0.rightButtonItems = [
                    .textButton(title: "Color!", onTap: .sendMessage(.changeColor)),
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
