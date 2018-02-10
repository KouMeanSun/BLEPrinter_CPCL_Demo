//
//  BleInfo.h
//  bleDemo
//
//  Created by wuyaju on 4/1/16.
//  Copyright © 2016 wuyaju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BleDeviceManager.h"

@interface BleInfo : NSObject <NSCoding, BLEOfflineHandleType>

@property (nonatomic, copy)NSString *bleName;
@property (nonatomic, copy)NSString *bleIdentifier;

@end
