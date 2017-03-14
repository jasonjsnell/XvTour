//
//  TourDataObj.swift
//  Refraktions
//
//  Created by Jason Snell on 3/13/17.
//  Copyright © 2017 Jason J. Snell. All rights reserved.
//

import Foundation

public class XvTourDataObj {
    
    public var title:String = ""
    public var desc:String = ""
    public var position:String = "posCenter"
    public var requiredUserAction:String = "actionTap"
    public var requiredDelay:Double = 2.5
    public var maxTime:Double = 25.0
    public var requiredNumberOfTaps:Int = 1
    public var selector:Selector?
    
    public init(){}
    
}
