//
//  QPBleInfoTool.h
//  bleDemo
//
//  Created by wuyaju on 16/4/1.
//  Copyright © 2016年 wuyaju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QPBleInfoTool : NSObject

/**
 *  返回已经配对过的蓝牙设备
 *
 *  @return 已配对的蓝牙设备数组，里面存放的是BleInfo类
 */
+ (NSArray *)pairBleInfo;

/**
 *  将已配对的蓝牙设备保存到plist文件中
 *
 *  @param bleInfoArray 已配对的蓝牙设别数组
 */
+ (BOOL)addPairBleInfo:(NSArray *)bleInfoArray;

/**
 *
 * 把mm转化为iOS的长度
 * @param mmLength 打印纸的距离，mm
 * return int      ios需要的长度
 */
+(int)commonsetIntWithMM:(int)mmLength;

@end
