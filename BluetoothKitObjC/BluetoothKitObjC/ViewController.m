//
//  ViewController.m
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/16.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "ViewController.h"
#import "BKCBCentralManager.h"
#import "Bleu/Bleu.h"

@interface ViewController ()

@property (nonatomic, strong) BKCBCentralManager *manager;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) NSMutableString *consoleText;
@property (nonatomic, strong) dispatch_queue_t operationQueue;
@property (nonatomic, strong) dispatch_queue_t dataQueue;
@end

@implementation ViewController

- (IBAction)stopAction:(id)sender {
    [self.manager stopScan];
}

- (IBAction)buttonAction:(id)sender {
    [self.manager stopScan];
    self.textView.text = @"scan for peripherals......";
    self.consoleText = [NSMutableString string];
    [[[[[[[self.manager scanForPeripheralsWithServices:nil] then:^id _Nullable(BKDiscovery * discovery) {
        NSLog(@"peripheral localName is %@", discovery.localName);
        [self.consoleText appendFormat:@"peripheral localName is %@", discovery.localName ?: @"unknown"];
        self.textView.text = self.consoleText;
        return [self.manager connectPeripheral:discovery.peripheral];
    }] then:^id _Nullable(CBPeripheral *peripheral) {
        [self.consoleText appendString:@"\n--------------------------\n"];
        [self.consoleText appendFormat:@"connect peripheral is %@", peripheral.description];
        self.textView.text = self.consoleText;
        NSLog(@"connect peripheral is %@", peripheral.description);
        return [self.manager discoverServices:nil forPeripheral:peripheral];
    }] then:^id _Nullable(NSArray<CBService *> *services) {
        [self.consoleText appendString:@"\n--------------------------\n"];
        [self.consoleText appendFormat:@"discover services is %@", services.description];
        self.textView.text = self.consoleText;
        NSLog(@"discover services is %@", services.description);
        return [self.manager discoverCharacteristics:nil forService:services.firstObject];
    }] then:^id _Nullable(NSArray<CBCharacteristic *> *characteristics) {
        [self.consoleText appendString:@"\n--------------------------\n"];
        [self.consoleText appendFormat:@"discover characteristics is %@", characteristics.description];
        self.textView.text = self.consoleText;
        NSLog(@"discover characteristics is %@", characteristics.description);
        return [self.manager readValueForCharacteristic:characteristics.firstObject];
    }] then:^id _Nullable(NSData *value) {
        [self.consoleText appendString:@"\n--------------------------\n"];
        NSString *str = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
        [self.consoleText appendFormat:@"read value for characteristics is %@", str];
        self.textView.text = self.consoleText;
        NSLog(@"read value for characteristics is %@", str);
        return NULL;
    }] catch:^(NSError * _Nonnull error) {
        [self.consoleText appendString:@"\n--------------------------\n"];
        NSString *str = [NSString stringWithFormat:@"catch error: %@", error.localizedDescription];
        [self.consoleText appendString:str];
        self.textView.text = self.consoleText;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.manager = [BKCBCentralManager manager];
    self.textView.text = @"bluetooth standby";
    self.textView.layer.borderColor = [UIColor redColor].CGColor;
    self.textView.layer.borderWidth = 1;
    
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
    
    RadarOptions *options = [[RadarOptions alloc] init];
    
    CBUUID *serviceUUID = [CBUUID UUIDWithString:@"8EE4CFC9-9DB5-417D-A08A-EE397C54672F"];
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:@"A265E5E3-1E11-4E55-B725-95465188B4FE"];
    
    RadarRequest *request = [[RadarRequest alloc] initWithServiceUUID:serviceUUID characteristicUUID:characteristicUUID];
    request.response = ^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        
    };
    
    [Bleu sendRequest:request options:options completionHandler:^(NSDictionary * _Nullable info, NSError * _Nullable error) {
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
