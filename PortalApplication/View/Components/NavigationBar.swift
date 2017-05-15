//
//  NavigationBar.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 1/27/17.
//
//

import Foundation

public enum NavigationBarTitle<MessageType> {
    
    case text(String)
    case image(Image)
    case component(Component<MessageType>)
    
}

public enum NavigationBarButton<MessageType> {
    
    case textButton(title: String, onTap: MessageType)
    case imageButton(icon: Image, onTap: MessageType)
    
}

public struct NavigationBarProperties<MessageType> {
    
    public var title: NavigationBarTitle<MessageType>?
    public var hideBackButtonTitle: Bool
    public var onBack: MessageType?
    public var leftButtonItems: [NavigationBarButton<MessageType>]?
    public var rightButtonItems: [NavigationBarButton<MessageType>]?
    
    fileprivate init(
        title: NavigationBarTitle<MessageType>? = .none,
        hideBackButtonTitle: Bool = false,
        onBack: MessageType? = .none,
        leftButtonItems: [NavigationBarButton<MessageType>]? = .none,
        rightButtonItems: [NavigationBarButton<MessageType>]? = .none) {
        self.title = title
        self.hideBackButtonTitle = hideBackButtonTitle
        self.onBack = onBack
        self.leftButtonItems = leftButtonItems
        self.rightButtonItems = rightButtonItems
    }
    
}

public struct NavigationBar<MessageType> {
    
    public let properties: NavigationBarProperties<MessageType>
    public let style: StyleSheet<NavigationBarStyleSheet>
    
    fileprivate init(properties: NavigationBarProperties<MessageType>, style: StyleSheet<NavigationBarStyleSheet>) {
        self.properties = properties
        self.style = style
    }
    
}

public func navigationBar<MessageType>(
    properties: NavigationBarProperties<MessageType>,
    style: StyleSheet<NavigationBarStyleSheet> = navigationBarStyleSheet()) -> NavigationBar<MessageType> {
    return NavigationBar(properties: properties, style: style)
}

public func navigationBar<MessageType>(
    title: String,
    onBack: MessageType,
    style: StyleSheet<NavigationBarStyleSheet> = navigationBarStyleSheet()) -> NavigationBar<MessageType> {
    return NavigationBar(
        properties: properties() {
            $0.title = .text(title)
            $0.onBack = onBack
        },
        style: style
    )
}

public func navigationBar<MessageType>(
    title: Image,
    onBack: MessageType,
    style: StyleSheet<NavigationBarStyleSheet> = navigationBarStyleSheet()) -> NavigationBar<MessageType> {
    return NavigationBar(
        properties: properties() {
            $0.title = .image(title)
            $0.onBack = onBack
        },
        style: style
    )
}

public func properties<MessageType>(configure: (inout NavigationBarProperties<MessageType>) -> ()) -> NavigationBarProperties<MessageType> {
    var properties = NavigationBarProperties<MessageType>()
    configure(&properties)
    return properties
}

// MARK: - Style sheet

public let defaultNavigationBarTitleFontSize: UInt = 17

public struct NavigationBarStyleSheet {
    
    public static let `default` = StyleSheet<NavigationBarStyleSheet>(component: NavigationBarStyleSheet())
    
    public var tintColor: Color
    public var titleTextColor: Color
    public var titleTextFont: Font
    public var titleTextSize: UInt
    public var isTranslucent: Bool
    public var statusBarStyle: StatusBarStyle
    
    fileprivate init(
        tintColor: Color = .black,
        titleTextColor: Color = .black,
        titleTextFont: Font = defaultFont,
        titleTextSize: UInt = defaultNavigationBarTitleFontSize,
        isTranslucent: Bool = true,
        statusBarStyle: StatusBarStyle = .`default`) {
        self.tintColor = tintColor
        self.titleTextFont = titleTextFont
        self.titleTextColor = titleTextColor
        self.titleTextSize = titleTextSize
        self.isTranslucent = isTranslucent
        self.statusBarStyle = statusBarStyle
    }
    
}

public func navigationBarStyleSheet(configure: (inout BaseStyleSheet, inout NavigationBarStyleSheet) -> () = { _ in }) -> StyleSheet<NavigationBarStyleSheet> {
    var base = BaseStyleSheet()
    var component = NavigationBarStyleSheet()
    configure(&base, &component)
    return StyleSheet(component: component, base: base)
}
