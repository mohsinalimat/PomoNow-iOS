//
//  TagSelectViewController.swift
//  PomoNow
//
//  Created by Megabits on 15/10/18.
//  Copyright © 2015年 ScrewBox. All rights reserved.
//

import UIKit

var taskString = ""
var selectTag = 0
class TagSelectView: UIView, UITextFieldDelegate {
    
    var select:[Bool] = [true,false,false,false,false]
    @IBOutlet weak var task: UITextField! {
        didSet{
            task.delegate = self
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() //释放键盘
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        NotificationCenter.default.removeObserver(self)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        NotificationCenter.default.addObserver(self,
            selector: #selector(TagSelectView.didChange(_:)),
            name: NSNotification.Name.UITextFieldTextDidChange,
            object: nil) //为文字改变添加监视
        return true
    }
    
    @objc func didChange(_ notification: Notification) {
        taskString = task.text ?? ""
    }
    
    @IBOutlet weak var tagA: UIView!
    @IBOutlet weak var tagB: UIView!
    @IBOutlet weak var tagC: UIView!
    @IBOutlet weak var tagD: UIView!
    @IBOutlet weak var tagE: UIView!
    
    @IBAction func Select(_ sender: UITapGestureRecognizer) {
        selectedTag = sender.view!.tag
    }
    
    var selectedTag = 0{
        didSet {
            for i in 0...4 {
                select[i] = false
            }
            select[selectedTag] = true
            updateUI()
            selectTag = selectedTag
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        taskString = ""
        selectTag = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func awakeFromNib() {
        let time: TimeInterval = 0.1
        let delay = DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delay) {
            self.task.becomeFirstResponder()
        }
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "TagSelectView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
    func updateUI() { //单选控制器状态刷新
        tagA.isHidden = !select[0]
        tagB.isHidden = !select[1]
        tagC.isHidden = !select[2]
        tagD.isHidden = !select[3]
        tagE.isHidden = !select[4]
    }

}
