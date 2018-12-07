//
//  TestViewController.m
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/12/7.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import "TestViewController.h"
#import "LGBluetooth.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialization of CentralManager
    [LGCentralManager sharedInstance];
    
//    self.textView.text = @"bluetooth standby";
//    self.textView.layer.borderColor = [UIColor redColor].CGColor;
//    self.textView.layer.borderWidth = 1;
    
    //    _operationQueue = dispatch_queue_create("com.sugar.ble.central", DISPATCH_QUEUE_CONCURRENT);
    //    _dataQueue = dispatch_queue_create("com.sugar.ble.central", DISPATCH_QUEUE_SERIAL);
    
    //    dispatch_async(_operationQueue, ^{
    //        NSLog(@"aaaaa");
    //        sleep(2);
    //    });
    //
    //    dispatch_async(_operationQueue, ^{
    //        NSLog(@"ccccc");
    //        sleep(2);
    //    });
    //
    //    dispatch_async(_operationQueue, ^{
    //        NSLog(@"ddddd");
    //        sleep(2);
    //    });
    //
    //    NSLog(@"bbbbb");
}

- (IBAction)stopAction:(id)sender {
    //    [self.manager stopScan];
}

- (IBAction)buttonAction:(id)sender {
    //    [self.manager stopScan];
    //    self.textView.text = @"scan for peripherals......";
    //    self.consoleText = [NSMutableString string];
    //    [[[[[[[self.manager scanForPeripheralsWithServices:nil] then:^id _Nullable(BKDiscovery * discovery) {
    //        NSLog(@"peripheral localName is %@", discovery.localName);
    //        [self.consoleText appendFormat:@"peripheral localName is %@", discovery.localName ?: @"unknown"];
    //        self.textView.text = self.consoleText;
    //        return [self.manager connectPeripheral:discovery.peripheral];
    //    }] then:^id _Nullable(CBPeripheral *peripheral) {
    //        [self.consoleText appendString:@"\n--------------------------\n"];
    //        [self.consoleText appendFormat:@"connect peripheral is %@", peripheral.description];
    //        self.textView.text = self.consoleText;
    //        NSLog(@"connect peripheral is %@", peripheral.description);
    //        return [self.manager discoverServices:nil forPeripheral:peripheral];
    //    }] then:^id _Nullable(NSArray<CBService *> *services) {
    //        [self.consoleText appendString:@"\n--------------------------\n"];
    //        [self.consoleText appendFormat:@"discover services is %@", services.description];
    //        self.textView.text = self.consoleText;
    //        NSLog(@"discover services is %@", services.description);
    //        return [self.manager discoverCharacteristics:nil forService:services.firstObject];
    //    }] then:^id _Nullable(NSArray<CBCharacteristic *> *characteristics) {
    //        [self.consoleText appendString:@"\n--------------------------\n"];
    //        [self.consoleText appendFormat:@"discover characteristics is %@", characteristics.description];
    //        self.textView.text = self.consoleText;
    //        NSLog(@"discover characteristics is %@", characteristics.description);
    //        return [self.manager readValueForCharacteristic:characteristics.firstObject];
    //    }] then:^id _Nullable(NSData *value) {
    //        [self.consoleText appendString:@"\n--------------------------\n"];
    //        NSString *str = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
    //        [self.consoleText appendFormat:@"read value for characteristics is %@", str];
    //        self.textView.text = self.consoleText;
    //        NSLog(@"read value for characteristics is %@", str);
    //        return NULL;
    //    }] catch:^(NSError * _Nonnull error) {
    //        [self.consoleText appendString:@"\n--------------------------\n"];
    //        NSString *str = [NSString stringWithFormat:@"catch error: %@", error.localizedDescription];
    //        [self.consoleText appendString:str];
    //        self.textView.text = self.consoleText;
    //    }];
}

- (IBAction)testPressed:(UIButton *)sender
{
    // Scaning 4 seconds for peripherals
    [[LGCentralManager sharedInstance] scanForPeripheralsByInterval:4
                                                         completion:^(NSArray *peripherals)
     {
         // If we found any peripherals sending to test
         if (peripherals.count) {
             [self testPeripheral:peripherals[0]];
         }
     }];
}

- (void)testPeripheral:(LGPeripheral *)peripheral
{
    // First of all connecting to peripheral
    [peripheral connectWithCompletion:^(NSError *error) {
        // Discovering services of peripheral
        [peripheral discoverServicesWithCompletion:^(NSArray *services, NSError *error) {
            for (LGService *service in services) {
                // Finding out our service
                if ([service.UUIDString isEqualToString:@"5ec0"]) {
                    // Discovering characteristics of our service
                    [service discoverCharacteristicsWithCompletion:^(NSArray *characteristics, NSError *error) {
                        // We need to count down completed operations for disconnecting
                        __block int i = 0;
                        for (LGCharacteristic *charact in characteristics) {
                            // cef9 is a writabble characteristic, lets test writting
                            if ([charact.UUIDString isEqualToString:@"cef9"]) {
                                [charact writeByte:0xFF completion:^(NSError *error) {
                                    if (++i == 3) {
                                        // finnally disconnecting
                                        [peripheral disconnectWithCompletion:nil];
                                    }
                                }];
                            } else {
                                // Other characteristics are readonly, testing read
                                [charact readValueWithBlock:^(NSData *data, NSError *error) {
                                    if (++i == 3) {
                                        // finnally disconnecting
                                        [peripheral disconnectWithCompletion:nil];
                                    }
                                }];
                            }
                        }
                    }];
                }
            }
        }];
    }];
}

@end
