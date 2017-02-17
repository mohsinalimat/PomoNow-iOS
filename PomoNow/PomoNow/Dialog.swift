//
//  Dialog.swift
//  PomoNow
//
//  Created by 孟金羽 on 16/8/17.
//  Copyright © 2016年 JinyuMeng. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class Dialog: UIView, UIPickerViewDelegate, UIPickerViewDataSource{
    
    typealias DatePickerCallback = (_ timer: TimeInterval) -> Void
    typealias PickerCallback = (_ rowSelect:Int) -> Void
    typealias AddTaskCallback = (_ task:String,_ aim:Int,_ tag:Int) -> Void
    
    /* Consts */
    private let DialogDefaultButtonHeight:       CGFloat = 50
    private let DialogDefaultButtonSpacerHeight: CGFloat = 1
    private let DialogCornerRadius:              CGFloat = 7
    private let DialogDoneButtonTag:             Int     = 1
    
    /* Views */
    private var dialogView:   UIView!
    private var titleLabel:   UILabel!
    private var datePicker:   UIDatePicker!
    private var cancelButton: UIButton!
    private var doneButton:   UIButton!
    
    private var Picker:   UIPickerView!
    private var selected = false
    private var nowDialog = 0
    
    /* Vars */
    private var defaultTime:    TimeInterval?
    private var datePickerMode: UIDatePickerMode?
    private var callback:       DatePickerCallback?
    private var maxKeyBoardHeight: CGFloat = 0
    private var dialogHeight: CGFloat = 0
    
    private var rowSelected = 0
    private var defaultRow:Int!
    private var numbers = ["1","2","3","4","5","6","7","8","9","10"]
    private var pickerCallback:       PickerCallback?
    
    private var addTaskCallback:      AddTaskCallback?
    
    //delegate
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return numbers[row]
    }
    
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        rowSelected = row
        selected = true
    }
    
    /* Overrides */
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.dialogView = createContainerView()
    
        self.dialogView!.layer.shouldRasterize = true
        self.dialogView!.layer.rasterizationScale = UIScreen.main.scale
    
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    
        self.dialogView!.layer.opacity = 0.5
        self.dialogView!.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1)
    
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    
        self.addSubview(self.dialogView!)
        dialogHeight = dialogView.frame.origin.y
        
        NotificationCenter.default.addObserver(self, selector:#selector(Dialog.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector:#selector(Dialog.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
        NotificationCenter.default.addObserver(self, selector:#selector(Dialog.isNeedClose), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil) //旋转屏幕时关闭对话框
        NotificationCenter.default.addObserver(self, selector:#selector(Dialog.forceClose), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        self.accessibilityViewIsModal = true
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification,self)
    }
    
    //根据键盘状态调整对话框位置
    @objc private func keyboardWillShow(_ notif:Notification){
        let userInfo:NSDictionary = (notif as NSNotification).userInfo! as NSDictionary;
        let keyBoardInfo: AnyObject? = userInfo.object(forKey: UIKeyboardFrameEndUserInfoKey) as AnyObject?;
        let keyBoardHeight = (keyBoardInfo?.cgRectValue.size.height)!; //键盘最终的高度
        if keyBoardHeight > 10 {
            maxKeyBoardHeight = keyBoardHeight
            dialogView.frame.origin.y = dialogHeight - maxKeyBoardHeight/3
        }
    }
    @objc private func keyboardWillHide(_ notif:Notification){
        dialogView.frame.origin.y = dialogHeight
    }
    
    /* Create the dialog view, and animate opening the dialog */
    func showDatePicker(_ title: String, doneButtonTitle: String = "Done", cancelButtonTitle: String = "Cancel", defaultTime: TimeInterval  = TimeInterval(), datePickerMode: UIDatePickerMode = .dateAndTime, callback: @escaping DatePickerCallback) { //此处设置传入参数
        nowDialog = 0
        setupView()
        self.titleLabel.text = title
        self.doneButton.setTitle(doneButtonTitle, for: UIControlState())
        self.cancelButton.setTitle(cancelButtonTitle, for: UIControlState())
        self.datePickerMode = datePickerMode
        self.callback = callback
        self.defaultTime = defaultTime
        self.datePicker.datePickerMode = self.datePickerMode ?? .date
        self.datePicker.countDownDuration = self.defaultTime ?? TimeInterval()
        
        showDialogInSame()
    }
    
    func showPicker(_ title: String, doneButtonTitle: String = "Done", cancelButtonTitle: String = "Cancel", defaults: Int = 1, callback: @escaping PickerCallback) { //此处设置传入参数
        nowDialog = 1
        setupView()
        self.titleLabel.text = title
        self.doneButton.setTitle(doneButtonTitle, for: UIControlState())
        self.cancelButton.setTitle(cancelButtonTitle, for: UIControlState())
        self.pickerCallback = callback
        self.defaultRow = defaults
        self.Picker.selectRow(defaults, inComponent: 0, animated: true)
        
        showDialogInSame()
    }
    
    private func showDialogInSame() { //显示不同对话框时的相同代码
        /* */
        UIApplication.shared.windows.first!.addSubview(self)
        UIApplication.shared.windows.first!.endEditing(true)
        
        /* Anim */
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: UIViewAnimationOptions.beginFromCurrentState,
            animations: { () -> Void in
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
                self.dialogView!.layer.opacity = 1
                self.dialogView!.layer.transform = CATransform3DMakeScale(1, 1, 1)
            },
            completion: nil
        )
    }
    
    @objc private func isNeedClose() {
        if isiPad {
            close()
        }
    }
    
    /* Dialog close animation then cleaning and removing the view from the parent */
    private func close() {
        NotificationCenter.default.removeObserver(self)
        
        let currentTransform = self.dialogView.layer.transform
        
        let startRotation = (self.value(forKeyPath: "layer.transform.rotation.z") as? NSNumber) as? Double ?? 0.0
        let rotation = CATransform3DMakeRotation((CGFloat)(-startRotation + M_PI * 270 / 180), 0, 0, 0)
        
        self.dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1))
        self.dialogView.layer.opacity = 1
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: UIViewAnimationOptions.beginFromCurrentState,
            animations: { () -> Void in
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                self.dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6, 0.6, 1))
                self.dialogView.layer.opacity = 0
            }) { (finished: Bool) -> Void in
                for v in self.subviews {
                    v.removeFromSuperview()
                }
                
                self.removeFromSuperview()
        }
    }
    
    @objc private func forceClose() {
        NotificationCenter.default.removeObserver(self)
        self.removeFromSuperview()
    }
    
    /* Creates the container view here: create the dialog, then add the custom content and buttons */
    private func createContainerView() -> UIView {
        let screenSize = countScreenSize()
        var dialogSize = CGSize(
            width: 300,
            height: 230
                + DialogDefaultButtonHeight
                + DialogDefaultButtonSpacerHeight)
        if nowDialog == 2 {
            dialogSize = CGSize(
                width: 300,
                height: 190
                    + DialogDefaultButtonHeight
                    + DialogDefaultButtonSpacerHeight)
        }
        // For the black background
        self.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        // This is the dialog's container; we attach the custom content and the buttons to this one
        let dialogContainer = UIView(frame: CGRect(x: (screenSize.width - dialogSize.width) / 2, y: (screenSize.height - dialogSize.height) / 2, width: dialogSize.width, height: dialogSize.height))
        
        // First, we style the dialog to match the iOS8 UIAlertView >>>
        let gradient: CAGradientLayer = CAGradientLayer(layer: self.layer)
        gradient.frame = dialogContainer.bounds
        gradient.colors = [UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).cgColor,
            UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor,
            UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).cgColor]
        
        let cornerRadius = DialogCornerRadius
        gradient.cornerRadius = cornerRadius
        dialogContainer.layer.insertSublayer(gradient, at: 0)
        
        dialogContainer.layer.cornerRadius = cornerRadius
        dialogContainer.layer.borderColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1).cgColor
        dialogContainer.layer.borderWidth = 1
        dialogContainer.layer.shadowRadius = cornerRadius + 5
        dialogContainer.layer.shadowOpacity = 0.1
        dialogContainer.layer.shadowOffset = CGSize(width: 0 - (cornerRadius + 5) / 2, height: 0 - (cornerRadius + 5) / 2)
        dialogContainer.layer.shadowColor = UIColor.black.cgColor
        dialogContainer.layer.shadowPath = UIBezierPath(roundedRect: dialogContainer.bounds, cornerRadius: dialogContainer.layer.cornerRadius).cgPath
        
        // There is a line above the button
        let lineView = UIView(frame: CGRect(x: 0, y: dialogContainer.bounds.size.height - DialogDefaultButtonHeight - DialogDefaultButtonSpacerHeight, width: dialogContainer.bounds.size.width, height: DialogDefaultButtonSpacerHeight))
        lineView.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        dialogContainer.addSubview(lineView)
        // ˆˆˆ
        
        //Title
        self.titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 280, height: 30))
        self.titleLabel.textAlignment = NSTextAlignment.center
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        dialogContainer.addSubview(self.titleLabel)
        self.datePicker = UIDatePicker(frame: CGRect(x: 0, y: 30, width: 0, height: 0))
        self.datePicker.autoresizingMask = UIViewAutoresizing.flexibleRightMargin
        self.datePicker.frame.size.width = 300
        
        self.Picker = UIPickerView(frame: CGRect(x: 0, y: 30, width: 0, height: 0))
        self.Picker.delegate = self
        self.Picker.autoresizingMask = UIViewAutoresizing.flexibleRightMargin
        self.Picker.frame.size.width = 300
        
        if nowDialog == 0 {
            dialogContainer.addSubview(self.datePicker)
        } else if nowDialog == 1 {
            dialogContainer.addSubview(self.Picker)
        }
        // Add the buttons
        addButtonsToView(dialogContainer)
        return dialogContainer
    }
    
    /* Add buttons to container */
    private func addButtonsToView(_ container: UIView) {
        let buttonWidth = container.bounds.size.width / 2
        
        self.cancelButton = UIButton(type: UIButtonType.custom) as UIButton
        self.cancelButton.frame = CGRect(
            x: 0,
            y: container.bounds.size.height - DialogDefaultButtonHeight,
            width: buttonWidth,
            height: DialogDefaultButtonHeight
        )
        self.cancelButton.setTitleColor(UIColor(red:0.9412, green:0.3412, blue:0.302, alpha:1.0), for: UIControlState())
        self.cancelButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), for: UIControlState.highlighted)
        self.cancelButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        self.cancelButton.layer.cornerRadius = DialogCornerRadius
        self.cancelButton.addTarget(self, action: #selector(Dialog.buttonTapped(_:)), for: UIControlEvents.touchUpInside)
        container.addSubview(self.cancelButton)
        
        self.doneButton = UIButton(type: UIButtonType.custom) as UIButton
        self.doneButton.frame = CGRect(
            x: buttonWidth,
            y: container.bounds.size.height - DialogDefaultButtonHeight,
            width: buttonWidth,
            height: DialogDefaultButtonHeight
        )
        self.doneButton.tag = DialogDoneButtonTag
        
        self.doneButton.setTitleColor(UIColor(red:0.9412, green:0.3412, blue:0.302, alpha:1.0), for: UIControlState())
        self.doneButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), for: UIControlState.highlighted)
        self.doneButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        self.doneButton.layer.cornerRadius = DialogCornerRadius
        self.doneButton.addTarget(self, action: #selector(Dialog.buttonTapped(_:)), for: UIControlEvents.touchUpInside)
        container.addSubview(self.doneButton)
    }
    
    @objc private func buttonTapped(_ sender: UIButton!) { //发送消息
        if sender.tag == DialogDoneButtonTag {
            self.callback?(self.datePicker.countDownDuration)
            if selected {
                self.pickerCallback?(rowSelected)
            } else {
                self.pickerCallback?(defaultRow)
            }
        }
        
        close()
    }
    
    /* Helper function: count and return the screen's size */
    private func countScreenSize() -> CGSize {
        let screenWidth = dilogWidth
        let screenHeight = UIScreen.main.bounds.size.height
        
        return CGSize(width: screenWidth, height: screenHeight)
    }
    
}
