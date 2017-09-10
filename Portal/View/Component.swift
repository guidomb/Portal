//
//  Component.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 1/27/17.
//
//
// swiftlint:disable file_length

import Foundation

public enum RootComponent<MessageType> {

    case simple
    case stack(NavigationBar<MessageType>)
    case tab(TabBar<MessageType>)

}

public enum SupportedOrientations {

    case portrait
    case landscape
    case all

}

public enum Gesture<MessageType> {

    case tap(message: MessageType)

}

public extension Gesture {

    public func map<NewMessageType>(_ transform: @escaping (MessageType) -> NewMessageType) -> Gesture<NewMessageType> {
        switch self {

        case .tap(let message):
            return .tap(message: transform(message))

        }
    }

}

public struct CustomComponent {

    public let identifier: String
    public let information: [String : Any]

    public init(identifier: String, information: [String : Any] = [:]) {
        self.identifier = identifier
        self.information = information
    }

}

public indirect enum Component<MessageType> {

    case button(ButtonProperties<MessageType>, StyleSheet<ButtonStyleSheet>, Layout)
    case label(LabelProperties, StyleSheet<LabelStyleSheet>, Layout)
    case mapView(MapProperties, StyleSheet<EmptyStyleSheet>, Layout)
    case imageView(Image, StyleSheet<EmptyStyleSheet>, Layout)
    case container([Component<MessageType>], StyleSheet<EmptyStyleSheet>, Layout)
    case table(TableProperties<MessageType>, StyleSheet<TableStyleSheet>, Layout)
    case collection(CollectionProperties<MessageType>, StyleSheet<EmptyStyleSheet>, Layout)
    case carousel(CarouselProperties<MessageType>, StyleSheet<EmptyStyleSheet>, Layout)
    case touchable(gesture: Gesture<MessageType>, child: Component<MessageType>)
    case segmented(ZipList<SegmentProperties<MessageType>>, StyleSheet<SegmentedStyleSheet>, Layout)
    case progress(ProgressCounter, StyleSheet<ProgressStyleSheet>, Layout)
    case textField(TextFieldProperties<MessageType>, StyleSheet<TextFieldStyleSheet>, Layout)
    case custom(CustomComponent, StyleSheet<EmptyStyleSheet>, Layout)
    case spinner(Bool, StyleSheet<SpinnerStyleSheet>, Layout)
    case textView(Text, StyleSheet<TextViewStyleSheet>, Layout)

    public var layout: Layout {
        switch self {

        case .button(_, _, let layout):
            return layout

        case .label(_, _, let layout):
            return layout

        case .textField(_, _, let layout):
            return layout

        case .mapView(_, _, let layout):
            return layout

        case .imageView(_, _, let layout):
            return layout

        case .container(_, _, let layout):
            return layout

        case .table(_, _, let layout):
            return layout

        case .touchable(_, let child):
            return child.layout

        case .segmented(_, _, let layout):
            return layout

        case .progress(_, _, let layout):
            return layout

        case .collection(_, _, let layout):
            return layout

        case .carousel(_, _, let layout):
            return layout

        case .custom(_, _, let layout):
            return layout

        case .spinner(_, _, let layout):
            return layout

        case .textView(_, _, let layout):
            return layout

        }
    }

}

extension Component {

    // swiftlint:disable cyclomatic_complexity
    public func map<NewMessageType>(
        _ transform: @escaping (MessageType) -> NewMessageType) -> Component<NewMessageType> {
        switch self {

        case .button(let properties, let style, let layout):
            return .button(properties.map(transform), style, layout)

        case .label(let properties, let style, let layout):
            return .label(properties, style, layout)

        case .textField(let properties, let style, let layout):
            return .textField(properties.map(transform), style, layout)

        case .mapView(let properties, let style, let layout):
            return .mapView(properties, style, layout)

        case .imageView(let image, let style, let layout):
            return .imageView(image, style, layout)

        case .container(let children, let style, let layout):
            return .container(children.map { $0.map(transform) }, style, layout)

        case .table(let properties, let style, let layout):
            return .table(properties.map(transform), style, layout)

        case .touchable(let gesture, let child):
            return .touchable(gesture: gesture.map(transform), child: child.map(transform))

        case .segmented(let segments, let style, let layout):
            return .segmented(segments.map { $0.map(transform) }, style, layout)

        case .progress(let progress, let style, let layout):
            return .progress(progress, style, layout)

        case .collection(let properties, let style, let layout):
            return .collection(properties.map(transform), style, layout)

        case .carousel(let properties, let style, let layout):
            return .carousel(properties.map(transform), style, layout)

        case .custom(let customComponent, let style, let layout):
            return .custom(customComponent, style, layout)

        case .spinner(let isActive, let style, let layout):
            return .spinner(isActive, style, layout)

        case .textView(let text, let style, let layout):
            return .textView(text, style, layout)

        }
    }
    // swiftlint:enable cyclomatic_complexity

    public var customComponentIdentifiers: [String] {
        switch self {

        case .container(let children, _, _):
            return children.flatMap { $0.customComponentIdentifiers }

        case .custom(let customComponent, _, _):
            return [customComponent.identifier]

        default:
            return []

        }
    }

}

extension Component {
    
    var fullChangeSet: ComponentChangeSet<MessageType> {
        switch self {
            
        case .button(let properties, let style, let layout):
            return .button(ButtonChangeSet.fullChangeSet(properties: properties, style: style, layout: layout))
            
        case .label(let properties, let style, let layout):
            return .label(LabelChangeSet.fullChangeSet(properties: properties, style: style, layout: layout))
            
        case .textField(let properties, let style, let layout):
            return .textField(TextFieldChangeSet.fullChangeSet(properties: properties, style: style, layout: layout))
            
        case .mapView(let properties, let style, let layout):
            return .mapView(MapViewChangeSet.fullChangeSet(properties: properties, style: style, layout: layout))
            
        case .imageView(let image, let style, let layout):
            return .imageView(ImageViewChangeSet.fullChangeSet(image: image, style: style, layout: layout))
            
        case .container(let children, let style, let layout):
            return .container(ContainerChangeSet<MessageType>.fullChangeSet(
                children: children, style: style, layout: layout))
            
        case .table(let properties, let style, let layout):
            return .table(TableChangeSet.fullChangeSet(properties: properties, style: style, layout: layout))
            
        case .touchable(let gesture, let child):
            return .touchable(TouchableChangeSet<MessageType>.fullChangeSet(gesture: gesture, child: child))
            
        case .segmented(let segments, let style, let layout):
            return .segmented(SegmentedChangeSet.fullChangeSet(segments: segments, style: style, layout: layout))
            
        case .progress(let progress, let style, let layout):
            return .progress(ProgressChangeSet.fullChangeSet(progress: progress, style: style, layout: layout))
            
        case .collection(let properties, let style, let layout):
            return .collection(CollectionChangeSet.fullChangeSet(properties: properties, style: style, layout: layout))
            
        case .carousel(let properties, let style, let layout):
            return .carousel(CarouselChangeSet.fullChangeSet(properties: properties, style: style, layout: layout))
            
        case .custom(let customComponent, let style, let layout):
            return .custom(CustomComponentChangeSet.fullChangeSet(
                customComponent: customComponent, style: style, layout: layout))
            
        case .spinner(let isActive, let style, let layout):
            return .spinner(SpinnerChangeSet.fullChangeSet(isActive: isActive, style: style, layout: layout))
            
        case .textView(let text, let style, let layout):
            return .textView(TextViewChangeSet.fullChangeSet(text: text, style: style, layout: layout))
        }
    }

    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity
    func changeSet(for component: Component<MessageType>) -> ComponentChangeSet<MessageType> {
        switch (self, component) {
            
        case (.button(let oldProperties, let oldStyle, let oldLayout),
              .button(let newProperties, let newStyle, let newLayout)):
            return .button(
                ButtonChangeSet(
                    properties: oldProperties.changeSet(for: newProperties),
                    baseStyleSheet: oldStyle.base.changeSet(for: newStyle.base),
                    buttonStyleSheet: oldStyle.component.changeSet(for: newStyle.component),
                    layout: oldLayout.changeSet(for: newLayout)
                )
            )
            
        case (.label(let oldProperties, let oldStyle, let oldLayout),
              .label(let newProperties, let newStyle, let newLayout)):
            return .label(
                LabelChangeSet(
                    properties: oldProperties.changeSet(for: newProperties),
                    baseStyleSheet: oldStyle.base.changeSet(for: newStyle.base),
                    labelStyleSheet: oldStyle.component.changeSet(for: newStyle.component),
                    layout: oldLayout.changeSet(for: newLayout)
                )
            )
            
        case (.textField(let oldProperties, let oldStyle, let oldLayout),
              .textField(let newProperties, let newStyle, let newLayout)):
            return .textField(
                TextFieldChangeSet(
                    properties: oldProperties.changeSet(for: newProperties),
                    baseStyleSheet: oldStyle.base.changeSet(for: newStyle.base),
                    textFieldStyleSheet: oldStyle.component.changeSet(for: newStyle.component),
                    layout: oldLayout.changeSet(for: newLayout)
                )
            )
        
        case (.mapView(let oldProperties, let oldStyle, let oldLayout),
              .mapView(let newProperties, let newStyle, let newLayout)):
            return .mapView(
                MapViewChangeSet(
                    properties: oldProperties.changeSet(for: newProperties),
                    baseStyleSheet: oldStyle.base.changeSet(for: newStyle.base),
                    layout: oldLayout.changeSet(for: newLayout)
                )
            )

        case (.imageView(let oldImage, let oldStyle, let oldLayout),
              .imageView(let newImage, let newStyle, let newLayout)):
            let image: PropertyChange<Image?> = (oldImage == newImage) ? .noChange : .change(to: newImage)
            return .imageView(
                ImageViewChangeSet(
                    image: image,
                    baseStyleSheet: oldStyle.base.changeSet(for: newStyle.base),
                    layout: oldLayout.changeSet(for: newLayout)
                )
            )
         
        case (.container(let oldChildren, let oldStyle, let oldLayout),
              .container(let newChildren, let newStyle, let newLayout)):
            guard oldChildren.count == newChildren.count else {
                return .container(
                    ContainerChangeSet<MessageType>.fullChangeSet(
                        children: newChildren,
                        style: newStyle,
                        layout: newLayout
                    )
                )
            }
            let children = zip(oldChildren, newChildren).map { (old, new) in old.changeSet(for: new) }
            return .container(
                ContainerChangeSet(
                    children: children,
                    baseStyleSheet: oldStyle.base.changeSet(for: newStyle.base),
                    layout: oldLayout.changeSet(for: newLayout)
                )
            )
           
        case (.table(let oldProperties, let oldStyle, let oldLayout),
              .table(let newProperties, let newStyle, let newLayout)):
            return .table(
                TableChangeSet(
                    properties: oldProperties.changeSet(for: newProperties),
                    baseStyleSheet: oldStyle.base.changeSet(for: newStyle.base),
                    tableStyleSheet: oldStyle.component.changeSet(for: newStyle.component),
                    layout: oldLayout.changeSet(for: newLayout)
                )
            )
        
        case (.touchable(_, let oldChild),
              .touchable(let newGesture, let newChild)):
            return .touchable(
                TouchableChangeSet(
                    gesture: .change(to: newGesture),
                    child: oldChild.changeSet(for: newChild)
                )
            )
            
        case (.segmented(_, let oldStyle, let oldLayout),
              .segmented(let newSegments, let newStyle, let newLayout)):
            return .segmented(
                SegmentedChangeSet(
                    segments: .change(to: newSegments),
                    baseStyleSheet: oldStyle.base.changeSet(for: newStyle.base),
                    layout: oldLayout.changeSet(for: newLayout)
                )
            )
    
        case (.progress(_, let oldStyle, let oldLayout),
              .progress(let newProgressCounter, let newStyle, let newLayout)):
            return .progress(
                ProgressChangeSet(
                    progress: .change(to: newProgressCounter),
                    baseStyleSheet: oldStyle.base.changeSet(for: newStyle.base),
                    layout: oldLayout.changeSet(for: newLayout)
                )
            )
    
        case (.collection(let oldProperties, let oldStyle, let oldLayout),
              .collection(let newProperties, let newStyle, let newLayout)):
            return .collection(
                CollectionChangeSet(
                    properties: oldProperties.changeSet(for: newProperties),
                    baseStyleSheet: oldStyle.base.changeSet(for: newStyle.base),
                    layout: oldLayout.changeSet(for: newLayout)
                )
            )
        
        case (.carousel(let oldProperties, let oldStyle, let oldLayout),
              .carousel(let newProperties, let newStyle, let newLayout)):
            return .carousel(
                CarouselChangeSet(
                    properties: oldProperties.changeSet(for: newProperties),
                    baseStyleSheet: oldStyle.base.changeSet(for: newStyle.base),
                    layout: oldLayout.changeSet(for: newLayout)
                )
            )
            
        case (.custom(let oldCustomComponent, let oldStyle, let oldLayout),
              .custom(let newCustomComponent, let newStyle, let newLayout)):
            return .custom(
                CustomComponentChangeSet(
                    oldCustomComponent: oldCustomComponent,
                    newCustomComponent: newCustomComponent,
                    baseStyleSheet: oldStyle.base.changeSet(for: newStyle.base),
                    layout: oldLayout.changeSet(for: newLayout)
                )
            )
          
        case (.spinner(let oldIsActive, let oldStyle, let oldLayout),
              .spinner(let newIsActive, let newStyle, let newLayout)):
            let isActive: PropertyChange<Bool> = oldIsActive == newIsActive ? .noChange : .change(to: newIsActive)
            return .spinner(
                SpinnerChangeSet(
                    isActive: isActive,
                    baseStyleSheet: oldStyle.base.changeSet(for: newStyle.base),
                    layout: oldLayout.changeSet(for: newLayout)
                )
            )
            
        case (.textView(let oldText, let oldStyle, let oldLayout),
              .textView(let newText, let newStyle, let newLayout)):
            let text: PropertyChange<Text> = oldText == newText ? .noChange : .change(to: newText)
            return .textView(
                TextViewChangeSet(
                    text: text,
                    baseStyleSheet: oldStyle.base.changeSet(for: newStyle.base),
                    layout: oldLayout.changeSet(for: newLayout)
                )
            )
         
        default:
            return component.fullChangeSet
        
        }
    }
    // swiftlint:enable function_body_length
    // swiftlint:enable cyclomatic_complexity
}

public struct CustomComponentChangeSet {
    
    static func fullChangeSet(
        customComponent: CustomComponent,
        style: StyleSheet<EmptyStyleSheet>,
        layout: Layout) -> CustomComponentChangeSet {
        return CustomComponentChangeSet(
            oldCustomComponent: .none,
            newCustomComponent: customComponent,
            baseStyleSheet: style.base.fullChangeSet,
            layout: layout.fullChangeSet
        )
    }
    
    let oldCustomComponent: CustomComponent?
    let newCustomComponent: CustomComponent
    let baseStyleSheet: [BaseStyleSheet.Property]
    let layout: [Layout.Property]
    
    init(
        oldCustomComponent: CustomComponent?,
        newCustomComponent: CustomComponent,
        baseStyleSheet: [BaseStyleSheet.Property] = [],
        layout: [Layout.Property] = []) {
        self.oldCustomComponent = oldCustomComponent
        self.newCustomComponent = newCustomComponent
        self.baseStyleSheet = baseStyleSheet
        self.layout = layout
    }
}

public struct ContainerChangeSet<MessageType> {

    static func fullChangeSet(
        children: [Component<MessageType>],
        style: StyleSheet<EmptyStyleSheet>,
        layout: Layout) -> ContainerChangeSet<MessageType> {
        return ContainerChangeSet<MessageType>(
            children: children.map { $0.fullChangeSet },
            baseStyleSheet: style.base.fullChangeSet,
            layout: layout.fullChangeSet
        )
    }

    let children: [ComponentChangeSet<MessageType>]
    let baseStyleSheet: [BaseStyleSheet.Property]
    let layout: [Layout.Property]

    init(
        children: [ComponentChangeSet<MessageType>] = [],
        baseStyleSheet: [BaseStyleSheet.Property] = [],
        layout: [Layout.Property] = []) {
        self.children = children
        self.baseStyleSheet = baseStyleSheet
        self.layout = layout
    }
}

public struct TouchableChangeSet<MessageType> {
    
    typealias GestureChange = PropertyChange<Gesture<MessageType>>
    
    static func fullChangeSet(
        gesture: Gesture<MessageType>,
        child: Component<MessageType>) -> TouchableChangeSet<MessageType> {
        return TouchableChangeSet(
            gesture: .change(to: gesture),
            child: child.fullChangeSet
        )
    }
    
    let gesture: GestureChange
    let child: ComponentChangeSet<MessageType>
    
}

public indirect enum ComponentChangeSet<MessageType> {

    case empty
    case button(ButtonChangeSet<MessageType>)
    case label(LabelChangeSet)
    case mapView(MapViewChangeSet)
    case imageView(ImageViewChangeSet)
    case container(ContainerChangeSet<MessageType>)
    case table(TableChangeSet<MessageType>)
    case collection(CollectionChangeSet<MessageType>)
    case carousel(CarouselChangeSet<MessageType>)
    case touchable(TouchableChangeSet<MessageType>)
    case segmented(SegmentedChangeSet<MessageType>)
    case progress(ProgressChangeSet)
    case textField(TextFieldChangeSet<MessageType>)
    case custom(CustomComponentChangeSet)
    case spinner(SpinnerChangeSet)
    case textView(TextViewChangeSet)

}

public func container<MessageType>(
    children: [Component<MessageType>] = [],
    style: StyleSheet<EmptyStyleSheet> = EmptyStyleSheet.`default`,
    layout: Layout = layout()) -> Component<MessageType> {
    return .container(children, style, layout)
}

public func touchable<MessageType>(
    gesture: Gesture<MessageType>,
    child: Component<MessageType>) -> Component<MessageType> {
    return .touchable(gesture: gesture, child: child)
}
