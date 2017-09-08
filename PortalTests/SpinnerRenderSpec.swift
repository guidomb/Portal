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
                    isActive: true,
                    style: style,
                    layout: layout()
                )
            }
        
            context("when the change set contains spinner property changes") {
                
                it("applies 'isActive' property changes") {
                    let spinner = UIActivityIndicatorView()
                    let _: Render<String> = spinner.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(spinner.isAnimating).to(beTrue())
                }
                
                context("when the `isActive` is already configured") {
                    
                    var configuredSpinner: UIActivityIndicatorView!
                    
                    beforeEach {
                        configuredSpinner = UIActivityIndicatorView()
                        let _: Render<String> = configuredSpinner.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    }
                    
                    it("replaces the previous value") {
                        let newChangeSet = SpinnerChangeSet(isActive: .change(to: false))
                        let _: Render<String> = configuredSpinner.apply(changeSet: newChangeSet, layoutEngine: layoutEngine)
                        
                        expect(configuredSpinner.isAnimating).to(beFalse())
                    }
                    
                }
                
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
