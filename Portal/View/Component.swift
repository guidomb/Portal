//
//  Component.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 1/27/17.
//
//
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
    case spinner(StyleSheet<SpinnerStyleSheet>, Layout)
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

        case .spinner(_, let layout):
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

        case .spinner(let style, let layout):
            return .spinner(style, layout)

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
