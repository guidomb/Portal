//
//  UIViewExtensions.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal extension UIView {
    
    internal func safeTraverse(visitor: @escaping (UIView) -> Void) {
        guard self.managedByPortal else { return }
        
        visitor(self)
        self.subviews.forEach { $0.safeTraverse(visitor: visitor) }
    }
    
    internal var managedByPortal: Bool {
        set {
            objc_setAssociatedObject(self, &managedByPortalAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &managedByPortalAssociationKey) as? Bool ?? false
        }
    }
    
    internal func register<MessageType>(dispatcher: MessageDispatcher<MessageType>) {
        let dispatchers = objc_getAssociatedObject(self, &messageDispatcherAssociationKey)
            as? NSMutableArray ?? NSMutableArray()
        dispatchers.add(dispatcher)
        objc_setAssociatedObject(self, &messageDispatcherAssociationKey, dispatchers,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    internal func unregisterDispatchers() {
        objc_setAssociatedObject(self, &messageDispatcherAssociationKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    internal func bindMessageDispatcher<MessageType>(binder: (Mailbox<MessageType>) -> Void) -> Mailbox<MessageType> {
        unregisterDispatchers()
        let mailbox = Mailbox<MessageType>()
        binder(mailbox)
        return mailbox
    }
    
    internal func addDebugFrame() {
        topBorder(thickness: 1.0, color: .red)
        bottomBorder(thickness: 1.0, color: .red)
        leftBorder(thickness: 1.0, color: .red)
        rightBorder(thickness: 1.0, color: .red)
        
    }
    
    internal func addChangeDebugAnimation(duration: TimeInterval = 0.5, backgroundColor: UIColor = .red) {
        let frame = CGRect(origin: .zero, size: self.bounds.size)
        let view = UIView(frame: frame)
        view.backgroundColor = backgroundColor

        UIView.animate(
            withDuration: duration,
            animations: { view.backgroundColor = .none },
            completion: { _ in view.removeFromSuperview() }
        )

        self.addSubview(view)
    }
    
    internal func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: CAAnimationDelegate? = .none) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(.pi * 2.0)
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = Float.infinity
        
        if let delegate = completionDelegate {
            rotateAnimation.delegate = delegate
        }
        layer.add(rotateAnimation, forKey: AnimationKey.rotation360.rawValue)
    }
    
}

fileprivate var managedByPortalAssociationKey = 0
fileprivate var messageDispatcherAssociationKey = 1

fileprivate enum AnimationKey: String {
    
    case rotation360 = "me.guidomb.PortalView.AnimationKey.360DegreeRotation"
    
}

fileprivate extension UIView {

    fileprivate func topBorder(thickness: Float, color: UIColor) {
        let borderView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: superview!.bounds.width - 1.0,
            height: CGFloat(thickness))
        )
        borderView.backgroundColor = color
        addSubview(borderView)
    }
    
    fileprivate func bottomBorder(thickness: Float, color: UIColor) {
        let borderView = UIView(frame: CGRect(x: 0, y: bounds.height, width: superview!.bounds.width - 1.0,
                                              height: CGFloat(thickness)))
        borderView.backgroundColor = color
        addSubview(borderView)
    }
    
    fileprivate func leftBorder(thickness: Float, color: UIColor) {
        let borderView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(thickness), height: bounds.height))
        borderView.backgroundColor = color
        addSubview(borderView)
    }
    
    fileprivate func rightBorder(thickness: Float, color: UIColor) {
        let borderView = UIView(frame: CGRect(x: superview!.bounds.width - 1.0, y: 0, width: CGFloat(thickness),
                                              height: bounds.height))
        borderView.backgroundColor = color
        addSubview(borderView)
    }
    
}
