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

@property (nonatomic, strong) BKCBCentralManager *manager;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) NSMutableString *consoleText;

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
    self.manager = [BKCBCentralManager manager];
    self.textView.text = @"bluetooth standby";
    self.textView.layer.borderColor = [UIColor redColor].CGColor;
    self.textView.layer.borderWidth = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
