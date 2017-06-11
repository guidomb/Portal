//
//  CustomController.swift
//  PortalExample
//
//  Created by Guido Marucci Blas on 6/10/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

final class CustomController: UIViewController {
    
    private let frame: CGRect
    private var _onTap: () -> Void
    
    var onTap: () -> Void {
        set {
            self._onTap = newValue
            (self.view as? CustomView)?.onTap = newValue
        }
        get {
            return _onTap
        }
    }
    
    init(frame: CGRect, onTap: @escaping () -> Void) {
        self.frame = frame
        self._onTap = onTap
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let bundle = Bundle.main.loadNibNamed("CustomView", owner: nil, options: nil)
        if let customView = bundle?.last as? CustomView {
            customView.onTap = self.onTap
            customView.frame = self.frame
            self.view = customView
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Custom controller will appear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Custom controller did appear")
    }
    
    deinit {
        print("Killing custom controller")
    }
    
}
