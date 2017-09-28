//
//  ImageViewRenderer.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func apply<MessageType>(changeSet: ImageViewChangeSet, layoutEngine: LayoutEngine) -> Render<MessageType> {
        apply(image: changeSet.image)
        apply(changeSet: changeSet.baseStyleSheet)
        layoutEngine.apply(changeSet: changeSet.layout, to: self)
                
        return Render(view: self, mailbox: getMailbox(), executeAfterLayout: .none)
    }
    
}

extension Image {
    
    var asUIImage: UIImage? {
        switch self {
            
        case .localImage(let imageName):
            return UIImage(named: imageName, in: .main, compatibleWith: .none)
            
        case .blob(let imageData, _):
            return UIImage(data: imageData)
            
        }
    }
    
    // Whenever possible image loading should be done off the main thread
    // because in performance sensitive scenarios loading an image could
    // cause frame drops.
    //
    // Large images compressed using a image format like JPG, need to
    // decompressed and transformed into bitmaps in order to be displayed
    // inside a UIImageView. Loading possible large images inside a table
    // view could make scrolling slugish.
    //
    // - Parameter onLoad Callback function that will get called on the
    // main thread with the loaded image and the hash value returned
    // by loadUImage
    // - Returns a hash value that identifies the image to be loaded
    // which can be used to decided wether to actually display the
    // image after it has been loaded. One would want to avoid
    // displaying images that are no longer valid due to UI being
    // updated.
    func loadUIImage(_ onLoad: @escaping (UIImage?, Int) -> Void) -> Int {
        switch self {
            
        case .localImage(let imageName):
            let hashValue = imageName.hashValue
            imageProcessingQueue.async {
                let image = UIImage(named: imageName, in: .main, compatibleWith: .none)
                DispatchQueue.main.async { onLoad(image, hashValue) }
            }
            return hashValue
            
        case .blob(let imageData, _):
            let hashValue = imageData.hashValue
            imageProcessingQueue.async {
                let image = UIImage(data: imageData)
                DispatchQueue.main.async { onLoad(image, hashValue) }
            }
            return hashValue
            
        }
    }
    
}

extension UIImageView {
    
    func load(image: Image) {
        self.tag = image.loadUIImage { loadedImage, hash in
            guard self.tag == hash else { return }
            self.tag = 0
            self.image = loadedImage
        }
    }
    
}

fileprivate let imageProcessingQueue = DispatchQueue(
    label: "com.guidomb.Portal.ImageProcessingQueue",
    qos: .utility,
    attributes: .concurrent
)

fileprivate extension UIImageView {
    
    fileprivate func apply(image: PropertyChange<Image?>) {
        guard case .change(let value) = image else { return }
        
        switch value {
        case .some(let image):
            self.load(image: image)
            
        case .none:
            self.image = .none
        }
    }
    
}
