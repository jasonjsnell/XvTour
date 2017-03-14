//
//  TourViewController.swift
//  Refraktions
//
//  Created by Jason Snell on 11/14/16.
//  Copyright © 2016 Jason J. Snell. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass
import XvUtils

public class XvTourViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //panel that contains rectangle and text
    fileprivate var panel:Panel = Panel()
    
    //screen vars
    fileprivate var currScreenNum:Int = 0
    fileprivate var currScreenData:XvTourDataObj = XvTourDataObj()
    
    //timer
    fileprivate var requiredDelayTimer:Timer = Timer()
    fileprivate var maxTimePerScreenTimer:Timer = Timer()
    fileprivate var hasMaxTimePerScreenPassed:Bool = false
    
    //vars to track user
    fileprivate var hasUserCompletedRequiredAction:Bool = false
    fileprivate var hasRequiredDelayPassed:Bool = false
    fileprivate var numberOfUserTaps:Int = 0
    fileprivate var lastScreenNum:Int = 0
   
    
    
    fileprivate let debug:Bool = false
    
    //MARK:-
    //MARK:INIT
    
    public func setup(firstScreenData:XvTourDataObj, lastScreenNum:Int){
        
        if (debug){ print("TOUR: Init") }
        
        //record vars
        self.lastScreenNum = lastScreenNum
        
        //take up entire screen
        view.frame = CGRect(
            x: 0, y: 0,
            width: XvUtils.Screen.width(),
            height: XvUtils.Screen.max())
        
        //add panel
        panel.view.frame = CGRect(
            x:(XvUtils.Screen.width() / 2),
            y: (XvUtils.Screen.height() / 2),
            width: XvUtils.Screen.width(),
            height: XvUtils.Screen.height())
        
        view.addSubview(panel.view)
        
        
        //show first screen
        showScreen(withScreenData: firstScreenData)
        
    }
    
    public func shutdown(){
        
        maxTimePerScreenTimer.invalidate()
        requiredDelayTimer.invalidate()
        
        for recognizer in view.gestureRecognizers ?? [] {
            view.removeGestureRecognizer(recognizer)
        }
        
    }
    
    public func getCurrScreenNum() -> Int {
        return currScreenNum
    }
    
        
    //MARK: -
    //MARK:SCREENS
    
    fileprivate func attemptToMoveToNextScreen(){
        
        //if all reqs are satisfied
        if ((hasRequiredDelayPassed &&
            numberOfUserTaps >= currScreenData.requiredNumberOfTaps &&
            hasUserCompletedRequiredAction) || hasMaxTimePerScreenPassed){
            
            //then reset all vars
            hasRequiredDelayPassed = false
            numberOfUserTaps = 0
            hasUserCompletedRequiredAction = false
            hasMaxTimePerScreenPassed = false
            maxTimePerScreenTimer.invalidate()
            requiredDelayTimer.invalidate()
            
            //if screen num is last in sequence, end tour
            if (currScreenNum >= lastScreenNum){
                
                Utils.postNotification(name: XvTourConstants.kTourComplete, userInfo: nil)
                
                //else move to next screen
            } else {
                
                //advance screen number
                currScreenNum += 1
                
                //show
                Utils.postNotification(name: XvTourConstants.kTourScreenComplete, userInfo: nil)
                
                if (debug){
                    print("TOUR: Move to screen", currScreenNum)
                }
                
            }
            
        }
        
    }
    
    
    public func showScreen(withScreenData:XvTourDataObj){
        
        //DATA
        currScreenData = withScreenData
        
        //TIMERS
        //reset time req if delay is over 0
        if (currScreenData.requiredDelay > 0){
            
            hasRequiredDelayPassed = false
            startTimer(withRequiredDelay: currScreenData.requiredDelay)
            
        } else {
            
            hasRequiredDelayPassed = true
            
        }
        
        //reset action req if not none
        if (currScreenData.requiredUserAction != XvTourConstants.ACTION_NONE){
            
            hasUserCompletedRequiredAction = false
            
        } else {
            
            hasUserCompletedRequiredAction = true
            
        }
        
        //max timer
        startTimer(withMaxTime: currScreenData.maxTime)
        
        //redraw panel to current screen vars
        reorient()
        
        //perform the selector associated with this data obj
        //this shows the next step in the interface reveal
        perform(currScreenData.selector)
        
    }

    
    //MARK: -
    //MARK:TIMERS
    
    fileprivate func startTimer(withRequiredDelay:Double){
        requiredDelayTimer = Timer.scheduledTimer(
            timeInterval: withRequiredDelay,
            target: self,
            selector: #selector(requiredDelayPassed),
            userInfo: nil,
            repeats: false)
    }
    
    internal func requiredDelayPassed(){
        if (debug){
            print("TOUR: Required delay has passed")
        }
        
        hasRequiredDelayPassed = true
        attemptToMoveToNextScreen()
    }
    
    fileprivate func startTimer(withMaxTime:Double){
        maxTimePerScreenTimer = Timer.scheduledTimer(
            timeInterval: withMaxTime,
            target: self,
            selector: #selector(maxTimePerScreenPassed),
            userInfo: nil,
            repeats: false)
    }
    
    internal func maxTimePerScreenPassed(){
        if (debug){
            print("TOUR: Max timer per screen passed")
        }
        hasMaxTimePerScreenPassed = true
        attemptToMoveToNextScreen()
    }

    
    //MARK: -
    //MARK:USER INPUT ROUTING
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       //pass touches along to user input
        Utils.postNotification(
            name: XvTourConstants.kTourTouchesBegan,
            userInfo: ["touches" : touches, "event" : event!])
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //pass touches along to user input
        Utils.postNotification(
            name: XvTourConstants.kTourTouchesMoved,
            userInfo: ["touches" : touches, "event" : event!])
        
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //up number of taps
        numberOfUserTaps += 1
        
        if (currScreenData.requiredUserAction == XvTourConstants.ACTION_TAP){
            hasUserCompletedRequiredAction = true
        }
        
        attemptToMoveToNextScreen()
        
        //pass touches along to user input
        Utils.postNotification(
            name: XvTourConstants.kTourTouchesEnded,
            userInfo: ["touches" : touches, "event" : event!])
    
    }
    
    public func panDetected(recognizer:UIPanGestureRecognizer){
        
        //custom pan just for the tour
        
        let location:CGPoint = recognizer.location(in: self.view)
        
        if (recognizer.state == .changed){
            
            Utils.postNotification(
                name: XvTourConstants.kTourPanDetected,
                userInfo: ["yPosition" : location.y])
            
        } else if(recognizer.state == UIGestureRecognizerState.ended){
            
            //do this when it ends
            if (currScreenData.requiredUserAction == XvTourConstants.ACTION_PAN){
                hasUserCompletedRequiredAction = true
                attemptToMoveToNextScreen()
            }

        }
        
    }
    
    //MARK:- ORIENTATION
    public func reorient(){
        
        //show panel with data, returns new panel size
        if let newPanelSize:CGSize = panel.showWith(data: currScreenData) {
            
            var xVariant:CGFloat = 2 //default is center
            var yVariant:CGFloat = 2
            
            //position panel based data value
            if (currScreenData.position == XvTourConstants.POSITION_BOTTOM){
                if (XvUtils.Screen.orientation() == XvUtils.Screen.ORIENTATION_LANDSCAPE){
                    xVariant = 4 //left
                } else {
                    yVariant = 1.25 //bottom
                }
                
            }
            
            //create new rect
            let newPanelRect:CGRect = CGRect(
                x:(XvUtils.Screen.width() / xVariant) - (newPanelSize.width/2),
                y: (XvUtils.Screen.height() / yVariant) - (newPanelSize.height/2),
                width: XvUtils.Screen.width(),
                height: XvUtils.Screen.height())
            
            //animate the transition
            XvUtils.Anim.redraw(target: panel.view, toRect: newPanelRect, afterDelay: 0.0)
        }
        
        
    }
    
   
    
}
