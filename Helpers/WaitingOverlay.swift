//
//  WaitingOverlay.swift
//  POS
//
//  Created by Gal Blank on 12/14/15.
//  Copyright © 2015 1stPayGateway. All rights reserved.
//

import Foundation
import UIKit

class WaitingOverlay:UIView  {
    
    var  caption:String = ""
    var isCurrentlyActive:Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        self.alpha = 0.7
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10.0
        let activityWheel: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityWheel.center = self.center
        activityWheel.style = .white
        activityWheel.startAnimating()
        self.addSubview(activityWheel)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
    }
    
    override func draw(_ rect: CGRect) {
        let labelCaption: UILabel = UILabel(frame: CGRect(x: 5, y: self.frame.size.height / 2, width: self.frame.size.width - 5, height: 60))
        // /*CGRectMake(0, 500, 768,100)*/
        labelCaption.text = caption
        labelCaption.layer.cornerRadius = 10.0
        labelCaption.textColor = UIColor.white
        labelCaption.font = UIFont.systemFont(ofSize: 14)
        labelCaption.backgroundColor = UIColor.clear
        labelCaption.numberOfLines = 0
        labelCaption.textAlignment = .center
        self.addSubview(labelCaption)
    }
    
}
