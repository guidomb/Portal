//
//  ImageViewRenderSpec.swift
//  PortalTests
//
//  Created by Argentino Ducret on 8/29/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Quick
import Nimble
@testable import Portal

class ImageViewRendererSpec: QuickSpec {
    override func spec() {

        var layoutEngine: LayoutEngine!
        
        beforeEach {
            layoutEngine = YogaLayoutEngine()
        }
        
        describe(".apply(changeSet: ImageViewChangeSet) -> Result") {
            
            var changeSet: ImageViewChangeSet!
            var image: Image!
            
            beforeEach {
                image = Image.loadImage(named: "search.png", from: Bundle(for: ImageViewRendererSpec.self))!
                changeSet = ImageViewChangeSet.fullChangeSet(image: image, style: styleSheet(), layout: layout())
            }
            
            context("when the change set contains image changes") {
                
                it("applies 'image' changes") {
                    let imageView = UIImageView()
                    let _: Render<String> = imageView.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(imageView.image).to(equal(image.asUIImage))
                }
                
                context("when there are optional properties set to .none") {
                
                    var configuredImageView: UIImageView!
                    
                    beforeEach {
                        configuredImageView = UIImageView()
                        let _: Render<String> = configuredImageView.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    }
                    
                    it("removes the image property") {
                        let newChangeSet = ImageViewChangeSet(image: .change(to: .none))
                        let _: Render<String> = configuredImageView.apply(changeSet: newChangeSet, layoutEngine: layoutEngine)
                        expect(configuredImageView.image).to(beNil())
                    }
                
                }
                
            }
            
        }
        
    }
}
