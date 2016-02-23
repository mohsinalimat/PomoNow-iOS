import Foundation
import UIKit
import QuartzCore

class Dialog: UIView, UIPickerViewDelegate, UIPickerViewDataSource{
    
    typealias DatePickerCallback = (timer: NSTimeInterval) -> Void
    typealias PickerCallback = (rowSelect:Int) -> Void
    
    /* Consts */
    private let kDatePickerDialogDefaultButtonHeight:       CGFloat = 50
    private let kDatePickerDialogDefaultButtonSpacerHeight: CGFloat = 1
    private let kDatePickerDialogCornerRadius:              CGFloat = 7
    private let kDatePickerDialogDoneButtonTag:             Int     = 1
    
    private let kPickerDialogDefaultButtonHeight:       CGFloat = 50
    private let kPickerDialogDefaultButtonSpacerHeight: CGFloat = 1
    private let kPickerDialogCornerRadius:              CGFloat = 7
    private let kPickerDialogDoneButtonTag:             Int     = 1
    
    /* Views */
    private var dialogView:   UIView!
    private var titleLabel:   UILabel!
    private var datePicker:   UIDatePicker!
    private var cancelButton: UIButton!
    private var doneButton:   UIButton!
    
    private var Picker:   UIPickerView!
    private var selected = false
    private var nowDialog = 0
    
    private var taskAdd:      UIView!
    
    /* Vars */
    private var defaultTime:    NSTimeInterval?
    private var datePickerMode: UIDatePickerMode?
    private var callback:       DatePickerCallback?
    private var maxKeyBoardHeight: CGFloat = 0
    private var dialogHeight: CGFloat = 0
    
    var rowSelected = 0
    var defaultRow:Int!
    var numbers = ["1","2","3","4","5","6","7","8","9","10"]
    private var pcallback:       PickerCallback?
    
    //delegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return numbers[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        rowSelected = row
        selected = true
    }
    
    /* Overrides */
    init() {
        super.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.dialogView = createContainerView()
    
        self.dialogView!.layer.shouldRasterize = true
        self.dialogView!.layer.rasterizationScale = UIScreen.mainScreen().scale
    
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
    
        self.dialogView!.layer.opacity = 0.5
        self.dialogView!.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1)
    
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    
        self.addSubview(self.dialogView!)
        dialogHeight = dialogView.frame.origin.y
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil);
    }
    
    //根据键盘状态调整对话框位置
    func keyboardWillShow(notif:NSNotification){
        let userInfo:NSDictionary = notif.userInfo!;
        let keyBoardInfo: AnyObject? = userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey);
        let keyBoardHeight = (keyBoardInfo?.CGRectValue.size.height)!; //键盘最终的高度
        if keyBoardHeight > 10 {
            maxKeyBoardHeight = keyBoardHeight
            dialogView.frame.origin.y = dialogHeight - maxKeyBoardHeight/3
        }
    }
    func keyboardWillHide(notif:NSNotification){
        dialogView.frame.origin.y = dialogHeight
    }
    
    /* Create the dialog view, and animate opening the dialog */
    func showDatePicker(title: String, doneButtonTitle: String = "Done", cancelButtonTitle: String = "Cancel", defaultTime: NSTimeInterval  = NSTimeInterval(), datePickerMode: UIDatePickerMode = .DateAndTime, callback: DatePickerCallback) { //此处设置传入参数
        nowDialog = 0
        setupView()
        self.titleLabel.text = title
        self.doneButton.setTitle(doneButtonTitle, forState: .Normal)
        self.cancelButton.setTitle(cancelButtonTitle, forState: .Normal)
        self.datePickerMode = datePickerMode
        self.callback = callback
        self.defaultTime = defaultTime
        self.datePicker.datePickerMode = self.datePickerMode ?? .Date
        self.datePicker.countDownDuration = self.defaultTime ?? NSTimeInterval()
        
        showDialogInSame()
    }
    
    func showPicker(title: String, doneButtonTitle: String = "Done", cancelButtonTitle: String = "Cancel", defaults: Int = 1, callback: PickerCallback) { //此处设置传入参数
        nowDialog = 1
        setupView()
        self.titleLabel.text = title
        self.doneButton.setTitle(doneButtonTitle, forState: .Normal)
        self.cancelButton.setTitle(cancelButtonTitle, forState: .Normal)
        self.pcallback = callback
        self.defaultRow = defaults
        self.Picker.selectRow(defaults, inComponent: 0, animated: true)
        
        showDialogInSame()
    }
    
    func showAddTask(title: String, doneButtonTitle: String = "Done", cancelButtonTitle: String = "Cancel", callback: DatePickerCallback) { //此处设置传入参数
        nowDialog = 2
        setupView()
        self.titleLabel.text = title
        self.doneButton.setTitle(doneButtonTitle, forState: .Normal)
        self.cancelButton.setTitle(cancelButtonTitle, forState: .Normal)
        self.callback = callback
        
        showDialogInSame()
    }
    
    func showDialogInSame() { //显示不同对话框时的相同代码
        /* */
        UIApplication.sharedApplication().windows.first!.addSubview(self)
        UIApplication.sharedApplication().windows.first!.endEditing(true)
        
        /* Anim */
        UIView.animateWithDuration(
            0.2,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
                self.dialogView!.layer.opacity = 1
                self.dialogView!.layer.transform = CATransform3DMakeScale(1, 1, 1)
            },
            completion: nil
        )
    }
    
    /* Dialog close animation then cleaning and removing the view from the parent */
    private func close() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        let currentTransform = self.dialogView.layer.transform
        
        let startRotation = (self.valueForKeyPath("layer.transform.rotation.z") as? NSNumber) as? Double ?? 0.0
        let rotation = CATransform3DMakeRotation((CGFloat)(-startRotation + M_PI * 270 / 180), 0, 0, 0)
        
        self.dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1))
        self.dialogView.layer.opacity = 1
        
        UIView.animateWithDuration(
            0.2,
            delay: 0,
            options: UIViewAnimationOptions.TransitionNone,
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
    private func createContainerView() -> UIView {
        let screenSize = countScreenSize()
        var dialogSize = CGSizeMake(
            300,
            230
                + kDatePickerDialogDefaultButtonHeight
                + kDatePickerDialogDefaultButtonSpacerHeight)
        if nowDialog == 2 {
            dialogSize = CGSizeMake(
                300,
                130
                    + kDatePickerDialogDefaultButtonHeight
                    + kDatePickerDialogDefaultButtonSpacerHeight)
        }
        // For the black background
        self.frame = CGRectMake(0, 0, screenSize.width, screenSize.height)
        // This is the dialog's container; we attach the custom content and the buttons to this one
        let dialogContainer = UIView(frame: CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height))
        
        // First, we style the dialog to match the iOS8 UIAlertView >>>
        let gradient: CAGradientLayer = CAGradientLayer(layer: self.layer)
        gradient.frame = dialogContainer.bounds
        gradient.colors = [UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).CGColor,
            UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).CGColor,
            UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).CGColor]
        
        let cornerRadius = kDatePickerDialogCornerRadius
        gradient.cornerRadius = cornerRadius
        dialogContainer.layer.insertSublayer(gradient, atIndex: 0)
        
        dialogContainer.layer.cornerRadius = cornerRadius
        dialogContainer.layer.borderColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1).CGColor
        dialogContainer.layer.borderWidth = 1
        dialogContainer.layer.shadowRadius = cornerRadius + 5
        dialogContainer.layer.shadowOpacity = 0.1
        dialogContainer.layer.shadowOffset = CGSizeMake(0 - (cornerRadius + 5) / 2, 0 - (cornerRadius + 5) / 2)
        dialogContainer.layer.shadowColor = UIColor.blackColor().CGColor
        dialogContainer.layer.shadowPath = UIBezierPath(roundedRect: dialogContainer.bounds, cornerRadius: dialogContainer.layer.cornerRadius).CGPath
        
        // There is a line above the button
        let lineView = UIView(frame: CGRectMake(0, dialogContainer.bounds.size.height - kDatePickerDialogDefaultButtonHeight - kDatePickerDialogDefaultButtonSpacerHeight, dialogContainer.bounds.size.width, kDatePickerDialogDefaultButtonSpacerHeight))
        lineView.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        dialogContainer.addSubview(lineView)
        // ˆˆˆ
        
        //Title
        self.titleLabel = UILabel(frame: CGRectMake(10, 10, 280, 30))
        self.titleLabel.textAlignment = NSTextAlignment.Center
        self.titleLabel.font = UIFont.boldSystemFontOfSize(17)
        dialogContainer.addSubview(self.titleLabel)
        self.datePicker = UIDatePicker(frame: CGRectMake(0, 30, 0, 0))
        self.datePicker.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin
        self.datePicker.frame.size.width = 300
        
        self.Picker = UIPickerView(frame: CGRectMake(0, 30, 0, 0))
        self.Picker.delegate = self
        self.Picker.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin
        self.Picker.frame.size.width = 300
        
        self.taskAdd = TagSelectView.instanceFromNib()
        self.taskAdd.frame = CGRectMake(0, 30, 300, 100)
        
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
    private func addButtonsToView(container: UIView) {
        let buttonWidth = container.bounds.size.width / 2
        
        self.cancelButton = UIButton(type: UIButtonType.Custom) as UIButton
        self.cancelButton.frame = CGRectMake(
            0,
            container.bounds.size.height - kDatePickerDialogDefaultButtonHeight,
            buttonWidth,
            kDatePickerDialogDefaultButtonHeight
        )
        self.cancelButton.setTitleColor(UIColor(red: 0, green: 0.5, blue: 1, alpha: 1), forState: UIControlState.Normal)
        self.cancelButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), forState: UIControlState.Highlighted)
        self.cancelButton.titleLabel!.font = UIFont.boldSystemFontOfSize(14)
        self.cancelButton.layer.cornerRadius = kDatePickerDialogCornerRadius
        self.cancelButton.addTarget(self, action: "buttonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        container.addSubview(self.cancelButton)
        
        self.doneButton = UIButton(type: UIButtonType.Custom) as UIButton
        self.doneButton.frame = CGRectMake(
            buttonWidth,
            container.bounds.size.height - kDatePickerDialogDefaultButtonHeight,
            buttonWidth,
            kDatePickerDialogDefaultButtonHeight
        )
        if nowDialog == 0 {
            self.doneButton.tag = kDatePickerDialogDoneButtonTag
        } else if nowDialog == 1 {
            self.doneButton.tag = kPickerDialogDoneButtonTag
        } else if nowDialog == 2 {
            self.doneButton.tag = kDatePickerDialogDoneButtonTag
        }
        
        self.doneButton.setTitleColor(UIColor(red: 0, green: 0.5, blue: 1, alpha: 1), forState: UIControlState.Normal)
        self.doneButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), forState: UIControlState.Highlighted)
        self.doneButton.titleLabel!.font = UIFont.boldSystemFontOfSize(14)
        self.doneButton.layer.cornerRadius = kDatePickerDialogCornerRadius
        self.doneButton.addTarget(self, action: "buttonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        container.addSubview(self.doneButton)
    }
    
    func buttonTapped(sender: UIButton!) {
        if sender.tag == kDatePickerDialogDoneButtonTag {
            self.callback?(timer: self.datePicker.countDownDuration)
        }
        if sender.tag == kPickerDialogDoneButtonTag {
            if selected {
                self.pcallback?(rowSelect: rowSelected)
            } else {
                self.pcallback?(rowSelect: defaultRow)
            }
            
        }
        
        close()
    }
    
    /* Helper function: count and return the screen's size */
    func countScreenSize() -> CGSize {
        let screenWidth = UIScreen.mainScreen().applicationFrame.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        return CGSizeMake(screenWidth, screenHeight)
    }
    
}
