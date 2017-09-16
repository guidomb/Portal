//
//  ComponentChangeSet.swift
//  Portal
//
//  Created by Guido Marucci Blas on 9/10/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//
import Foundation

public indirect enum ComponentChangeSet<MessageType> {

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

extension ComponentChangeSet {

    var isEmpty: Bool {
        switch self {
        case .button(let buttonChangeSet):
            return buttonChangeSet.isEmpty
            
        case .label(let labelChangeSet):
            return labelChangeSet.isEmpty
            
        case .mapView(let mapViewChangeSet):
            return mapViewChangeSet.isEmpty
            
        case .imageView(let imageViewChangeSet):
            return imageViewChangeSet.isEmpty
            
        case .container(let containerChangeSet):
            return containerChangeSet.isEmpty
            
        case .table(let tableChangeSet):
            return tableChangeSet.isEmpty
            
        case .collection(let collectionChangeSet):
            return collectionChangeSet.isEmpty
            
        case .carousel(let carouselChangeSet):
            return carouselChangeSet.isEmpty
            
        case .touchable(let touchableChangeSet):
            return touchableChangeSet.child.isEmpty
            
        case .segmented(let segmentedChangeSet):
            return segmentedChangeSet.isEmpty
            
        case .progress(let progressChangeSet):
            return progressChangeSet.isEmpty
            
        case .textField(let textFieldChangeSet):
            return textFieldChangeSet.isEmpty
            
        case .custom:
            return false
            
        case .spinner(let spinnerChangeSet):
            return spinnerChangeSet.isEmpty
            
        case .textView(let textViewChangeSet):
            return textViewChangeSet.isEmpty
            
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

        case .spinner(let style, let layout):
            return .spinner(SpinnerChangeSet.fullChangeSet(style: style, layout: layout))

        case .textView(let text, let style, let layout):
            return .textView(TextViewChangeSet.fullChangeSet(text: text, style: style, layout: layout))
        }
    }

    // swiftlint:disable function_body_length cyclomatic_complexity
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

        case (.spinner(let oldStyle, let oldLayout),
              .spinner(let newStyle, let newLayout)):
            return .spinner(
                SpinnerChangeSet(
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
    // swiftlint:enable function_body_length cyclomatic_complexity
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

    public let oldCustomComponent: CustomComponent?
    public let newCustomComponent: CustomComponent
    public let baseStyleSheet: [BaseStyleSheet.Property]
    public let layout: [Layout.Property]

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
    
    var isEmpty: Bool {
        return  baseStyleSheet.isEmpty      &&
                layout.isEmpty              &&
                children.reduce(true) { (result, child) in result && child.isEmpty }
        
    }

    public var childrenCount: Int { return children.count }

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
