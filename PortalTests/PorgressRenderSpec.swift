//
//  PorgressRenderSpec.swift
//  PortalTests
//
//  Created by Argentino Ducret on 9/1/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Quick
import Nimble
@testable import Portal

class ProgressRenderSpec: QuickSpec {
    override func spec() {
        
        var layoutEngine: LayoutEngine!
        
        beforeEach {
            layoutEngine = YogaLayoutEngine()
        }
        
        describe(".apply(changeSet: ProgressChangeSet) -> Result") {
            
            var changeSet: ProgressChangeSet!
            
            beforeEach {
                let progressCounter = ProgressCounter(partial: 5, total: 10)!
                
                let progressStyle = progressStyleSheet { base, progress in
                    progress.progressStyle = .color(.red)
                    progress.trackStyle = .image(Image.loadImage(named: "search.png", from: Bundle(for: ButtonRendererSpec.self))!)
                }
                
                changeSet = ProgressChangeSet.fullChangeSet(
                    progress: progressCounter,
                    style: progressStyle,
                    layout: layout()
                )
            }
            
            context("when the change set contains progress counter property changes") {
                
                it("applies 'progress' property changes") {
                    let progress = UIProgressView()
                    let _: Render<String> = progress.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(progress.progress).to(equal(0.5))
                }
                
            }
            
            context("when the change set contains progress stylesheet changes") {
                
                it("applies 'trackStyle' property changes") {
                    let progress = UIProgressView()
                    let _: Render<String> = progress.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(progress.trackImage).to(equal(Image.loadImage(named: "search.png", from: Bundle(for: ButtonRendererSpec.self))!.asUIImage))
                }
                
                it("applies 'progressStyle' and 'textSize' property changes") {
                    let progress = UIProgressView()
                    let _: Render<String> = progress.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(progress.progressTintColor).to(equal(.red))
                }
                
            }
            
        }
        
    }
}
