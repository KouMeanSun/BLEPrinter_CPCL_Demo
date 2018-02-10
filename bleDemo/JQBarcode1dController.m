//
//  JQBarcode1dController.m
//  bleDemo
//
//  Created by wuyaju on 2017/6/23.
//  Copyright © 2017年 wuyaju. All rights reserved.
//

#import "JQBarcode1dController.h"
#import "ZHPickView.h"
#import "MBProgressHUD+MJ.h"

#import "JQESCTool.h"
#import "BleDeviceManager.h"

@interface JQBarcode1dController () <BleDeviceManagerDelegate>

@property (nonatomic, strong)NSArray *listBarcode1dType;
@property (nonatomic, strong)NSArray *listBarcode1dWidth;
@property (nonatomic, strong)NSArray *listBarcode1dHeight;
@property (nonatomic, strong)NSArray *listBarcode1dHRIposition;
@property (nonatomic, strong)NSArray *listBarcode1dHRIFont;

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *defaultBtn;

@property (nonatomic, strong)BleDeviceManager *bleManager;
@property (nonatomic, strong)JQESCTool *escManager;

@property (nonatomic, assign)NSInteger barcode1dType;
@property (nonatomic, assign)NSInteger barcode1dWidth;
@property (nonatomic, assign)NSInteger barcode1dHeight;
@property (nonatomic, assign)NSInteger barcode1dHRIposition;
@property (nonatomic, assign)NSInteger barcode1dHRIFont;

@end

@implementation JQBarcode1dController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initReouse];
    self.escManager = [JQESCTool ESCManager];
    self.bleManager = [BleDeviceManager bleManager];
    self.bleManager.delegate = self;
    [self defaultValue];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)initReouse {
    self.sendBtn.layer.cornerRadius = 5;
    self.sendBtn.layer.masksToBounds = YES;
    self.sendBtn.backgroundColor = [UIColor orangeColor];
    
    self.defaultBtn.layer.cornerRadius = 5;
    self.defaultBtn.layer.masksToBounds = YES;
    self.defaultBtn.backgroundColor = [UIColor orangeColor];
    
    self.listBarcode1dType = [NSArray arrayWithObjects:@"UPC-A", @"UPC-E", @"EAN13", @"EAN8",
                              @"CODE39", @"ITF", @"CODABAR", @"CODE93", @"CODE128", nil];
    self.listBarcode1dWidth = [NSArray arrayWithObjects:@"1", @"2", @"3", nil];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:256];
    for (int i = 0; i < 256; i++) {
        array[i] = [NSString stringWithFormat:@"%d", i];
    }
    self.listBarcode1dHeight = array;
    self.listBarcode1dHRIposition = [NSArray arrayWithObjects:@"不显示", @"显示在上方°", @"显示在下方°", nil];
    self.listBarcode1dHRIFont = [NSArray arrayWithObjects:@"字体A", @"字体B", nil];
}

- (void)defaultValue {
    self.barcode1dType = 0;
    self.barcode1dWidth = 0;
    self.barcode1dHeight = 50;
    self.barcode1dHRIposition = 0;
    self.barcode1dHRIFont = 0;
}

- (void)setDefault {
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self tableView:self.tableView didEditRowAtIndexPath:indexPath subTitle:self.listBarcode1dType.firstObject];
    }
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self tableView:self.tableView didEditRowAtIndexPath:indexPath subTitle:self.listBarcode1dWidth.firstObject];
    }
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        [self tableView:self.tableView didEditRowAtIndexPath:indexPath subTitle:self.listBarcode1dHeight[51]];
    }
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
        [self tableView:self.tableView didEditRowAtIndexPath:indexPath subTitle:self.listBarcode1dHRIposition.firstObject];
    }
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0];
        [self tableView:self.tableView didEditRowAtIndexPath:indexPath subTitle:self.listBarcode1dHRIFont.firstObject];
    }
    
    [self defaultValue];
}

- (void)showMessage:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *done = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:done];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didEditRowAtIndexPath:(NSIndexPath *)indexPath subTitle:(NSString *)subTitle {
    //选取某个cell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = subTitle;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:{
                ZHPickView *pickView = [[ZHPickView alloc] init];
                [pickView setDataViewWithItem:self.listBarcode1dType];
                [pickView showPickView:self.view];
                pickView.block = ^(NSString *selectedStr) {
                    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [self tableView:tableView didEditRowAtIndexPath:selectIndexPath subTitle:selectedStr];
                    self.barcode1dType = [self.listBarcode1dType indexOfObject:selectedStr];
                };
                break;
            }
            case 1:{
                ZHPickView *pickView = [[ZHPickView alloc] init];
                [pickView setDataViewWithItem:self.listBarcode1dWidth];
                [pickView showPickView:self.view];
                pickView.block = ^(NSString *selectedStr) {
                    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                    [self tableView:tableView didEditRowAtIndexPath:selectIndexPath subTitle:selectedStr];
                    if ([selectedStr isEqualToString:@"1"]) {
                        self.barcode1dWidth = 0;
                    }else if ([selectedStr isEqualToString:@"2"]) {
                        self.barcode1dWidth = 2;
                    }else if ([selectedStr isEqualToString:@"3"]) {
                        self.barcode1dWidth = 3;
                    }
                };
                break;
            }
            case 2:{
                ZHPickView *pickView = [[ZHPickView alloc] init];
                [pickView setDataViewWithItem:self.listBarcode1dHeight];
                [pickView showPickView:self.view];
                pickView.block = ^(NSString *selectedStr) {
                    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                    [self tableView:tableView didEditRowAtIndexPath:selectIndexPath subTitle:selectedStr];
                    self.barcode1dHeight = [self.listBarcode1dHeight indexOfObject:selectedStr];
                };
                break;
            }
            case 3:{
                ZHPickView *pickView = [[ZHPickView alloc] init];
                [pickView setDataViewWithItem:self.listBarcode1dHRIposition];
                [pickView showPickView:self.view];
                pickView.block = ^(NSString *selectedStr) {
                    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                    [self tableView:tableView didEditRowAtIndexPath:selectIndexPath subTitle:selectedStr];
                    if ([selectedStr isEqualToString:@"不显示"]) {
                        self.barcode1dHRIposition = 0;
                    }else if ([selectedStr isEqualToString:@"显示在上方°"]) {
                        self.barcode1dHRIposition = 1;
                    }else if ([selectedStr isEqualToString:@"显示在下方°"]) {
                        self.barcode1dHRIposition = 2;
                    }
                };
                break;
            }
            case 4:{
                ZHPickView *pickView = [[ZHPickView alloc] init];
                [pickView setDataViewWithItem:self.listBarcode1dHRIFont];
                [pickView showPickView:self.view];
                pickView.block = ^(NSString *selectedStr) {
                    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                    [self tableView:tableView didEditRowAtIndexPath:selectIndexPath subTitle:selectedStr];
                    if ([selectedStr isEqualToString:@"字体A"]) {
                        self.barcode1dHRIFont = 0;
                    }else if ([selectedStr isEqualToString:@"字体B"]) {
                        self.barcode1dHRIFont = 1;
                    }
                };
                break;
            }
                
            default:
                break;
        }
    }
}
- (IBAction)sendBtnClicked:(UIButton *)sender {
    // 判断当前是否连接蓝牙打印机
    if (![self.bleManager isConnectBle]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"未连接设备！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *done = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:done];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if (![self.escManager esc_reset]) return;
    if (![self.escManager esc_barcode_1d:self.barcode1dHRIposition
                                HRI_font:self.barcode1dHRIFont
                                   width:self.barcode1dWidth
                                  height:self.barcode1dHeight
                                    type:self.barcode1dType
                                 content:self.textField.text]) return;
    if (![self.escManager esc_print_enter]) return;
    if (![self.escManager esc_print_formfeed]) return;
    NSLog(@"发送打印条形码指令完毕！");
}
- (IBAction)defaultBtnClicked:(id)sender {
    [self setDefault];
}

#pragma mark - BleDeviceManagerDelegate代理方法
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
