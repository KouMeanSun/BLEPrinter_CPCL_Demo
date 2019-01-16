//
//  FirstViewController.m
//  bleDemo
//
//  Created by 高明阳(01370716) on 2018/2/1.
//  Copyright © 2018年 wuyaju. All rights reserved.
//

#import "FirstViewController.h"
#import "BleDeviceManager.h"
#import "BleDeviceManagerViewController.h"
#import "MBProgressHUD+MJ.h"
#import "JQTextTestController.h"
#import "JQBarcode1dController.h"
#import "JQESCTool.h"
#import "JQCPCLTool.h"
#import "QPBleInfoTool.h"
#import "UIImage+Bitmap.h"

#define GBK_Encoding CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)

@interface FirstViewController ()<UITableViewDelegate,UITableViewDataSource,BleDeviceManagerDelegate>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataList;
@property (nonatomic, strong)BleDeviceManager *bleManager;
@property (nonatomic, strong)UIBarButtonItem *addBleItem;
@property (nonatomic, strong)UIBarButtonItem *connectedItem;
@property (nonatomic, strong)JQCPCLTool *cpclManager;
@property (nonatomic,strong)JQESCTool *escManager;

@property (nonatomic,assign)int pageWidth;
@property (nonatomic,assign)int pageHeight;
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    self.bleManager = [BleDeviceManager bleManager];
    self.bleManager.delegate = self;
    self.cpclManager = [JQCPCLTool CPCLManager];
    self.escManager  = [JQESCTool ESCManager];
    self.dataList = [NSMutableArray arrayWithArray:@[@"pos指令打印测试",
                                                     @"cpcl指令打印测试",
                                                     @"条形码打印测试",
                                                     @"矩形打印测试",
                                                     @"二维码打印测试",
                                                     @"图片打印测试",
                                                     @"运单打印测试",
                                                     @"标签打印测试",
                                                     @"文本CPCL指令测试",
                                                     @"文本CPCL指令打印图片",
                                                     @"文本CPCL指令打印电话图片"]];
    //打印纸的宽度，实际可能需要调整，开发先用这个来测试
    self.pageWidth = 588;
    //打印纸的高度，实际可能需要调整，开发先用这个来测试
    self.pageHeight = 800;
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

#pragma mark UITableViewDelegate,UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.dataList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mycell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mycell"];
    }
    cell.textLabel.text = self.dataList[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
//            NSLog(@"点击了文字打印测试");
            [self pushTextTestController];
            break;
        case 1:
//            NSLog(@"点击了条形码测试");
            [self pushBarcode1dController];
            break;
        case 2:
//            NSLog(@"点击了矩形打印测试");
            [self pushBoxPrintTest];
            break;
        case 3:
//            NSLog(@"点击了二维码打印测试");
            [self pushQRCodePrintTest];
            break;
        case 4:
//            NSLog(@"点击了图片打印测试");
            [self pushImagePrintTest];
            break;
        case 5:
            [self pushPrintOrderTest];
            break;
        case 6:
            [self pushPrintTagTest];
            break;
        case 7:
            [self pushTextCPCLCodeTest];
            break;
        case 8:
            [self pushTextImgCPCLPrintTest];
            break;
        case 9:
            [self pushTextPhoneImgCPCLPrintTest];
            break;
        default:
            break;
    }
}
#pragma mark - 私有方法
// 进入蓝牙设备管理界面
- (void)connectBle{
    BleDeviceManagerViewController *bleMgr = [[BleDeviceManagerViewController alloc] init];
    [self.navigationController pushViewController:bleMgr animated:YES];
}
// 提示消息
- (void)showMessage:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *done = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:done];
    [self presentViewController:alert animated:YES completion:nil];
}
//文本打印电话图片测试
-(void)pushTextPhoneImgCPCLPrintTest{
    NSError *error;
    NSString *textContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"phoneimg" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"获取文本失败!error:%@",error);
        return;
    }
    NSData *cpclCode = [textContents dataUsingEncoding:GBK_Encoding];
    [self.bleManager writeData:cpclCode];
    NSLog(@"textContents:%@",textContents);
}


//文本图片打印测试
-(void)pushTextImgCPCLPrintTest{
    NSError *error;
    NSString *textContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"img" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"获取文本失败!error:%@",error);
        return;
    }
//    UIImage *image = [UIImage imageNamed:@"sflogo.png"];
//    UIImage *newImage = [image imageWithscaleMaxWidth:500];
//    newImage = [newImage blackAndWhiteImage];
//
//    NSString *hex = [self.cpclManager picToBitmbp:newImage];
//    //    NSString *hex = [self UIImageToBase64Str:image];
//
//    NSInteger hei = image.size.height;
//    NSInteger wid = image.size.width;
//    if (wid % 8 > 0) {
//        wid = wid / 8;
//    }else{
//        wid = wid / 8 - 1;
//    }
//    NSString *widStr = [NSString stringWithFormat:@"%ld",wid];
//    NSString *heiStr = [NSString stringWithFormat:@"%ld",hei];
    NSData *cpclCode = [textContents dataUsingEncoding:GBK_Encoding];
    [self.bleManager writeData:cpclCode];
    NSLog(@"textContents:%@",textContents);
}

// 文本指令测试
-(void)pushTextCPCLCodeTest{
//    NSError *error;
//    NSString *textContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"order" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
//    if (error) {
//        NSLog(@"获取文本失败!error:%@",error);
//        return;
//    }
//    UIImage *image = [UIImage imageNamed:@"sflogoandphone"];
//    UIImage *newImage = [image imageWithscaleMaxWidth:500];
//    newImage = [newImage blackAndWhiteImage];
//
//    NSString *hex = [self.cpclManager picToBitmbp:newImage];
//
//    NSInteger hei = image.size.height;
//    NSInteger wid = image.size.width;
//    if (wid % 8 > 0) {
//        wid = wid / 8;
//    }else{
//        wid = wid / 8 - 1;
//    }
//    NSString *widStr = [NSString stringWithFormat:@"%ld",wid];
//    NSString *heiStr = [NSString stringWithFormat:@"%ld",hei];
//    NSString *replacedStr1 = [textContents stringByReplacingOccurrencesOfString:@"SFLOGOWIDTH" withString:widStr];
//    NSString *replacedStr2 = [replacedStr1 stringByReplacingOccurrencesOfString:@"SFLOGOHEIGHT" withString:heiStr];
//    NSString *replacedStr3 = [replacedStr2 stringByReplacingOccurrencesOfString:@"SFLOGOIMAGEDATA" withString:hex];
//    NSLog(@"replacedStr3:%@",replacedStr3);
//    NSData *cpclCode = [replacedStr3 dataUsingEncoding:GBK_Encoding];
//    [self.bleManager writeData:cpclCode];
}

// 进入文字打印测试   能够打印
-(void)pushTextTestController{
//    JQBarcode1dController *jq =[[JQBarcode1dController alloc]init];
//       UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//        JQBarcode1dController *vc = [story instantiateViewControllerWithIdentifier:@"JQBarcode1dController"];
//   [self.navigationController pushViewController:vc animated:YES];
//   UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//    JQTextTestController *vc = [story instantiateViewControllerWithIdentifier:@"JQTextTestController"];
//    vc.title = @"文字打印测试";
//    [self.navigationController pushViewController:vc animated:YES];
//    NSLog(@"点击了打印按钮");
//    // 判断当前是否连接蓝牙打印机
//    [self printWithModelindex:1];
    
    if (![self.escManager esc_reset]) return;
    
    [self.escManager esc_systemSelectPaperType:1];
    [self.escManager esc_SelectPrintMode:1];
    [self.escManager pageModeSetPrintAreawithX:0 Y:0 AreaWidth:750 AreaHeight:1440];
    
    
    
    [self.escManager  standardModeSetHorStartingPositionX:30 Y:400];
    [self.escManager barcodePrintQR:4 data:@"https://test.hyj-kj.com/apply/downLoad/?isScan=1&orderNum=hyj06342019011553300"];
    
    
    
    [self.escManager  standardModeSetHorStartingPositionX:180 Y:200];
    [self.escManager esc_print_text:@"第1联（电子联单）"];
    
    
    [self.escManager  standardModeSetHorStartingPositionX:180 Y:300];
    [self.escManager esc_print_text:@"工单:hyj0274201808220001"];
    
    [self.escManager  standardModeSetHorStartingPositionX:180 Y:400];
    [self.escManager esc_print_text:@"土方单位:深圳市金鼎盛土石方"];
    
    
    [self.escManager  standardModeSetHorStartingPositionX:30 Y:480];
    [self.escManager esc_print_text:@"泥头车牌：粤B32961"];
    
    
    [self.escManager  standardModeSetHorStartingPositionX:30 Y:560];
    [self.escManager esc_print_text:@"驾驶司机：粤B3219S1"];
    
    [self.escManager  standardModeSetHorStartingPositionX:30 Y:640];
    [self.escManager esc_print_text:@"所属车队：临时车"];
    
    
    [self.escManager  standardModeSetHorStartingPositionX:30 Y:720];
    [self.escManager esc_print_text:@"放行人员：吴启晨"];
    
    [self.escManager  standardModeSetHorStartingPositionX:30 Y:800];
    [self.escManager esc_print_text:@"今日车次：1"];
    
    
    [self.escManager  standardModeSetHorStartingPositionX:30 Y:880];
    [self.escManager esc_print_text:@"倒土方式：自倒"];
    
    [self.escManager  standardModeSetHorStartingPositionX:30 Y:960];
    [self.escManager esc_print_text:@"渣土类型：好土"];
    
    [self.escManager  standardModeSetHorStartingPositionX:30 Y:1040];
    [self.escManager esc_print_text:@"价    格：1元"];
    
    [self.escManager  standardModeSetHorStartingPositionX:30 Y:1120];
    [self.escManager esc_print_text:@"入场时间：2018-08-22  15:39:53"];
    
    
    [self.escManager  standardModeSetHorStartingPositionX:30 Y:1200];
    [self.escManager esc_print_text:@"进场时间：2018-08-22  15:40:05（白班）"];
    
    
    
    
    
  [self.escManager esc_prints];
  //  [self.escManager esc_pageModePrint];
    
}



-(void)printWithModelindex:(NSInteger)index
{
    
    @try{
        
        [self.cpclManager reset];
        
        [self.cpclManager pageSetup:570 pageHeight:720 qty:1];

        
        for (NSInteger i = 0; i<index; i++) {
            
   /*
    

    
    [[printer labelEdit] printText:@"0" y:0 fontName:@"2" content:dict[@"title"] angle:ROTATED_0 sizeHorizontal:1 sizeVertical:1];

    [labelEdit printBarcodeQR:30 y:80 angle:ROTATED_0 content:[dict[@"qrcode"] dataUsingEncoding:NSUTF8StringEncoding] ECCLever:QR_LEVEL_L cellWidth:4 model:QR_MODE_ENHANCED];

    
    [[printer labelEdit] printText:170 y:80 fontName:@"3" content:[NSString stringWithFormat:@"第%d联(电子联单)",index] angle:ROTATED_0 sizeHorizontal:1 sizeVertical:1];

    
    [[printer labelEdit] printText:170 y:130 fontName:@"3" content:[NSString stringWithFormat:@"工单:%@",dict[@"ordernumber"]] angle:ROTATED_0 sizeHorizontal:1 sizeVertical:1];

    [[printer labelEdit] printText:170 y:180 fontName:@"3" content:[NSString stringWithFormat:@"土方单位:%@",Str]  angle:ROTATED_0 sizeHorizontal:1 sizeVertical:1];

    
    */
                [self.cpclManager drawText:0  text_y:0 text:@"打印工地" fontSize:2  rotate:0 bold:0 reverse:NO underline:NO];
          
                [self.cpclManager drawQrCode:30  start_y:80 text:@"www.baidu.com" rotate:0 ver:0 lel:0];

                [self.cpclManager drawText:170  text_y:80 text:@"打印工地" fontSize:2  rotate:0 bold:0 reverse:NO underline:NO];

                [self.cpclManager drawText:170  text_y:130 text:@"打印工地" fontSize:2  rotate:0 bold:0 reverse:NO underline:NO];
                [self.cpclManager drawText:170 text_y:180 text:@"打印工地" fontSize:2  rotate:0 bold:0 reverse:NO underline:NO];

  
     
            
        }
        
        [self.cpclManager print:0 skip:0];
        
    }@catch (NSException *e){

    }@finally{

    }
    
    //1、重置打印机
    
    
    
    
}
// 进入条形码打印测试  现在打印出来的还是数组，不是条码
-(void)pushBarcode1dController{
//    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//    JQBarcode1dController *vc = [story instantiateViewControllerWithIdentifier:@"JQBarcode1dController"];
//    vc.title = @"条形码打印测试";
//    [self.navigationController pushViewController:vc animated:YES];
    // 判断当前是否连接蓝牙打印机
//    if (![self.bleManager isConnectBle]) {
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"未连接设备！" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *done = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
//        [alert addAction:done];
//        [self presentViewController:alert animated:YES completion:nil];
//        return;
//    }
    [self.cpclManager reset];
    
    [self.cpclManager pageSetup:570 pageHeight:720 qty:1];
    
     [self.cpclManager drawText:150  text_y:0  text:@"测试工地" fontSize:2  rotate:0 bold:0 reverse:NO underline:NO];
     [self.cpclManager drawQrCode:30 start_y:80 text:@"https://test.hyj-kj.com/apply/downLoad/?isScan=1&orderNum=hyj06342019011553300" rotate:0 ver:0 lel:0];
      [self.cpclManager drawText:170  text_y:80  text:@"第1联(电子联单)" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
     [self.cpclManager drawText:170  text_y:130  text:@"工单:hyj0274201808220001" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
     [self.cpclManager drawText:170  text_y:180  text:@"土方单位:深圳市金鼎盛土石方有限公司" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
     [self.cpclManager drawText:30  text_y:240   text:@"泥头车牌：粤B32961" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
     [self.cpclManager drawText:30  text_y:280  text:@"驾驶司机：粤B3219S1" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
     [self.cpclManager drawText:30  text_y:320  text:@"所属车队：临时车" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
     [self.cpclManager drawText:30  text_y:360  text:@"放行人员：赖世路" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
     [self.cpclManager drawText:30  text_y:400  text:@"今日车次：1" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
     [self.cpclManager drawText:30  text_y:440  text:@"倒土方式：自倒" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
    [self.cpclManager drawText:30  text_y:480  text:@"渣土类型：好土" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
    [self.cpclManager drawText:30  text_y:520  text:@"价格：1元" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
     [self.cpclManager drawText:30  text_y:560  text:@"入场时间：2018-08-22  15:39:53" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
     [self.cpclManager drawText:30  text_y:600  text:@"进场时间：2018-08-22  15:40:05（白班）" fontSize:3  rotate:0 bold:0 reverse:NO underline:NO];
    
    //4、调用打印命令
    [self.cpclManager print:0 skip:0];
    
    
//    [[printer printerConfigure] setPrintDirection:PRINT_DIRECTION_NORAML];
//    LabelEdit *labelEdit = [printer labelEdit];
//
//    [labelEdit setLabelSize:570 height:720];
    
//    if (dict[@"title"]) {
//        [[printer labelEdit] printText:[self XForTitle:dict[@"title"]] y:0 fontName:@"2" content:dict[@"title"] angle:ROTATED_0 sizeHorizontal:1 sizeVertical:1];
//    }
//
//    //  [labelEdit printLine:0 startY:100 endX:570 endY:100 thickness:2];
//    if (dict[@"qrcode"]) {
//        [labelEdit printBarcodeQR:30 y:80 angle:ROTATED_0 content:[dict[@"qrcode"] dataUsingEncoding:NSUTF8StringEncoding] ECCLever:QR_LEVEL_L cellWidth:4 model:QR_MODE_ENHANCED];
//    }
//
//    [[printer labelEdit] printText:170 y:80 fontName:@"3" content:[NSString stringWithFormat:@"第%d联(电子联单)",index] angle:ROTATED_0 sizeHorizontal:1 sizeVertical:1];
//    // [labelEdit printBarcodeQR:80 y:220 angle:ROTATED_0 content:[dict[@"qrcode"] dataUsingEncoding:NSUTF8StringEncoding] ECCLever:QR_LEVEL_L cellWidth:4 model:QR_MODE_ENHANCED];
//
//
//    if (dict[@"ordernumber"]) {
//        [[printer labelEdit] printText:170 y:130 fontName:@"3" content:[NSString stringWithFormat:@"%@",dict[@"ordernumber"]] angle:ROTATED_0 sizeHorizontal:1 sizeVertical:1];
//    }
//    NSString *Str =dict[@"dumperCompany"];
//
//    if (Str && Str.length <=12) {
//        [[printer labelEdit] printText:170 y:180 fontName:@"3" content:[NSString stringWithFormat:@"土方单位:%@",Str]  angle:ROTATED_0 sizeHorizontal:1 sizeVertical:1];
//    }else if (Str && Str.length>12)
//    {
//        NSString * subString1 = [Str substringToIndex:12];
//        NSString * subString2 = [Str substringFromIndex:12];
//
//        [[printer labelEdit] printText:170 y:180 fontName:@"3" content:[NSString stringWithFormat:@"土方单位:%@",subString1]  angle:ROTATED_0 sizeHorizontal:1 sizeVertical:1];
//        [[printer labelEdit] printText:280 y:205 fontName:@"3" content:[NSString stringWithFormat:@"%@",subString2]  angle:ROTATED_0 sizeHorizontal:1 sizeVertical:1];
//    }
//
//
//
//
//    if (dict[@"platenumber"]) {
//        [[printer labelEdit] printText:30 y:240 fontName:@"3" content:[NSString stringWithFormat:@"%@",dict[@"platenumber"]] angle:ROTATED_0 sizeHorizontal:1 sizeVertical:1];
//    }
//
//    if(dict[@"driver"]){
//        [[printer labelEdit] printText:30 y:280 fontName:@"3" content:[NSString stringWithFormat:@"%@",dict[@"driver"]] angle:ROTATED_0 sizeHorizontal:1 sizeVertical:1];
//    }
//
//
//    if (dict[@"captain"]) {
//        [[printer labelEdit] printText:30 y:320 fontName:@"3" content:[NSString stringWithFormat:@"%@",dict[@"captain"]] angle:ROTATED_0 sizeHorizontal:1 sizeVertical:1];
//    }
//
//    if (dict[@"releaseperson"]) {
//        [[printer labelEdit] printText:30 y:360 fontName:@"3" content:[NSString stringWithFormat:@"%@",dict[@"releaseperson"]] angle:ROTATED_0 sizeHorizontal:1 sizeVertical:1];
//    }
//
//    if (dict[@"Poursoiltype"]) {
//        [[printer labelEdit] printText:30 y:400 fontName:@"3" content:[NSString stringWithFormat:@"%@",dict[@"Poursoiltype"]] angle:ROTATED_0 sizeHorizontal:1 sizeVertical:1];
//    }
//    if (dict[@"soiltype"]) {
//        [[printer labelEdit] printText:30 y:440 fontName:@"3" content:[NSString stringWithFormat:@"%@",dict[@"soiltype"]] angle:ROTATED_0 sizeHorizontal:1 sizeVertical:1];
//    }
//
//    if (dict[@"price"]) {
//        [[printer labelEdit] printText:30 y:480 fontName:@"3" content:[NSString stringWithFormat: @"%@",dict[@"price"]] angle:ROTATED_0 sizeHorizontal:1 sizeVertical:1];
//    }
//
//
//
//    [[printer labelEdit] printText:30 y:520 fontName:@"3" content:[NSString stringWithFormat:@"%@",dict[@"intime"]] angle:ROTATED_0 sizeHorizontal:1 sizeVertical:1];
//
//    [[printer labelEdit] printText:30 y:560 fontName:@"3" content:[NSString stringWithFormat:@"%@",dict[@"outtime"]]angle:ROTATED_0 sizeHorizontal:1 sizeVertical:1];
//
//    [[printer labelEdit] printText:30 y:600 fontName:@"3" content: [NSString stringWithFormat:@"%@",dict[@"amount"]] angle:ROTATED_0 sizeHorizontal:1 sizeVertical:1];
    
    
}
//矩形打印测试
-(void)pushBoxPrintTest{
    NSLog(@"矩形打印测试");
    if (![self.bleManager isConnectBle]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"未连接设备！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *done = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:done];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
//    //1、重置打印机
     [self.cpclManager reset];
//    //2、初始化 进入打印 控制指令
    [self.cpclManager pageSetup:568 pageHeight:800 qty:1];
//    //3、打印矩形
    [self.cpclManager drawBox:1 top_left_x:100 top_left_y:100 bottom_right_x:200 bottom_right_y:200];
//    //4、调用打印命令
    [self.cpclManager print:0 skip:0];
}
// 二维码打印测试
-(void)pushQRCodePrintTest{
    NSLog(@"二维码打印测试");
    if (![self.bleManager isConnectBle]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"未连接设备！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *done = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:done];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    //1、重置打印机
    [self.cpclManager reset];
//    //2、初始化 进入打印 控制指令
   [self.cpclManager pageSetup:568 pageHeight:800 qty:1];
//    //3、打印二维码
    [self.cpclManager drawQrCode:10 start_y:10 text:@"www.baidu.com" rotate:0 ver:0 lel:0];
//    //4、调用打印命令
   [self.cpclManager print:0 skip:0];
}

// 图片打印测试
-(void)pushImagePrintTest{
    NSLog(@"图片打印测试");
    if (![self.bleManager isConnectBle]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"未连接设备！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *done = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:done];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    //1、重置打印机
     [self.cpclManager reset];
//    //2、初始化 进入打印 控制指令
    [self.cpclManager pageSetup:568 pageHeight:800 qty:1];
//    //3、打印图片
//    [self.cpclManager drawGraphic:20 start_y:20 picName:@"phonepng24"];
//    //test
    [self.cpclManager drawGraphicWithX:220 y:20 imageName:@"phonepng24"];
//    [self.escManager esc_print_ImageWithWidth:10 height:10 x:8 y:8 imageName:@"phone.png"];
//    [self.escManager esc_print_text:@"你是个演员演员" font:2 size:0 x:21 y:10];
//    //4、调用打印命令
    [self.cpclManager print:0 skip:0];
//    NSLog(@"调用完打印命令!");
    //------------test
//    //1、重置打印机
//    [self.cpclManager reset];
//    [self.cpclManager pageSetup:568 pageHeight:800 qty:1];
//    [self.cpclManager drawText:0 text_y:0 text:@"" fontSize:2 rotate:0 bold:0 reverse:NO underline:NO];
//    //4、调用打印命令，
//    [self.cpclManager print:0 skip:0];
}
// 运单打印测试
-(void)pushPrintOrderTest{
    NSLog(@"运单打印测试");
    if (![self.bleManager isConnectBle]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"未连接设备！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *done = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:done];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
//-------------
    [MBProgressHUD showMessage:@"开始打印，新北洋BTP-P33大约需要45秒。。。。"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,45*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
    });
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(globalQueue, ^{
        [self.cpclManager reset];
        if ([self.bleManager.discoveredPeripheral.name isEqualToString:@"HM-A300"]) {
            self.pageWidth = 588;
        }else if([self.bleManager.discoveredPeripheral.name isEqualToString:@"BTP-P33"]){
            self.pageWidth = 568;
        }
        [self.cpclManager pageSetup:(self.pageWidth) pageHeight:(self.pageHeight) qty:(1)];
        
        [self.cpclManager drawBox:(1) top_left_x:(0) top_left_y:([QPBleInfoTool commonsetIntWithMM:0]) bottom_right_x:(self.pageWidth) bottom_right_y:(self.pageHeight-100)];
        
        [self.cpclManager drawBox:(1) top_left_x:(0) top_left_y:([QPBleInfoTool commonsetIntWithMM:0]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:86]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:18])];
        
        // 顺丰和悟空logo
//        [self.cpclManager drawGraphic:[QPBleInfoTool commonsetIntWithMM:2] start_y:[QPBleInfoTool commonsetIntWithMM:2] picName:@"sflogoz"];
        [self.cpclManager printSFAndWKLogoWithX:[QPBleInfoTool commonsetIntWithMM:2] y:[QPBleInfoTool commonsetIntWithMM:2]];

        //9533866
        //test
//       [self.cpclManager drawGraphicWithX:[QPBleInfoTool commonsetIntWithMM:2] y:[QPBleInfoTool commonsetIntWithMM:2] imageName:@"sflogo"];
        [self.cpclManager printSFAndWKPhoneWithX:[QPBleInfoTool commonsetIntWithMM:39] y:[QPBleInfoTool commonsetIntWithMM:2]];
        // 悟空快运栏=====================
        [self.cpclManager drawBox:(2) top_left_x:(0) top_left_y:([QPBleInfoTool commonsetIntWithMM:18]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:86]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:37])];
        // 条形码
        [self.cpclManager drawBarCode:([QPBleInfoTool commonsetIntWithMM:4]) start_y:([QPBleInfoTool commonsetIntWithMM:20]) text:@"123456789123" type:1 rotate:0 linewidth:2 height:80];
        //母单号
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:4]) text_y:([QPBleInfoTool commonsetIntWithMM:32]) text:@"母单号" fontSize:2 rotate:0 bold:NO reverse:NO underline:NO];
        //123 456 789 123
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:19]) text_y:([QPBleInfoTool commonsetIntWithMM:32]) text:@"123 456 789 123" fontSize:2 rotate:0 bold:NO reverse:NO underline:NO];
        //包裹【悟空快运】的方块
        [self.cpclManager drawBox:(1) top_left_x:([QPBleInfoTool commonsetIntWithMM:55]) top_left_y:([QPBleInfoTool commonsetIntWithMM:18]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:86]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:37])];
        // 悟空快运 文字
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:59]) text_y:([QPBleInfoTool commonsetIntWithMM:25]) text:@"悟空快运" fontSize:1 rotate:0 bold:1 reverse:NO underline:NO];
        // 收件方 一栏 ==========================
        [self.cpclManager drawBox:(2) top_left_x:(0) top_left_y:([QPBleInfoTool commonsetIntWithMM:37]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:86]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:50])];
        // 包裹 收件方 文字的框框
        [self.cpclManager drawBox:(1) top_left_x:(0) top_left_y:([QPBleInfoTool commonsetIntWithMM:37]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:6]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:50])];
        // 寄件方 文字 竖着的
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:1]) text_y:([QPBleInfoTool commonsetIntWithMM:38]) width:([QPBleInfoTool commonsetIntWithMM:4]) height:([QPBleInfoTool commonsetIntWithMM:12]) str:@"收件方" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
        // 刘德华
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:8]) text_y:([QPBleInfoTool commonsetIntWithMM:39]) text:@"刘德华" fontSize:3 rotate:0 bold:1 reverse:NO underline:NO];
        // 136 0000 0000
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:28]) text_y:([QPBleInfoTool commonsetIntWithMM:39]) text:@"136 0000 0000" fontSize:2 rotate:0 bold:0 reverse:NO underline:NO];
        // 广东省深圳市南山区软件产业基地17楼
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:8]) text_y:([QPBleInfoTool commonsetIntWithMM:45]) text:@"广东省深圳市南山区软件产业基地17楼" fontSize:2 rotate:0 bold:0 reverse:NO underline:NO];
        //// 寄件方 一栏
        // 寄件方 的框框
        [self.cpclManager drawBox:(1) top_left_x:([QPBleInfoTool commonsetIntWithMM:0]) top_left_y:([QPBleInfoTool commonsetIntWithMM:50]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:73]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:63])];
        // 寄件方 文字 竖着的
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:1]) text_y:([QPBleInfoTool commonsetIntWithMM:51]) width:([QPBleInfoTool commonsetIntWithMM:4]) height:([QPBleInfoTool commonsetIntWithMM:12]) str:@"寄件方" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
        
        //包裹寄件方 文字的框框
        [self.cpclManager drawBox:(1) top_left_x:([QPBleInfoTool commonsetIntWithMM:0]) top_left_y:([QPBleInfoTool commonsetIntWithMM:50]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:6]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:63])];
        // 张学友
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:8]) text_y:([QPBleInfoTool commonsetIntWithMM:52]) text:@"张学友" fontSize:3 rotate:0 bold:1 reverse:NO underline:NO];
        // 186 8888 8888
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:28]) text_y:([QPBleInfoTool commonsetIntWithMM:52]) text:@"186 8888 8888" fontSize:2 rotate:0 bold:0 reverse:NO underline:NO];
        // 广东省深圳市南山区软件产业基地17楼
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:8]) text_y:([QPBleInfoTool commonsetIntWithMM:58]) text:@"广东省深圳市南山区软件产业基地17楼" fontSize:2 rotate:0 bold:0 reverse:NO underline:NO];
        
        // 寄托物 一栏 ===============
        [self.cpclManager drawBox:(2) top_left_x:(0) top_left_y:([QPBleInfoTool commonsetIntWithMM:63]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:73]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:80])];
        // 包裹 寄托物 文字的框框
        [self.cpclManager drawBox:(1) top_left_x:([QPBleInfoTool commonsetIntWithMM:0]) top_left_y:([QPBleInfoTool commonsetIntWithMM:63]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:6]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:80])];
        // 寄托物 文字 竖着的
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:1]) text_y:([QPBleInfoTool commonsetIntWithMM:66]) width:([QPBleInfoTool commonsetIntWithMM:4]) height:([QPBleInfoTool commonsetIntWithMM:13]) str:@"寄托物" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
        // 服务类型  文字
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:8]) text_y:([QPBleInfoTool commonsetIntWithMM:64]) text:@"服务类型：" fontSize:2 rotate:0 bold:0 reverse:NO underline:NO];
        // 门到门  文字
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:23]) text_y:([QPBleInfoTool commonsetIntWithMM:64]) text:@"门到门" fontSize:2 rotate:0 bold:0 reverse:NO underline:NO];
        // 增值服务：
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:8]) text_y:([QPBleInfoTool commonsetIntWithMM:68]) text:@"增值服务：" fontSize:2 rotate:0 bold:0 reverse:NO underline:NO];
        // 保价
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:23]) text_y:([QPBleInfoTool commonsetIntWithMM:68]) text:@"保价" fontSize:2 rotate:0 bold:0 reverse:NO underline:NO];
        // 备注说明：
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:8]) text_y:([QPBleInfoTool commonsetIntWithMM:72]) text:@"备注说明：" fontSize:2 rotate:0 bold:0 reverse:NO underline:NO];
        // 我是备注
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:23]) text_y:([QPBleInfoTool commonsetIntWithMM:72]) width:([QPBleInfoTool commonsetIntWithMM:48]) height:([QPBleInfoTool commonsetIntWithMM:10]) str:@"我是备注我是备注我是备注我是备注" fontsize:2 rotate:0 bold:0 underline:0 reverse:0];
        
        
        // 包裹 寄件客户存根联 文字的框框
        [self.cpclManager drawBox:(1) top_left_x:([QPBleInfoTool commonsetIntWithMM:73]) top_left_y:([QPBleInfoTool commonsetIntWithMM:50]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:86]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:80])];
        // 寄件客户存根联 文字 数着的
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:75]) text_y:([QPBleInfoTool commonsetIntWithMM:51]) width:([QPBleInfoTool commonsetIntWithMM:4]) height:([QPBleInfoTool commonsetIntWithMM:25]) str:@"寄件客户存根联" fontsize:2 rotate:0 bold:1 underline:NO reverse:NO];
        //        总件数 一栏框框 ==========
        [self.cpclManager drawBox:(1) top_left_x:([QPBleInfoTool commonsetIntWithMM:0]) top_left_y:([QPBleInfoTool commonsetIntWithMM:80]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:50]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:90])];
        //包裹 总件数 的框框
        [self.cpclManager drawBox:(1) top_left_x:([QPBleInfoTool commonsetIntWithMM:0]) top_left_y:([QPBleInfoTool commonsetIntWithMM:80]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:11]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:90])];
        // 总件数 文字
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:0]) text_y:([QPBleInfoTool commonsetIntWithMM:83]) text:@"总件数" fontSize:3 rotate:0 bold:0 reverse:NO underline:NO];
        // 计费重量 框框
        [self.cpclManager drawBox:(1) top_left_x:([QPBleInfoTool commonsetIntWithMM:20]) top_left_y:([QPBleInfoTool commonsetIntWithMM:80]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:35]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:90])];
        // 计费重量 文字
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:21]) text_y:([QPBleInfoTool commonsetIntWithMM:83]) text:@"计费重量" fontSize:2 rotate:0 bold:0 reverse:NO underline:NO];
        //  运费 一栏框框 ==========
        [self.cpclManager drawBox:(1) top_left_x:([QPBleInfoTool commonsetIntWithMM:0]) top_left_y:([QPBleInfoTool commonsetIntWithMM:90]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:50]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:100])];
        //包裹 运费 的框框
        [self.cpclManager drawBox:(1) top_left_x:([QPBleInfoTool commonsetIntWithMM:0]) top_left_y:([QPBleInfoTool commonsetIntWithMM:90]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:11]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:100])];
        // 运费 文字
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:1]) text_y:([QPBleInfoTool commonsetIntWithMM:93]) text:@"运费" fontSize:2 rotate:0 bold:0 reverse:NO underline:NO];
        //  寄件客户签名： 框框
        [self.cpclManager drawBox:(1) top_left_x:([QPBleInfoTool commonsetIntWithMM:50]) top_left_y:([QPBleInfoTool commonsetIntWithMM:80]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:86]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:100])];
        //寄件客户签名： 文字
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:51]) text_y:([QPBleInfoTool commonsetIntWithMM:82]) text:@"寄件客户签名：" fontSize:2 rotate:0 bold:1 reverse:NO underline:NO];
        // 月
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:67]) text_y:([QPBleInfoTool commonsetIntWithMM:96]) text:@"月" fontSize:2 rotate:0 bold:1 reverse:NO underline:NO];
        // 日
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:77]) text_y:([QPBleInfoTool commonsetIntWithMM:96]) text:@"日" fontSize:2 rotate:0 bold:1 reverse:NO underline:NO];
        // *签收前请注意检查获取包装！
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:2]) text_y:([QPBleInfoTool commonsetIntWithMM:101]) text:@"*签收前请注意检查获取包装！" fontSize:2 rotate:0 bold:1 reverse:NO underline:NO];
        
        [self.cpclManager print:0 skip:0];
        
    });
    
    
}
// 标签打印测试
-(void)pushPrintTagTest{
    NSLog(@"标签打印测试");
    if (![self.bleManager isConnectBle]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"未连接设备！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *done = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:done];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
  //------
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(globalQueue, ^{
        [self.cpclManager reset];
        if ([self.bleManager.discoveredPeripheral.name isEqualToString:@"HM-A300"]) {
            self.pageWidth = 588;
        }else if([self.bleManager.discoveredPeripheral.name isEqualToString:@"BTP-P33"]){
            self.pageWidth = 568;
        }
        [self.cpclManager pageSetup:self.pageWidth pageHeight:self.pageHeight qty:1];
        [self.cpclManager drawBox:(1) top_left_x:(0) top_left_y:([QPBleInfoTool commonsetIntWithMM:0]) bottom_right_x:(self.pageWidth) bottom_right_y:(self.pageHeight-100)];
        
        [self.cpclManager drawBox:(1) top_left_x:(0) top_left_y:([QPBleInfoTool commonsetIntWithMM:0]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:86]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:18])];
        // 顺丰和悟空logo
//        [self.cpclManager drawGraphic:[QPBleInfoTool commonsetIntWithMM:2] start_y:[QPBleInfoTool commonsetIntWithMM:2] picName:@"sflogo"];
        [self.cpclManager printSFAndWKLogoWithX:[QPBleInfoTool commonsetIntWithMM:2] y:[QPBleInfoTool commonsetIntWithMM:2]];
        //9533866
//        [self.cpclManager drawGraphic:[QPBleInfoTool commonsetIntWithMM:40] start_y:[QPBleInfoTool commonsetIntWithMM:2] picName:@"phone"];
        [self.cpclManager printSFAndWKPhoneWithX:[QPBleInfoTool commonsetIntWithMM:39] y:[QPBleInfoTool commonsetIntWithMM:2]];
        // 悟空快运栏=====================
        [self.cpclManager drawBox:(2) top_left_x:(0) top_left_y:([QPBleInfoTool commonsetIntWithMM:18]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:86]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:43])];
        // 条形码
        [self.cpclManager drawBarCode:([QPBleInfoTool commonsetIntWithMM:4]) start_y:([QPBleInfoTool commonsetIntWithMM:20]) text:@"123456789123" type:1 rotate:0 linewidth:2 height:80];
        //母单号
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:4]) text_y:([QPBleInfoTool commonsetIntWithMM:32]) text:@"母单号" fontSize:3 rotate:0 bold:NO reverse:NO underline:NO];
        //123 456 789 123
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:19]) text_y:([QPBleInfoTool commonsetIntWithMM:32]) text:@"123 456 789 123" fontSize:2 rotate:0 bold:NO reverse:NO underline:NO];
        //子单号
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:4]) text_y:([QPBleInfoTool commonsetIntWithMM:35]) text:@"子单号" fontSize:3 rotate:0 bold:NO reverse:NO underline:NO];
        //123 456 789 123
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:19]) text_y:([QPBleInfoTool commonsetIntWithMM:35]) text:@"123 456 789 123 001" fontSize:2 rotate:0 bold:NO reverse:NO underline:NO];
        //包裹【悟空快运】的方块
        [self.cpclManager drawBox:(1) top_left_x:([QPBleInfoTool commonsetIntWithMM:55]) top_left_y:([QPBleInfoTool commonsetIntWithMM:18]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:86]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:43])];
        // 悟空快运 文字
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:59]) text_y:([QPBleInfoTool commonsetIntWithMM:28]) text:@"悟空快运" fontSize:3 rotate:0 bold:1 reverse:NO underline:NO];
        // 始发地 一栏 ==========================
        [self.cpclManager drawBox:(2) top_left_x:(0) top_left_y:([QPBleInfoTool commonsetIntWithMM:43]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:73]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:56])];
        // 包裹 始发地 文字的框框
        [self.cpclManager drawBox:(1) top_left_x:(0) top_left_y:([QPBleInfoTool commonsetIntWithMM:43]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:6]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:56])];
        // 始发地 文字 竖着的
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:1]) text_y:([QPBleInfoTool commonsetIntWithMM:45]) width:([QPBleInfoTool commonsetIntWithMM:4]) height:([QPBleInfoTool commonsetIntWithMM:13]) str:@"始发地" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
        // 深圳市
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:12]) text_y:([QPBleInfoTool commonsetIntWithMM:47]) text:@"深圳市" fontSize:3 rotate:0 bold:1 reverse:NO underline:NO];
        
        // 包裹 目的地 文字的框框
        [self.cpclManager drawBox:(1) top_left_x:([QPBleInfoTool commonsetIntWithMM:35]) top_left_y:([QPBleInfoTool commonsetIntWithMM:43]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:41]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:56])];
        // 目的地 文字 竖着的
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:37]) text_y:([QPBleInfoTool commonsetIntWithMM:45]) width:([QPBleInfoTool commonsetIntWithMM:4]) height:([QPBleInfoTool commonsetIntWithMM:13]) str:@"目的地" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
        // 北京市
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:43]) text_y:([QPBleInfoTool commonsetIntWithMM:47]) text:@"北京市" fontSize:3 rotate:0 bold:1 reverse:NO underline:NO];
        // 服务类型 一栏 ===============
        [self.cpclManager drawBox:(2) top_left_x:(0) top_left_y:([QPBleInfoTool commonsetIntWithMM:56]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:73]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:73])];
        // 包裹 服务类型 文字的框框
        [self.cpclManager drawBox:(1) top_left_x:([QPBleInfoTool commonsetIntWithMM:0]) top_left_y:([QPBleInfoTool commonsetIntWithMM:56]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:6]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:73])];
        // 服务类型 文字 竖着的
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:1]) text_y:([QPBleInfoTool commonsetIntWithMM:59]) width:([QPBleInfoTool commonsetIntWithMM:4]) height:([QPBleInfoTool commonsetIntWithMM:13]) str:@"服务类型" fontsize:2 rotate:0 bold:0 underline:NO reverse:NO];
        // 门到门  文字
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:12]) text_y:([QPBleInfoTool commonsetIntWithMM:62]) text:@"门到门" fontSize:3 rotate:0 bold:1 reverse:NO underline:NO];
        // 包裹 标签栏 文字的框框
        [self.cpclManager drawBox:(1) top_left_x:([QPBleInfoTool commonsetIntWithMM:73]) top_left_y:([QPBleInfoTool commonsetIntWithMM:43]) bottom_right_x:([QPBleInfoTool commonsetIntWithMM:86]) bottom_right_y:([QPBleInfoTool commonsetIntWithMM:73])];
        // 标签栏 文字 数着的
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:75]) text_y:([QPBleInfoTool commonsetIntWithMM:50]) width:([QPBleInfoTool commonsetIntWithMM:4]) height:([QPBleInfoTool commonsetIntWithMM:13]) str:@"标签栏" fontsize:3 rotate:0 bold:1 underline:NO reverse:NO];
        //最后一栏框框 ==========
        // 件号:  文字
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:4]) text_y:(self.pageHeight-150) text:@"件号：" fontSize:3 rotate:0 bold:1 reverse:NO underline:NO];
        
        // 2/2
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:14]) text_y:(self.pageHeight-147) text:@"2/2" fontSize:2 rotate:0 bold:1 reverse:NO underline:NO];
        // 月
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:60]) text_y:(self.pageHeight-150) text:@"月" fontSize:3 rotate:0 bold:1 reverse:NO underline:NO];
        //日
        [self.cpclManager drawText:([QPBleInfoTool commonsetIntWithMM:73]) text_y:(self.pageHeight-150) text:@"日" fontSize:3 rotate:0 bold:1 reverse:NO underline:NO];
        
        [self.cpclManager print:0 skip:0];
        //=========================================
    });
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

#pragma mark lazy load
-(UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.frame = self.view.bounds;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}
-(NSMutableArray *)dataList{
    if (_dataList == nil) {
        _dataList = [NSMutableArray new];
    }
    return _dataList;
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
@end
