//
//  ViewController.m
//  EFNEHotspotHelperDemo
//
//  Created by EyreFree on 17/3/8.
//  Copyright © 2017年 EyreFree. All rights reserved.
//

#import "ViewController.h"
#import <NetworkExtension/NetworkExtension.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "W5StatusManager.h"
#import "InfiniteTabPageViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UITextView *outputLabel;
@property (nonatomic, strong) UIButton *settingButton;
@property (nonatomic, copy) NSString *infoString;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 添加控件
    [self addControl];

    [self scanWifiInfo];
    // 根据扫描任务添加结果设置按钮状态
    [self.settingButton setEnabled:YES];

    // 添加进入前台时的刷新
    [self observeApplicationNotifications];
    
    if (@available(iOS 11.0, *)) {
        [[NEHotspotConfigurationManager sharedManager] getConfiguredSSIDsWithCompletionHandler:^(NSArray<NSString *> * array) {
            
            for (NSString * str in array) {
                
                NSLog(@"加入过的WiFi：%@",str);
            }
        }];
    } else {
        // Fallback on earlier versions
    }
    
    [self getSignalStrength:^(float signalStrength) {
        NSString *wifiName = [self getCurrentWifiName];
        self.outputLabel.text = [NSString stringWithFormat:@"wifiName: %@, wifiSignalStrength: %.3f", wifiName, signalStrength];
    }];
    
    [[W5StatusManager shared] getSSID:^(id ssid) {
        NSLog(@"ssid: %@", ssid);
    }];
    
    [[W5StatusManager shared] getBSSID:^(id bssid) {
        NSLog(@"bssid: %@", bssid);
    }];
    
    [[W5StatusManager shared] getBroadcast:^(id address) {
        NSLog(@"Broadcast address: %@", address);
    }];
    
    [[W5StatusManager shared] getIPAddress:^(id address) {
        NSLog(@"IPAddress: %@", address);
    }];
    
    [[W5StatusManager shared] getIPV4Address:^(id address) {
        NSLog(@"IPV4Address: %@", address);
    }];
}

//获取当前wifi名
- (NSString *)getCurrentWifiName {
    
    NSString * wifiName = @"";
    //NOTE: CNCopySupportedInterfaces iOS9+
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    
    if (!wifiInterfaces) {
        wifiName = @"";
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString *interfaceName in interfaces) {
        NSLog(@"interfaceName: %@", interfaceName);
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        if (dictRef) {
            
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            NSLog(@"networkInfo: %@", networkInfo);
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    return wifiName;
}

//获取当前WiFi的信号强度
- (void)getSignalStrength:(void(^)(float signalStrength))resultBlock{
    
    UIApplication *app = [UIApplication sharedApplication];
    //如果是Iphone X, NSArray *subviews = [[[[application valueForKeyPath:@"_statusBar"] valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    id dataNetworkItemView = nil;
    
    for (id subview in subviews) {
        
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            
            dataNetworkItemView = subview;
            break;
        }
    }
    
    int signalStrength = [[dataNetworkItemView valueForKey:@"_wifiStrengthBars"] intValue];    
    //获取到的信号强度最大值为3，所以除3得到百分比
    float signalStrengthTwo = signalStrength / 3.00;
    
    resultBlock(signalStrengthTwo);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];

    [self refresh];
}

- (void)addControl {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;

    self.outputLabel = [[UITextView alloc] initWithFrame: CGRectMake(3, 23, screenSize.width - 6, screenSize.height - 89)];
    self.outputLabel.font = [UIFont systemFontOfSize: 13];
    self.outputLabel.layer.borderWidth = 1;
    self.outputLabel.editable = NO;
    self.outputLabel.layer.borderColor = [[UIColor blackColor] CGColor];
    [self.view addSubview: self.outputLabel];

    self.settingButton = [[UIButton alloc] initWithFrame: CGRectMake(3, screenSize.height - 64, screenSize.width - 6, 60)];
    self.settingButton.titleLabel.font = [UIFont systemFontOfSize: 20];
    [self.settingButton setTitle: @"Open WiFi Setting" forState: UIControlStateNormal];
    [self.settingButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
    self.settingButton.layer.borderWidth = 1;
    self.settingButton.layer.borderColor = [[UIColor blackColor] CGColor];
    [self.settingButton addTarget: self action:@selector(openWiFiSetting) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: self.settingButton];
}

- (BOOL)scanWifiInfo {
    NSLog(@"1.Start");
    self.outputLabel.text = @"1.Start";

    NSMutableDictionary* options = [[NSMutableDictionary alloc] init];
    [options setObject:@"SFHotspot" forKey: kNEHotspotHelperOptionDisplayName];
    dispatch_queue_t queue = dispatch_queue_create("EFNEHotspotHelperDemo", NULL);

    NSLog(@"2.Try");
    self.outputLabel.text = @"2.Try";

    __weak typeof(self) weakself = self;
    
    BOOL returnType = [NEHotspotHelper registerWithOptions: options queue: queue handler: ^(NEHotspotHelperCommand * cmd) {

        NSLog(@"4.Finish");

        NSMutableString* resultString = [[NSMutableString alloc] initWithString: @""];

        NEHotspotNetwork* network;
        if (cmd.commandType == kNEHotspotHelperCommandTypeEvaluate || cmd.commandType == kNEHotspotHelperCommandTypeFilterScanList) {
            // 遍历 WiFi 列表，打印基本信息
            for (network in cmd.networkList) {
                NSString* wifiInfoString = [[NSString alloc] initWithFormat: @"SSID: %@\nMac地址: %@\n信号强度: %f\nCommandType:%ld\n\n",
                                            network.SSID, network.BSSID, network.signalStrength, (long)cmd.commandType];
                NSLog(@"%@", wifiInfoString);
                [resultString appendString: wifiInfoString];

                // 检测到指定 WiFi 可设定密码直接连接
                if ([network.SSID isEqualToString: @"测试 WiFi"]) {
                    [network setConfidence: kNEHotspotHelperConfidenceHigh];
                    [network setPassword: @"123456789"];
                    NEHotspotHelperResponse *response = [cmd createResponse: kNEHotspotHelperResultSuccess];
                    NSLog(@"Response CMD: %@", response);
                    [response setNetworkList: @[network]];
                    [response setNetwork: network];
                    [response deliver];
                }
            }
        }

        weakself.infoString = resultString;
    }];

    // 注册成功 returnType 会返回一个 Yes 值，否则 No
    NSString* logString = [[NSString alloc] initWithFormat: @"3.Result: %@", returnType == YES ? @"Yes" : @"No"];
    NSLog(@"%@", logString);
    self.outputLabel.text = logString;

    return returnType;
}

// 打开 无线局域网设置
- (void)openWiFiSetting {
    InfiniteTabPageViewController *vc = [[InfiniteTabPageViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
    
//    NSURL* urlCheck1 = [NSURL URLWithString: @"App-Prefs:root=WIFI"];
//    NSURL* urlCheck2 = [NSURL URLWithString: @"prefs:root=WIFI"];
//    NSURL* urlCheck3 = [NSURL URLWithString: UIApplicationOpenSettingsURLString];
//
//    NSLog(@"Try to open WiFi Setting, waiting...");
//    self.outputLabel.text = @"Try to open WiFi Setting, waiting...";
//
//    if ([[UIApplication sharedApplication] canOpenURL: urlCheck1]) {
//        [[UIApplication sharedApplication] openURL: urlCheck1];
//    } else if ([[UIApplication sharedApplication] canOpenURL: urlCheck2]) {
//        [[UIApplication sharedApplication] openURL: urlCheck2];
//    } else if ([[UIApplication sharedApplication] canOpenURL: urlCheck3]) {
//        [[UIApplication sharedApplication] openURL: urlCheck3];
//    } else {
//        NSLog(@"Unable to open WiFi Setting!");
//        self.outputLabel.text = @"Unable to open WiFi Setting!";
//
//        return;
//    }
//    NSLog(@"Open WiFi Setting successful.");
//    self.outputLabel.text = @"Open WiFi Setting successful.";
}

// 从设置页或者其他地方回来刷新
- (void)observeApplicationNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver: self];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(refresh)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(refresh)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
}

// 刷新获取到的 WiFi 信息
- (void)refresh {
    if (self.infoString != nil && ![self.infoString isEqual: @""]) {
        self.outputLabel.text = self.infoString;
    }
}

@end
