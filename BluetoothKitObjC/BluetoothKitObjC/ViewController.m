//
//  ViewController.m
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/16.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "ViewController.h"
#import "BKCBCentralManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BKCBCentralManager *manager = [BKCBCentralManager manager];
    [[[[[[[manager scanForPeripheralsWithServices:nil] then:^id _Nullable(BKDiscovery * discovery) {
        
        return [manager connectPeripheral:discovery.peripheral];
    }] then:^id _Nullable(CBPeripheral *peripheral) {
        
        return [manager discoverServices:nil];
    }] then:^id _Nullable(NSArray<CBService *> *services) {
        
        return [manager discoverCharacteristics:nil forService:services.firstObject];
    }] then:^id _Nullable(NSArray<CBCharacteristic *> *characteristics) {
        
        return [manager readValueForCharacteristic:characteristics.firstObject];
    }] then:^id _Nullable(NSData *value) {
        
        return NULL;
    }] catch:^(NSError * _Nonnull error) {
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
