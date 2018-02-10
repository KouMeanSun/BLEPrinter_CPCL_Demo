//
//  MainViewController.m
//  collectionView
//
//  Created by Lansum Stuff on 16/3/29.
//  Copyright © 2016年 Lansum Stuff. All rights reserved.
//

#import "MainViewController.h"
#import "BleDeviceManagerViewController.h"
#import "BleDeviceManager.h"
#import "MBProgressHUD+MJ.h"
#import "JQTextTestController.h"
#import "JQBarcode1dController.h"
#import "JQESCTool.h"

typedef NS_ENUM(NSInteger, JQPrintTestMode) {
    JQPrintTestModeNone,
    JQPrintTestModePrinting,
    JQPrintTestModeMovie,
    JQPrintTestModeWaybill,
    JQPrintTestModeQRCode,
};

#define ScrenWidth self.view.bounds.size.width

@interface MainViewController () <BleDeviceManagerDelegate>

@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)UIBarButtonItem *addBleItem;
@property (nonatomic, strong)UIBarButtonItem *connectedItem;

@property (nonatomic, strong)BleDeviceManager *bleManager;
@property (nonatomic, strong)JQESCTool *escManager;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [UIView new];
    
    self.bleManager = [BleDeviceManager bleManager];
    self.bleManager.delegate = self;
    
    self.escManager = [JQESCTool ESCManager];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([self.bleManager isConnectBle]) {
        self.navigationItem.rightBarButtonItem = self.connectedItem;
    }else{
        self.navigationItem.rightBarButtonItem = self.addBleItem;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.bleManager.delegate = self;
}

#pragma mark - 私有方法
// 进入蓝牙设备管理界面
- (void)connectBle{
    BleDeviceManagerViewController *bleMgr = [[BleDeviceManagerViewController alloc] init];
    [self.navigationController pushViewController:bleMgr animated:YES];
}

- (void)showMessage:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *done = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:done];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 懒加载
- (NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray arrayWithObjects:@"电影票", @"电子运单", @"二维码", nil];
    }
    
    return _dataArray;
}

- (UIBarButtonItem *)connectedItem{
    if (_addBleItem == nil) {
        UIButton *rightBtn = [[UIButton alloc] init];
        rightBtn.bounds = CGRectMake(0, 0, 35, 35);
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"print.png"] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(connectBle) forControlEvents:UIControlEventTouchUpInside];
        _addBleItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    }
    
    return _addBleItem;
}

- (UIBarButtonItem *)addBleItem{
    if (_connectedItem == nil) {
        _connectedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(connectBle)];
    }
    
    return _connectedItem;
}

#pragma mark - BleDeviceManagerDelegate代理方法
/**
 *  连接到外围设备
 */
- (void)didConnectPeripheral{
    self.navigationItem.rightBarButtonItem = self.connectedItem;
}

/**
 *  连接外围设备失败
 */
- (void)didFailToConnectPeripheral{
    [MBProgressHUD hideHUD];
    [MBProgressHUD showError:@"连接失败"];
    self.navigationItem.rightBarButtonItem = self.addBleItem;
}

/**
 *  和外围设备断开连接
 */
- (void)didDisconnectPeripheral{
    [MBProgressHUD hideHUD];
    [MBProgressHUD showError:@"和设备断开连接"];
    self.navigationItem.rightBarButtonItem = self.addBleItem;
}

/**
 *  蓝牙作为中心设备状态发生变化
 */
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

/**
 *  打印机状态发生变化
 */
- (void)didUpdateBlePrintStatus:(JQBlePrintStatus)blePrintStatus{
    switch (blePrintStatus) {
        case JQBlePrintStatusOk:
            [self showMessage:@"打印完成"];
            break;
        case JQBlePrintStatusNoPaper:
            [self showMessage:@"缺纸！"];
            break;
        case JQBlePrintStatusOverHeat:
            [self showMessage:@"打印头过热！"];
            break;
        case JQBlePrintStatusBatteryLow:
            [self showMessage:@"电量低！"];
            break;
        case JQBlePrintStatusPrinting:
            [self showMessage:@"正在打印中！"];
            break;
        case JQBlePrintStatusCoverOpen:
            [self showMessage:@"纸仓盖未关闭！"];
            break;
        default:
            break;
    }
    
}

@end
