//
//  SpinnerRenderSpec.swift
//  PortalTests
//
//  Created by Argentino Ducret on 9/5/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Quick
import Nimble
@testable import Portal

class SpinnerRenderSpec: QuickSpec {
    override func spec() {
        
        var layoutEngine: LayoutEngine!
        
        beforeEach {
            layoutEngine = YogaLayoutEngine()
        }
        
        describe(".apply(changeSet: SpinnerChangeSet) -> Result") {
            
            var changeSet: SpinnerChangeSet!
            
            let style = spinnerStyleSheet { base, spinner in
                spinner.color = .red
            }
            
            beforeEach {
                changeSet = SpinnerChangeSet.fullChangeSet(
                    style: style,
                    layout: layout()
                )
            }
        
            it("makes the spinner spin") {
                let spinner = UIActivityIndicatorView()
                let _: Render<String> = spinner.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                expect(spinner.isAnimating).to(beTrue())
            }
            
            context("when the change set contains spinner stylesheet changes") {
                
                it("applies 'textColor' property changes") {
                    let spinner = UIActivityIndicatorView()
                    let _: Render<String> = spinner.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(spinner.color).to(equal(.red))
                }
                
            }
            
        }
        
    }
}
