//
//  JQCPCLTool.m
//  bleDemo
//
//  Created by 高明阳(01370716) on 2018/2/6.
//  Copyright © 2018年 gaomingyang. All rights reserved.
//

#import "JQCPCLTool.h"
#import <UIKit/UIKit.h>
#import "BleDeviceManager.h"
#import "UIImage+Bitmap.h"

#define GBK_Encoding CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)
@interface JQCPCLTool()
@property (nonatomic, strong)BleDeviceManager *bleManager;


@end
@implementation JQCPCLTool
/**
 *  获取打印服务单例对象
 *
 *  @return 打印服务单例对象
 */
+(instancetype)CPCLManager{
    static JQCPCLTool *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JQCPCLTool alloc] init];
    });
    
    return manager;
}

- (instancetype)init{
    self = [super init];
    
    self.bleManager = [BleDeviceManager bleManager];
    
    return self;
}

/**
 *  重置打印机
 */
-(void)reset{
    
    Byte reset[] = {0x1B, 0x40};
    //清空数据
    [self.finalData resetBytesInRange:NSMakeRange(0, self.finalData.length)];
    [self.finalData setLength:0];
    [self.bleManager writeCmd:reset cmdLenth:sizeof(reset)];
    
}
/**
 *  页模式下打印
 *
 *  @param horizontal 0:正常打印，不旋转；
 *                    1：整个页面顺时针旋转180°后，再打印
 *  @param skip       0：打印结束后不定位，直接停止；
 *                    1：打印结束后定位到标签分割线，如果无缝隙，最大进纸30mm后停止
 */
- (void)print:(int)horizontal skip:(int)skip{
    NSString *FORM = @"FORM\n";
    NSData   *formData = [FORM dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:formData];
    NSString *PRINT = @"PRINT\n";
    NSData *printData = [PRINT dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:printData];
    NSLog(@"最终调用打印命令-self.finalData:%ld",(unsigned long)self.finalData.length);
    [self.bleManager writeData:self.finalData];
}
/**
 *  设置打印纸张大小（打印区域）的大小
 *
 *  @param pageWidth  打印区域宽度
 *  @param pageHeight 打印区域高度
 */
- (void)pageSetup:(int)pageWidth pageHeight:(int)pageHeight qty:(int)qty{
    NSString *INIT_PRINT_COMMOND_TEMPLATE = [NSString stringWithFormat:@"! %d %d %d %d %d\n",0,200,200,pageHeight,qty];
    NSString *PAGE_WIDTH = [NSString stringWithFormat:@"PAGE-WIDTH %d\n",pageWidth];
    NSLog(@"INIT_PRINT_COMMOND_TEMPLATE :%@",INIT_PRINT_COMMOND_TEMPLATE);
    NSLog(@"PAGE_WIDTH:%@",PAGE_WIDTH);
    NSData *initData = [INIT_PRINT_COMMOND_TEMPLATE dataUsingEncoding:GBK_Encoding];
    NSData *page_width_data = [PAGE_WIDTH dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:initData];
    [self.finalData appendData:page_width_data];
}
/**
 *  打印边框
 *
 *  @param lineWidth      边框线条宽度
 *  @param top_left_x     矩形框左上角x坐标
 *  @param top_left_y     矩形框左上角y坐标
 *  @param bottom_right_x 矩形框右下角x坐标
 *  @param bottom_right_y 矩形框右下角y坐标
 */
- (void)drawBox:(int)lineWidth top_left_x:(int)top_left_x top_left_y:(int)top_left_y
 bottom_right_x:(int)bottom_right_x bottom_right_y:(int)bottom_right_y{
    NSString *BOX_CMD_TEMPLATE = [NSString stringWithFormat:@"BOX %d %d %d %d %d\n",top_left_x,top_left_y,bottom_right_x,bottom_right_y,lineWidth];
    NSLog(@"BOX_CMD_TEMPLATE:%@",BOX_CMD_TEMPLATE);
    NSData *bytesData = [BOX_CMD_TEMPLATE dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:bytesData];
}
/**
 *  打印线条
 *
 *  @param lineWidth 线条宽度
 *  @param start_x   线条起始点x坐标
 *  @param start_y   线条起始点y坐标
 *  @param end_x     线条结束点x坐标
 *  @param end_y     线条结束点y坐标
 *  @param fullline  true:实线  false: 虚线  保留字段
 */
- (void)drawLine:(int)lineWidth start_x:(int)start_x start_y:(int)start_y end_x:(int)end_x end_y:(int)end_y fullline:(BOOL)fullline{
    NSString *LINE_CMD_TEMPLATE = [NSString stringWithFormat:@"LINE %d %d %d %d %d\n",start_x,start_y,end_x,end_y,lineWidth];
    NSLog(@"LINE_CMD_TEMPLATE:%@",LINE_CMD_TEMPLATE);
    NSData *bytesData = [LINE_CMD_TEMPLATE dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:bytesData];
}
/**
 *  页模式下打印文本框
 *
 *  @param text_x    起始横坐标
 *  @param text_y    起始纵坐标
 *  @param text      打印的文本内容
 *  @param fontSize  字体大小 1：16点阵；2：24点阵；3：32点阵；4：24点阵放大一倍；5：32点阵放大一倍; 6：24点阵放大两倍；7：32点阵放大两倍；其他：24点阵
 *  @param rotate    旋转角度: 0：不旋转；    1：90度；    2：180°；    3:270°
 *  @param bold      是否粗体: false：否； true：是
 *  @param reverse   是否反白：false：不反白；true：反白
 *  @param underline 是有有下划线：false:没有；true：有
 */
- (void)drawText:(int)text_x text_y:(int)text_y text:(NSString *)text fontSize:(int)fontSize rotate:(int)rotate bold:(int)bold reverse:(BOOL)reverse underline:(BOOL)underline{
    if (underline) {
        NSString *UNDERLINE_CMD_TEMPLATE = [NSString stringWithFormat:@"UNDERLINE ON\n"];
        NSData *ubytesData = [UNDERLINE_CMD_TEMPLATE dataUsingEncoding:GBK_Encoding];
        [self.finalData appendData:ubytesData];
    }
    if (bold) {
        NSString *BOLD_CMD_TEMPLATE = [NSString stringWithFormat:@"U1 SETBOLD 2\n"];
        NSData *bBytesData = [BOLD_CMD_TEMPLATE dataUsingEncoding:GBK_Encoding];
        [self.finalData appendData:bBytesData];
    }
    
    NSString *printName  = self.bleManager.discoveredPeripheral.name;
    int font =  7;
    if([printName isEqualToString:@"HM-A300"]) {
        font = 7;
    }else if([printName isEqualToString:@"BTP-P33"]){
        font = 3;
    }
    
    NSString *TEXT_CMD = [NSString stringWithFormat:@"TEXT %d %d %d %d %@\n",font,fontSize,text_x,text_y,text];
    NSLog(@"TEXT_CMD_TEMPLATE:%@",TEXT_CMD);
    NSData *bytesData = [TEXT_CMD dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:bytesData];
    if (underline) {
        NSString *UNDERLINE_OFF_CMD_TEMPLATE = [NSString stringWithFormat:@"UNDERLINE OFF\n"];
        NSData *nfbytesData = [UNDERLINE_OFF_CMD_TEMPLATE dataUsingEncoding:GBK_Encoding];
        [self.finalData appendData:nfbytesData];
    }
    if (bold) {
        NSString *OFF_BOLD_CMD_TEMPLATE = [NSString stringWithFormat:@"U1 SETBOLD 0\n"];
        NSData   *offBoldBytesData = [OFF_BOLD_CMD_TEMPLATE dataUsingEncoding:GBK_Encoding];
        [self.finalData appendData:offBoldBytesData];
    }
}

/**
 *  页模式下打印文本框
 *
 *  @param text_x    起始横坐标
 *  @param text_y    起始纵坐标
 *  @param width     文本框宽度
 *  @param height    文本框高度
 *  @param text      打印的文本内容
 *  @param fontSize  字体大小 1：16点阵；2：24点阵；3：32点阵；4：24点阵放大一倍；5：32点阵放大一倍; 6：24点阵放大两倍；7：32点阵放大两倍；其他：24点阵
 *  @param rotate    旋转角度: 0：不旋转；    1：90度；    2：180°；    3:270°
 *  @param bold      是否粗体: false：否； true：是
 *  @param reverse   是否反白：false：不反白；true：反白
 *  @param underline 是有有下划线：false:没有；true：有
 */
- (void)drawText:(int)text_x text_y:(int)text_y width:(int)width height:(int)height str:(NSString *)str fontsize:(int)fontsize
          rotate:(int)rotate bold:(int)bold underline:(BOOL)underline reverse:(BOOL)reverse{
    int length = (int)str.length;
    int itemY = 25;
    int itemX = 25;
    if (height>width) {//文字竖着显示
        for (int i=0; i<length; i++) {
            NSString *subStr = [str substringWithRange:NSMakeRange(i, 1)];
            int itemText_y = i*itemY + text_y;
            [self drawText:text_x text_y:itemText_y  text:subStr fontSize:fontsize rotate:rotate bold:bold reverse:reverse underline:underline];
        }
    }
    if (width>=height) {//文字正常显示
        int lineNum = 0;//第几行
        int lineCount = width/itemX;//一行能够显示多少个字
        int itemText_y = text_y;
        for (int i=0; i<length; i++) {
            NSString *subStr = [str substringWithRange:NSMakeRange(i, 1)];
            int itemText_x = i*itemX + text_x;
            //            if (itemText_x + itemX > width+text_x) {
            lineNum = i/lineCount;//当前是第几行
            itemText_x  = (i%lineCount)*itemX+text_x;
            itemText_y = lineNum*itemY + text_y;
            //            }
            [self drawText:itemText_x text_y:itemText_y  text:subStr fontSize:fontsize rotate:rotate bold:bold reverse:reverse underline:underline];
        }
    }
    
}
/**
 *  打印一维条码
 *
 *  @param start_x   一维码起始横坐标
 *  @param start_y   一维码起始纵坐标
 *  @param text      内容
 *  @param type      条码类型：0：CODE39；    1：CODE128；2：CODE93 3：CODEBAR；4：EAN8；5：EAN13；6：UPCA; 7:UPC-E; 8:ITF
 *  @param rotate    旋转角度: 0：不旋转；1：90度；    2：180°；3:270°
 *  @param linewidth 条码线宽度
 *  @param height    条码高度
 */
- (void)drawBarCode:(int)start_x start_y:(int)start_y text:(NSString *)text type:(int)type rotate:(int)rotate linewidth:(int)linewidth height:(int)height{
    NSString *BARCODE_CMD_TEMPLATE = [NSString stringWithFormat:@"BARCODE %@ %d %d %d %d %d %@\n",[self getBarcodeTypeWithIntType:type],linewidth,rotate,height,start_x,start_y,text];
    NSLog(@"BARCODE_CMD_TEMPLATE:%@",BARCODE_CMD_TEMPLATE);
    NSData *barData = [BARCODE_CMD_TEMPLATE dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:barData];
}
/**
 *  打印二维码
 *
 *  @param start_x 二维码起始横坐标
 *  @param start_y 二维码起始纵坐标
 *  @param text    二维码内容
 *  @param rotate  旋转角度：0：不旋转；    1：90度；    2：180°；    3:270°
 *  @param ver     QrCode宽度(2-6)
 *  @param lel     QrCode纠错等级(0-20)
 */
- (void)drawQrCode:(int)start_x start_y:(int)start_y text:(NSString *)text rotate:(int)rotate ver:(int)ver lel:(int)lel{
    NSString *QR_CODE_TEMPLATE1 = [NSString stringWithFormat:@"B QR %d %d M %d U %d\n",start_x,start_y,2,5];
    NSData   *qrTemplate1Data = [QR_CODE_TEMPLATE1 dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:qrTemplate1Data];
    NSString *QR_CODE_TEMPLATE2 = [NSString stringWithFormat:@"MA,QR code %@\n",text];// MA一些模式选择
    NSData   *qrTGemplate2Data = [QR_CODE_TEMPLATE2 dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:qrTGemplate2Data];
    NSString *ENDQR = @"ENDQR\n";
    NSData   *endQRData = [ENDQR dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:endQRData];
}
/**
 *  打印图片
 *
 *  @param start_x     图片起始点横坐标
 *  @param start_y     图片起始点纵坐标
 *  @param picName     图片名字
 */
- (void)drawGraphic:(int)start_x start_y:(int)start_y picName:(NSString *)picName{
    UIImage *image = [UIImage imageNamed:picName];
    UIImage *newImage = [image imageWithscaleMaxWidth:500];
    newImage = [newImage blackAndWhiteImage];
    
    NSString *hex = [self picToBitmbp:newImage];
    //    NSString *hex = [self UIImageToBase64Str:image];
    
    NSInteger hei = image.size.height;
    NSInteger wid = image.size.width;
    if (wid % 8 > 0) {
        wid = wid / 8;
    }else{
        wid = wid / 8 - 1;
    }
    //    NSString *imageStr = [self stringFromHexString:hex];
    // CG 8 8 0 10 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F  0F 0F 0F 0F 0F 0F 0F 0F
    
    //EXPANDED-GRAPHICS  打印图片清晰，但是需要点击两次
    //CG 打印图片不清晰，但是点击一次就可以。
    NSString *IMAGE_PRINT_CMD_TEMPLATE = [NSString stringWithFormat:@"CG %ld %ld %d %d %@",(long)wid,(long)hei,start_x,start_y,hex];
    NSData   *cmdData = [IMAGE_PRINT_CMD_TEMPLATE dataUsingEncoding:GBK_Encoding];
    //    NSLog(@"IMAGE_PRINT_CMD_TEMPLATE:%@",IMAGE_PRINT_CMD_TEMPLATE);
    [self.finalData appendData:cmdData];
    
    //再添加一个换行
    NSData *enterData = [@"\n" dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:enterData];
    
    //    NSString *FORM_CMD = [NSString stringWithFormat:@"FORM\r\n"];
    //    NSData *formData = [FORM_CMD dataUsingEncoding:GBK_Encoding];
    //    [self.finalData appendData:formData];
}

-(void)drawGraphicWithX:(int)x y:(int)y imageName:(NSString *)imageName{
    //如果图片过大则可以先缩小下图片再获取图片的数据
    UIImage *image = [UIImage imageNamed:imageName];
    image = [image imageWithscaleMaxWidth:400];
    image = [image blackAndWhiteImage];
    
    NSData  *imageData = [self pictureToBitMap:image];
    
    
    //    Byte alignBytes[] = {0x1B,0x61,0x00};
    //    [self.finalData appendBytes:alignBytes length:sizeof(alignBytes)];
    
    NSInteger hei = image.size.height;
    NSInteger wid = image.size.width;
    if (wid % 8 > 0) {
        wid = wid / 8;
    }else{
        wid = wid / 8 - 1;
    }
    // CG 8 8 0 10 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F  0F 0F 0F 0F 0F 0F 0F 0F
    NSString *IMAGE_PRINT_CMD_TEMPLATE = [NSString stringWithFormat:@"CG %ld %ld %d %ld ",(long)wid,(long)hei,x,(long)y];
    NSData   *cmdData = [IMAGE_PRINT_CMD_TEMPLATE dataUsingEncoding:GBK_Encoding];
    NSLog(@"IMAGE_PRINT_CMD_TEMPLATE:%@",IMAGE_PRINT_CMD_TEMPLATE);
    [self.finalData appendData:cmdData];
    //    NSData   *imageData = [self dataFormHexString:hex];
    //    NSMutableData *connectData = [NSMutableData new];
    //    [connectData appendData:cmdData];
    //    [connectData appendData:imageData];
    [self.finalData appendData:imageData];
    
    //再添加一个换行
    Byte esc_print_enter[] = {0x0D};
    [self.finalData appendBytes:esc_print_enter length:sizeof(esc_print_enter)];
    
    //  -- test
    //1、重置打印机
    //    [self reset];
    //    [self pageSetup:568 pageHeight:800 qty:1];
    //    [self drawText:0 text_y:0 text:@"重" fontSize:2 rotate:0 bold:0 reverse:NO underline:NO];
    //    //4、调用打印命令，
    //    [self print:0 skip:0];
}

/**
 打印顺丰logo图片
 **/
-(void)printSFAndWKLogoWithX:(int)x y:(int)y{
    NSString *IMAGE_PRINT_CMD_TEMPLATE = [NSString stringWithFormat:@"EG 25 77 %d %ld 000000007ff8000000000000000000000000000000000000000000001fffffe0000000000000000000000000000000000000000001fffffffc000000000000000001fffffffffffffffffc000007ffffffff800000000000000001fffffffffffffffffe00003fffffffffe00000000000000001fffffffffffffffffe0000fffffffffff80000000000000001fffffffffffffffffe0003fffffffffffe0000000000000001fffffffffffffffffe0007ffffffffffff8000000000000001fffffffffffffffffe001fffffffffffffc000000000000001fffffffffffffffffe000ffffe0001ffff8000000000000001fffffffffffffffffe0003ffe000001fff0000000000000001fffffffffffffffffe0081ff00000003fe0800000000000001fff0e0007ffe3ffffe00c0fc00000000f81c00000000000001fff0e0007ffc1ffffe01e07000000000301e00000000000001fff0e0007800000ffe01f00000000000003e00000000000001ffc0e0007800000ffe03f00000000000007f00000000000001ffc03c3ff800000ffe03f8000000000000ff00000000000001ffc00000f87fff0ffe07fc000000000000ff80000000000001ffc02000f843e00ffe07fc000000000001ff80000000000001ffc02000ff83e07ffe0ffc000000000000ff80000000000001ffc01000ff07f07ffe0ff8000000000000ffc0000000000001ffc01870fe07f83ffe1ff80000000000007fc0000000000001ff8010307e0ff83ffe1ff003ff8007ffe07fe0000000000001ff8000007e1ffc1ffe1ff00fffe07ffff83fe0000000000001ff8000007c00000ffe3fe01ffff07ffffc3fe0000000000001ff8000007c00000ffe3fe03ffff07ffffc1ff0000000000001ff8018007c00001ffe3fe07ffff07ffffc1ff0000000000001ffd0f0007ffc1ffffe3fc07feff07ffffc1ff0000000000001fff0e0007ffc1ffffe7fc0ff00f07f003c1ff0000000000001fff0e0007ffc1ffffe7fc0fe00307e000c0ff0000000000001fff0e0f07ffc1ffffe7fc0fc00007e00000ff8000000000001fff0e0f87ffe1ffffe7fc0fc00007e00000ff8000000000001fff0e0f07804100ffe7f80fe00007e00000ff8000000000001fff0e00078000007fe7f80ff00007e00000ff8000000000001fff0e00078000007fe7f80ffc0007e000007f8000000000001fff0e000f8000007feff807ff0007e020007f8000000000001fff9fffffffffffffeff803ffc007e0f8007f8000000000001fffffffffffffffffeff801ffe007e1fc007f8000000000001fffffffffffffffffeff800fff807e1fc007f8000000000001fffffffffffffffffeff8007ffc07e1fc007f8000000000001fffffffffffffffffeff8001ffe07e1fc007f8000000000001fffff1fffffffffffeff80007fe07e1fc007f8000000000001ffffe0fff860001ffe7f80001ff07e0f8007f8000000000001ffffe0fff820001ffe7f800007f07e00000ff8000000000001ffc000007820001ffe7f800003f87e00000ff8000000000001ffc000007860001ffe7fc00003f87e00000ff8000000000001ffc000007ffffffffe7fc00003f87e00000ff8000000000001ffc00000787ffffffe7fc08003f87e00000ff8000000000001ffffe0fff83ffffffe7fc0e003f87e00001ff0000000000001ffffe0fff800000ffe3fc0f007f87e00001ff0000000000001ffffe0fff800000ffe3fe0fe0ff07e00001ff0000000000001ffc00000f800000ffe3fe0fffff07e00001ff0000000000001ffc0000078783ffffe3fe0ffffe07e00003fe0000000000001ffc0000078307c3ffe1ff0ffffe07e00003fe0000000000001ffc00000f8307c3ffe1ff07fffc07e00007fe0000000000001ffffe1fff830fc1ffe1ff81fff007e00007fc0000000000001ffffe0fff820fc1ffe0ff803fc007e00007fc0000000000001ffffe1fff820001ffe0ffc000000000000ffc0000000000001ffc000007840000ffe07fc000000000001ff80000000000001ff8000007840000ffe07fc000000000001ff80000000000001ff8000007860001ffe07f8000000000000ff00000000000001ff800000783ffffffe03f00000000000007f00000000000001ffffe1fff800000ffe03f00000000000003e00000000000001ffffe0fff800000ffe01e07000000000301e00000000000001ffffe0fff800000ffe00c0f800000000f81c00000000000001ffffe1fffffffffffe00c1ff00000003fe0800000000000001fffffffffffffffffe0003ffc000001fff0000000000000001fffffffffffffffffe000ffffc0001ffff8000000000000001fffffffffffffffffe001fffffffffffffc000000000000001fffffffffffffffffe0007ffffffffffff8000000000000001fffffffffffffffffe0003fffffffffffe0000000000000001fffffffffffffffffe0000fffffffffff80000000000000001fffffffffffffffffe00003ffffffffff00000000000000001fffffffffffffffffe00000fffffffff8000000000000000008000000000001ffffc000001fffffffc0000000000000000000000000000000000000000001fffffe000000000000000000000000000000000000000000000fff800000000000000000000000000000000000000",x,(long)y];
    NSData   *cmdData = [IMAGE_PRINT_CMD_TEMPLATE dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:cmdData];
    //再添加一个换行
    NSData *enterData = [@"\n" dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:enterData];
}

/**
 打印顺丰电话图片
 **/
-(void)printSFAndWKPhoneWithX:(int)x y:(int)y{
    NSString *IMAGE_PRINT_CMD_TEMPLATE = [NSString stringWithFormat:@"EG 30 83 %d %ld 00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000001ffe000000000000000000000000000000000000000000000000000000007fff8000001f80000000001fc0001fc0000f80000fc0000fc00000000001ffffc00000fff007fffe00fff000fff0007ff8003ff8003ff80000000003fffff00003fff807fffe01fffc01fffc01fffc00fffc00fffc0000000007fffff80007fffc07fffe03fffe03fffe03ffff01fffe01fffe000000000ffffffc000ffffe07fffe07ffff07ffff07ffff03ffff03ffff000000001ffffffc000ffffe07fffe0fffff0fffff07ffff83ffff83ffff800000003ffffffe001fe0ff0ffffe0ff0ff0ff0ff07f07f87f07f87f07f800000003ffff9ff001fc07f0fc0001fe07f1fe07f0ff03f87f03f87f03f800000007ffff0ff001fc03f0fc0001fc03f9fc03f8fe03f8fe03c0fe03c000000007ffff07f801f803f8fc00000c03f80c03f8fe03f8fe0000fe000000000007fffe07f803f803f8fc00000007f00007f07f03f8fc0000fc00000000000fffff07f801f803f8fcfc00000ff0000ff07f8ff8fc7f00fc7f000000000fffff8ff801fc03f8ffff80003fe0003fe07ffff1fcff81fcff800000000fffff8ffc01fc07f8ffffc007ffc007ffc03fffe1ffffe1ffffe00000000fffff1ffc01ff1ff8ffffe007ff0007ff000fff81fffff1fffff00000000ffffe1ffc00fffff8fffff007ff8007ff800fffc1fffff9fffff80000000ffffc3ffc00fffff8ff1ff007ffc007ffc03ffff1ffcff9ffcff80000000ffff87ff8007ffff8fc07f807fff007fff07ffff9ff03f9ff03f80000000ffe70fff8003ffbf80003f8000ff0000ff0ff8ff9fe01fdfe01fc0000000ff801fff80007e3f80003f80007f80007f8fe03fdfc01fdfc01fc00000007f803fff8000003f80003f80003f80003f8fe01fcfc01fcfc01fc00000007f807fff0000003f00c03f80003f80003f9fc01fcfc01fcfc01fc00000003fc1ffff0001807f1fc03f8fc03f8fc03f9fc01fcfe01fcfe01fc00000003fefffff001fc07f1fc07f9fc03f9fc03f9fe01fcfe03fcfe03fc00000001ffffffe001fe0fe1fe0ff1fe07f9fe07f8ff03fc7f07f87f07f800000001ffffffc000ff7fe0ffbff1ff9ff9ff9ff8ff8ffc7ffff87ffff800000000ffffff8000ffffc0ffffe0fffff0fffff0fffff83ffff03ffff0000000007fffff00007fff807fffe07fffe07fffe07ffff03fffe03fffe0000000003ffffe00003fff003fffc03fffc03fffc03fffe01fffc01fffc0000000000ffffc00000ffe000fff001fff001fff000fff8007ff8007ff800000000007fff0000003f00001f80003f80003f80001fc0000f80000f8000000000000ffc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c0000000000007fe0fc00000000000000000000000000000000000000001c0000000000007fe1ff00000000000000000000000000000000000000001c0000000000007fe3c700000000000000000000000000000000000000001c000000000000700383800000000000000000000c081f0306c0818060c0dc0c0f033c03c8700302000f803c0cf1e00000000e1c1f8707e1c1c0e0e1dc3c3fc3ff0ffc600700001fe0ff1ffbf00000000e1c3f878ee1c38071e1dc787fe3ff1ffc7fc77e003ff1ff9ffff80000000e3e3b8f8ee3e38071f1dcf0f0e3c79c3c7fe7ff00387bc39e3e38000000063e39cf8e63e38071f39ce0e0f3839c1c70e7c700783383de1c38000000073631cd9c73630039b39fe0e07383bc1c00f78380700381dc1c38000000073671cddc7367003bb39fe0e07383b81c00770380700381dc1c38000000033770dddc3377003bbb1ff0e07383bc1c00770380700381dc1c3800000003e360fcf83e36001f3b1e78e073839c1ce0770380703b81dc1c3800000003e3e0f8f83e3e0e1f1f1c38f0e3839e3ce0e3879c787bc3dc1c3800000001e3c078f81e3c0e1f1e1c3c79e3838ffc79e3cf1e3cf1e79c1c3800000001e3c078f01e3c0e0e1e1c1e3fc38387dc7fc1fe1e1ff0ff1c1c3800000000c18030700c180e0e0c0c0e1f0303001c1f80fc0c0fc07e0c18180000000000000000000000000000000000001c1c000000000000000000000000000000000000000000000000000000001e7c000000000000000000000000000000000000000000000000000000000ff80000000000000000000000000000000000000000000000000000000007f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",x,(long)y];
    NSData   *cmdData = [IMAGE_PRINT_CMD_TEMPLATE dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:cmdData];
    //再添加一个换行
    NSData *enterData = [@"\n" dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:enterData];
}


- (NSMutableString *)picToBitmbp:(UIImage *)image{
    NSInteger wid = image.size.width;
    NSInteger hid = image.size.height;
    NSMutableString *str = [[NSMutableString alloc] init];
    if ((wid % 8) > 0) {
        wid = image.size.width + (8 - wid % 8);
    }
    else {
        wid = image.size.width;
    }
    // ============获取像素颜色的相关代码
    //    NSInteger back = 0;
    CGImageRef inImage = image.CGImage;
    
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL) {
        NSLog(@"cgctx == NULL");
        return 0; /* error */
    }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    CGContextDrawImage(cgctx, rect, inImage);
    
    unsigned char* data = CGBitmapContextGetData (cgctx);
    
    //    return back;
    
    //==============================
    for (int y = 0; y < hid - 1; y++) {
        NSInteger bit = 128;
        NSInteger currentValue = 0;
        for (int x = 0; x < wid - 1; x++) {
            NSInteger intensity = 0;
            if (x < image.size.width) {
                //                intensity = [self getPixelColorAtLocation:CGPointMake(x, y) image:image];
                if (data != NULL) {
                    
                    int offset = 4*((w*round(y))+round(x));
                    int alpha =  data[offset];
                    int red = data[offset+1];
                    int green = data[offset+2];
                    int blue = data[offset+3];
                    if (alpha == 0) {
                        intensity = 0;
                    }else{
                        intensity = 255 - (alpha + red + green + blue) / 4;
                    }
                }
                
            }else{
                intensity = 0;
            }
            if (intensity >= 128) {
                currentValue |= bit;
                bit = bit >> 1;
            }else{
                currentValue &= ~bit;
                bit = bit >> 1;
            }
            if (bit == 0) {
                
                [str appendFormat:@"%@",[self ToHex:currentValue]];
                bit = 128;
                currentValue = 0;
            }
        }
    }
    //------释放
    // When finished, release the context
    CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data) { free(data); }
    //=======
    return str;
}
-(NSString *)ToHex:(long long int)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    long long int ttmpig;
    for (int i = 0; i<17; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        
        if (tmpid == 0) {
            break;
        }
        
    }
    if (str.length == 1) {
        str = [NSString stringWithFormat:@"0%@",str];
    }
    
    return str;
}
-(NSMutableData *)pictureToBitMap:(UIImage *)image{
    NSInteger wid = image.size.width;
    NSInteger hid = image.size.height;
    //    NSMutableString *str = [[NSMutableString alloc] init];
    NSMutableData   *bufferData = [NSMutableData new];
    if ((wid % 8) > 0) {
        wid = image.size.width + (8 - wid % 8);
    }
    else {
        wid = image.size.width;
    }
    // ============获取像素颜色的相关代码
    //    NSInteger back = 0;
    CGImageRef inImage = image.CGImage;
    
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL) {
        return 0; /* error */
    }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    CGContextDrawImage(cgctx, rect, inImage);
    
    unsigned char* data = CGBitmapContextGetData (cgctx);
    
    //    return back;
    
    //==============================
    for (int y = 0; y < hid - 1; y++) {
        NSInteger bit = 128;
        NSInteger currentValue = 0;
        for (int x = 0; x < wid - 1; x++) {
            NSInteger intensity = 0;
            if (x < image.size.width) {
                //                intensity = [self getPixelColorAtLocation:CGPointMake(x, y) image:image];
                if (data != NULL) {
                    
                    int offset = 4*((w*round(y))+round(x));
                    int alpha =  data[offset];
                    int red = data[offset+1];
                    int green = data[offset+2];
                    int blue = data[offset+3];
                    if (alpha == 0) {
                        intensity = 0;
                    }else{
                        intensity = 255 - (alpha + red + green + blue) / 4;
                    }
                }
            }else{
                intensity = 0;
            }
            if (intensity >= 128) {
                currentValue |= bit;
                bit = bit >> 1;
            }else{
                currentValue &= ~bit;
                bit = bit >> 1;
            }
            if (bit == 0) {
                
                //                [str appendFormat:@"%@",[self ToHex:currentValue]];
                NSData *data = [self toHexData:currentValue];
                [bufferData appendData:data];
                bit = 128;
                currentValue = 0;
            }
        }
    }
    //------释放
    // When finished, release the context
    CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data) { free(data); }
    //=======
    return bufferData;
}
-(NSData *)toHexData:(long long int)tmpid{
    NSString *nLetterValue;
    NSString *str =@"";
    long long int ttmpig;
    for (int i = 0; i<17; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        
        if (tmpid == 0) {
            break;
        }
        
    }
    if (str.length == 1) {
        str = [NSString stringWithFormat:@"0%@",str];
    }
    
    return [self dataFormHexString:str];
}
- (NSData*)dataFormHexString:(NSString*)hexString{
    hexString=[[hexString uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!(hexString && [hexString length] > 0 && [hexString length]%2 == 0)) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    return bytes;
}
- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
    
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *     bitmapData;
    long             bitmapByteCount;
    long             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

/**
 *@param type      条码类型：0：CODE39；    1：CODE128；2：CODE93 3：CODEBAR；4：EAN8；5：EAN13；6：UPCA; 7:UPC-E; 8:ITF
 **/
-(NSString *)getBarcodeTypeWithIntType:(int)type{
    NSString *typeStr = @"";
    switch (type) {
        case 0:
            typeStr = @"39";
            break;
        case 1:
            typeStr = @"128";
            break;
        case 2:
            typeStr = @"93";
            break;
        case 3:
            typeStr = @"CODEBAR";
            break;
        case 4:
            typeStr = @"EAN8";
            break;
        case 5:
            typeStr = @"EAN13";
            break;
        case 6:
            typeStr = @"UPCA";
            break;
        case 7:
            typeStr = @"UPCE";
            break;
        case 8:
            typeStr = @"I2OF5";
            break;
        default:
            break;
    }
    return typeStr;
}
// 十六进制转换为普通字符串的。
-(NSString *)stringFromHexString:(NSString *)hexString { //
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [NSScanner scannerWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    //    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
}
//普通字符串转换为十六进制的。
- (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}
//图片转字符串
-(NSString *)UIImageToBase64Str:(UIImage *) image
{
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encodedImageStr;
}

#pragma mark -- lazy load
-(NSMutableData  *)finalData{
    if (_finalData == nil) {
        _finalData = [NSMutableData new];
    }
    return _finalData;
}
@end

