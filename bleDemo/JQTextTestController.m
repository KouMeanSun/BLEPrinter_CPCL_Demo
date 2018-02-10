//
//  JQTextTestController.m
//  bleDemo
//
//  Created by wuyaju on 2017/6/23.
//  Copyright © 2017年 wuyaju. All rights reserved.
//

#import "JQTextTestController.h"
#import "ZHPickView.h"
#import "MBProgressHUD+MJ.h"

#import "JQESCTool.h"
#import "BleDeviceManager.h"

@interface JQTextTestController () <BleDeviceManagerDelegate>

@property (nonatomic, strong)NSArray *listCharacterFont;
@property (nonatomic, strong)NSArray *listAlign;
@property (nonatomic, strong)NSArray *listRotate;
@property (nonatomic, strong)NSArray *listWinth;
@property (nonatomic, strong)NSArray *listHeight;

@property (weak, nonatomic) IBOutlet UISwitch *boldSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *underLineSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *reverseSwitch;

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *defaultBtn;

@property (nonatomic, strong)BleDeviceManager *bleManager;
@property (nonatomic, strong)JQESCTool *escManager;

@property (nonatomic, assign)Boolean bold;
@property (nonatomic, assign)NSInteger underline;
@property (nonatomic, assign)Boolean reverse;

@property (nonatomic, assign)NSInteger font;
@property (nonatomic, assign)NSInteger width;
@property (nonatomic, assign)NSInteger height;
@property (nonatomic, assign)NSInteger align;
@property (nonatomic, assign)NSInteger rotate;

@end

@implementation JQTextTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initReouse];
    self.title = @"文本测试";
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
    
    self.listCharacterFont = [NSArray arrayWithObjects:@"字体D", @"字体A", @"字体B", @"字体C", nil];
    self.listWinth = [NSArray arrayWithObjects:@"1倍宽", @"2倍宽", @"3倍宽", @"4倍宽", nil];
    self.listHeight = [NSArray arrayWithObjects:@"1倍高", @"2倍高", @"3倍高", @"4倍高", nil];
    self.listAlign = [NSArray arrayWithObjects:@"左对齐", @"居中对齐", @"右对齐", nil];
    self.listRotate = [NSArray arrayWithObjects:@"不旋转", @"顺时针旋转90", @"顺时针旋转180", @"顺时针旋转270", nil];
}

- (void)defaultValue {
    self.bold = NO;
    self.underline = 0;
    self.reverse = NO;
    
    self.font = 0;
    self.width = 0;
    self.height = 0;
    self.align = 0;
    self.rotate = 0;
}

- (void)setDefault {
    [self.boldSwitch setOn:NO animated:YES];
    [self.underLineSwitch setOn:NO animated:YES];
    [self.reverseSwitch setOn:NO animated:YES];
    
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        [self tableView:self.tableView didEditRowAtIndexPath:indexPath subTitle:self.listCharacterFont.firstObject];
    }
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
        [self tableView:self.tableView didEditRowAtIndexPath:indexPath subTitle:self.listWinth.firstObject];
    }
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
        [self tableView:self.tableView didEditRowAtIndexPath:indexPath subTitle:self.listHeight.firstObject];
    }
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:1];
        [self tableView:self.tableView didEditRowAtIndexPath:indexPath subTitle:self.listAlign.firstObject];
    }
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:1];
        [self tableView:self.tableView didEditRowAtIndexPath:indexPath subTitle:self.listRotate.firstObject];
    }
    
    [self defaultValue];
}

- (void)showMessage:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *done = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:done];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)switchChange:(UISwitch *)sender {
    switch (sender.tag) {
        // 加粗
        case 0:
            self.bold = sender.on;
            break;
        // 下划线
        case 1:
            if (sender.on) {
                self.underline = 2;
            }else {
                self.underline = 0;
            }
            break;
        // 黑白反显
        case 2:
            self.reverse = sender.on;
            break;
        default:
            break;
    }
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
    
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:{
                ZHPickView *pickView = [[ZHPickView alloc] init];
                [pickView setDataViewWithItem:self.listCharacterFont];
                [pickView showPickView:self.view];
                pickView.block = ^(NSString *selectedStr) {
                    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                    [self tableView:tableView didEditRowAtIndexPath:selectIndexPath subTitle:selectedStr];
                    
                    if ([selectedStr isEqualToString:@"字体D"]) {
                        self.font = 3;
                    }else if ([selectedStr isEqualToString:@"字体A"]) {
                        self.font = 0;
                    }else if ([selectedStr isEqualToString:@"字体B"]) {
                        self.font = 1;
                    }else if ([selectedStr isEqualToString:@"字体C"]) {
                        self.font = 2;
                    }
                };
                break;
            }
            case 1:{
                ZHPickView *pickView = [[ZHPickView alloc] init];
                [pickView setDataViewWithItem:self.listWinth];
                [pickView showPickView:self.view];
                pickView.block = ^(NSString *selectedStr) {
                    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
                    [self tableView:tableView didEditRowAtIndexPath:selectIndexPath subTitle:selectedStr];
                    if ([selectedStr isEqualToString:@"1倍宽"]) {
                        self.width = 0;
                    }else if ([selectedStr isEqualToString:@"2倍宽"]) {
                        self.width = 20;
                    }else if ([selectedStr isEqualToString:@"3倍宽"]) {
                        self.width = 30;
                    }else if ([selectedStr isEqualToString:@"4倍宽"]) {
                        self.width = 40;
                    }
                };
                break;
            }
            case 2:{
                ZHPickView *pickView = [[ZHPickView alloc] init];
                [pickView setDataViewWithItem:self.listHeight];
                [pickView showPickView:self.view];
                pickView.block = ^(NSString *selectedStr) {
                    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:2 inSection:1];
                    [self tableView:tableView didEditRowAtIndexPath:selectIndexPath subTitle:selectedStr];
                    if ([selectedStr isEqualToString:@"1倍高"]) {
                        self.height = 0;
                    }else if ([selectedStr isEqualToString:@"2倍高"]) {
                        self.height = 2;
                    }else if ([selectedStr isEqualToString:@"3倍高"]) {
                        self.height = 3;
                    }else if ([selectedStr isEqualToString:@"4倍高"]) {
                        self.height = 4;
                    }
                };
                break;
            }
            case 3:{
                ZHPickView *pickView = [[ZHPickView alloc] init];
                [pickView setDataViewWithItem:self.listAlign];
                [pickView showPickView:self.view];
                pickView.block = ^(NSString *selectedStr) {
                    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:3 inSection:1];
                    [self tableView:tableView didEditRowAtIndexPath:selectIndexPath subTitle:selectedStr];
                    if ([selectedStr isEqualToString:@"左对齐"]) {
                        self.align = 0;
                    }else if ([selectedStr isEqualToString:@"居中对齐"]) {
                        self.align = 1;
                    }else if ([selectedStr isEqualToString:@"右对齐"]) {
                        self.align = 2;
                    }
                };
                break;
            }
            case 4:{
                ZHPickView *pickView = [[ZHPickView alloc] init];
                [pickView setDataViewWithItem:self.listRotate];
                [pickView showPickView:self.view];
                pickView.block = ^(NSString *selectedStr) {
                    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:4 inSection:1];
                    [self tableView:tableView didEditRowAtIndexPath:selectIndexPath subTitle:selectedStr];
                    if ([selectedStr isEqualToString:@"不旋转"]) {
                        self.rotate = 0;
                    }else if ([selectedStr isEqualToString:@"顺时针旋转90"]) {
                        self.rotate = 1;
                    }else if ([selectedStr isEqualToString:@"顺时针旋转180"]) {
                        self.rotate = 2;
                    }else if ([selectedStr isEqualToString:@"顺时针旋转270"]) {
                        self.rotate = 3;
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
    NSLog(@"点击了打印按钮");
    // 判断当前是否连接蓝牙打印机
    if (![self.bleManager isConnectBle]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"未连接设备！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *done = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:done];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if (![self.escManager esc_reset]) return;
    if (![self.escManager esc_bold:self.bold]) return;
    if (![self.escManager esc_underline:self.underline]) return;
    if (![self.escManager esc_black_white_reverse:self.reverse]) return;
    if (![self.escManager esc_font:self.font]) return;
    if (![self.escManager esc_align:self.align]) return;
    if (![self.escManager esc_rotate:self.rotate]) return;
    if (![self.escManager esc_character_size:(self.width + self.height)]) return;
    if (![self.escManager esc_print_text:self.textField.text]) return;
    if (![self.escManager esc_print_enter]) return;
    if (![self.escManager esc_print_formfeed]) return;
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
