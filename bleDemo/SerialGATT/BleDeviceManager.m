//
//  BleDeviceManager.m
//
//  Created by Lansum Stuff on 16/3/29.
//  Copyright © 2016年 Lansum Stuff. All rights reserved.
//
#import "BleDeviceManager.h"
#import "BleInfo.h"
#include "QPBleInfoTool.h"

@interface BleDeviceManager ()

@property (nonatomic, strong)NSTimer *scanBleTimeout;
@property (nonatomic, strong)NSTimer *connectBleTimeout;
// 当点击已配对列表去连接设备时，保存扫描到的已配对的外设
@property (nonatomic, strong)CBPeripheral *findPairBle;

@property (nonatomic, strong)NSData *readData;
@property (nonatomic, copy)NSString *connectBleName;

@end

@implementation BleDeviceManager

+ (instancetype)bleManager{
    static BleDeviceManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BleDeviceManager alloc] init];
        [manager setup];
    });
    
    return manager;
}

#pragma mark - 懒加载
- (NSMutableArray *)peripherals{
    if (_peripherals == nil) {
        _peripherals = [NSMutableArray array];
    }
    
    return _peripherals;
}

#pragma mark - 私有方法
/*
 *  初始化中心设备
 */
- (void)setup {
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}

/**
 *  开始查找所有外设
 *
 *  @param timeout 查找超时时间
 *
 *  @return -1：BLE没有初始化成功
 */
- (int)findPeripherals:(int)timeout {
    if ([self.centralManager state] != CBCentralManagerStatePoweredOn) {
        printf("CoreBluetooth is not correctly initialized !\n");
        return -1;
    }
    
    self.scanBleTimeout = [NSTimer scheduledTimerWithTimeInterval:(float)timeout target:self selector:@selector(scanTimerout:) userInfo:nil repeats:NO];
    [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @(NO)}];
    
    return 0;
}

/**
 *  开始查找提供特定服务的外设
 *
 *  @param serviceArray 包含指定服务UUID的集合
 *  @param timeout 查找超时时间
 *
 *  @return -1：BLE没有初始化成功
 */
- (int)findPeripherals:(NSArray *)serviceArray timreOut:(NSTimeInterval)timeout {
    if ([self.centralManager state] != CBCentralManagerStatePoweredOn) {
        printf("CoreBluetooth is not correctly initialized !\n");
        return -1;
    }
    
    self.scanBleTimeout = [NSTimer scheduledTimerWithTimeInterval:(float)timeout target:self selector:@selector(scanTimerout:) userInfo:nil repeats:NO];
    [self.centralManager scanForPeripheralsWithServices:serviceArray options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @(NO)}];
    return 0;
}

/*
 * 蓝牙扫描超时处理方法
 */
- (void)scanTimerout:(NSTimer *)timer {
    self.connectBleName = nil;
    [self.centralManager stopScan];
    if ([self.delegate respondsToSelector:@selector(scanTimerout)]) {
        [self.delegate scanTimerout];
    }
}

/**
 *  停止扫描外围设备
 */
- (void)stopScan {
    [self.centralManager stopScan];
    // 用户主动停止扫描时，有可能超时时间还未到，此时应当停止扫描超时定时器
    if ([self.scanBleTimeout isValid]) {
        [self.scanBleTimeout invalidate];
        self.scanBleTimeout = nil;
        
        if ([self.delegate respondsToSelector:@selector(scanTimerout)]) {
            [self.delegate scanTimerout];
        }
    }
}

/*
 *  打印外围设备信息
 */
- (void) printPeripheralInfo:(CBPeripheral*)peripheral {
    NSLog(@"-------------------------------------");
    NSLog(@"UUID(identifier) : %@", peripheral.identifier.UUIDString);
    NSLog(@"Name             : %@", peripheral.name);
    NSLog(@"isConnected      : %d", peripheral.state == CBPeripheralStateConnected);
    NSLog(@"-------------------------------------\r\n");
}

/**
 *  连接到指定名字的外围设备
 *
 *  @param peripheral 指定的外围设备
 */
- (void)connectBlePrint:(NSString *)bleName {
    if (self.discoveredPeripheral) {
        // 判断将要连接的蓝牙是否已经连接
        if ([self.discoveredPeripheral.name isEqualToString:bleName]) {
            return;
        }
    }
    
    // 表明通过名字连接设备
    self.connectBleName = bleName;
    // 开始扫描连接指定的蓝牙设备
    [self findPeripherals:8];
}

/**
 *  连接到指定的外围设备
 *
 *  @param peripheral 指定的外围设备
 */
-(void) connectPeripheral:(CBPeripheral *)peripheral {
    if (self.discoveredPeripheral) {
        // 判断将要连接的蓝牙是否已经连接
        if (![self.discoveredPeripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
            return;
        }
    }
    
    // 表明直接通过扫描到的外设连接设备
    self.connectBleName = nil;
    [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey: @YES, CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES, CBConnectPeripheralOptionNotifyOnNotificationKey: @YES}];
    self.connectBleTimeout = [NSTimer scheduledTimerWithTimeInterval:(float)6 target:self selector:@selector(connectBleTimeout:) userInfo:nil repeats:NO];
}

/*
 * 蓝牙连接超时处理方法
 */
-(void) connectBleTimeout:(NSTimer *)timer {
    if ([self.delegate respondsToSelector:@selector(didFailToConnectPeripheral)]) {
        [self.delegate didFailToConnectPeripheral];
    }
}

/**
 *  断开指定的外围设备
 *
 *  @param peripheral 指定的外围设备
 */
-(void) disconnect:(CBPeripheral *)peripheral {
    if (peripheral.state != CBPeripheralStateDisconnected) {
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}

#pragma mark - CBCentralManager Delegates代理方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if ([self.delegate respondsToSelector:@selector(didUpdatecentralManagerState:)]) {
        [self.delegate didUpdatecentralManagerState:central];
    }
}

/**
 *  发现外围设备
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"发现外围设备，名字---%@", peripheral.name);
    
    // 从已配对列表中或者扫描二维码方式连接蓝牙时，名字作为唯一的区别，主动开始连接设备，
    if (self.connectBleName) {
        if ([self.connectBleName isEqualToString:peripheral.name]) {
            [self stopScan];
            // 必须强指针引用，否则方法结束后，会销毁
            self.findPairBle = peripheral;
            [self connectPeripheral:self.findPairBle];
        }
    }else{// 如果名字为空，说明是用户启动了扫描蓝牙
        // 防止重复加入
        for (CBPeripheral *oldPeripheral in self.peripherals) {
            if ([oldPeripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString] &&
                [oldPeripheral.name isEqualToString:peripheral.name]) {
                return;
            }
        }
        
        NSLog(@"发现新的外围设备");
        [self printPeripheralInfo:peripheral];
        [self.peripherals addObject:peripheral];
        if ([self.delegate respondsToSelector:@selector(peripheralFound:)]) {
            [self.delegate peripheralFound:peripheral];
        }
    }
}

/**
 *  已经连接到外围设备
 */
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    // 取消连接蓝牙超时定时器
    if ([self.connectBleTimeout isValid]) {
        [self.connectBleTimeout invalidate];
        self.connectBleTimeout = nil;
    }
    
    NSLog(@"已经连接到外围设备");
    [self printPeripheralInfo:peripheral];
    
    self.discoveredPeripheral = peripheral;
    self.discoveredPeripheral.delegate = self;
    // 发现指定的服务
    CBUUID *serviceUUID = [CBUUID UUIDWithString:SERVICE_UUID];
    [self.discoveredPeripheral discoverServices:@[serviceUUID]];
}

/**
 *  已经和外围设备断开连接
 */
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"和外围设备断开连接");
    self.discoveredPeripheral = nil;
    self.characteristic = nil;
    self.notifiCharacteristic = nil;
    
    if ([self.delegate respondsToSelector:@selector(didDisconnectPeripheral)]) {
        [self.delegate didDisconnectPeripheral];
    }
}

/**
 *  连接外围设备失败
 */
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"连接外围设备失败 %@: %@\n", [peripheral name], [error localizedDescription]);
    if ([self.delegate respondsToSelector:@selector(didFailToConnectPeripheral)]) {
        [self.delegate didFailToConnectPeripheral];
    }
}

#pragma mark - CBPeripheral delegates代理方法
/**
 *  已经发现服务
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        //[self getAllCharacteristicsFromKeyfob:peripheral];
        CBUUID *charUUID = [CBUUID UUIDWithString:WRITE_CHAR_UUID];
        CBUUID *notifiCharUUID = [CBUUID UUIDWithString:NOTIFI_CHAR_UUID];
        // 发现指定服务的指定特征
        for (CBService *service in peripheral.services) {
            if ([service.UUID.UUIDString isEqualToString:SERVICE_UUID]) {
                NSLog(@"发现服务: %@", service.UUID.UUIDString);
                [peripheral discoverCharacteristics:@[charUUID, notifiCharUUID] forService:service];
            }
        }
    }
    else {
        NSLog(@"服务发现失败");
    }
}

/**
 *  已经发现特征
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!error) {
        
        // 发现指定服务的指定特征
        for (CBCharacteristic *characteristic in service.characteristics) {
            // 发现了可写的特征
            if ([characteristic.UUID.UUIDString isEqualToString:WRITE_CHAR_UUID]) {
                NSLog(@"发现特征: %@", characteristic.UUID.UUIDString);
                self.characteristic = characteristic;
            }
            
            // 发现了提供订阅的特征
            if ([characteristic.UUID.UUIDString isEqualToString:NOTIFI_CHAR_UUID]) {
                NSLog(@"发现特征: %@", characteristic.UUID.UUIDString);
                self.notifiCharacteristic = characteristic;
                // 订阅特征
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
        
        if (self.characteristic && self.notifiCharacteristic) {
            // 通知代理此时真正连接上提供指定服务和特征的外围设备
            if ([self.delegate respondsToSelector:@selector(didConnectPeripheral)]) {
                [self.delegate didConnectPeripheral];
            }
        }
    }
    else {
        NSLog(@"特征发现失败");
    }
}

/**
 *  订阅特征状态更新
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
//        printf("Updated notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[self UUIDToString:(__bridge CFUUIDRef )peripheral.identifier]);
    }
    else {
//        printf("Error in setting notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[self UUIDToString:(__bridge CFUUIDRef )peripheral.identifier]);
//        printf("Error code was %s\r\n",[[error description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
    }
}

/**
 *  外围设备更新特征值
 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"updateValueForCharacteristic failed");
        return;
    }
    
    self.readData = characteristic.value;
    
    JQBlePrintStatus blePrintStatus;
    NSString *result = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    if ([result isEqualToString:@"OK"]) {
        blePrintStatus = JQBlePrintStatusOk;
        if ([self.delegate respondsToSelector:@selector(didUpdateBlePrintStatus:)]) {
            [self.delegate didUpdateBlePrintStatus:blePrintStatus];
        }
    }else if ([result isEqualToString:@"ERROR"]){
        // 请求查询具体错误类型
        [self requestBlePrintStatus];
    }else{
        Byte result[2];
        [characteristic.value getBytes:result length:2];
        blePrintStatus = (JQBlePrintStatus)result[0];
        if (blePrintStatus!=JQBlePrintStatusNoPaper && blePrintStatus!=JQBlePrintStatusOverHeat &&
            blePrintStatus!=JQBlePrintStatusBatteryLow && blePrintStatus!=JQBlePrintStatusPrinting &&
            blePrintStatus!=JQBlePrintStatusCoverOpen && blePrintStatus!=JQBlePrintStatusOk) {
            blePrintStatus = JQBlePrintStatusNoError;
        }
        if ([self.delegate respondsToSelector:@selector(didUpdateBlePrintStatus:)]) {
            [self.delegate didUpdateBlePrintStatus:blePrintStatus];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

#pragma mark - basic operations for SerialGATT service

/**
 向外围设备写入字符串信息
 */
- (void)write:(CBPeripheral *)peripheral message:(NSString *)message {
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *data = [message dataUsingEncoding:enc];
    [self write:peripheral data:data];
}

/**
 向外围设备写入二进制数据，自动进行分段发送
 */
- (void)write:(CBPeripheral *)peripheral data:(NSData *)data {
    NSUInteger limitLength = 20;
    // iOS 9 以后，系统添加了这个API来获取特性能写入的最大长度
    if ([self.discoveredPeripheral respondsToSelector:@selector(maximumWriteValueLengthForType:)]) {
            limitLength = [self.discoveredPeripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithResponse];
    }
//    NSLog(@"=====limitLength:%ld",limitLength);
    if(data.length > limitLength) {
        NSUInteger i = 0;
        while ((i + 1) * limitLength <= data.length) {
//            注意：每个打印机都有一个缓冲区，缓冲区的大小视品牌型号有所不同。打印机的打印速度有限，如果我们瞬间发送大量的数据给打印机，会造成打印机缓冲区满。缓冲区满后，如继续写入，可能会出现数据丢失，打印乱码。
            [NSThread sleepForTimeInterval:0.002];
            NSData *dataSend = [data subdataWithRange:NSMakeRange(i * limitLength, limitLength)];
            [self write:peripheral withData:dataSend];
            i++;
        }
        i = data.length % limitLength;
        if(i > 0)
        {
            NSData *dataSend = [data subdataWithRange:NSMakeRange(data.length - i, i)];
            [self write:peripheral withData:dataSend];
        }
        
    }else {
        [self write:peripheral withData:data];
    }
}

/**
 向外围设备写入二进制数据，自动进行分段发送
 */
- (Boolean)writeData:(NSData *)data {
    if (data == nil) {
        NSLog(@" 向外围设备写入二进制数据，自动进行分段发送   data == nil");
        return false;
    }
    [self write:self.discoveredPeripheral data:data];
    
    return true;
}


/**
 写入二进制命令

 @param cmd 命令缓冲区地址
 @param length 命令长度
 */
- (Boolean)writeCmd:(Byte *)cmd cmdLenth:(NSUInteger)length {
    NSData *data = [NSData dataWithBytes:cmd length:length];
    return [self writeData:data];
}

/**
 向外围设备写入字符串信息
 */
- (Boolean)writeText:(NSString *)message {
    if (message == nil) {
        return false;
    }
    
    [self write:self.discoveredPeripheral message:message];
    
    return true;
}

- (void)read:(CBPeripheral *)peripheral{
    printf("begin reading\n");
    //[peripheral readValueForCharacteristic:dataRecvrCharacteristic];
    printf("now can reading......\n");
}

-(void) notify: (CBPeripheral *)peripheral on:(BOOL)on {
    [self notification:SERVICE_UUID characteristicUUID:NOTIFI_CHAR_UUID peripheral:peripheral on:YES];
}

/*
 *  订阅特征值
 *
 *  @param serviceUUID Service UUID to read from (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to read from (e.g. 0x2401)
 *  @param p CBPeripheral to read from
 *
 *  @discussion Main routine for enabling and disabling notification services. It converts integers
 *  into CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service.
 *  If this is found, the notfication is set.
 *
 */
-(void) notification:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID peripheral:(CBPeripheral *)peripheral on:(BOOL)on {
    CBService *service = [self findServiceFromUUIDEx:[CBUUID UUIDWithString:serviceUUID] peripheral:peripheral];
    if (!service) {
//        NSLog(@"Could not find service with UUID %@ on peripheral with UUID",[self CBUUIDToString:su],[self UUIDToString:(__bridge CFUUIDRef )p.identifier]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUIDEx:[CBUUID UUIDWithString:characteristicUUID] service:service];
    if (!characteristic) {
//        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:(__bridge CFUUIDRef )p.identifier]);
        return;
    }
    [peripheral setNotifyValue:on forCharacteristic:characteristic];
}

// 向外围设备写入二进制数据
-(void) write:(CBPeripheral *)peripheral withData:(NSData *)data {
    [self writeValue:SERVICE_UUID characteristicUUID:WRITE_CHAR_UUID peripheral:peripheral data:data];
}

/*!
 *  @method 向指定外围设备、指定服务、指定特征写入数据
 *
 *  @param serviceUUID Service UUID to write to (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to write to (e.g. 0x2401)
 *  @param data Data to write to peripheral
 *  @param p CBPeripheral to write to
 *
 *  @discussion Main routine for writeValue request, writes without feedback. It converts integer into
 *  CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service. 
 *  If this is found, value is written. If not nothing is done.
 *
 */

-(void) writeValue:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID peripheral:(CBPeripheral *)peripheral data:(NSData *)data {
    
    if(self.characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse)
    {
//        NSLog(@"self.characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse");
        [peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    }else
    {
//        NSLog(@"else");
        [peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    }
}


/*!
 *  向外围设备发起读请求
 *
 *  @param serviceUUID Service UUID to read from (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to read from (e.g. 0x2401)
 *  @param p CBPeripheral to read from
 *
 *  @discussion Main routine for read value request. It converts integers into
 *  CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service. 
 *  If this is found, the read value is started. When value is read the didUpdateValueForCharacteristic 
 *  routine is called.
 *
 *  @see didUpdateValueForCharacteristic
 */

-(void) readValue: (NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID peripheral:(CBPeripheral *)peripheral {
    CBService *service = [self findServiceFromUUIDEx:[CBUUID UUIDWithString:serviceUUID] peripheral:peripheral];
    if (!service) {
        //        NSLog(@"Could not find service with UUID %@ on peripheral with UUID",[self CBUUIDToString:su],[self UUIDToString:(__bridge CFUUIDRef )p.identifier]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUIDEx:[CBUUID UUIDWithString:characteristicUUID] service:service];
    if (!characteristic) {
        //        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:(__bridge CFUUIDRef )p.identifier]);
        return;
    }
    [peripheral readValueForCharacteristic:characteristic];
}

/*
 *  根据服务的UUID从外围设备的服务UUID集合中匹配
 *
 */
-(CBService *) findServiceFromUUIDEx:(CBUUID *)serviceUUID peripheral:(CBPeripheral *)peripheral {
    for (CBService *service in peripheral.services) {
        if ([service.UUID.UUIDString isEqualToString:serviceUUID.UUIDString]) {
            return service;
        }
    }
    
    return nil;
}

/*
 *  根据特征的UUID从服务的特征UUID集合中匹配
 *
 */
-(CBCharacteristic *) findCharacteristicFromUUIDEx:(CBUUID *)characteristicUUID service:(CBService*)service {
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID.UUIDString isEqualToString:characteristicUUID.UUIDString]) {
            return characteristic;
        }
    }
    
    return nil;
}

// 蓝牙外设是否连接
- (BOOL)isConnectBle{
    return (self.discoveredPeripheral.state == CBPeripheralStateConnected);
}

// 给蓝牙打印机发送命令，请求查询打印机的状态
- (void)requestBlePrintStatus{
    if (self.isConnectBle) {
        Byte dataArray[3];
        dataArray[0] = 0x10;
        dataArray[1] = 0x04;
        dataArray[2] = 0x05;
        NSData *data = [NSData dataWithBytes:dataArray length:sizeof(dataArray)];
        [self write:self.discoveredPeripheral data:data];
    }
}

- (void)readBlePrintStatus:(NSTimeInterval)timeout success:(void (^)(JQBlePrintStatus blePrintStatus))success fail:(void (^)(void))fail{
    NSTimeInterval __block timerOut = timeout*100;
    [self requestBlePrintStatus];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (timerOut) {
            if (self.readData) {
                Byte result[2];
                [self.readData getBytes:result length:2];
                JQBlePrintStatus statueCode = (JQBlePrintStatus)result[0];
                if (statueCode!=JQBlePrintStatusNoPaper && statueCode!=JQBlePrintStatusOverHeat &&
                    statueCode!=JQBlePrintStatusBatteryLow && statueCode!=JQBlePrintStatusPrinting &&
                    statueCode!=JQBlePrintStatusCoverOpen && statueCode!=JQBlePrintStatusOk) {
                    statueCode = JQBlePrintStatusNoError;
                }
                self.readData = nil;
                if (success) {
                    success(statueCode);
                }
                return;
            }
            timerOut--;
            [NSThread sleepForTimeInterval:0.01];
        }
        
        // 超时时间到，未读取到打印机状态
        if (timerOut == 0) {
            if (fail) {
                fail();
            }
        }
    });
}

@end
