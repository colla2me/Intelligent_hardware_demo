//
//  InfiniteTabPageViewController.m
//  EFNEHotspotHelperDemo
//
//  Created by Samuel on 2018/10/21.
//  Copyright © 2018年 EyreFree. All rights reserved.
//

#import "InfiniteTabPageViewController.h"
#import "DemoViewController.h"

@interface InfiniteTabPageViewController ()

@end

@implementation InfiniteTabPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DemoViewController *vc1 = [[DemoViewController alloc] init];
    vc1.index = 1;
    vc1.view.backgroundColor = [UIColor redColor];
    DemoViewController *vc2 = [[DemoViewController alloc] init];
    vc2.index = 2;
    vc2.view.backgroundColor = [UIColor greenColor];
    DemoViewController *vc3 = [[DemoViewController alloc] init];
    vc3.index = 3;
    vc3.view.backgroundColor = [UIColor blueColor];
    self.isInfinity = YES;
    self.tabItems = @[vc1, vc2, vc3];
}

@end
