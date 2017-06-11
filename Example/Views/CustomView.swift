//
//  CustomView.swift
//  Portal
//
//  Created by Guido Marucci Blas on 5/12/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

final class CustomView: UIView {
    
    @IBOutlet weak var redView: UIView!
    @IBOutlet weak var blueView: UIView!
    @IBOutlet weak var greenView: UIView!
    
    var onTap: (() -> Void)? = .none
    
    override func awakeFromNib() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        redView.addGestureRecognizer(gestureRecognizer)
    }
    
    func tapped() {
        onTap?()
    }
    
}
