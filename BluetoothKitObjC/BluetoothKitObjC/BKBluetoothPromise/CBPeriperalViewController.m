//
//  CBPeriperalViewController.m
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/10/25.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import "CBPeriperalViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeriperalViewController () <CBPeripheralManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBMutableCharacteristic *heartCharacter;
@property (nonatomic, strong) CBMutableCharacteristic *writeCharacter;
@property (strong, nonatomic) NSMutableString *consoleText;

@end

@implementation CBPeriperalViewController

- (IBAction)buttonAction:(id)sender {
    [self.peripheralManager stopAdvertising];
    [self setupServicesAndCharacteristics];
}

- (IBAction)stopAdvertising:(id)sender {
    
    [self.peripheralManager stopAdvertising];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *options = @{CBPeripheralManagerOptionShowPowerAlertKey: @YES};
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:options];
    self.textView.text = @"peripheral standby";
    self.textView.layer.borderColor = [UIColor redColor].CGColor;
    self.textView.layer.borderWidth = 1;
}

// A265E5E3-1E11-4E55-B725-95465188B4FE
// 0882D876-F3C1-4487-803F-E437E1701AA2
// 4B25B1C8-27EE-4B9E-9BB7-F16C8CABC6DB
// 9C868D9E-4DD6-49F7-90FD-51A29BBB90D7
- (void)setupServicesAndCharacteristics {
    CBUUID *heartRateServiceUUID = [CBUUID UUIDWithString:@"180D"];
    CBUUID *UUID1 = [CBUUID UUIDWithString:@"A265E5E3-1E11-4E55-B725-95465188B4FE"];
    CBUUID *UUID2 = [CBUUID UUIDWithString:@"0882D876-F3C1-4487-803F-E437E1701AA2"];
    CBUUID *UUID3 = [CBUUID UUIDWithString:@"4B25B1C8-27EE-4B9E-9BB7-F16C8CABC6DB"];
    CBUUID *UUID4 = [CBUUID UUIDWithString:@"9C868D9E-4DD6-49F7-90FD-51A29BBB90D7"];
    
    CBMutableCharacteristic *heartCharacter = [[CBMutableCharacteristic alloc] initWithType:heartRateServiceUUID properties:CBCharacteristicPropertyRead value:[@"heart beating" dataUsingEncoding:NSUTF8StringEncoding] permissions:CBAttributePermissionsReadable];
    CBMutableCharacteristic *character1 = [[CBMutableCharacteristic alloc] initWithType:UUID1 properties:CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsWriteable];
    CBMutableCharacteristic *character2 = [[CBMutableCharacteristic alloc] initWithType:UUID2 properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsWriteable];
    CBMutableCharacteristic *character3 = [[CBMutableCharacteristic alloc] initWithType:UUID3 properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsWriteable];
    CBMutableCharacteristic *character4 = [[CBMutableCharacteristic alloc] initWithType:UUID4 properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsWriteable];
    
    CBUUID *CBUUIDCharacteristicUserDescriptionStringUUID = [CBUUID UUIDWithString:CBUUIDCharacteristicUserDescriptionString];
    CBMutableDescriptor *desc = [[CBMutableDescriptor alloc]initWithType: CBUUIDCharacteristicUserDescriptionStringUUID value:@"hello BLE"];
    [character1 setDescriptors:@[desc]];
    [character2 setDescriptors:@[desc]];
    [character3 setDescriptors:@[desc]];
    [character4 setDescriptors:@[desc]];
    
    self.heartCharacter = heartCharacter;
    self.writeCharacter = character1;
    
    CBUUID *serviceUUID = [CBUUID UUIDWithString:@"8EE4CFC9-9DB5-417D-A08A-EE397C54672F"];
    CBMutableService *service = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    service.characteristics = @[heartCharacter, character1, character2, character3, character4];
    [self.peripheralManager removeAllServices];
    [self.peripheralManager addService:service];
}

#pragma mark - CBPeripheralManager Delegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSLog(@"Peripheral Manager Did Update State");
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"CBPeripheralManagerStatePoweredOn");
            break;
            
        case CBPeripheralManagerStatePoweredOff:
            NSLog(@"CBPeripheralManagerStatePoweredOff");
            break;
            
        case CBPeripheralManagerStateUnsupported:
            NSLog(@"CBPeripheralManagerStateUnsupported");
            break;
            
        default:
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Add Service Failed: %@", error);
        return;
    }
    NSLog(@"Add Service Successfully");
    [peripheral startAdvertising:@{CBAdvertisementDataLocalNameKey: @"BluetoothKit", CBAdvertisementDataServiceUUIDsKey: @[service.UUID]}];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary<NSString *,id> *)state {
    
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    if (error) {
        NSLog(@"Start Advertising Failed");
        return;
    }
    self.textView.text = @"start advertising ......";
    NSLog(@"Start Advertising ......");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    self.textView.text = @">>>>>> did Receive Read Request";
    if ([request.characteristic.UUID isEqual:_heartCharacter.UUID]) {
        
        NSLog(@"didReceiveReadRequest: %@", request);
        
        if (request.offset > _heartCharacter.value.length) {
            [peripheral respondToRequest:request withResult:CBATTErrorInvalidOffset];
            return;
        }
        
        NSRange range = (NSRange){request.offset, _heartCharacter.value.length - request.offset};
        request.value = [_heartCharacter.value subdataWithRange:range];
        [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    self.textView.text = @">>>>>> did Receive Write Requests";
    
    CBATTRequest *request = requests.firstObject;
    
    _writeCharacter.value = request.value;
    
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(nonnull CBCentral *)central didSubscribeToCharacteristic:(nonnull CBCharacteristic *)characteristic {
    
    self.textView.text = @">>>>>> central subscribed to characteristic";
    
    NSLog(@"Central subscribed to characteristic %@", characteristic);
    
    NSData *updatedData = characteristic.value;
    BOOL didSendValue = [peripheral updateValue:updatedData forCharacteristic:(CBMutableCharacteristic *)characteristic onSubscribedCentrals:nil];
    
    NSLog(@"Send updated data to centrals ? %@", (didSendValue ? @"successed" : @"failed"));
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(nonnull CBCentral *)central didUnsubscribeFromCharacteristic:(nonnull CBCharacteristic *)characteristic {
    NSLog(@"Central unsubscribed from characteristic %@", characteristic);
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    NSLog(@"当传输队列有可用的空间时, 重新发送值");
}

@end
