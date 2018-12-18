//
//  BLEDefines.h
//  BluetoothKitObjC
//
//  Created by samuel on 2018/11/15.
//  Copyright © 2018 samuel. All rights reserved.
//

#ifdef DEBUG
#ifndef BLELog
#define BLELog(fmt, ...) fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:fmt, ##__VA_ARGS__] UTF8String]);
#endif
#else
#ifndef BLELog
#define BLELog(fmt, ...) // NSLog((@"[%s Line %d]" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#endif
#endif

#ifndef BLEDefines_h
#define BLEDefines_h

//#define TEST_SERVICE_UUID                       "CDD1"
//#define TEST_CHAR_TX_UUID                       "CDD2"
#define TEST_CHAR_RX_UUID                       "CDD2"

#define HEART_RATE_SERVICE_UUID                            "180D"
#define HEART_RATE_MEASUREMENT                             "2A37"
//#define POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID        "2A37"
//#define POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID      "2A38"
//#define POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID  "2A29"

#define BLE_MODULE_VERSION                   "2A26"

#endif /* BLEDefines_h */
