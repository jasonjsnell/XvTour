//
//  TourPanelViewController.swift
//  Refraktions
//
//  Created by Jason Snell on 11/14/16.
//  Copyright © 2016 Jason J. Snell. All rights reserved.
//

import UIKit
import XvUtils

class Panel: UIViewController {
    
    //labels
    fileprivate var titleLabel:UILabel?
    fileprivate var descLabel:UILabel?
    fileprivate var areLabelsValid:Bool = false
    
    //font size
    fileprivate let TITLE_FONT_SIZE:CGFloat = 18
    fileprivate let DESC_FONT_SIZE:CGFloat = 15
    
    //font name
    fileprivate let TITLE_FONT_NAME:String = XvUtils.Text.HELV_BOLD
    fileprivate let DESC_FONT_NAME:String = XvUtils.Text.HELV_REGULAR
    
    //font margins
    fileprivate let TITLE_MARGIN_TOP:CGFloat = 24
    fileprivate let DESC_MARGIN_TOP:CGFloat = 53
    fileprivate let TEXT_MARGIN_SIDES:CGFloat = 28
    fileprivate let TEXT_MARGIN_BOTTOM:CGFloat = 40
    
    //bg pane
    fileprivate var bg:UIImageView = UIImageView()
    fileprivate var bgWidth:CGFloat = 0
    fileprivate let BG_WIDTH_MAX:CGFloat = 325
    fileprivate let BG_SIDE_MARGIN:CGFloat = 90
    internal let BG_STARTING_WIDTH:CGFloat = 300
    internal let BG_STARTING_HEIGHT:CGFloat = 150
    
    //MARK:-
    //MARK:INIT
    
    override func viewDidLoad() {
    
        self.view.isUserInteractionEnabled = false
        initBg()
        initLabels()
    
    }
    
    //MARK:-
    //MARK:SHOW
    internal func showWith(data:XvTourDataObj) -> CGSize? {
        
        if (!areLabelsValid){
            print("TOUR PANEL: Text labels are nil")
            return nil
        }
        
        //hide labels
        titleLabel!.alpha = 0
        descLabel!.alpha = 0
        
        //set text
        XvUtils.Text.set(label: titleLabel!, withText: data.title)
        XvUtils.Text.set(label: descLabel!, withText: data.desc)
        
        //sizing
        titleLabel!.sizeToFit()

        //grab frame in order to resize it
        var descLabelFrame:CGRect = descLabel!.frame
        
        //reset width to visual fit in bg pane
        descLabelFrame.size.width = bgWidth - (TEXT_MARGIN_SIDES * 2)
        
        //set width into current frame (needed for bounding rect func below to work)
        descLabel!.frame = descLabelFrame
        
        //get the bounding rect of desc text (as ns string) and grab height
        //this allows \n breaks to be seen in the string and size the label correspondingly
        let descTextAsNSString:NSString = data.desc as NSString
            
        let descLabelHeight = descTextAsNSString.boundingRect(
            with: CGSize(
                width:self.descLabel!.frame.size.width,
                height:CGFloat.greatestFiniteMagnitude),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [NSFontAttributeName: descLabel!.font],
            context: nil).size.height
        
        //put the new height into the frame
        descLabelFrame.size.height = descLabelHeight
        
        //set height into current frame
        descLabel!.frame = descLabelFrame
        
        //calc height of bg based on height of desc text
        let bgHeight:CGFloat = DESC_MARGIN_TOP + descLabelHeight + TEXT_MARGIN_BOTTOM
        
        //calc new bg rect
        let newBgRect:CGRect = CGRect(
            x: 0, y: 0,
            width: bgWidth, height: bgHeight)
        
        
        
        //send new data to anim class
        XvUtils.Anim.fadeIn(target: titleLabel!, afterDelay: 0.3)
        XvUtils.Anim.fadeIn(target: descLabel!, afterDelay: 0.33)
        XvUtils.Anim.redraw(target: bg, toRect: newBgRect, afterDelay: 0.0)
        XvUtils.Anim.change(target: bg, toColor: UIColor.black, withDuration:1.0)
        
        return CGSize(width:bgWidth, height:bgHeight)
        
    }
    
    //MARK:-
    //MARK:HIDE
    internal func hide(){
        XvUtils.Anim.fadeOut(target: self.view, afterDelay: 0.0)
    }
    
    //MARK:-
    //MARK:PRIVATE
    //MARK:-
    
    //MARK:GRAPHICS RENDER
    
    fileprivate func initLabels(){
        
        titleLabel = XvUtils.Text.createLabel(
            text: "",
            fontName: TITLE_FONT_NAME,
            size: TITLE_FONT_SIZE,
            alignment: NSTextAlignment.left)
        
        descLabel = XvUtils.Text.createLabel(
            text: "",
            fontName: DESC_FONT_NAME,
            size: DESC_FONT_SIZE,
            alignment: NSTextAlignment.left)
        
        //make sure labels are not nil (meaning fonts are valid)
        if (titleLabel != nil ||
            descLabel  != nil) {
            areLabelsValid = true
        
            descLabel!.lineBreakMode = .byWordWrapping
            descLabel!.numberOfLines = 0
            
            XvUtils.Text.position(
                label: titleLabel!,
                x: TEXT_MARGIN_SIDES,
                y: TITLE_MARGIN_TOP,
                centered: false)
            
            XvUtils.Text.position(
                label: descLabel!,
                x: TEXT_MARGIN_SIDES,
                y: DESC_MARGIN_TOP,
                centered: false)
            
            //add text to screen
            view.addSubview(titleLabel!)
            view.addSubview(descLabel!)
            
        }
        
    }
    
    fileprivate func initBg(){
        
        bgWidth = XvUtils.Screen.width() - BG_SIDE_MARGIN
        if (bgWidth > BG_WIDTH_MAX){
            bgWidth = BG_WIDTH_MAX
        }
        
        //build black pane
        bg = UIImageView(frame: CGRect(x:0, y:0, width:1, height:1))
        bg.backgroundColor = UIColor.white
        bg.alpha = 0.75
        bg.layer.cornerRadius = 8.0
        bg.clipsToBounds = true
        view.addSubview(bg)
        
    }

    
    
}
