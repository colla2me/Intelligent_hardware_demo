//
//  ViewController.m
//  BluetoothKitObjC
//
//  Created by samuel on 2018/10/16.
//  Copyright © 2018 samuel. All rights reserved.
//

#import "ViewController.h"
//#import "BKCBCentralManager.h"
#import "Bleu.h"
#import "Pulsator.h"

@interface ViewController ()<CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBMutableCharacteristic *heartCharacter;
@property (nonatomic, strong) CBMutableCharacteristic *writeCharacter;

//@property (nonatomic, strong) BKCBCentralManager *manager;
//@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) NSMutableString *consoleText;
@property (nonatomic, strong) dispatch_queue_t operationQueue;
@property (nonatomic, strong) dispatch_queue_t dataQueue;
@property (nonatomic, strong) Pulsator *pulsator;
@end

const float kMaxRadius = 200.0;
const float kMaxDuration = 10.0;

@implementation ViewController

- (void)setupPeripheralMode {
//    NSDictionary *options = @{CBPeripheralManagerOptionShowPowerAlertKey: @YES};
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    self.resultLabel.text = @"stand by";
    self.messageView.editable = NO;
}

- (void)setupCentralMode {
    RadarOptions *options = [[RadarOptions alloc] init];
    
    CBUUID *serviceUUID = [CBUUID UUIDWithString:@"8EE4CFC9-9DB5-417D-A08A-EE397C54672F"];
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:@"A265E5E3-1E11-4E55-B725-95465188B4FE"];
    
    RadarRequest *request = [[RadarRequest alloc] initWithServiceUUID:serviceUUID characteristicUUID:characteristicUUID];
    
    request.response = ^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {};
    
    [Bleu sendRequest:request options:options completionHandler:^(NSDictionary * _Nullable info, NSError * _Nullable error) {
        NSLog(@"[Bleu sendRequest]>>>>>>>> info: %@, error: %@", info, error);
    }];
    
    self.messageView.editable = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self setupPeripheralMode];

//    [self setupCentralMode];
    self.pulsator = [[Pulsator alloc] init];
    [self setupPalsotor];
    [self.sourceView.layer.superlayer insertSublayer:self.pulsator below:self.sourceView.layer];
    
    NSString *testName = @"test_ble_peripheral";
    if ([testName hasPrefix:@"test_ble_peripheral"]) {
        NSLog(@"matched !!!!");
    }
}

- (void)setupPalsotor {
    self.countSlider.value = 5;
    [self countChanged:self.countSlider];
    
    self.radiusSlider.value = 0.7;
    [self radiusChanged:self.radiusSlider];
    
    self.durationSlider.value = 0.5;
    [self durationChanged:self.durationSlider];
    
    self.rSlider.value = 0;
    self.gSlider.value = 0.455;
    self.bSlider.value = 0.756;
    self.aSlider.value = 1;
    [self colorChanged:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.pulsator.position = self.sourceView.layer.position;
}

- (IBAction)sendAction:(UIBarButtonItem *)sender {
    if (self.peripheralManager) return;
    if (!self.messageView.text.length) return;
    NSData *data = [self.messageView.text dataUsingEncoding:NSUTF8StringEncoding];
    [[Bleu shared].radar sendData:data];
}

- (IBAction)refreshAction:(UIBarButtonItem *)sender {
    [Bleu cancel];
}

- (IBAction)switchChanged:(UISwitch *)sender {
    if (sender.isOn) {
        [self.pulsator start];
    } else {
        [self.pulsator stop];
    }
}

- (IBAction)advertisingChanged:(UISwitch *)sender {
    if (sender.isOn) {
        [self.pulsator start];
        [self.peripheralManager startAdvertising:@{CBAdvertisementDataLocalNameKey: @"30days-tech-ble", CBAdvertisementDataServiceUUIDsKey: @[[CBUUID UUIDWithString:@"8EE4CFC9-9DB5-417D-A08A-EE397C54672F"]]}];
    } else {
        [self.pulsator stop];
        [self.peripheralManager stopAdvertising];
        self.resultLabel.text = @"Stop Advertising";
    }
}

- (IBAction)countChanged:(UISlider *)sender {
    self.pulsator.numPulse = (NSUInteger)sender.value;
    self.countLabel.text = @(self.pulsator.numPulse).stringValue;
}

- (IBAction)radiusChanged:(UISlider *)sender {
    self.pulsator.radius = sender.value * kMaxRadius;
    self.radiusLabel.text = [NSString stringWithFormat:@"%.0f", self.pulsator.radius];
}

- (IBAction)durationChanged:(UISlider *)sender {
    self.pulsator.animationDuration = sender.value * kMaxDuration;
    self.durationLabel.text = [NSString stringWithFormat:@"%.0f", self.pulsator.animationDuration];
}

- (IBAction)colorChanged:(UISlider *)sender {
    self.pulsator.backgroundColor = [UIColor colorWithRed:self.rSlider.value green:self.gSlider.value blue:self.bSlider.value alpha:self.aSlider.value].CGColor;
    
    self.rLabel.text = [NSString stringWithFormat:@"%.2f", self.rSlider.value];
    self.gLabel.text = [NSString stringWithFormat:@"%.2f", self.gSlider.value];
    self.bLabel.text = [NSString stringWithFormat:@"%.2f", self.bSlider.value];
    self.aLabel.text = [NSString stringWithFormat:@"%.2f", self.aSlider.value];
}

#pragma mark - CBPeripheralManager Delegate

- (void)setupServicesAndCharacteristics {
    CBUUID *heartRateServiceUUID = [CBUUID UUIDWithString:@"180D"];
    CBUUID *UUID1 = [CBUUID UUIDWithString:@"A265E5E3-1E11-4E55-B725-95465188B4FE"];
    CBUUID *UUID2 = [CBUUID UUIDWithString:@"0882D876-F3C1-4487-803F-E437E1701AA2"];
    CBUUID *UUID3 = [CBUUID UUIDWithString:@"4B25B1C8-27EE-4B9E-9BB7-F16C8CABC6DB"];
    CBUUID *UUID4 = [CBUUID UUIDWithString:@"9C868D9E-4DD6-49F7-90FD-51A29BBB90D7"];
    
    CBMutableCharacteristic *heartCharacter = [[CBMutableCharacteristic alloc] initWithType:heartRateServiceUUID properties:CBCharacteristicPropertyRead value:[@"heart beating" dataUsingEncoding:NSUTF8StringEncoding] permissions:CBAttributePermissionsReadable];
    CBMutableCharacteristic *character1 = [[CBMutableCharacteristic alloc] initWithType:UUID1 properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    CBMutableCharacteristic *character2 = [[CBMutableCharacteristic alloc] initWithType:UUID2 properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsWriteable];
    CBMutableCharacteristic *character3 = [[CBMutableCharacteristic alloc] initWithType:UUID3 properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsWriteable];
    CBMutableCharacteristic *character4 = [[CBMutableCharacteristic alloc] initWithType:UUID4 properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsWriteable];
    
    CBUUID *CBUUIDCharacteristicUserDescriptionStringUUID = [CBUUID UUIDWithString:CBUUIDCharacteristicUserDescriptionString];
    CBMutableDescriptor *desc = [[CBMutableDescriptor alloc] initWithType: CBUUIDCharacteristicUserDescriptionStringUUID value:@"hello BLE"];
    [character1 setDescriptors:@[desc]];
    [character2 setDescriptors:@[desc]];
    [character3 setDescriptors:@[desc]];
    [character4 setDescriptors:@[desc]];
    
    self.heartCharacter = heartCharacter;
    self.writeCharacter = character1;
    
    CBUUID *serviceUUID = [CBUUID UUIDWithString:@"8EE4CFC9-9DB5-417D-A08A-EE397C54672F"];
    CBMutableService *service = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    service.characteristics = @[heartCharacter, character1, character2, character3, character4];
//    [self.peripheralManager removeAllServices];
    [self.peripheralManager addService:service];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSLog(@"Peripheral Manager Did Update State");
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"CBPeripheralManagerStatePoweredOn");
//            break;
            return;
            
        case CBPeripheralManagerStatePoweredOff:
            NSLog(@"CBPeripheralManagerStatePoweredOff");
            [self.peripheralManager stopAdvertising];
            break;
            
        case CBPeripheralManagerStateUnsupported:
            NSLog(@"CBPeripheralManagerStateUnsupported");
            break;
            
        default:
            break;
    }
    
    [self setupServicesAndCharacteristics];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Add Service Failed: %@", error);
        return;
    }
    NSLog(@"Add Service Successfully! Start Advertising......");
    [peripheral startAdvertising:@{CBAdvertisementDataLocalNameKey: @"30days-tech-ble", CBAdvertisementDataServiceUUIDsKey: @[service.UUID]}];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary<NSString *,id> *)state {
    
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    if (error) {
        NSLog(@"Start Advertising Failed");
        return;
    }
    self.resultLabel.text = @"start advertising ......";
    NSLog(@"Start Advertising ......");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    self.resultLabel.text = @">>>>>> did Receive Read Request";
    if ([request.characteristic.UUID isEqual:_heartCharacter.UUID]) {
        
        NSLog(@"didReceiveReadRequest: %@", request);
        
        if (request.offset > _heartCharacter.value.length) {
            [peripheral respondToRequest:request withResult:CBATTErrorInvalidOffset];
            return;
        }
        
        NSRange range = (NSRange){request.offset, _heartCharacter.value.length - request.offset};
        if (range.location == NSNotFound) return;
        request.value = [_heartCharacter.value subdataWithRange:range];
        [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    self.resultLabel.text = @">>>>>> did Receive Write Requests";
    
    CBATTRequest *request = requests.firstObject;
    
    _writeCharacter.value = request.value;
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
    self.messageView.text = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(nonnull CBCentral *)central didSubscribeToCharacteristic:(nonnull CBCharacteristic *)characteristic {
    
    self.resultLabel.text = @">>>>>> central subscribed to characteristic";
    
    NSLog(@"Central subscribed to characteristic %@", characteristic);
    
    NSData *updatedData = characteristic.value;
    if (!updatedData) return;
    BOOL didSendValue = [peripheral updateValue:updatedData forCharacteristic:(CBMutableCharacteristic *)characteristic onSubscribedCentrals:nil];
    
    self.messageView.text = [[NSString alloc] initWithData:updatedData encoding:NSUTF8StringEncoding];
    NSLog(@"Send updated data to centrals ? %@", (didSendValue ? @"successed" : @"failed"));
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(nonnull CBCentral *)central didUnsubscribeFromCharacteristic:(nonnull CBCharacteristic *)characteristic {
    NSLog(@"Central unsubscribed from characteristic %@", characteristic);
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    NSLog(@"当传输队列有可用的空间时, 重新发送值");
}

@end
