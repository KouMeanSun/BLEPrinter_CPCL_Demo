//
//  QPBleInfoTool.m
//  bleDemo
//
//  Created by wuyaju on 16/4/1.
//  Copyright © 2016年 wuyaju. All rights reserved.
//

#import "QPBleInfoTool.h"
#import "BleInfo.h"

// 文件路径
#define QPPairBleInfoFilepath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"pairBleInfo.data"]

@implementation QPBleInfoTool

/**
 *  返回已经配对过的蓝牙设备
 *
 *  @return 已配对的蓝牙设备数组，里面存放的是BleInfo类
 */
+ (NSArray *)pairBleInfo{
    NSArray *pairBleInfoArray = [NSKeyedUnarchiver unarchiveObjectWithFile:QPPairBleInfoFilepath];
    
    return pairBleInfoArray;
}

/**
 *  将已配对的蓝牙设备保存到plist文件中
 *
 *  @param bleInfoArray 已配对的蓝牙设别数组
 */
+ (BOOL)addPairBleInfo:(NSArray *)bleInfoArray{
    if (bleInfoArray.count) {
        return [NSKeyedArchiver archiveRootObject:bleInfoArray toFile:QPPairBleInfoFilepath];
    }else{
        NSFileManager* fileManager = [NSFileManager defaultManager];
        BOOL blHave=[fileManager fileExistsAtPath:QPPairBleInfoFilepath];
        if (blHave) {
            [fileManager removeItemAtPath:QPPairBleInfoFilepath error:nil];
        }
        return true;
    }
}
/**
 *
 * 把mm转化为iOS的长度
 * @param mmLength 打印纸的距离，mm
 * return int      ios需要的长度
 */
+(int)commonsetIntWithMM:(int)mmLength{
    //  8.19047619047619 这个系数是自己测试的，不一定准，后期可能需要修改
    double tmp = mmLength*7.047619047619048;
    return (int)tmp;
}
@end
