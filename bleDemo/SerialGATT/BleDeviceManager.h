//
//  BleDeviceManager.h
//
//  Created by Lansum Stuff on 16/3/29.
//  Copyright © 2016年 Lansum Stuff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define SERVICE_UUID @"49535343-FE7D-4AE5-8FA9-9FAFD205E455"
// 提供只写的特征
#define WRITE_CHAR_UUID @"49535343-8841-43F4-A8D4-ECBE34729BB3"
// 提供通知的特征
#define NOTIFI_CHAR_UUID @"49535343-1E4D-4BD9-BA61-23C647249616"

typedef NS_ENUM(NSInteger, JQBlePrintStatus) {
    JQBlePrintStatusNoPaper = 0x01,      // 缺纸
    JQBlePrintStatusOverHeat = 0x02,     // 打印头过热
    JQBlePrintStatusBatteryLow = 0x04,   // 电量低
    JQBlePrintStatusPrinting = 0x08,     // 正在打印中
    JQBlePrintStatusCoverOpen = 0x10,    // 纸仓盖未关闭
    JQBlePrintStatusNoError,             // 其他值，没有错误
    JQBlePrintStatusOk,                  // 打印完毕
};

@protocol BLEOfflineHandleType <NSObject>

- (NSString *)actionId;
- (NSString *)handleActionName;
- (NSString *)handleActionContent;
- (NSString *)name;
- (NSString *)serviceUUID;
- (NSString *)charUUID;

@end

@protocol BleDeviceManagerDelegate <NSObject>

@optional
- (void)peripheralFound:(CBPeripheral *)peripheral;
- (void)scanTimerout;
- (void)didConnectPeripheral;
- (void)didDisconnectPeripheral;
- (void)didFailToConnectPeripheral;
- (void)didUpdatecentralManagerState:(CBCentralManager *)central;
- (void)didUpdateBlePrintStatus:(JQBlePrintStatus)blePrintStatus;

@end

@interface BleDeviceManager: NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, weak) id <BleDeviceManagerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *peripherals;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *discoveredPeripheral;
@property (nonatomic, strong)CBCharacteristic *characteristic;
@property (nonatomic, strong)CBCharacteristic *notifiCharacteristic;

+ (instancetype)bleManager;

- (int)findPeripherals:(int)timeout;
- (int)findPeripherals:(NSArray *)serviceArray timreOut:(NSTimeInterval)timeout;
- (void)stopScan;

- (void)connectBlePrint:(NSString *)bleName;
- (void)connectPeripheral:(CBPeripheral *)peripheral;
- (void)disconnect:(CBPeripheral *)peripheral;

/**
 向外围设备写入二进制数据，自动进行分段发送
 */
- (Boolean)writeData:(NSData *)data;

/**
 写入二进制命令
 
 @param cmd 命令缓冲区地址
 @param length 命令长度
 */
- (Boolean)writeCmd:(Byte *)cmd cmdLenth:(NSUInteger)length;

/**
 向外围设备写入字符串信息
 */
- (Boolean)writeText:(NSString *)message;

/**
 蓝牙外设是否连接
 */
- (BOOL)isConnectBle;

/**
 读取蓝牙打印机状态
 */
- (void)readBlePrintStatus:(NSTimeInterval)timeout success:(void (^)(JQBlePrintStatus blePrintStatus))success fail:(void (^)(void))fail;

@end
