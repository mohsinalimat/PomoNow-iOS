//
//  DataManagement.swift
//  PomoNow
//
//  Created by 孟金羽 on 16/8/7.
//  Copyright © 2016年 JinyuMeng. All rights reserved.
//

import CoreData
import UIKit

public func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

public func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class DataManagement :NSObject {
    private let defaults = UserDefaults.standard
   
    override init() {
        super.init()
    }
    
    //Defaults
    func getDefaults (_ key: String) -> AnyObject? {
        if key != "" {
            return defaults.object(forKey: key) as AnyObject?
        } else {
            return nil
        }
    }
    
    func setDefaults (_ key: String,value: AnyObject) {
        if key != "" {
            defaults.set(value,forKey: key)
        }
    }
    
    func removeDefaults (_ key: String) {
        if key != "" {
            defaults.removeObject(forKey: key)
        }
    }
}
