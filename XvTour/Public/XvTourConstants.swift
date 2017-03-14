//
//  TourConstants.swift
//  Refraktions
//
//  Created by Jason Snell on 3/13/17.
//  Copyright © 2017 Jason J. Snell. All rights reserved.
//

import Foundation

public class XvTourConstants {
    
    //MARK: NOTIFICATIONS
    //tour
    public static let kTourComplete:String = "kTourComplete"
    public static let kTourScreenComplete:String = "kTourScreenComplete"
    
    //user input
    public static let kTourTouchesBegan:String = "kTourTouchesBegan"
    public static let kTourTouchesMoved:String = "kTourTouchesMoved"
    public static let kTourTouchesEnded:String = "kTourTouchesEnded"
    public static let kTourPanDetected:String = "kTourPanDetected"
    
    //MARK: REQ USER ACTIONS
    public static let ACTION_NONE:String = "actionNone"
    public static let ACTION_TAP:String = "actionTap"
    public static let ACTION_PAN:String = "actionPan"
    public static let ACTION_CIRCLE:String = "actionCircle"
    
    //MARK: POSITION
    public static let POSITION_CENTER:String = "posCenter"
    public static let POSITION_BOTTOM:String = "posBottom"
    
}
