//
//  TextFieldRenderer.swift
//  PortalView
//
//  Created by Juan Franco Caracciolo on 4/10/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public let defaultTextFieldFontSize = UInt(UIFont.systemFontSize)

extension UITextField: MessageProducer {

    internal func apply<MessageType>(
        changeSet: TextFieldChangeSet<MessageType>,
        layoutEngine: LayoutEngine) -> Render<MessageType> {

        apply(changeSet: changeSet.properties)
        apply(changeSet: changeSet.baseStyleSheet)
        apply(changeSet: changeSet.textFieldStyleSheet)
        layoutEngine.apply(changeSet: changeSet.layout, to: self)

        return Render(view: self, mailbox: getMailbox(), executeAfterLayout: .none)
    }

}

fileprivate extension UITextField {

    fileprivate func apply<MessageType>(changeSet: [TextFieldProperties<MessageType>.Property]) {
        for property in changeSet {
            switch property {

            case .text(let text):
                self.text = text

            case .placeholder(let placeholder):
                self.placeholder = placeholder

            case .isSecureTextEntry(let isSecureTextEntry):
                self.isSecureTextEntry = isSecureTextEntry

            case .shouldReturn(let shouldReturn):
                if shouldReturn {
                    self.delegate = self
                } else {
                    self.delegate = .none
                }

            case .onEvents(let events):
                apply(events: events)
            }
        }
    }

    fileprivate func apply<MessageType>(events: TextFieldEvents<MessageType>) {
        for (event, maybeMessageMapper) in events.getMessageMappersByEvent() {
            if let messageMapper = maybeMessageMapper {
                _ = self.on(event: event) { sender -> MessageType? in
                    guard let textField = sender as? UITextField else { return .none }
                    return textField.text.flatMap(messageMapper)
                }
            } else {
                let _: MessageDispatcher<MessageType>? = self.stopDispatchingMessages(for: event)
            }
        }
    }

    fileprivate func apply(changeSet: [TextFieldStyleSheet.Property]) {
        for property in changeSet {
            switch property {

            case .textAlignment(let alignment):
                self.textAlignment = alignment.asNSTextAlignment

            case .textColor(let color):
                self.textColor = color.asUIColor

            case .textFont(let font):
                let fontSize = self.font?.pointSize ?? CGFloat(defaultTextFieldFontSize)
                self.font = font.uiFont(withSize: fontSize)

            case .textSize(let textSize):
                let fontName = self.font?.fontName
                fontName |> { self.font = UIFont(name: $0, size: CGFloat(textSize)) }
            }
        }
    }

}

extension TextFieldEvents {

    fileprivate func getMessageMappersByEvent() -> [(UIControl.Event, ((String) -> MessageType)?)] {
        return [
            (.editingDidBegin, onEditingBegin),
            (.editingChanged, onEditingChanged),
            (.editingDidEnd, onEditingEnd)
        ]
    }

}

extension UITextField: UITextFieldDelegate {

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }

}
