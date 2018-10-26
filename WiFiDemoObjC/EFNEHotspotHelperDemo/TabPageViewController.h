//
//  TabPageViewController.h
//  EFNEHotspotHelperDemo
//
//  Created by Samuel on 2018/10/21.
//  Copyright © 2018年 EyreFree. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabPageViewController : UIPageViewController

@property (nonatomic, assign) BOOL isInfinity;
@property (nonatomic, strong) NSArray<UIViewController *> *tabItems;

@end
