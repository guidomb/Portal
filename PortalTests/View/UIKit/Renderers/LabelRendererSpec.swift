//
//  LabelRendererSpec.swift
//  PortalTests
//
//  Created by Pablo Giorgi on 8/28/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Quick
import Nimble
@testable import Portal

class LabelRendererSpec: QuickSpec {
    override func spec() {

        var layoutEngine: LayoutEngine!

        beforeEach {
            layoutEngine = YogaLayoutEngine()
        }

        describe(".apply(changeSet: TextFieldChangeSet) -> Result") {

            var changeSet: LabelChangeSet!

            beforeEach {

                let labelProperties: LabelProperties = properties(
                    text: "Hello World before layout",
                    textAfterLayout: "Hello World"
                )

                let labelStyle = labelStyleSheet { base, label in
                    label.textColor = .red
                    label.textFont = Font(name: "Helvetica")
                    label.textSize = 12
                    label.textAligment = .center
                    label.adjustToFitWidth = true
                    label.numberOfLines = 0
                    label.minimumScaleFactor = 1.0
                }

                changeSet = LabelChangeSet.fullChangeSet(
                    properties: labelProperties,
                    styleSheet: labelStyle,
                    layout: layout()
                )
                
            }

            context("when the change set contains label property changes") {

                it("applies 'text' property changes") {
                    let label = UILabel()
                    let _: Render<String> = label.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        expect(label.text).to(equal("Hello World"))
                    }
                }

                context("when the change set contains label stylesheet changes") {

                    it("applies 'textColor' property changes") {
                        let label = UILabel()
                        let _: Render<String> = label.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                        expect(label.textColor).to(equal(.red))
                    }

                    it("applies 'aligment' property changes") {
                        let label = UILabel()
                        let _: Render<String> = label.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                        expect(label.textAlignment).to(equal(NSTextAlignment.center))
                    }

                    it("applies 'textFont' and 'textSize' property changes") {
                        let label = UILabel()
                        let _: Render<String> = label.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                        expect(label.font).to(equal(UIFont(name: "Helvetica", size: 12)))
                    }

                    it("applies 'adjustToFitWidth' property changes") {
                        let label = UILabel()
                        let _: Render<String> = label.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                        expect(label.adjustsFontSizeToFitWidth).to(equal(true))
                    }
                    
                    it("applies 'numberOfLines' property changes") {
                        let label = UILabel()
                        let _: Render<String> = label.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                        expect(label.numberOfLines).to(equal(0))
                    }
                    
                    it("applies 'minimumScaleFactor' property changes") {
                        let label = UILabel()
                        let _: Render<String> = label.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                        expect(label.minimumScaleFactor).to(equal(1.0))
                    }
                    
                }

            }

        }

    }
}
