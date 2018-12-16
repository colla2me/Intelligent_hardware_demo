//
//  BLEViewController.m
//  BluetoothKitObjC
//
//  Created by samuel on 2018/12/16.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "BLEViewController.h"
#import "CentralModeViewController.h"
#import "PeripheralModeViewController.h"

@interface BLEViewController ()

@end

@implementation BLEViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)centralModeAction:(UIButton *)sender {
    
    [self.navigationController pushViewController:[CentralModeViewController new] animated:YES];
}

- (IBAction)peripheralModeAction:(UIButton *)sender {
    
    [self.navigationController pushViewController:[PeripheralModeViewController new] animated:YES];
}


@end
