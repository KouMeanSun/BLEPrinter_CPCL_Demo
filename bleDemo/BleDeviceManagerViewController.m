//
//  BleDeviceManagerViewController.m
//  collectionView
//
//  Created by Lansum Stuff on 16/3/29.
//  Copyright © 2016年 Lansum Stuff. All rights reserved.
//

#import "BleDeviceManagerViewController.h"
#import "BleDeviceManager.h"
#import "Masonry.h"
#import "BleInfo.h"
#include "QPBleInfoTool.h"
#import "MBProgressHUD+MJ.h"
#import <AVFoundation/AVFoundation.h>
#import "QRCodeController.h"
#import "AppDelegate.h"

@interface BleDeviceManagerViewController () <BleDeviceManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)NSMutableArray *pairBleArray;
@property (nonatomic, strong)BleDeviceManager *bleManager;
@property (nonatomic, weak)UIButton *scanBtn;
@property (nonatomic, weak)UITableView *tableView;

@end

@implementation BleDeviceManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBtn];
    
    self.title = @"我的设备";
    
    self.bleManager = [BleDeviceManager bleManager];
    self.bleManager.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated{
    self.bleManager.delegate = self;
}

#pragma mark - 懒加载
- (NSMutableArray *)pairBleArray{
    if (_pairBleArray == nil) {
        _pairBleArray = (NSMutableArray *)[QPBleInfoTool pairBleInfo];
        if (_pairBleArray == nil) {
            _pairBleArray = [NSMutableArray array];
        }
    }
    
    return _pairBleArray;
}

#pragma mark - 私有方法
- (void)setupBtn{

    int padding = 10;
    int btnHeight = 40;
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.sectionHeaderHeight = 40;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    UIImageView *backView = [[UIImageView alloc] init];
    backView.image = [UIImage imageNamed:@"12.jpg"];
    backView.userInteractionEnabled = YES;
    [self.view addSubview:backView];
    [self.view bringSubviewToFront:backView];
    
    // 添加搜索按钮
    UIButton *scanBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    scanBtn.layer.cornerRadius = 5;
    scanBtn.backgroundColor = [UIColor grayColor];
    [scanBtn setTitle:@"搜索" forState:UIControlStateNormal];
    scanBtn.tintColor = [UIColor whiteColor];
    [scanBtn addTarget:self action:@selector(scanBle:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:scanBtn];
    self.scanBtn = scanBtn;
    
    // 添加扫一扫按钮
    UIButton *richScanBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    richScanBtn.layer.cornerRadius = 5;
    richScanBtn.backgroundColor = [UIColor greenColor];
    [richScanBtn setTitle:@"扫一扫" forState:UIControlStateNormal];
    richScanBtn.tintColor = [UIColor whiteColor];
    [richScanBtn addTarget:self action:@selector(richScan:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:richScanBtn];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(backView);
    }];
    
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(60);
    }];
    
    [scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView.mas_left).with.offset(2*padding);
        make.bottom.equalTo(backView.mas_bottom).with.offset(-padding);
        make.right.equalTo(richScanBtn.mas_left).with.offset(-2*padding);
        make.height.mas_equalTo(btnHeight);
        make.width.equalTo(richScanBtn);
    }];
    
    [richScanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(scanBtn.mas_right).with.offset(2*padding);
        make.bottom.equalTo(backView.mas_bottom).with.offset(-padding);
        make.right.equalTo(backView.mas_right).with.offset(-2*padding);
        make.height.mas_equalTo(btnHeight);
        make.width.equalTo(scanBtn);
    }];
}

/**
 *  是否可以打开设置页面
 */
- (BOOL)canOpenSystemSettingView {
    if (IS_VAILABLE_IOS8) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

/**
 *  跳到系统设置页面
 */
- (void)systemSettingView {
    if (IS_VAILABLE_IOS8) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

/**
 *  搜索按钮事件
 */
- (void)scanBle:(UIButton *)btn{
    if ([btn.titleLabel.text isEqualToString:@"搜索"]) {
        [btn setTitle:@"停止搜索" forState:UIControlStateNormal];
        // 搜索前清空上次已经搜索到的设备
        [self.bleManager.peripherals removeAllObjects];
        [self.bleManager findPeripherals:8];
    }else if ([btn.titleLabel.text isEqualToString:@"停止搜索"]){
        [btn setTitle:@"搜索" forState:UIControlStateNormal];
        [self.bleManager stopScan];
    }
}

/**
 *  点击扫描二维码事件
 */
- (void)richScan:(UIButton *)btn{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusDenied){
        if (IS_VAILABLE_IOS8) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"相机权限受限" message:@"请在iPhone的\"设置->隐私->相机\"选项中,允许\"自游邦\"访问您的相机." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([self canOpenSystemSettingView]) {
                    [self systemSettingView];
                }
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"相机权限受限" message:@"请在iPhone的\"设置->隐私->相机\"选项中,允许\"自游邦\"访问您的相机." delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
            [alert show];
        }
        
        return;
    }
    
    QRCodeController *qrcodeVC = [[QRCodeController alloc] init];
    qrcodeVC.view.alpha = 0;
    [qrcodeVC setDidReceiveBlock:^(NSString *result) {
        NSLog(@"%@", result);
        // 判断将要连接的蓝牙是否已经连接
        if (![self.bleManager.discoveredPeripheral.name isEqual:result] ) {
            [MBProgressHUD showMessage:@"正在连接设备..."];
            [self stopScanAndWriteData];
            // 从已配对列表中连接蓝牙设备，此时不知道蓝牙设别存不存在，采取扫描连接指定名字指定服务的方式
            [self.bleManager connectBlePrint:result];
        }else{
            [MBProgressHUD showSuccess:@"设备已经连接"];
        }
    }];
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [del.window.rootViewController addChildViewController:qrcodeVC];
    [del.window.rootViewController.view addSubview:qrcodeVC.view];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        qrcodeVC.view.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

/**
 *  将已连接的设备添加到已配对设备集合中
 */
- (void)addBleToPairBle:(BleInfo *)bleInfo{
    for (BleInfo *ble in self.pairBleArray) {
        if ([ble.bleIdentifier isEqualToString:bleInfo.bleIdentifier] &&
            [ble.bleName isEqualToString:bleInfo.bleName] ) {
            return;
        }
    }
    
    // 将新配对的设备添加到已配对设备集合中
    [self.pairBleArray addObject:bleInfo];
    [QPBleInfoTool addPairBleInfo:self.pairBleArray];
    
    // 将已配对设备从已搜索到得设备列表中删除
    for (int i = 0; i < self.bleManager.peripherals.count; i++) {
        CBPeripheral *peripheral = self.bleManager.peripherals[i];
        if ([peripheral.identifier.UUIDString isEqualToString:bleInfo.bleIdentifier] &&
            [peripheral.name isEqualToString:bleInfo.bleName]) {
            [self.bleManager.peripherals removeObject:peripheral];
            break;
        }
    }
}

- (void)stopScanAndWriteData{
    [self.bleManager stopScan];
    self.bleManager.discoveredPeripheral = nil;
}

-(void)unselectCell:(id)sender{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - BleDeviceManagerDelegate代理方法
- (void)scanTimerout{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
        [self.scanBtn setTitle:@"搜索" forState:UIControlStateNormal];
    });
}

- (void)peripheralFound:(CBPeripheral *)peripheral{
    // 查看是否在已配对列表中
    NSArray *pairBleArray = [QPBleInfoTool pairBleInfo];
    for (BleInfo *ble in pairBleArray) {
        if ([peripheral.identifier.UUIDString isEqualToString:ble.bleIdentifier] &&
            [peripheral.name isEqualToString:ble.bleName]) {
            // 将已经查找到的设备从已搜索到得设备列表中删除
            for (int i = 0; i < self.bleManager.peripherals.count; i++) {
                CBPeripheral *peripheral = self.bleManager.peripherals[i];
                if ([peripheral.identifier.UUIDString isEqualToString:ble.bleIdentifier] &&
                    [peripheral.name isEqualToString:ble.bleName]) {
                    [self.bleManager.peripherals removeObject:peripheral];
                    break;
                }
            }
            
            return;
        }
    }
    
    [self.tableView reloadData];
}

/**
 *  连接到外围设备
 */
- (void)didConnectPeripheral{
    [MBProgressHUD hideHUD];
    [MBProgressHUD showSuccess:@"连接成功"];
    
    BleInfo *ble = [[BleInfo alloc] init];
    ble.bleName = self.bleManager.discoveredPeripheral.name;
    ble.bleIdentifier = self.bleManager.discoveredPeripheral.identifier.UUIDString;
    
    [self addBleToPairBle:ble];
    
    // 刷新tableview
    [self.tableView reloadData];
}

/**
 *  连接外围设备失败
 */
- (void)didFailToConnectPeripheral{
    [MBProgressHUD hideHUD];
    [MBProgressHUD showError:@"连接失败"];
}

/**
 *  和外围设备断开连接
 */
- (void)didDisconnectPeripheral{
    [MBProgressHUD hideHUD];
    
    [MBProgressHUD showError:@"和设备断开连接"];
    [self stopScanAndWriteData];
    
    // 刷新tableview，刷新蓝牙连接状态
    [self.tableView reloadData];
}

- (void)didUpdatecentralManagerState:(CBCentralManager *)central{
    switch (central.state) {
        case CBCentralManagerStateUnsupported:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"设备不支持蓝牙功能" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            break;
        }
        case CBCentralManagerStateUnauthorized:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"蓝牙功能未授权，请到设置中开启" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            break;
        }
        case CBCentralManagerStatePoweredOff:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"蓝牙未开启" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            break;
        }
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource数据源方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.pairBleArray.count;
    }else if (section == 1){
        return self.bleManager.peripherals.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self performSelector:@selector(unselectCell:) withObject:nil afterDelay:1];
    
    if (indexPath.section == 0) {
        static NSString *cellID = @"pairBleCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        }
        
        BleInfo *bleInfo = self.pairBleArray[indexPath.row];
        if ([self.bleManager.discoveredPeripheral.identifier.UUIDString isEqualToString:bleInfo.bleIdentifier] &&
            [self.bleManager.discoveredPeripheral.name isEqualToString:bleInfo.bleName]) {
            cell.detailTextLabel.text = @"已连接";
        }else{
            cell.detailTextLabel.text = @"未连接";
        }
        cell.textLabel.text = bleInfo.bleName;
        
        return cell;
    }else if (indexPath.section == 1){
        static NSString *cellID = @"nearBlecell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        }
        
        CBPeripheral *peripheral = self.bleManager.peripherals[indexPath.row];
        cell.textLabel.text = peripheral.name;
        cell.detailTextLabel.text = peripheral.identifier.UUIDString;
        return cell;
    }
    
    return nil;
}

/**
 *  返回组标题
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        if (self.pairBleArray.count) {
            return @"已配对";
        }
    }else if (section == 1){
        if (self.bleManager.peripherals.count) {
            return @"附近的设备";
        }
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate代理方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 点击连接已配对设备
    if (indexPath.section == 0) {
        // 判断将要连接的蓝牙是否已经连接
        BleInfo *ble = self.pairBleArray[indexPath.row];
        if ([self.bleManager.discoveredPeripheral.name isEqual:ble.bleName] ) {
            return;
        }
        
        [MBProgressHUD showMessage:@"正在连接设备..."];
        [self stopScanAndWriteData];
        // 从已配对列表中连接蓝牙设备，此时不知道蓝牙设别存不存在，采取扫描连接指定名字指定服务的方式
        [self.bleManager connectBlePrint:ble.bleName];
    }else if (indexPath.section == 1){ // 点击连接已搜索到设备
        CBPeripheral *peripheral = self.bleManager.peripherals[indexPath.row];
        if ([self.bleManager.discoveredPeripheral.identifier.UUIDString isEqual:peripheral.identifier.UUIDString] ) {
            return;
        }
        
        [MBProgressHUD showMessage:@"正在连接设备..."];
        [self stopScanAndWriteData];
        // 从搜索到的蓝牙列表中连接提供指定服务的设备
        [self.bleManager connectPeripheral:peripheral];
    }
}

/**
 *  如果实现了这个方法,就自动实现了滑动删除的功能
 *  点击了删除按钮就会调用
 *  提交了一个编辑操作就会调用(操作:删除\添加)
 *  @param editingStyle 编辑的行为
 *  @param indexPath    操作的行号
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) { // 提交的是删除操作
        // 1.删除模型数据
        [self.pairBleArray removeObjectAtIndex:indexPath.row];
        
        // 2.刷新表格
        // 局部刷新某些行(使用前提:模型数据的行数不变)
        if (self.pairBleArray.count) {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }else{
            [self.tableView reloadData];
        }
        
        if (self.bleManager.discoveredPeripheral) {
            [self.bleManager disconnect:self.bleManager.discoveredPeripheral];
        }
        // 3.归档
        [QPBleInfoTool addPairBleInfo:self.pairBleArray];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}

/**
 *  当tableView进入编辑状态的时候会调用,询问每一行进行怎样的操作(添加\删除)
 */
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

@end
