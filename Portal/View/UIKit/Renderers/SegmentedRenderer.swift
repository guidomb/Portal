//
//  SegmentedRenderer.swift
//  PortalView
//
//  Created by Cristian Ames on 4/4/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal struct SegmentedRenderer<MessageType, RouteType: Route>: UIKitRenderer {
    
    typealias ActionType = Action<RouteType, MessageType>
    
    let segments: ZipList<SegmentProperties<ActionType>>
    let style: StyleSheet<SegmentedStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<ActionType> {
        let segmentedControl = UISegmentedControl(items: [])
        
        for (index, segment) in segments.enumerated() {
            switch segment.content {
            case .image(let image):
                segmentedControl.insertSegment(with: image.asUIImage, at: index, animated: false)
            case .title(let text):
                segmentedControl.insertSegment(withTitle: text, at: index, animated: false)
            }
            segmentedControl.setEnabled(segment.isEnabled, forSegmentAt: index)
        }
        segmentedControl.selectedSegmentIndex = Int(segments.centerIndex)
        
        segmentedControl.apply(style: style.base)
        segmentedControl.apply(style: style.component)
        layoutEngine.apply(layout: layout, to: segmentedControl)
        
        segmentedControl.unregisterDispatchers()
        segmentedControl.removeTarget(.none, action: .none, for: .valueChanged)
        let mailbox = segmentedControl.bindMessageDispatcher { mailbox in
            _ = segmentedControl.dispatch(
                messages: segments.map { $0.onTap },
                for: .valueChanged, with: mailbox
            )
        }
        
        return Render(view: segmentedControl, mailbox: mailbox)
    }
    
}

extension UISegmentedControl {
    
    fileprivate func dispatch<MessageType>(
        messages: [MessageType?],
        for event: UIControlEvents,
        with mailbox: Mailbox<MessageType> = Mailbox()) -> Mailbox<MessageType> {
        
        let dispatcher = MessageDispatcher(mailbox: mailbox) { sender in
            guard let segmentedControl = sender as? UISegmentedControl else { return .none }
            let index = segmentedControl.selectedSegmentIndex
            return index < messages.count ? messages[index] : .none
        }
        self.register(dispatcher: dispatcher)
        self.addTarget(dispatcher, action: dispatcher.selector, for: event)
        return dispatcher.mailbox
    }
    
}


extension UISegmentedControl {
    
    fileprivate func apply(style: SegmentedStyleSheet) {
        self.tintColor = style.borderColor.asUIColor
        var dictionary = [String: Any]()
        let font = UIFont(name: style.textFont.name , size: CGFloat(style.textSize)) ?? .none
        dictionary[NSForegroundColorAttributeName] = style.textColor.asUIColor
        font.apply { dictionary[NSFontAttributeName] = $0 }
        self.setTitleTextAttributes(dictionary, for: .normal)
    }
    
}
