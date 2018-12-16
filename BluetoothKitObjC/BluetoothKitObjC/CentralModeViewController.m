//
//  CentralModeViewController.m
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/12/8.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import "CentralModeViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <Masonry.h>
#import "BLECentralManager.h"

#define SERVICE_UUID        @"CDD1"
#define CHARACTERISTIC_UUID @"CDD2"

@interface CentralModeViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate, BLEDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;
@property (weak, nonatomic) UITextField *textField;

@property (nonatomic, strong) BLECentralManager *centralBLE;

@end

@implementation CentralModeViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.textField resignFirstResponder];
}

#pragma mark - BLEDelegate

- (void)bleDidDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    [self.centralBLE connectPeripheral:peripheral];
}

- (void)bleDidReceiveData:(unsigned char *)data length:(NSUInteger)length {
    BLELog(@"bleDidReceiveData");
    
    // Append to the buffer
    NSData *d = [NSData dataWithBytes:data length:length];
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    BLELog(@"Received data %@", s);
    self.textField.text = s;
}

- (void)bleDidChangeState:(BOOL)isEnabled {
    NSString *state = isEnabled ? @"bluetoothEnabled" : @"bluetoothDisabled";
    BLELog(@"bleDidChangedState: %@", state);
    if (isEnabled) {
        [self.centralBLE findBLEPeripherals:10.0];
    }
}

- (void)bleDidConnect {
    BLELog(@"bleDidConnect");
}

- (void)bleDidDisconnect {
    BLELog(@"bleDidDisconnect");
}

- (void)bleDidReadRSSI:(NSNumber *)rssi {
    BLELog(@"bleDidReadRSSI: %@", rssi);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.centralBLE cancelConnection];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"蓝牙中心设备";
    // 创建中心设备管理器，会回调centralManagerDidUpdateState
//    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    
    self.centralBLE = [BLECentralManager manager];
    self.centralBLE.delegate = self;
    
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
    [sendBtn setTitle:@"write data" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendBtn];
    [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textField.mas_bottom).offset(20);
        make.left.equalTo(textField.mas_left);
    }];
    
    UIButton *fetchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    fetchBtn.contentEdgeInsets = UIEdgeInsetsMake(4, 6, 4, 6);
    fetchBtn.layer.borderColor = [UIColor grayColor].CGColor;
    fetchBtn.layer.borderWidth = 0.5;
    [fetchBtn setTitle:@"fetch data" forState:UIControlStateNormal];
    [fetchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [fetchBtn addTarget:self action:@selector(fetchAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fetchBtn];
    [fetchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textField.mas_bottom).offset(20);
        make.right.equalTo(textField.mas_right);
    }];
    
    UIButton *readBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    readBtn.contentEdgeInsets = UIEdgeInsetsMake(4, 6, 4, 6);
    readBtn.layer.borderColor = [UIColor grayColor].CGColor;
    readBtn.layer.borderWidth = 0.5;
    [readBtn setTitle:@"read rssi" forState:UIControlStateNormal];
    [readBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [readBtn addTarget:self action:@selector(readAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:readBtn];
    [readBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fetchBtn.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
    }];
}

- (void)readAction {
    [self.centralBLE readRSSI];
}

/** 读取数据 */
- (void)fetchAction {
//    [self.peripheral readValueForCharacteristic:self.characteristic];
    [self.centralBLE read];
}

/** 写入数据 */
- (void)sendAction {
    // 用NSData类型来写入
    NSData *data = [self.textField.text dataUsingEncoding:NSUTF8StringEncoding];
    // 根据上面的特征self.characteristic来写入数据
//    [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    
    [self.centralBLE write:data];
}

/** 判断手机蓝牙状态
 CBManagerStateUnknown = 0,  未知
 CBManagerStateResetting,    重置中
 CBManagerStateUnsupported,  不支持
 CBManagerStateUnauthorized, 未验证
 CBManagerStatePoweredOff,   未启动
 CBManagerStatePoweredOn,    可用
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    // 蓝牙可用，开始扫描外设
    if (central.state == CBManagerStatePoweredOn) {
        NSLog(@"蓝牙可用");
        // 根据SERVICE_UUID来扫描外设，如果不设置SERVICE_UUID，则扫描所有蓝牙设备
        [central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICE_UUID]] options:nil];
    }
    if(central.state == CBManagerStateUnsupported) {
        NSLog(@"该设备不支持蓝牙");
    }
    if (central.state == CBManagerStatePoweredOff) {
        NSLog(@"蓝牙已关闭");
    }
}

/** 发现符合要求的外设，回调 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    // 对外设对象进行强引用
    self.peripheral = peripheral;
    
    //    if ([peripheral.name hasPrefix:@"WH"]) {
    //        // 可以根据外设名字来过滤外设
    //        [central connectPeripheral:peripheral options:nil];
    //    }
    
    // 连接外设
    [central connectPeripheral:peripheral options:nil];
}

/** 连接成功 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    // 可以停止扫描
    [self.centralManager stopScan];
    // 设置代理
    peripheral.delegate = self;
    // 根据UUID来寻找服务
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_UUID]]];
    NSLog(@"连接成功");
}

/** 连接失败的回调 */
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"连接失败");
}

/** 断开连接 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"断开连接");
    // 断开连接可以设置重新连接
    [central connectPeripheral:peripheral options:nil];
}

#pragma mark -
#pragma mark - CBPeripheralDelegate

/** 发现服务 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    // 遍历出外设中所有的服务
    for (CBService *service in peripheral.services) {
        NSLog(@"所有的服务：%@",service);
    }
    
    // 这里仅有一个服务，所以直接获取
    CBService *service = peripheral.services.lastObject;
    // 根据UUID寻找服务中的特征
    [peripheral discoverCharacteristics:nil forService:service];
}

/** 发现特征回调 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    // 遍历出所需要的特征
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"所有特征：%@", characteristic);
        // 从外设开发人员那里拿到不同特征的UUID，不同特征做不同事情，比如有读取数据的特征，也有写入数据的特征
    }
    
    // 这里只获取一个特征，写入数据的时候需要用到这个特征
    self.characteristic = service.characteristics.lastObject;
    
    // 直接读取这个特征数据，会调用didUpdateValueForCharacteristic
    //    [peripheral readValueForCharacteristic:self.characteristic];
    
    // 订阅通知
    //    [peripheral setNotifyValue:YES forCharacteristic:self.characteristic];
    
    // 直接读取这个特征数据，会调用didUpdateValueForCharacteristic
    if (self.characteristic.properties & CBCharacteristicPropertyRead) {
        [peripheral readValueForCharacteristic:self.characteristic];
    }  
    
    // 订阅通知
    if (self.characteristic.properties & CBCharacteristicPropertyNotify) {
        [peripheral setNotifyValue:YES forCharacteristic:self.characteristic];
    }
}

/** 订阅状态的改变 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"订阅失败");
        NSLog(@"%@",error);
    }
    if (characteristic.isNotifying) {
        NSLog(@"订阅成功");
    } else {
        NSLog(@"取消订阅");
    }
}

/** 接收到数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    // 拿到外设发送过来的数据
    NSData *data = characteristic.value;
    self.textField.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

/** 写入数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"写入成功");
}

@end
