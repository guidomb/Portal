// Generated using Sourcery 0.7.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable file_length
fileprivate func compareOptionals<T>(lhs: T?, rhs: T?, compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
    switch (lhs, rhs) {
    case let (lValue?, rValue?):
        return compare(lValue, rValue)
    case (nil, nil):
        return true
    default:
        return false
    }
}

fileprivate func compareArrays<T>(lhs: [T], rhs: [T], compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (idx, lhsItem) in lhs.enumerated() {
        guard compare(lhsItem, rhs[idx]) else { return false }
    }

    return true
}


// MARK: - AutoEquatable for classes, protocols, structs
// MARK: - AspectRatio AutoEquatable
extension AspectRatio: Equatable {}
public func == (lhs: AspectRatio, rhs: AspectRatio) -> Bool {
    guard lhs.rawValue == rhs.rawValue else { return false }
    return true
}
// MARK: - Color AutoEquatable
extension Color: Equatable {}
public func == (lhs: Color, rhs: Color) -> Bool {
    guard lhs.red == rhs.red else { return false }
    guard lhs.green == rhs.green else { return false }
    guard lhs.blue == rhs.blue else { return false }
    guard lhs.alpha == rhs.alpha else { return false }
    return true
}
// MARK: - Coordinates AutoEquatable
extension Coordinates: Equatable {}
public func == (lhs: Coordinates, rhs: Coordinates) -> Bool {
    guard lhs.latitude == rhs.latitude else { return false }
    guard lhs.longitude == rhs.longitude else { return false }
    return true
}
// MARK: - Edge AutoEquatable
extension Edge: Equatable {}
public func == (lhs: Edge, rhs: Edge) -> Bool {
    guard compareOptionals(lhs: lhs.left, rhs: rhs.left, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.top, rhs: rhs.top, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.right, rhs: rhs.right, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.bottom, rhs: rhs.bottom, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.start, rhs: rhs.start, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.end, rhs: rhs.end, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.horizontal, rhs: rhs.horizontal, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.vertical, rhs: rhs.vertical, compare: ==) else { return false }
    return true
}
// MARK: - FlexValue AutoEquatable
extension FlexValue: Equatable {}
public func == (lhs: FlexValue, rhs: FlexValue) -> Bool {
    guard lhs.rawValue == rhs.rawValue else { return false }
    return true
}
// MARK: - Font AutoEquatable
extension Font: Equatable {}
public func == (lhs: Font, rhs: Font) -> Bool {
    guard lhs.name == rhs.name else { return false }
    return true
}
// MARK: - MapPlacemark AutoEquatable
extension MapPlacemark: Equatable {}
public func == (lhs: MapPlacemark, rhs: MapPlacemark) -> Bool {
    guard lhs.coordinates == rhs.coordinates else { return false }
    guard compareOptionals(lhs: lhs.icon, rhs: rhs.icon, compare: ==) else { return false }
    return true
}
// MARK: - Offset AutoEquatable
extension Offset: Equatable {}
public func == (lhs: Offset, rhs: Offset) -> Bool {
    guard lhs.x == rhs.x else { return false }
    guard lhs.y == rhs.y else { return false }
    return true
}
// MARK: - SectionInset AutoEquatable
extension SectionInset: Equatable {}
public func == (lhs: SectionInset, rhs: SectionInset) -> Bool {
    guard lhs.bottom == rhs.bottom else { return false }
    guard lhs.top == rhs.top else { return false }
    guard lhs.left == rhs.left else { return false }
    guard lhs.right == rhs.right else { return false }
    return true
}
// MARK: - Shadow AutoEquatable
extension Shadow: Equatable {}
public func == (lhs: Shadow, rhs: Shadow) -> Bool {
    guard lhs.color == rhs.color else { return false }
    guard lhs.opacity == rhs.opacity else { return false }
    guard lhs.offset == rhs.offset else { return false }
    guard lhs.radius == rhs.radius else { return false }
    guard lhs.shouldRasterize == rhs.shouldRasterize else { return false }
    return true
}
// MARK: - Size AutoEquatable
extension Size: Equatable {}
public func == (lhs: Size, rhs: Size) -> Bool {
    guard lhs.width == rhs.width else { return false }
    guard lhs.height == rhs.height else { return false }
    return true
}

// MARK: - AutoEquatable for Enums
// MARK: - Border AutoEquatable
extension Border: Equatable {}
public func == (lhs: Border, rhs: Border) -> Bool {
    switch (lhs, rhs) {
    case (.all(let lhs), .all(let rhs)):
        return lhs == rhs
    case (.by(let lhs), .by(let rhs)):
        return lhs == rhs
    default: return false
    }
}
// MARK: - Image AutoEquatable
extension Image: Equatable {}
public func == (lhs: Image, rhs: Image) -> Bool {
    switch (lhs, rhs) {
    case (.localImage(let lhs), .localImage(let rhs)):
        return lhs == rhs
    case (.blob(let lhs), .blob(let rhs)):
        return lhs == rhs
    default: return false
    }
}
// MARK: - Margin AutoEquatable
extension Margin: Equatable {}
public func == (lhs: Margin, rhs: Margin) -> Bool {
    switch (lhs, rhs) {
    case (.all(let lhs), .all(let rhs)):
        return lhs == rhs
    case (.by(let lhs), .by(let rhs)):
        return lhs == rhs
    default: return false
    }
}
// MARK: - Padding AutoEquatable
extension Padding: Equatable {}
public func == (lhs: Padding, rhs: Padding) -> Bool {
    switch (lhs, rhs) {
    case (.all(let lhs), .all(let rhs)):
        return lhs == rhs
    case (.by(let lhs), .by(let rhs)):
        return lhs == rhs
    default: return false
    }
}
// MARK: - Position AutoEquatable
extension Position: Equatable {}
public func == (lhs: Position, rhs: Position) -> Bool {
    switch (lhs, rhs) {
    case (.relative, .relative):
        return true
    case (.absolute(let lhs), .absolute(let rhs)):
        return lhs == rhs
    default: return false
    }
}
// MARK: - ProgressContentType AutoEquatable
extension ProgressContentType: Equatable {}
public func == (lhs: ProgressContentType, rhs: ProgressContentType) -> Bool {
    switch (lhs, rhs) {
    case (.color(let lhs), .color(let rhs)):
        return lhs == rhs
    case (.image(let lhs), .image(let rhs)):
        return lhs == rhs
    default: return false
    }
}
// MARK: - Text AutoEquatable
extension Text: Equatable {}
public func == (lhs: Text, rhs: Text) -> Bool {
    switch (lhs, rhs) {
    case (.regular(let lhs), .regular(let rhs)):
        return lhs == rhs
    case (.attributed(let lhs), .attributed(let rhs)):
        return lhs == rhs
    default: return false
    }
}
