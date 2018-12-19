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

static NSString * const kDEVICE_INFO_SERVICE_UUID     = @"180A";
static NSString * const kSYSTEM_ID_CHAR_UUID          = @"2A23";
static NSString * const kBLE_MODULE_VERSION           = @"2A26";

#endif /* BLEDefines_h */
