//
//  PeripheralModeViewController.m
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/12/8.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import "PeripheralModeViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <Masonry.h>

#define SERVICE_UUID @"CDD1"
#define CHARACTERISTIC_UUID @"CDD2"

@interface PeripheralModeViewController ()
<CBPeripheralManagerDelegate>

@property (weak, nonatomic) UITextField *textField;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBMutableCharacteristic *characteristic;
@end

@implementation PeripheralModeViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.textField resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.peripheralManager stopAdvertising];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"蓝牙外设";
    // 创建外设管理器，会回调peripheralManagerDidUpdateState方法
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    
    UITextField *textField = [[UITextField alloc] init];
    textField.font = [UIFont systemFontOfSize:15];
    textField.textColor = [UIColor blackColor];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:textField];
    self.textField = textField;
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(260, 40));
        make.top.mas_equalTo(100);
        make.centerX.equalTo(self.view);
    }];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.contentEdgeInsets = UIEdgeInsetsMake(4, 6, 4, 6);
    sendBtn.layer.borderColor = [UIColor grayColor].CGColor;
    sendBtn.layer.borderWidth = 0.5;
    [sendBtn setTitle:@"send data" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendBtn];
    [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textField.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
    }];
}

/** 通过固定的特征发送数据到中心设备 */
- (void)sendAction {
    BOOL sendSuccess = [self.peripheralManager updateValue:[self.textField.text dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.characteristic onSubscribedCentrals:nil];
    if (sendSuccess) {
        NSLog(@"数据发送成功");
    }else {
        NSLog(@"数据发送失败");
    }
}

/** 设备的蓝牙状态
 CBManagerStateUnknown = 0,  未知
 CBManagerStateResetting,    重置中
 CBManagerStateUnsupported,  不支持
 CBManagerStateUnauthorized, 未验证
 CBManagerStatePoweredOff,   未启动
 CBManagerStatePoweredOn,    可用
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state == CBManagerStatePoweredOn) {
        // 创建Service（服务）和Characteristics（特征）
        [self setupServiceAndCharacteristics];
        // 根据服务的UUID开始广播
        [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:SERVICE_UUID]]}];
    }
}

/** 创建服务和特征 */
- (void)setupServiceAndCharacteristics {
    // 创建服务
    CBUUID *serviceID = [CBUUID UUIDWithString:SERVICE_UUID];
    CBMutableService *service = [[CBMutableService alloc] initWithType:serviceID primary:YES];
    // 创建服务中的特征
    CBUUID *characteristicID = [CBUUID UUIDWithString:CHARACTERISTIC_UUID];
    CBMutableCharacteristic *characteristic = [
                                               [CBMutableCharacteristic alloc]
                                               initWithType:characteristicID
                                               properties:
                                               CBCharacteristicPropertyRead |
                                               CBCharacteristicPropertyWrite |
                                               CBCharacteristicPropertyNotify
                                               value:nil
                                               permissions:CBAttributePermissionsReadable |
                                               CBAttributePermissionsWriteable
                                               ];
    // 特征添加进服务
    service.characteristics = @[characteristic];
    // 服务加入管理
    [self.peripheralManager addService:service];
    
    // 为了手动给中心设备发送数据
    self.characteristic = characteristic;
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Add Service Failed: %@", error);
        return;
    }
    NSLog(@"Add Service Successfully! Start Advertising......");
    [peripheral startAdvertising:@{CBAdvertisementDataLocalNameKey: @"my_test_ble", CBAdvertisementDataServiceUUIDsKey: @[service.UUID]}];
}

/** 中心设备读取数据的时候回调 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    // 请求中的数据，这里把文本框中的数据发给中心设备
    request.value = [self.textField.text dataUsingEncoding:NSUTF8StringEncoding];
    // 成功响应请求
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}

/** 中心设备写入数据的时候回调 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    // 写入数据的请求
    CBATTRequest *request = requests.lastObject;
    // 把写入的数据显示在文本框中
    self.textField.text = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
}

/** 订阅成功回调 */
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"%s",__FUNCTION__);
}

/** 取消订阅回调 */
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"%s",__FUNCTION__);
}


@end
