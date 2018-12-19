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

#define DFUTARG_UUID        @"FE59"
#define SERVICE_UUID        @"180D"
#define CHARACTERISTIC_UUID @"2A37"

static NSString * const STEP_CHAR_UUID    =  @"FEDE"; //@"FF06";
static NSString * const BUTERY_CHAR_UUID  =  @"FEDF"; //@"FF0C";
static NSString * const SHAKE_CHAR_UUID   =  @"FEDD"; //@"2A06";
static NSString * const DEVICE_CHAR_UUID  =  @"FED2"; //@"FF01";

static NSString * const DEVICE_INFO_SERVICE_UUID  =  @"180A";
static NSString * const SYSTEM_ID_CHAR_UUID   =   @"2A23";

//4个字节Bytes 转 int
unsigned int TCcbytesValueToInt(Byte *bytesValue) {
    if (!bytesValue) return 0;
    unsigned int intV;
    intV = (unsigned int ) ( ((bytesValue[3] & 0xff)<<24)
                            |((bytesValue[2] & 0xff)<<16)
                            |((bytesValue[1] & 0xff)<<8)
                            |(bytesValue[0] & 0xff));
    return intV;
}

@interface CentralModeViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate, BLEDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBService *service;
@property (nonatomic, strong) CBCharacteristic *characteristic;
@property (nonatomic, strong) CBCharacteristic *shakeCC;
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

- (void)bleDidBeginScan {
    BLELog(@"bleDidBeginScan");
}

- (void)bleDidEndScan {
    BLELog(@"bleDidEndScan");
}

- (void)bleDidDiscoverServices:(NSArray<CBService *> *)services {
    BLELog(@"bleDidDiscoverServices: %lu", (unsigned long)services.count);
}

- (void)bleDidDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    [self reloadDiscoveredPeripherals:peripheral];
}

- (void)ble:(CBCharacteristic *)characteristic didReceiveBytes:(unsigned char *)bytes length:(NSUInteger)length{
    BLELog(@"bleDidReceiveData");
    
    // Append to the buffer
    NSString *s = [[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
    BLELog(@"Received data %@", s);
    self.textField.text = s;
}

- (void)bleDidChangeState:(BOOL)isEnabled {
    NSString *state = isEnabled ? @"bluetoothEnabled" : @"bluetoothDisabled";
    BLELog(@"bleDidChangedState: %@", state);
    if (isEnabled) {
        [self.centralBLE scanBLEPeripherals:3.0];
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
            for (CBCharacteristic *characteristic in self.service.characteristics) {
                if (characteristic.isNotifying) { // 解除订阅
                    [self.peripheral setNotifyValue:NO forCharacteristic:characteristic];
                }
            }
            
            if (CBPeripheralStateConnected == self.peripheral.state ||
                CBPeripheralStateConnecting == self.peripheral.state) {
                [self.centralManager cancelPeripheralConnection:self.peripheral];
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    self.title = @"蓝牙中心设备";
    // 创建中心设备管理器，会回调centralManagerDidUpdateState
//    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    
    self.centralBLE = [BLECentralManager manager];
    self.centralBLE.delegate = self;
    
//    self.centralBLE.readValue([CBUUID UUIDWithString:DEVICE_INFO_SERVICE_UUID], [CBUUID UUIDWithString:SYSTEM_ID_CHAR_UUID], ^(NSData *data) {
//
//    });
    
    
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
    
    UIButton *shakeBtn = [self buttonWithTitle:@"shake band" action:@selector(shakeMiBandAction:)];
    [self.view addSubview:shakeBtn];
    [shakeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tableView.mas_bottom).offset(20);
        make.right.equalTo(textField.mas_right);
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
        [self.centralBLE readForCharacteristic:[CBUUID UUIDWithString:SYSTEM_ID_CHAR_UUID] inService:[CBUUID UUIDWithString:DEVICE_INFO_SERVICE_UUID]];
    } else {
        if (self.peripheral && self.characteristic) {
            [self.peripheral readValueForCharacteristic:self.characteristic];
        }
    }
}

/** 写入数据 */
- (void)sendAction {
    // 用NSData类型来写入
    NSData *data = [self.textField.text dataUsingEncoding:NSUTF8StringEncoding];
    // 根据上面的特征self.characteristic来写入数据
    
    if (self.centralBLE) {
        [self.centralBLE write:data forCharacteristic:[CBUUID UUIDWithString:SHAKE_CHAR_UUID] inService:[CBUUID UUIDWithString:DEVICE_INFO_SERVICE_UUID]];
    } else {
        if (self.peripheral && self.characteristic) {
            [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        }
    }
}

- (void)scanAction {
    if (self.centralManager) {
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    } else {
        [self.centralBLE scanBLEPeripherals:3.0];
    }
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

- (void)reloadDiscoveredPeripherals:(CBPeripheral *)peripheral {
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
    
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.discoveredPeripherals.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
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
    if (@available(iOS 10, *)) {
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
}

/** 发现符合要求的外设，回调 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSString *peripheralName = peripheral.name ?: advertisementData[CBAdvertisementDataLocalNameKey];
    NSLog(@"didDiscoverPeripheral: %@ | name: %@", peripheral.identifier, peripheralName);
    
    [self reloadDiscoveredPeripherals:peripheral];
    
    static NSString * const BAND_PREFIX = @"FBRone"; // @"DBN_"
    if (peripheral.name && [peripheral.name hasPrefix:BAND_PREFIX]) {
        // 对外设对象进行强引用
        self.peripheral = peripheral;
        // 连接外设
        [central connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey: @YES}];
    }
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
        
        // 订阅通知
        if (characteristic.properties & CBCharacteristicPropertyNotify) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        
        // 从外设开发人员那里拿到不同特征的UUID，不同特征做不同事情，比如有读取数据的特征，也有写入数据的特征
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:STEP_CHAR_UUID]]) {
            [peripheral readValueForCharacteristic:characteristic];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BUTERY_CHAR_UUID]]) {
            [peripheral readValueForCharacteristic:characteristic];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SHAKE_CHAR_UUID]]) {
            self.shakeCC = characteristic;
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHAR_UUID]]) {
            [peripheral readValueForCharacteristic:characteristic];
        }
        
        // 直接读取这个特征数据，会调用didUpdateValueForCharacteristic
        if (characteristic.properties & CBCharacteristicPropertyRead) {
            [peripheral readValueForCharacteristic:characteristic];
        }
        
        if (characteristic.properties & CBCharacteristicPropertyWrite) {
            self.characteristic = characteristic;
        }
    }
    
    self.service = service;
    
    // 这里只获取一个特征，写入数据的时候需要用到这个特征
//    self.characteristic = service.characteristics.lastObject;
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
    if (error) {
        return;
    }
    
    // 拿到外设发送过来的数据
//    NSData *data = characteristic.value;
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]]) {
        [self getHeartBPMData:characteristic error:error];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SYSTEM_ID_CHAR_UUID]]) {
        NSString *addr = [self getMacAddrForCharacteristic:characteristic];
        NSLog(@"MAC 地址: %@", addr);
        self.textField.text = addr;
        
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:STEP_CHAR_UUID]]) {
        Byte *steBytes = (Byte *)characteristic.value.bytes;
        int steps = TCcbytesValueToInt(steBytes);
        NSLog(@"步数：%d",steps);
        
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BUTERY_CHAR_UUID]]) {
        Byte *bufferBytes = (Byte *)characteristic.value.bytes;
        int buterys = TCcbytesValueToInt(bufferBytes)&0xff;
        NSLog(@"电池：%d%%",buterys);

    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_CHAR_UUID]]) {
        Byte *infoByts = (Byte *)characteristic.value.bytes;
        if (!infoByts) return;
        NSString *info = [[NSString alloc] initWithBytes:infoByts length:sizeof(infoByts) encoding:NSUTF8StringEncoding];
        NSLog(@"设备：%@", info);
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

- (NSString *)getMacAddrForCharacteristic:(CBCharacteristic *)characteristic {
    NSString *desc = characteristic.value.description;
    NSMutableString *macAddr = [[NSMutableString alloc] init];
    [macAddr appendString:[[desc substringWithRange:NSMakeRange(16, 2)] uppercaseString]];
    [macAddr appendString:@":"];
    [macAddr appendString:[[desc substringWithRange:NSMakeRange(14, 2)] uppercaseString]];
    [macAddr appendString:@":"];
    [macAddr appendString:[[desc substringWithRange:NSMakeRange(12, 2)] uppercaseString]];
    [macAddr appendString:@":"];
    [macAddr appendString:[[desc substringWithRange:NSMakeRange(5, 2)] uppercaseString]];
    [macAddr appendString:@":"];
    [macAddr appendString:[[desc substringWithRange:NSMakeRange(3, 2)] uppercaseString]];
    [macAddr appendString:@":"];
    [macAddr appendString:[[desc substringWithRange:NSMakeRange(1, 2)] uppercaseString]];
    return macAddr;
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
        if (self.centralManager) {
            [self.centralManager cancelPeripheralConnection:self.peripheral];
        } else {
            [self.centralBLE cancelConnection];
        }
    }
    
    CBPeripheral *p = self.discoveredPeripherals[indexPath.row];
    if (self.centralManager) {
        [self.centralManager connectPeripheral:p options:nil];
    } else {
        [self.centralBLE connectPeripheral:p];
    }
    self.peripheral = p;
}

- (void)stopShakeAction:(UIButton *)sender {
    if (self.peripheral && self.shakeCC) {
        Byte zd[1] = {0};
        NSData *theData = [NSData dataWithBytes:zd length:1];
        [self.peripheral writeValue:theData forCharacteristic:self.shakeCC type:CBCharacteristicWriteWithoutResponse];
    }
}

//震动
- (void)shakeMiBandAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (!sender.selected) {
        [self stopShakeAction:sender];
        return;
    }
    if (self.peripheral && self.shakeCC) {
        Byte zd[1] = {0};
        NSData *theData = [NSData dataWithBytes:zd length:1];
        [self.peripheral writeValue:theData forCharacteristic:self.shakeCC type:CBCharacteristicWriteWithoutResponse];
    }
}


@end
