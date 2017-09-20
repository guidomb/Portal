// Generated using Sourcery 0.7.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


// MARK: - Alignment AutoPropertyDiffable
public extension Alignment {

    public enum Property {

        case content(AlignContent)
        case `self`(AlignSelf?)
        case items(AlignItems)

    }

    public var fullChangeSet: [Alignment.Property] {
        return [
            .content(self.content),
            .`self`(self.`self`),
            .items(self.items),
        ]
    }

    public func changeSet(for alignment: Alignment) -> [Alignment.Property] {
        var changeSet: [Alignment.Property] = []
        if self.content != alignment.content {
            changeSet.append(.content(alignment.content))
        }
        if self.`self` != alignment.`self` {
            changeSet.append(.`self`(alignment.`self`))
        }
        if self.items != alignment.items {
            changeSet.append(.items(alignment.items))
        }
        return changeSet
    }

}

// MARK: - BaseStyleSheet AutoPropertyDiffable
public extension BaseStyleSheet {

    public enum Property {

        case backgroundColor(Color)
        case cornerRadius(Float?)
        case borderColor(Color)
        case borderWidth(Float)
        case alpha(Float)
        case contentMode(ContentMode?)
        case clipToBounds(Bool)
        case shadow([Shadow.Property]?)

    }

    public var fullChangeSet: [BaseStyleSheet.Property] {
        return [
            .backgroundColor(self.backgroundColor),
            .cornerRadius(self.cornerRadius),
            .borderColor(self.borderColor),
            .borderWidth(self.borderWidth),
            .alpha(self.alpha),
            .contentMode(self.contentMode),
            .clipToBounds(self.clipToBounds),
            .shadow(self.shadow?.fullChangeSet),
        ]
    }

    public func changeSet(for baseStyleSheet: BaseStyleSheet) -> [BaseStyleSheet.Property] {
        var changeSet: [BaseStyleSheet.Property] = []
        if self.backgroundColor != baseStyleSheet.backgroundColor {
            changeSet.append(.backgroundColor(baseStyleSheet.backgroundColor))
        }
        if self.cornerRadius != baseStyleSheet.cornerRadius {
            changeSet.append(.cornerRadius(baseStyleSheet.cornerRadius))
        }
        if self.borderColor != baseStyleSheet.borderColor {
            changeSet.append(.borderColor(baseStyleSheet.borderColor))
        }
        if self.borderWidth != baseStyleSheet.borderWidth {
            changeSet.append(.borderWidth(baseStyleSheet.borderWidth))
        }
        if self.alpha != baseStyleSheet.alpha {
            changeSet.append(.alpha(baseStyleSheet.alpha))
        }
        if self.contentMode != baseStyleSheet.contentMode {
            changeSet.append(.contentMode(baseStyleSheet.contentMode))
        }
        if self.clipToBounds != baseStyleSheet.clipToBounds {
            changeSet.append(.clipToBounds(baseStyleSheet.clipToBounds))
        }
        switch (self.shadow, baseStyleSheet.shadow) {
        case (.some(let old), .some(let new)):
            let shadowChangeSet = old.changeSet(for: new)
            if !shadowChangeSet.isEmpty {
                changeSet.append(.shadow(shadowChangeSet))
            }
        case (.none, .some(let new)):
            changeSet.append(.shadow(new.fullChangeSet))
        case (.some(_), .none):
            changeSet.append(.shadow(.none))
        case (.none, .none):
            break
        }
        return changeSet
    }

}

// MARK: - ButtonProperties AutoPropertyDiffable
public extension ButtonProperties {

    public enum Property {

        case text(String?)
        case isActive(Bool)
        case icon(Image?)
        case onTap(MessageType?)

    }

    public var fullChangeSet: [ButtonProperties.Property] {
        return [
            .text(self.text),
            .isActive(self.isActive),
            .icon(self.icon),
            .onTap(self.onTap),
        ]
    }

    public func changeSet(for buttonProperties: ButtonProperties) -> [ButtonProperties.Property] {
        var changeSet: [ButtonProperties.Property] = []
        if self.text != buttonProperties.text {
            changeSet.append(.text(buttonProperties.text))
        }
        if self.isActive != buttonProperties.isActive {
            changeSet.append(.isActive(buttonProperties.isActive))
        }
        if self.icon != buttonProperties.icon {
            changeSet.append(.icon(buttonProperties.icon))
        }
        changeSet.append(.onTap(buttonProperties.onTap))
        return changeSet
    }

}

// MARK: - ButtonStyleSheet AutoPropertyDiffable
public extension ButtonStyleSheet {

    public enum Property {

        case textColor(Color)
        case textFont(Font)
        case textSize(UInt)

    }

    public var fullChangeSet: [ButtonStyleSheet.Property] {
        return [
            .textColor(self.textColor),
            .textFont(self.textFont),
            .textSize(self.textSize),
        ]
    }

    public func changeSet(for buttonStyleSheet: ButtonStyleSheet) -> [ButtonStyleSheet.Property] {
        var changeSet: [ButtonStyleSheet.Property] = []
        if self.textColor != buttonStyleSheet.textColor {
            changeSet.append(.textColor(buttonStyleSheet.textColor))
        }
        if self.textFont != buttonStyleSheet.textFont {
            changeSet.append(.textFont(buttonStyleSheet.textFont))
        }
        if self.textSize != buttonStyleSheet.textSize {
            changeSet.append(.textSize(buttonStyleSheet.textSize))
        }
        return changeSet
    }

}

// MARK: - CarouselProperties AutoPropertyDiffable
public extension CarouselProperties {

    public enum Property {

        case items(ZipList<CarouselItemProperties<MessageType>>?)
        case showsScrollIndicator(Bool)
        case isSnapToCellEnabled(Bool)
        case onSelectionChange((ZipListShiftOperation) -> MessageType?)
        case itemsSize(Size)
        case minimumInteritemSpacing(UInt)
        case minimumLineSpacing(UInt)
        case sectionInset(SectionInset)

    }

    public var fullChangeSet: [CarouselProperties.Property] {
        return [
            .items(self.items),
            .showsScrollIndicator(self.showsScrollIndicator),
            .isSnapToCellEnabled(self.isSnapToCellEnabled),
            .onSelectionChange(self.onSelectionChange),
            .itemsSize(self.itemsSize),
            .minimumInteritemSpacing(self.minimumInteritemSpacing),
            .minimumLineSpacing(self.minimumLineSpacing),
            .sectionInset(self.sectionInset),
        ]
    }

    public func changeSet(for carouselProperties: CarouselProperties) -> [CarouselProperties.Property] {
        var changeSet: [CarouselProperties.Property] = []
        changeSet.append(.items(carouselProperties.items))
        if self.showsScrollIndicator != carouselProperties.showsScrollIndicator {
            changeSet.append(.showsScrollIndicator(carouselProperties.showsScrollIndicator))
        }
        if self.isSnapToCellEnabled != carouselProperties.isSnapToCellEnabled {
            changeSet.append(.isSnapToCellEnabled(carouselProperties.isSnapToCellEnabled))
        }
        changeSet.append(.onSelectionChange(carouselProperties.onSelectionChange))
        if self.itemsSize != carouselProperties.itemsSize {
            changeSet.append(.itemsSize(carouselProperties.itemsSize))
        }
        if self.minimumInteritemSpacing != carouselProperties.minimumInteritemSpacing {
            changeSet.append(.minimumInteritemSpacing(carouselProperties.minimumInteritemSpacing))
        }
        if self.minimumLineSpacing != carouselProperties.minimumLineSpacing {
            changeSet.append(.minimumLineSpacing(carouselProperties.minimumLineSpacing))
        }
        if self.sectionInset != carouselProperties.sectionInset {
            changeSet.append(.sectionInset(carouselProperties.sectionInset))
        }
        return changeSet
    }

}

// MARK: - CollectionProperties AutoPropertyDiffable
public extension CollectionProperties {

    public enum Property {

        case items([CollectionItemProperties<MessageType>])
        case showsVerticalScrollIndicator(Bool)
        case showsHorizontalScrollIndicator(Bool)
        case refresh(RefreshProperties<MessageType>?)
        case itemsSize(Size)
        case minimumInteritemSpacing(UInt)
        case minimumLineSpacing(UInt)
        case scrollDirection(CollectionScrollDirection)
        case sectionInset(SectionInset)
        case paging(Bool)

    }

    public var fullChangeSet: [CollectionProperties.Property] {
        return [
            .items(self.items),
            .showsVerticalScrollIndicator(self.showsVerticalScrollIndicator),
            .showsHorizontalScrollIndicator(self.showsHorizontalScrollIndicator),
            .refresh(self.refresh),
            .itemsSize(self.itemsSize),
            .minimumInteritemSpacing(self.minimumInteritemSpacing),
            .minimumLineSpacing(self.minimumLineSpacing),
            .scrollDirection(self.scrollDirection),
            .sectionInset(self.sectionInset),
            .paging(self.paging),
        ]
    }

    public func changeSet(for collectionProperties: CollectionProperties) -> [CollectionProperties.Property] {
        var changeSet: [CollectionProperties.Property] = []
        changeSet.append(.items(collectionProperties.items))
        if self.showsVerticalScrollIndicator != collectionProperties.showsVerticalScrollIndicator {
            changeSet.append(.showsVerticalScrollIndicator(collectionProperties.showsVerticalScrollIndicator))
        }
        if self.showsHorizontalScrollIndicator != collectionProperties.showsHorizontalScrollIndicator {
            changeSet.append(.showsHorizontalScrollIndicator(collectionProperties.showsHorizontalScrollIndicator))
        }
        changeSet.append(.refresh(collectionProperties.refresh))
        if self.itemsSize != collectionProperties.itemsSize {
            changeSet.append(.itemsSize(collectionProperties.itemsSize))
        }
        if self.minimumInteritemSpacing != collectionProperties.minimumInteritemSpacing {
            changeSet.append(.minimumInteritemSpacing(collectionProperties.minimumInteritemSpacing))
        }
        if self.minimumLineSpacing != collectionProperties.minimumLineSpacing {
            changeSet.append(.minimumLineSpacing(collectionProperties.minimumLineSpacing))
        }
        if self.scrollDirection != collectionProperties.scrollDirection {
            changeSet.append(.scrollDirection(collectionProperties.scrollDirection))
        }
        if self.sectionInset != collectionProperties.sectionInset {
            changeSet.append(.sectionInset(collectionProperties.sectionInset))
        }
        if self.paging != collectionProperties.paging {
            changeSet.append(.paging(collectionProperties.paging))
        }
        return changeSet
    }

}

// MARK: - CollectionStyleSheet AutoPropertyDiffable
public extension CollectionStyleSheet {

    public enum Property {

        case refreshTintColor(Color)

    }

    public var fullChangeSet: [CollectionStyleSheet.Property] {
        return [
            .refreshTintColor(self.refreshTintColor),
        ]
    }

    public func changeSet(for collectionStyleSheet: CollectionStyleSheet) -> [CollectionStyleSheet.Property] {
        var changeSet: [CollectionStyleSheet.Property] = []
        if self.refreshTintColor != collectionStyleSheet.refreshTintColor {
            changeSet.append(.refreshTintColor(collectionStyleSheet.refreshTintColor))
        }
        return changeSet
    }

}

// MARK: - Dimension AutoPropertyDiffable
public extension Dimension {

    public enum Property {

        case minimum(UInt?)
        case maximum(UInt?)
        case value(UInt?)

    }

    public var fullChangeSet: [Dimension.Property] {
        return [
            .minimum(self.minimum),
            .maximum(self.maximum),
            .value(self.value),
        ]
    }

    public func changeSet(for dimension: Dimension) -> [Dimension.Property] {
        var changeSet: [Dimension.Property] = []
        if self.minimum != dimension.minimum {
            changeSet.append(.minimum(dimension.minimum))
        }
        if self.maximum != dimension.maximum {
            changeSet.append(.maximum(dimension.maximum))
        }
        if self.value != dimension.value {
            changeSet.append(.value(dimension.value))
        }
        return changeSet
    }

}

// MARK: - Flex AutoPropertyDiffable
public extension Flex {

    public enum Property {

        case direction(FlexDirection)
        case grow(FlexValue)
        case shrink(FlexValue)
        case wrap(FlexWrap)
        case basis(UInt?)

    }

    public var fullChangeSet: [Flex.Property] {
        return [
            .direction(self.direction),
            .grow(self.grow),
            .shrink(self.shrink),
            .wrap(self.wrap),
            .basis(self.basis),
        ]
    }

    public func changeSet(for flex: Flex) -> [Flex.Property] {
        var changeSet: [Flex.Property] = []
        if self.direction != flex.direction {
            changeSet.append(.direction(flex.direction))
        }
        if self.grow != flex.grow {
            changeSet.append(.grow(flex.grow))
        }
        if self.shrink != flex.shrink {
            changeSet.append(.shrink(flex.shrink))
        }
        if self.wrap != flex.wrap {
            changeSet.append(.wrap(flex.wrap))
        }
        if self.basis != flex.basis {
            changeSet.append(.basis(flex.basis))
        }
        return changeSet
    }

}

// MARK: - LabelProperties AutoPropertyDiffable
public extension LabelProperties {

    public enum Property {

        case text(String)
        case textAfterLayout(String?)

    }

    public var fullChangeSet: [LabelProperties.Property] {
        return [
            .text(self.text),
            .textAfterLayout(self.textAfterLayout),
        ]
    }

    public func changeSet(for labelProperties: LabelProperties) -> [LabelProperties.Property] {
        var changeSet: [LabelProperties.Property] = []
        if self.text != labelProperties.text {
            changeSet.append(.text(labelProperties.text))
        }
        if self.textAfterLayout != labelProperties.textAfterLayout {
            changeSet.append(.textAfterLayout(labelProperties.textAfterLayout))
        }
        return changeSet
    }

}

// MARK: - LabelStyleSheet AutoPropertyDiffable
public extension LabelStyleSheet {

    public enum Property {

        case textColor(Color)
        case textFont(Font)
        case textSize(UInt)
        case textAligment(TextAligment)
        case adjustToFitWidth(Bool)
        case numberOfLines(UInt)
        case minimumScaleFactor(Float)

    }

    public var fullChangeSet: [LabelStyleSheet.Property] {
        return [
            .textColor(self.textColor),
            .textFont(self.textFont),
            .textSize(self.textSize),
            .textAligment(self.textAligment),
            .adjustToFitWidth(self.adjustToFitWidth),
            .numberOfLines(self.numberOfLines),
            .minimumScaleFactor(self.minimumScaleFactor),
        ]
    }

    public func changeSet(for labelStyleSheet: LabelStyleSheet) -> [LabelStyleSheet.Property] {
        var changeSet: [LabelStyleSheet.Property] = []
        if self.textColor != labelStyleSheet.textColor {
            changeSet.append(.textColor(labelStyleSheet.textColor))
        }
        if self.textFont != labelStyleSheet.textFont {
            changeSet.append(.textFont(labelStyleSheet.textFont))
        }
        if self.textSize != labelStyleSheet.textSize {
            changeSet.append(.textSize(labelStyleSheet.textSize))
        }
        if self.textAligment != labelStyleSheet.textAligment {
            changeSet.append(.textAligment(labelStyleSheet.textAligment))
        }
        if self.adjustToFitWidth != labelStyleSheet.adjustToFitWidth {
            changeSet.append(.adjustToFitWidth(labelStyleSheet.adjustToFitWidth))
        }
        if self.numberOfLines != labelStyleSheet.numberOfLines {
            changeSet.append(.numberOfLines(labelStyleSheet.numberOfLines))
        }
        if self.minimumScaleFactor != labelStyleSheet.minimumScaleFactor {
            changeSet.append(.minimumScaleFactor(labelStyleSheet.minimumScaleFactor))
        }
        return changeSet
    }

}

// MARK: - Layout AutoPropertyDiffable
public extension Layout {

    public enum Property {

        case flex([Flex.Property])
        case justifyContent(JustifyContent)
        case width([Dimension.Property]?)
        case height([Dimension.Property]?)
        case alignment([Alignment.Property])
        case position(Position)
        case margin(Margin?)
        case padding(Padding?)
        case border(Border?)
        case aspectRatio(AspectRatio?)
        case direction(Direction)

    }

    public var fullChangeSet: [Layout.Property] {
        return [
            .flex(self.flex.fullChangeSet),
            .justifyContent(self.justifyContent),
            .width(self.width?.fullChangeSet),
            .height(self.height?.fullChangeSet),
            .alignment(self.alignment.fullChangeSet),
            .position(self.position),
            .margin(self.margin),
            .padding(self.padding),
            .border(self.border),
            .aspectRatio(self.aspectRatio),
            .direction(self.direction),
        ]
    }

    public func changeSet(for layout: Layout) -> [Layout.Property] {
        var changeSet: [Layout.Property] = []
        let flexChangeSet = self.flex.changeSet(for: layout.flex)
        if !flexChangeSet.isEmpty {
            changeSet.append(.flex(flexChangeSet))
        }
        if self.justifyContent != layout.justifyContent {
            changeSet.append(.justifyContent(layout.justifyContent))
        }
        switch (self.width, layout.width) {
        case (.some(let old), .some(let new)):
            let widthChangeSet = old.changeSet(for: new)
            if !widthChangeSet.isEmpty {
                changeSet.append(.width(widthChangeSet))
            }
        case (.none, .some(let new)):
            changeSet.append(.width(new.fullChangeSet))
        case (.some(_), .none):
            changeSet.append(.width(.none))
        case (.none, .none):
            break
        }
        switch (self.height, layout.height) {
        case (.some(let old), .some(let new)):
            let heightChangeSet = old.changeSet(for: new)
            if !heightChangeSet.isEmpty {
                changeSet.append(.height(heightChangeSet))
            }
        case (.none, .some(let new)):
            changeSet.append(.height(new.fullChangeSet))
        case (.some(_), .none):
            changeSet.append(.height(.none))
        case (.none, .none):
            break
        }
        let alignmentChangeSet = self.alignment.changeSet(for: layout.alignment)
        if !alignmentChangeSet.isEmpty {
            changeSet.append(.alignment(alignmentChangeSet))
        }
        if self.position != layout.position {
            changeSet.append(.position(layout.position))
        }
        if self.margin != layout.margin {
            changeSet.append(.margin(layout.margin))
        }
        if self.padding != layout.padding {
            changeSet.append(.padding(layout.padding))
        }
        if self.border != layout.border {
            changeSet.append(.border(layout.border))
        }
        if self.aspectRatio != layout.aspectRatio {
            changeSet.append(.aspectRatio(layout.aspectRatio))
        }
        if self.direction != layout.direction {
            changeSet.append(.direction(layout.direction))
        }
        return changeSet
    }

}

// MARK: - MapProperties AutoPropertyDiffable
public extension MapProperties {

    public enum Property {

        case placemarks([MapPlacemark])
        case center(Coordinates?)
        case isZoomEnabled(Bool)
        case zoomLevel(Double)
        case isScrollEnabled(Bool)

    }

    public var fullChangeSet: [MapProperties.Property] {
        return [
            .placemarks(self.placemarks),
            .center(self.center),
            .isZoomEnabled(self.isZoomEnabled),
            .zoomLevel(self.zoomLevel),
            .isScrollEnabled(self.isScrollEnabled),
        ]
    }

    public func changeSet(for mapProperties: MapProperties) -> [MapProperties.Property] {
        var changeSet: [MapProperties.Property] = []
        if self.placemarks != mapProperties.placemarks {
            changeSet.append(.placemarks(mapProperties.placemarks))
        }
        if self.center != mapProperties.center {
            changeSet.append(.center(mapProperties.center))
        }
        if self.isZoomEnabled != mapProperties.isZoomEnabled {
            changeSet.append(.isZoomEnabled(mapProperties.isZoomEnabled))
        }
        if self.zoomLevel != mapProperties.zoomLevel {
            changeSet.append(.zoomLevel(mapProperties.zoomLevel))
        }
        if self.isScrollEnabled != mapProperties.isScrollEnabled {
            changeSet.append(.isScrollEnabled(mapProperties.isScrollEnabled))
        }
        return changeSet
    }

}

// MARK: - ProgressStyleSheet AutoPropertyDiffable
public extension ProgressStyleSheet {

    public enum Property {

        case progressStyle(ProgressContentType)
        case trackStyle(ProgressContentType)

    }

    public var fullChangeSet: [ProgressStyleSheet.Property] {
        return [
            .progressStyle(self.progressStyle),
            .trackStyle(self.trackStyle),
        ]
    }

    public func changeSet(for progressStyleSheet: ProgressStyleSheet) -> [ProgressStyleSheet.Property] {
        var changeSet: [ProgressStyleSheet.Property] = []
        if self.progressStyle != progressStyleSheet.progressStyle {
            changeSet.append(.progressStyle(progressStyleSheet.progressStyle))
        }
        if self.trackStyle != progressStyleSheet.trackStyle {
            changeSet.append(.trackStyle(progressStyleSheet.trackStyle))
        }
        return changeSet
    }

}

// MARK: - SegmentedStyleSheet AutoPropertyDiffable
public extension SegmentedStyleSheet {

    public enum Property {

        case textFont(Font)
        case textSize(UInt)
        case textColor(Color)
        case borderColor(Color)

    }

    public var fullChangeSet: [SegmentedStyleSheet.Property] {
        return [
            .textFont(self.textFont),
            .textSize(self.textSize),
            .textColor(self.textColor),
            .borderColor(self.borderColor),
        ]
    }

    public func changeSet(for segmentedStyleSheet: SegmentedStyleSheet) -> [SegmentedStyleSheet.Property] {
        var changeSet: [SegmentedStyleSheet.Property] = []
        if self.textFont != segmentedStyleSheet.textFont {
            changeSet.append(.textFont(segmentedStyleSheet.textFont))
        }
        if self.textSize != segmentedStyleSheet.textSize {
            changeSet.append(.textSize(segmentedStyleSheet.textSize))
        }
        if self.textColor != segmentedStyleSheet.textColor {
            changeSet.append(.textColor(segmentedStyleSheet.textColor))
        }
        if self.borderColor != segmentedStyleSheet.borderColor {
            changeSet.append(.borderColor(segmentedStyleSheet.borderColor))
        }
        return changeSet
    }

}

// MARK: - Shadow AutoPropertyDiffable
public extension Shadow {

    public enum Property {

        case color(Color)
        case opacity(Float)
        case offset(Offset)
        case radius(Float)
        case shouldRasterize(Bool)

    }

    public var fullChangeSet: [Shadow.Property] {
        return [
            .color(self.color),
            .opacity(self.opacity),
            .offset(self.offset),
            .radius(self.radius),
            .shouldRasterize(self.shouldRasterize),
        ]
    }

    public func changeSet(for shadow: Shadow) -> [Shadow.Property] {
        var changeSet: [Shadow.Property] = []
        if self.color != shadow.color {
            changeSet.append(.color(shadow.color))
        }
        if self.opacity != shadow.opacity {
            changeSet.append(.opacity(shadow.opacity))
        }
        if self.offset != shadow.offset {
            changeSet.append(.offset(shadow.offset))
        }
        if self.radius != shadow.radius {
            changeSet.append(.radius(shadow.radius))
        }
        if self.shouldRasterize != shadow.shouldRasterize {
            changeSet.append(.shouldRasterize(shadow.shouldRasterize))
        }
        return changeSet
    }

}

// MARK: - SpinnerStyleSheet AutoPropertyDiffable
public extension SpinnerStyleSheet {

    public enum Property {

        case color(Color)

    }

    public var fullChangeSet: [SpinnerStyleSheet.Property] {
        return [
            .color(self.color),
        ]
    }

    public func changeSet(for spinnerStyleSheet: SpinnerStyleSheet) -> [SpinnerStyleSheet.Property] {
        var changeSet: [SpinnerStyleSheet.Property] = []
        if self.color != spinnerStyleSheet.color {
            changeSet.append(.color(spinnerStyleSheet.color))
        }
        return changeSet
    }

}

// MARK: - TableProperties AutoPropertyDiffable
public extension TableProperties {

    public enum Property {

        case items([TableItemProperties<MessageType>])
        case showsVerticalScrollIndicator(Bool)
        case showsHorizontalScrollIndicator(Bool)
        case refresh(RefreshProperties<MessageType>?)

    }

    public var fullChangeSet: [TableProperties.Property] {
        return [
            .items(self.items),
            .showsVerticalScrollIndicator(self.showsVerticalScrollIndicator),
            .showsHorizontalScrollIndicator(self.showsHorizontalScrollIndicator),
            .refresh(self.refresh),
        ]
    }

    public func changeSet(for tableProperties: TableProperties) -> [TableProperties.Property] {
        var changeSet: [TableProperties.Property] = []
        changeSet.append(.items(tableProperties.items))
        if self.showsVerticalScrollIndicator != tableProperties.showsVerticalScrollIndicator {
            changeSet.append(.showsVerticalScrollIndicator(tableProperties.showsVerticalScrollIndicator))
        }
        if self.showsHorizontalScrollIndicator != tableProperties.showsHorizontalScrollIndicator {
            changeSet.append(.showsHorizontalScrollIndicator(tableProperties.showsHorizontalScrollIndicator))
        }
        changeSet.append(.refresh(tableProperties.refresh))
        return changeSet
    }

}

// MARK: - TableStyleSheet AutoPropertyDiffable
public extension TableStyleSheet {

    public enum Property {

        case separatorColor(Color)
        case refreshTintColor(Color)

    }

    public var fullChangeSet: [TableStyleSheet.Property] {
        return [
            .separatorColor(self.separatorColor),
            .refreshTintColor(self.refreshTintColor),
        ]
    }

    public func changeSet(for tableStyleSheet: TableStyleSheet) -> [TableStyleSheet.Property] {
        var changeSet: [TableStyleSheet.Property] = []
        if self.separatorColor != tableStyleSheet.separatorColor {
            changeSet.append(.separatorColor(tableStyleSheet.separatorColor))
        }
        if self.refreshTintColor != tableStyleSheet.refreshTintColor {
            changeSet.append(.refreshTintColor(tableStyleSheet.refreshTintColor))
        }
        return changeSet
    }

}

// MARK: - TextFieldProperties AutoPropertyDiffable
public extension TextFieldProperties {

    public enum Property {

        case text(String?)
        case placeholder(String?)
        case isSecureTextEntry(Bool)
        case shouldReturn(Bool)
        case onEvents(TextFieldEvents<MessageType>)

    }

    public var fullChangeSet: [TextFieldProperties.Property] {
        return [
            .text(self.text),
            .placeholder(self.placeholder),
            .isSecureTextEntry(self.isSecureTextEntry),
            .shouldReturn(self.shouldReturn),
            .onEvents(self.onEvents),
        ]
    }

    public func changeSet(for textFieldProperties: TextFieldProperties) -> [TextFieldProperties.Property] {
        var changeSet: [TextFieldProperties.Property] = []
        if self.text != textFieldProperties.text {
            changeSet.append(.text(textFieldProperties.text))
        }
        if self.placeholder != textFieldProperties.placeholder {
            changeSet.append(.placeholder(textFieldProperties.placeholder))
        }
        if self.isSecureTextEntry != textFieldProperties.isSecureTextEntry {
            changeSet.append(.isSecureTextEntry(textFieldProperties.isSecureTextEntry))
        }
        if self.shouldReturn != textFieldProperties.shouldReturn {
            changeSet.append(.shouldReturn(textFieldProperties.shouldReturn))
        }
        changeSet.append(.onEvents(textFieldProperties.onEvents))
        return changeSet
    }

}

// MARK: - TextFieldStyleSheet AutoPropertyDiffable
public extension TextFieldStyleSheet {

    public enum Property {

        case textColor(Color)
        case textFont(Font)
        case textSize(UInt)
        case textAligment(TextAligment)

    }

    public var fullChangeSet: [TextFieldStyleSheet.Property] {
        return [
            .textColor(self.textColor),
            .textFont(self.textFont),
            .textSize(self.textSize),
            .textAligment(self.textAligment),
        ]
    }

    public func changeSet(for textFieldStyleSheet: TextFieldStyleSheet) -> [TextFieldStyleSheet.Property] {
        var changeSet: [TextFieldStyleSheet.Property] = []
        if self.textColor != textFieldStyleSheet.textColor {
            changeSet.append(.textColor(textFieldStyleSheet.textColor))
        }
        if self.textFont != textFieldStyleSheet.textFont {
            changeSet.append(.textFont(textFieldStyleSheet.textFont))
        }
        if self.textSize != textFieldStyleSheet.textSize {
            changeSet.append(.textSize(textFieldStyleSheet.textSize))
        }
        if self.textAligment != textFieldStyleSheet.textAligment {
            changeSet.append(.textAligment(textFieldStyleSheet.textAligment))
        }
        return changeSet
    }

}

// MARK: - TextViewStyleSheet AutoPropertyDiffable
public extension TextViewStyleSheet {

    public enum Property {

        case textColor(Color)
        case textFont(Font)
        case textSize(UInt)
        case textAligment(TextAligment)

    }

    public var fullChangeSet: [TextViewStyleSheet.Property] {
        return [
            .textColor(self.textColor),
            .textFont(self.textFont),
            .textSize(self.textSize),
            .textAligment(self.textAligment),
        ]
    }

    public func changeSet(for textViewStyleSheet: TextViewStyleSheet) -> [TextViewStyleSheet.Property] {
        var changeSet: [TextViewStyleSheet.Property] = []
        if self.textColor != textViewStyleSheet.textColor {
            changeSet.append(.textColor(textViewStyleSheet.textColor))
        }
        if self.textFont != textViewStyleSheet.textFont {
            changeSet.append(.textFont(textViewStyleSheet.textFont))
        }
        if self.textSize != textViewStyleSheet.textSize {
            changeSet.append(.textSize(textViewStyleSheet.textSize))
        }
        if self.textAligment != textViewStyleSheet.textAligment {
            changeSet.append(.textAligment(textViewStyleSheet.textAligment))
        }
        return changeSet
    }

}

// MARK: - ToggleProperties AutoPropertyDiffable
public extension ToggleProperties {

    public enum Property {

        case isOn(Bool)
        case isActive(Bool)
        case isEnabled(Bool)
        case onSwitch((Bool) -> MessageType?)

    }

    public var fullChangeSet: [ToggleProperties.Property] {
        return [
            .isOn(self.isOn),
            .isActive(self.isActive),
            .isEnabled(self.isEnabled),
            .onSwitch(self.onSwitch),
        ]
    }

    public func changeSet(for toggleProperties: ToggleProperties) -> [ToggleProperties.Property] {
        var changeSet: [ToggleProperties.Property] = []
        if self.isOn != toggleProperties.isOn {
            changeSet.append(.isOn(toggleProperties.isOn))
        }
        if self.isActive != toggleProperties.isActive {
            changeSet.append(.isActive(toggleProperties.isActive))
        }
        if self.isEnabled != toggleProperties.isEnabled {
            changeSet.append(.isEnabled(toggleProperties.isEnabled))
        }
        changeSet.append(.onSwitch(toggleProperties.onSwitch))
        return changeSet
    }

}

// MARK: - ToggleStyleSheet AutoPropertyDiffable
public extension ToggleStyleSheet {

    public enum Property {

        case onTintColor(Color?)
        case tintChangingColor(Color?)
        case thumbTintColor(Color?)

    }

    public var fullChangeSet: [ToggleStyleSheet.Property] {
        return [
            .onTintColor(self.onTintColor),
            .tintChangingColor(self.tintChangingColor),
            .thumbTintColor(self.thumbTintColor),
        ]
    }

    public func changeSet(for toggleStyleSheet: ToggleStyleSheet) -> [ToggleStyleSheet.Property] {
        var changeSet: [ToggleStyleSheet.Property] = []
        if self.onTintColor != toggleStyleSheet.onTintColor {
            changeSet.append(.onTintColor(toggleStyleSheet.onTintColor))
        }
        if self.tintChangingColor != toggleStyleSheet.tintChangingColor {
            changeSet.append(.tintChangingColor(toggleStyleSheet.tintChangingColor))
        }
        if self.thumbTintColor != toggleStyleSheet.thumbTintColor {
            changeSet.append(.thumbTintColor(toggleStyleSheet.thumbTintColor))
        }
        return changeSet
    }

}

