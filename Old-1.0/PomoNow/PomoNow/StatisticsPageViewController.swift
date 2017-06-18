//
//  StatisticsPageViewController.swift
//  PomoNow
//
//  Created by Megabits on 16/1/14.
//  Copyright © 2016年 ScrewBox. All rights reserved.
//

import Foundation
import UIKit

class StatisticsPageViewController: UIPageViewController,UIPageViewControllerDataSource, UIPageViewControllerDelegate{
    
    var index = 0
    var identifiers: NSArray = ["Statistics", "Statistics2"]
    override func viewDidLoad() {
        
        self.dataSource = self
        self.delegate = self
        
        let startingViewController = self.viewControllerAtIndex(self.index)
        let viewControllers: NSArray = [startingViewController]
        self.setViewControllers(viewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGrayColor()
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.grayColor()
        
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController! {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "PomoNow", bundle:nil)
        //first view controller = firstViewControllers navigation controller
        if index == 0 {
            
            return storyBoard.instantiateViewControllerWithIdentifier("Statistics")
            
        }
        
        //second view controller = secondViewController's navigation controller
        if index == 1 {
            
            return storyBoard.instantiateViewControllerWithIdentifier("Statistics2")
        }
        
        return nil
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let identifier = viewController.restorationIdentifier
        let index = self.identifiers.indexOfObject(identifier!)
        
        //if the index is the end of the array, return nil since we dont want a view controller after the last one
        if index == identifiers.count - 1 {
            
            return nil
        }
        
        //increment the index to get the viewController after the current index
        self.index = self.index + 1
        return self.viewControllerAtIndex(self.index)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let identifier = viewController.restorationIdentifier
        let index = self.identifiers.indexOfObject(identifier!)
        
        //if the index is 0, return nil since we dont want a view controller before the first one
        if index == 0 {
            
            return nil
        }
        
        //decrement the index to get the viewController before the current one
        self.index = self.index - 1
        return self.viewControllerAtIndex(self.index)
        
    }
    
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.identifiers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}
