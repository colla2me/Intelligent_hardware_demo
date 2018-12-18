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
#import "BLECell.h"

#define SERVICE_UUID        @"180D"
#define CHARACTERISTIC_UUID @"2A37"

static NSString * const DEVICE_INFO_SERVICE_UUID  =  @"180A";
static NSString * const SYSTEM_ID_SERVICE_UUID   =   @"2A23";

@interface CentralModeViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate, BLEDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;
@property (weak, nonatomic) UITextField *textField;

@property (nonatomic, strong) BLECentralManager *centralBLE;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<CBPeripheral *> *discoveredPeripherals;
@end

@implementation CentralModeViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.textField resignFirstResponder];
}

#pragma mark - BLEDelegate

- (void)bleDidDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    [self.centralBLE connectPeripheral:peripheral];
    [self.discoveredPeripherals addObject:peripheral];
    [self.tableView reloadData];
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
        [self.centralBLE findBLEPeripherals:3.0];
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
    [self cancelConnection];
}

- (void)cancelConnection {
    if (self.centralManager) {
        if (self.peripheral) {
            [self.centralManager cancelPeripheralConnection:self.peripheral];
            if (self.characteristic) {
                [self.peripheral setNotifyValue:NO forCharacteristic:self.characteristic];
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    self.title = @"蓝牙中心设备";
    // 创建中心设备管理器，会回调centralManagerDidUpdateState
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    
//    self.centralBLE = [BLECentralManager manager];
//    self.centralBLE.delegate = self;
    
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
    
    UIButton *sendBtn = [self buttonWithTitle:@"write data" action:@selector(sendAction)];
    [self.view addSubview:sendBtn];
    [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textField.mas_bottom).offset(20);
        make.left.equalTo(textField.mas_left);
    }];
    
    UIButton *fetchBtn = [self buttonWithTitle:@"fetch data" action:@selector(fetchAction)];
    [self.view addSubview:fetchBtn];
    [fetchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textField.mas_bottom).offset(20);
        make.right.equalTo(textField.mas_right);
    }];
    
    UIButton *readBtn = [self buttonWithTitle:@"read rssi" action:@selector(readAction)];
    [self.view addSubview:readBtn];
    [readBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sendBtn.mas_bottom).offset(20);
        make.left.equalTo(textField.mas_left);
    }];
    
    UIButton *scanBtn = [self buttonWithTitle:@"scan peripheral" action:@selector(scanAction)];
    [self.view addSubview:scanBtn];
    [scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fetchBtn.mas_bottom).offset(20);
        make.right.equalTo(textField.mas_right);
    }];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 44;
    tableView.layer.borderColor = [UIColor grayColor].CGColor;
    tableView.layer.borderWidth = 0.5;
    tableView.showsVerticalScrollIndicator = NO;
    [tableView registerClass:[BLECell class] forCellReuseIdentifier:@"ble"];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(scanBtn.mas_bottom).offset(40);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(-120);
    }];
}

- (void)readAction {
    if (self.centralBLE) {
        [self.centralBLE readRSSI];
    } else {
        [self.peripheral readRSSI];
    }
}

/** 读取数据 */
- (void)fetchAction {
    if (self.centralBLE) {
        [self.centralBLE read];
    } else {
        [self.peripheral readValueForCharacteristic:self.characteristic];
    }
}

/** 写入数据 */
- (void)sendAction {
    // 用NSData类型来写入
    NSData *data = [self.textField.text dataUsingEncoding:NSUTF8StringEncoding];
    // 根据上面的特征self.characteristic来写入数据
    
    if (self.centralBLE) {
        [self.centralBLE write:data];
    } else {
        [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    }
}

- (void)scanAction {
    [self.centralBLE findBLEPeripherals:3.0];
}

- (UIButton *)buttonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *readBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    readBtn.contentEdgeInsets = UIEdgeInsetsMake(4, 6, 4, 6);
    readBtn.layer.borderColor = [UIColor grayColor].CGColor;
    readBtn.layer.borderWidth = 0.5;
    [readBtn setTitle:title forState:UIControlStateNormal];
    [readBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [readBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return readBtn;
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
        // @[[CBUUID UUIDWithString:SERVICE_UUID]]
        // 根据SERVICE_UUID来扫描外设，如果不设置SERVICE_UUID，则扫描所有蓝牙设备
        [central scanForPeripheralsWithServices:nil options:nil];
        [NSTimer scheduledTimerWithTimeInterval:20.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
            [central stopScan];
        }];
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
    
    NSString *peripheralName = peripheral.name ?: advertisementData[CBAdvertisementDataLocalNameKey];
    NSLog(@"didDiscoverPeripheral: %@ | name: %@", peripheral.identifier, peripheralName);
    
    if (!_discoveredPeripherals) {
        self.discoveredPeripherals = [NSMutableArray arrayWithObject:peripheral];
    } else {
        for(int i = 0; i < self.discoveredPeripherals.count; i++)
        {
            CBPeripheral *p = [self.discoveredPeripherals objectAtIndex:i];
            
            if ((p.identifier == NULL) || (peripheral.identifier == NULL))
                continue;
            
            if ([p.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString])
            {
                [self.discoveredPeripherals replaceObjectAtIndex:i withObject:peripheral];
                BLELog(@"Duplicate UUID found updating...");
                return;
            }
        }
        
        [self.discoveredPeripherals addObject:peripheral];
    }
    
    static NSString * const BAND_PREFIX = @"X10"; // @"DBN_"
    if (peripheral.name && [peripheral.name hasPrefix:BAND_PREFIX]) {
        // 对外设对象进行强引用
        self.peripheral = peripheral;
        // 连接外设
        [central connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey: @YES}];
    }
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.discoveredPeripherals.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
}

/** 连接成功 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    // 可以停止扫描
    [self.centralManager stopScan];
    // 设置代理
    peripheral.delegate = self;
    // 根据UUID来寻找服务
    [peripheral discoverServices:nil];
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
    [central connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey: @YES}];
}

#pragma mark -
#pragma mark - CBPeripheralDelegate

/** 发现服务 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    // 遍历出外设中所有的服务
    for (CBService *service in peripheral.services) {
        NSLog(@"所有的服务UUID：%@",service.UUID.UUIDString);
        if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_INFO_SERVICE_UUID]]) {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
    
    // 这里仅有一个服务，所以直接获取
    CBService *service = peripheral.services.lastObject;
    // 根据UUID寻找服务中的特征
    if (service) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

/** 发现特征回调 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    // 遍历出所需要的特征
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"所有特征：%@", characteristic);
        // 从外设开发人员那里拿到不同特征的UUID，不同特征做不同事情，比如有读取数据的特征，也有写入数据的特征
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SYSTEM_ID_SERVICE_UUID]]) {
            [peripheral readValueForCharacteristic:characteristic];
        }
        
        // 直接读取这个特征数据，会调用didUpdateValueForCharacteristic
        if (self.characteristic.properties & CBCharacteristicPropertyRead) {
            [peripheral readValueForCharacteristic:self.characteristic];
        }
        
        // 订阅通知
        if (self.characteristic.properties & CBCharacteristicPropertyNotify) {
            [peripheral setNotifyValue:YES forCharacteristic:self.characteristic];
        }
    }
    
    // 这里只获取一个特征，写入数据的时候需要用到这个特征
    self.characteristic = service.characteristics.lastObject;
    
    // 直接读取这个特征数据，会调用didUpdateValueForCharacteristic
    //    [peripheral readValueForCharacteristic:self.characteristic];
    
    // 订阅通知
    //    [peripheral setNotifyValue:YES forCharacteristic:self.characteristic];
    
    // 直接读取这个特征数据，会调用didUpdateValueForCharacteristic
//    if (self.characteristic.properties & CBCharacteristicPropertyRead) {
//        [peripheral readValueForCharacteristic:self.characteristic];
//    }
    
    // 订阅通知
//    if (self.characteristic.properties & CBCharacteristicPropertyNotify) {
//        [peripheral setNotifyValue:YES forCharacteristic:self.characteristic];
//    }
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
//    [self getHeartBPMData:characteristic error:error];
    NSString *desc = characteristic.value.description;
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SYSTEM_ID_SERVICE_UUID]]) {
        NSMutableString *macString = [[NSMutableString alloc] init];
        [macString appendString:[[desc substringWithRange:NSMakeRange(16, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[desc substringWithRange:NSMakeRange(14, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[desc substringWithRange:NSMakeRange(12, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[desc substringWithRange:NSMakeRange(5, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[desc substringWithRange:NSMakeRange(3, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[desc substringWithRange:NSMakeRange(1, 2)] uppercaseString]];
        NSLog(@"MAC 地址: %@", macString);
    }
}

/** 写入数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"写入成功");
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    if (error) {
        return;
    }
    
    NSLog(@"读取RSSI成功");
    self.textField.text = RSSI.stringValue;
}

- (void) getHeartBPMData:(CBCharacteristic *)characteristic error:(NSError *)error {
    // Get the Heart Rate Monitor BPM
    NSData *data = [characteristic value];      // 1
    const uint8_t *reportData = [data bytes];
    uint16_t bpm = 0;
    
    if ((reportData[0] & 0x01) == 0) {          // 2
        // Retrieve the BPM value for the Heart Rate Monitor
        bpm = reportData[1];
    }
    else {
        bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));  // 3
    }
    // Display the heart rate value to the UI if no error occurred
    if( (characteristic.value)  || !error ) {   // 4
        
        NSString *heartBeatString = [NSString stringWithFormat:@"%i bpm", bpm];
        BLELog(@"heartBeat: %@", heartBeatString);
    }
    return;
}


#pragma mark - UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.discoveredPeripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BLECell *cell = [tableView dequeueReusableCellWithIdentifier:@"ble" forIndexPath:indexPath];
    CBPeripheral *p = self.discoveredPeripherals[indexPath.row];
    [cell configName:p.name ?: @"--------" uuidString:p.identifier.UUIDString];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.peripheral) {
        [self.centralManager cancelPeripheralConnection:self.peripheral];
    }
    
    CBPeripheral *p = self.discoveredPeripherals[indexPath.row];
    [self.centralManager connectPeripheral:p options:nil];
    self.peripheral = p;
}

@end
