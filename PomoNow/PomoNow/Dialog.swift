//
//  NavigationController.swift
//  PomoNow
//
//  Created by Megabits on 15/10/3.
//  Copyright © 2015年 Jinyu Meng. All rights reserved.
//

import UIKit

class Dialog: UIView, UIPickerViewDelegate, UIPickerViewDataSource{
    
    typealias DatePickerCallback = (_ timer: TimeInterval) -> Void
    typealias PickerCallback = (_ rowSelect:Int) -> Void
    
    /* Consts */
    fileprivate let kDatePickerDialogDefaultButtonHeight:       CGFloat = 50
    fileprivate let kDatePickerDialogDefaultButtonSpacerHeight: CGFloat = 1
    fileprivate let kDatePickerDialogCornerRadius:              CGFloat = 7
    fileprivate let kDatePickerDialogDoneButtonTag:             Int     = 1
    
    fileprivate let kPickerDialogDefaultButtonHeight:       CGFloat = 50
    fileprivate let kPickerDialogDefaultButtonSpacerHeight: CGFloat = 1
    fileprivate let kPickerDialogCornerRadius:              CGFloat = 7
    fileprivate let kPickerDialogDoneButtonTag:             Int     = 1
    
    /* Views */
    fileprivate var dialogView:   UIView!
    fileprivate var titleLabel:   UILabel!
    fileprivate var datePicker:   UIDatePicker!
    fileprivate var cancelButton: UIButton!
    fileprivate var doneButton:   UIButton!
    
    fileprivate var Picker:   UIPickerView!
    fileprivate var selected = false
    fileprivate var nowDialog = 0
    
    fileprivate var taskAdd:      UIView!
    
    /* Vars */
    fileprivate var defaultTime:    TimeInterval?
    fileprivate var datePickerMode: UIDatePickerMode?
    fileprivate var callback:       DatePickerCallback?
    fileprivate var maxKeyBoardHeight: CGFloat = 0
    fileprivate var dialogHeight: CGFloat = 0
    
    var rowSelected = 0
    var defaultRow:Int!
    var numbers = ["1","2","3","4","5","6","7","8","9","10"]
    fileprivate var pcallback:       PickerCallback?
    
    //delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return numbers[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
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
    
    func setupView() {
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
    }
    
    //根据键盘状态调整对话框位置
    @objc func keyboardWillShow(_ notif:Notification){
        let userInfo:NSDictionary = notif.userInfo! as NSDictionary;
        let keyBoardInfo: AnyObject? = userInfo.object(forKey: UIKeyboardFrameEndUserInfoKey) as AnyObject;
        let keyBoardHeight = (keyBoardInfo?.cgRectValue.size.height)!; //键盘最终的高度
        if keyBoardHeight > 10 {
            maxKeyBoardHeight = keyBoardHeight
            dialogView.frame.origin.y = dialogHeight - maxKeyBoardHeight/3
        }
    }
    @objc func keyboardWillHide(_ notif:Notification){
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
        self.pcallback = callback
        self.defaultRow = defaults
        self.Picker.selectRow(defaults, inComponent: 0, animated: true)
        
        showDialogInSame()
    }
    
    func showAddTask(_ title: String, doneButtonTitle: String = "Done", cancelButtonTitle: String = "Cancel", callback: @escaping DatePickerCallback) { //此处设置传入参数
        nowDialog = 2
        setupView()
        self.titleLabel.text = title
        self.doneButton.setTitle(doneButtonTitle, for: UIControlState())
        self.cancelButton.setTitle(cancelButtonTitle, for: UIControlState())
        self.callback = callback
        
        showDialogInSame()
    }
    
    func showDialogInSame() { //显示不同对话框时的相同代码
        /* */
        UIApplication.shared.windows.first!.addSubview(self)
        UIApplication.shared.windows.first!.endEditing(true)
        
        /* Anim */
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: UIViewAnimationOptions(),
            animations: { () -> Void in
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
                self.dialogView!.layer.opacity = 1
                self.dialogView!.layer.transform = CATransform3DMakeScale(1, 1, 1)
            },
            completion: nil
        )
    }
    
    /* Dialog close animation then cleaning and removing the view from the parent */
    fileprivate func close() {
        NotificationCenter.default.removeObserver(self)
        
        let currentTransform = self.dialogView.layer.transform
        
        let startRotation = (self.value(forKeyPath: "layer.transform.rotation.z") as? NSNumber) as? Double ?? 0.0
        let rotation = CATransform3DMakeRotation((CGFloat)(-startRotation + Double.pi * 270 / 180), 0, 0, 0)
        
        self.dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1))
        self.dialogView.layer.opacity = 1
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: UIViewAnimationOptions(),
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
    
    /* Creates the container view here: create the dialog, then add the custom content and buttons */
    fileprivate func createContainerView() -> UIView {
        let screenSize = countScreenSize()
        var dialogSize = CGSize(
            width: 300,
            height: 230
                + kDatePickerDialogDefaultButtonHeight
                + kDatePickerDialogDefaultButtonSpacerHeight)
        if nowDialog == 2 {
            dialogSize = CGSize(
                width: 300,
                height: 130
                    + kDatePickerDialogDefaultButtonHeight
                    + kDatePickerDialogDefaultButtonSpacerHeight)
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
        
        let cornerRadius = kDatePickerDialogCornerRadius
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
        let lineView = UIView(frame: CGRect(x: 0, y: dialogContainer.bounds.size.height - kDatePickerDialogDefaultButtonHeight - kDatePickerDialogDefaultButtonSpacerHeight, width: dialogContainer.bounds.size.width, height: kDatePickerDialogDefaultButtonSpacerHeight))
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
        
        self.taskAdd = TagSelectView.instanceFromNib()
        self.taskAdd.frame = CGRect(x: 0, y: 30, width: 300, height: 100)
        
        if nowDialog == 0 {
            dialogContainer.addSubview(self.datePicker)
        } else if nowDialog == 1 {
            dialogContainer.addSubview(self.Picker)
        } else if nowDialog == 2 {
            dialogContainer.addSubview(self.taskAdd)
        }
        // Add the buttons
        addButtonsToView(dialogContainer)
        return dialogContainer
    }
    
    /* Add buttons to container */
    fileprivate func addButtonsToView(_ container: UIView) {
        let buttonWidth = container.bounds.size.width / 2
        
        self.cancelButton = UIButton(type: UIButtonType.custom) as UIButton
        self.cancelButton.frame = CGRect(
            x: 0,
            y: container.bounds.size.height - kDatePickerDialogDefaultButtonHeight,
            width: buttonWidth,
            height: kDatePickerDialogDefaultButtonHeight
        )
        self.cancelButton.setTitleColor(UIColor(red: 0, green: 0.5, blue: 1, alpha: 1), for: UIControlState())
        self.cancelButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), for: UIControlState.highlighted)
        self.cancelButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        self.cancelButton.layer.cornerRadius = kDatePickerDialogCornerRadius
        self.cancelButton.addTarget(self, action: #selector(Dialog.buttonTapped(_:)), for: UIControlEvents.touchUpInside)
        container.addSubview(self.cancelButton)
        
        self.doneButton = UIButton(type: UIButtonType.custom) as UIButton
        self.doneButton.frame = CGRect(
            x: buttonWidth,
            y: container.bounds.size.height - kDatePickerDialogDefaultButtonHeight,
            width: buttonWidth,
            height: kDatePickerDialogDefaultButtonHeight
        )
        if nowDialog == 0 {
            self.doneButton.tag = kDatePickerDialogDoneButtonTag
        } else if nowDialog == 1 {
            self.doneButton.tag = kPickerDialogDoneButtonTag
        } else if nowDialog == 2 {
            self.doneButton.tag = kDatePickerDialogDoneButtonTag
        }
        
        self.doneButton.setTitleColor(UIColor(red: 0, green: 0.5, blue: 1, alpha: 1), for: UIControlState())
        self.doneButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), for: UIControlState.highlighted)
        self.doneButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        self.doneButton.layer.cornerRadius = kDatePickerDialogCornerRadius
        self.doneButton.addTarget(self, action: #selector(Dialog.buttonTapped(_:)), for: UIControlEvents.touchUpInside)
        container.addSubview(self.doneButton)
    }
    
    @objc func buttonTapped(_ sender: UIButton!) {
        if sender.tag == kDatePickerDialogDoneButtonTag {
            self.callback?(self.datePicker.countDownDuration)
        }
        if sender.tag == kPickerDialogDoneButtonTag {
            if selected {
                self.pcallback?(rowSelected)
            } else {
                self.pcallback?(defaultRow)
            }
            
        }
        
        close()
    }
    
    /* Helper function: count and return the screen's size */
    func countScreenSize() -> CGSize {
        let screenWidth = UIScreen.main.applicationFrame.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        return CGSize(width: screenWidth, height: screenHeight)
    }
    
}
