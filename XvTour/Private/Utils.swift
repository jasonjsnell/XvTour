//
//  TourUtils.swift
//  Refraktions
//
//  Created by Jason Snell on 3/13/17.
//  Copyright © 2017 Jason J. Snell. All rights reserved.
//

import Foundation
import UIKit

class Utils {
    
    //MARK: NOTIFICATIONS
    public class func postNotification(name:String, userInfo:[AnyHashable : Any]?){
        
        let notification:Notification.Name = Notification.Name(rawValue: name)
        NotificationCenter.default.post(
            name: notification,
            object: nil,
            userInfo: userInfo)
    }

}
