//
//  JQESCTool.m
//  bleDemo
//
//  Created by wuyaju on 2017/6/22.
//  Copyright © 2017年 wuyaju. All rights reserved.
//

#import "JQESCTool.h"
#import <UIKit/UIKit.h>
#import "BleDeviceManager.h"


#define GBK_Encoding CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)

@interface JQESCTool ()

@property (nonatomic, strong)BleDeviceManager *bleManager;

@property (nonatomic,strong)NSMutableData    *finalData;
@end

@implementation JQESCTool

+ (instancetype)ESCManager{
    static JQESCTool *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JQESCTool alloc] init];
    });
    
    return manager;
}

- (instancetype)init{
    self = [super init];
    
    self.bleManager = [BleDeviceManager bleManager];
    
    return self;
}

// 通过
/**
 * 3、打印文本。
 * @param text 表示所要打印的文本内容。
 */
- (Boolean)esc_print_text:(NSString *)text {
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *data = [text dataUsingEncoding:enc];
    [self.finalData appendData:data];
    return 0;
}

- (Boolean)barcodePrintQR:(int)size data:(NSString *)data {
    

    //发送设置QR码参数
    typedef unsigned char BYTE;
    BYTE pszCommand1[16] = {0};
    pszCommand1[0] = 0x1d;
    pszCommand1[1] = 0x28;
    pszCommand1[2] = 0x6b;
    pszCommand1[3] = 0x03;
    pszCommand1[4] = 0x00;
    pszCommand1[5] = 0x31;
    pszCommand1[6] = 0x43;
    pszCommand1[7] = size;
    pszCommand1[8] = 0x1d;
    pszCommand1[9] = 0x28;
    pszCommand1[10] = 0x6b;
    pszCommand1[11] = (data.length + 3);
    pszCommand1[12] = 0x00;
    pszCommand1[13] = 0x31;
    pszCommand1[14] = 0x50;
    pszCommand1[15] = 0x30;
    
    //[self.bleManager writeCmd:pszCommand1 cmdLenth:sizeof(pszCommand1)];
    
    [self.finalData appendBytes:pszCommand1 length:sizeof(pszCommand1)];
    
    //发送QR码数据
    NSData *dataSource = [data dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8)];
    [self.finalData appendData:dataSource];
    //[self.bleManager writeCmd:[dataSource bytes] cmdLenth:sizeof([dataSource bytes])];
    
    //发送结束数据
    BYTE pszCommand3[8] = {0};
    pszCommand3[0] = 0x1d;
    pszCommand3[1] = 0x28;
    pszCommand3[2] = 0x6b;
    pszCommand3[3] = 0x03;
    pszCommand3[4] = 0x00;
    pszCommand3[5] = 0x31;
    pszCommand3[6] = 0x51;
    pszCommand3[7] = 0x30;
    
    
      [self.finalData appendBytes:pszCommand3 length:sizeof(pszCommand3)];
    return 0;
    
    
}

/**
 * 4、发送字节流。
 * @param Bytes 表示所要发送的字节流。
 */
- (Boolean)esc_write_Bytes:(NSData *)Bytes {
    return [self.bleManager writeData:Bytes];
}

///**
// * 5、读取输入流。
// * @param Bytes Bytes表示用于存放接收数据的Byte。
// */
//- (Boolean)esc_read(Byte Bytes) {return mBluetoothPort.isOpen && mBluetoothPort.read(Bytes,0,Bytes.length,1000);}

// 通过
/**
 * 6、初始化打印机。
 * 使所有设置恢复到打印机开机时的默认值模式。
 */
- (Boolean)esc_reset {
    Byte reset[] = {0x1B, 0x40};
    //清空数据
    [self.finalData resetBytesInRange:NSMakeRange(0, self.finalData.length)];
    [self.finalData setLength:0];
    return [self.bleManager writeCmd:reset cmdLenth:sizeof(reset)];
}

// 通过
/**
 * 7、选择加粗模式。
 *
 * @param b b为true时选择加粗模式，b为false时取消加粗模式。
 */
- (Boolean)esc_bold:(Boolean)b {
    Byte esc_bold[3];
    esc_bold[0] = 0x1B;
    esc_bold[1] = 0x45;
    if(!b) esc_bold[2] = 0x00;
    else esc_bold[2] = 0x01;
    return [self.bleManager writeCmd:esc_bold cmdLenth:sizeof(esc_bold)];
}

// 通过
/**
 * 8、选择/取消下划线模式。
 * @param n 当n=1或n=49时选择下划线模式且设置为1点宽，当n=2或n=50时选择下划线模式且设置为2点宽，当n取其他值时取消下划线模式。
 */
- (Boolean)esc_underline:(NSInteger)n {
    Byte esc_underline[3];
    esc_underline[0] = 0x1B;
    esc_underline[1] = 0x2D;
    if (n == 1 || n == 49) esc_underline[2] = 0x01;
    else if (n == 2 || n == 50) esc_underline[2] = 0x02;
    else esc_underline[2] = 0x00;
    return [self.bleManager writeCmd:esc_underline cmdLenth:sizeof(esc_underline)];
}

// 通过
/**
 * 9、打印和行进。
 * 基于当前的行间距，打印缓冲区内的数据并走纸一行。
 */
- (Boolean)esc_print_formfeed {
    Byte esc_print_formfeed[] = {0x0A};
    return [self.bleManager writeCmd:esc_print_formfeed cmdLenth:sizeof(esc_print_formfeed)];
}

/**
 * 10、水平制表符。
 * 将打印位置移动至下一水平制表符位置。
 */
- (Boolean)esc_next_horizontal_tab {
    Byte esc_next_horizontal_tab[] = {0x09};
    return [self.bleManager writeCmd:esc_next_horizontal_tab cmdLenth:sizeof(esc_next_horizontal_tab)];
}

/**
 * 11、打印并走纸到左黑标处。
 * 将打印缓冲区中的数据全部打印出来并走纸到左黑标处。
 */
- (Boolean)esc_left_black_label {
    Byte esc_left_black_label[] = {0x0C};
    return [self.bleManager writeCmd:esc_left_black_label cmdLenth:sizeof(esc_left_black_label)];
}

// 通过
/**
 * 12、打印并回车。
 * 该指令等同于LF指令，既打印缓冲区内的数据并走纸一字符行。
 */
- (Boolean)esc_print_enter {
    Byte esc_print_enter[] = {0x0D};
    return [self.bleManager writeCmd:esc_print_enter cmdLenth:sizeof(esc_print_enter)];
}


/**
 * 13、设定右侧字符间距。
 * @param  n 当n＜0时设定右侧字符间距为0，当n＞255时设定右侧字符间距为【255×（水平或垂直移动单位）】,
 *           当0≤n≤255时设定右侧字符间距为【n×（水平或垂直移动单位）】。
 */
- (Boolean)esc_right_space:(NSInteger)n {
    Byte esc_right_space[3];
    esc_right_space[0] = 0x1B;
    esc_right_space[1] = 0x20;
    if(n < 0) esc_right_space[2] = 0x00;
    else if(0 <= n && n <= 255) esc_right_space[2] = (Byte)n;
    else if(n > 255) esc_right_space[2] = 0xFF;
    return [self.bleManager writeCmd:esc_right_space cmdLenth:sizeof(esc_right_space)];
}

/**
 * 14、选择打印模式。
 *  @param n 当n=0时选择字符字体A，当n=1时选择字符字体B，当n=2时表示选择字符字体C，当n=3时表示选择字符字体D；
 *           当n=8时选择字符加粗模式，当n=16时选择字符倍高模式，当n=32时选择字符倍宽模式，当n=128时选择字符下划线模式。
 *           此命令字体、加粗模式、倍高模式、倍宽模式、下划线模式同时设置。若要多种效果叠加，只需将相应的值相加即可
 *           （例如若要B字体加粗，只需将n=1+8即n=9传入）。
 */
- (Boolean)esc_print_mode:(NSInteger)n {
    Byte esc_print_mode[3];
    esc_print_mode[0] = 0x1B;
    esc_print_mode[1] = 0x21;
    
    if(n <= 0) esc_print_mode[2] = 0x00;
    else if(n == 1) esc_print_mode[2] = 0x01;
    else if(n == 2) esc_print_mode[2] = 0x02;
    else if(n == 3) esc_print_mode[2] = 0x03;
    else if(n == 8) esc_print_mode[2] = 0x08;
    else if(n == 16) esc_print_mode[2] = 0x10;
    else if(n == 32) esc_print_mode[2] = 0x20;
    else if(n == 128) esc_print_mode[2] = 0x80;
    else if(n >= 255) esc_print_mode[2] = 0xFF;
    else esc_print_mode[2] = (Byte)n;
    return [self.bleManager writeCmd:esc_print_mode cmdLenth:sizeof(esc_print_mode)];
}

/**
 * 15、设置绝对打印位置。
 * 将当前位置设置到距离行首（nL+nH×256）×（横向或纵向移动单位）处。当nL＜0或nL＞255时将nL设置为0，当nH＜0或nH＞255时将nH设置为0。
 *
 */
- (Boolean)esc_absolute_print_position:(NSInteger)nL nH:(NSInteger)nH {
    Byte esc_right_space[4];
    esc_right_space[0] = 0x1B;
    esc_right_space[1] = 0x24;
    
    if(nL < 0 || nL > 255) esc_right_space[2] = 0x00;
    else esc_right_space[2] = nL;
    
    if(nH < 0 || nH > 255) esc_right_space[3] = 0x00;
    else esc_right_space[3] = nH;
    return [self.bleManager writeCmd:esc_right_space cmdLenth:sizeof(esc_right_space)];
}

/**
 * 16、选择位图模式打印图片。
 * @param m m表示位图模式。当m=1时位图模式为8点双密度，当m=32时位图模式为24点单密度，当m=33时位图模式为24点双密度，
 *          除m=1,32,33之外位图模式都为8点单密度。
 * @param bitmap bitmap为要打印的位图。由于打印纸宽度有限，图片不可太大。
 */
//- (Boolean)esc_bitmap_mode(int m ,Bitmap bitmap){
//    if(m != 1 && m != 32 && m != 33) m = 0;
//    bitmap = Bitmap.createBitmap(bitmap);
//    int width = bitmap.getWidth();
//    int height = bitmap.getHeight();
//    int heightBytes = (height - 1) / 8 + 1;
//    int bufsize = width * heightBytes;
//    Byte maparray [bufsize];
//    int[] pixels = new int[width * height];
//    bitmap.getPixels(pixels, 0, width, 0, 0, width, height);
//    /**解析图片 获取位图数据**/
//    for (int j = 0; j < height; j++) {
//        for (int i = 0; i < width; i++) {
//            int pixel = pixels[width * j + i];
//            if (pixel != Color.WHITE) {//如果不是空白的话用黑色填充    这里如果童鞋要过滤颜色在这里处理
//                maparray[i + (j / 8) * width] |= (Byte) (0x80 >> (j % 8));
//            }
//        }
//    }
//    Byte Cmd [5];
//    Byte pictureTop {0x1B,0x33,0x00};
//    if(!mBluetoothPort.write(pictureTop,0,pictureTop.length)){
//        return false;
//    }
//    /**对位图数据进行处理**/
//    for (int i = 0; i < heightBytes; i++) {
//        Cmd[0] = 0x1B;
//        Cmd[1] = 0x2A;
//        Cmd[2] = (Byte) m;
//        Cmd[3] = (Byte) (width % 256);
//        Cmd[4] = (Byte) (width / 256);
//        if(!mBluetoothPort.write(Cmd,0,5)){return false;}
//        if(!mBluetoothPort.write(maparray, i * width, width)){return false;}
//        if(!mBluetoothPort.write(new Byte{0x0D,0x0A},0,2)){return false;}
//    }
//    return true;
//}

/**
 * 17、设置默认行高。
 * 将行间距设为约 3.75mm{30/203"}。
 */
- (Boolean)esc_default_line_height {
    Byte esc_default_line_height[] = {0x1B, 0x32};
    return [self.bleManager writeCmd:esc_default_line_height cmdLenth:sizeof(esc_default_line_height)];
}

/**
 选择打印模式

 @param mode 1，行模式 0，页模式
 @return 执行结果
 */
-(Boolean)esc_SelectPrintMode:(int)mode
{

    if(mode==0)
    {
        Byte byteL[] = {27, 83};
       // return [self.bleManager writeCmd:byteL cmdLenth:sizeof(byteL)];
           [self.finalData appendBytes:byteL length:sizeof(byteL)];
    }
    if(mode==1)
    {
        Byte byteS[] = {27, 76};
        [self.finalData appendBytes:byteS length:sizeof(byteS)];;
       // return [self.bleManager writeCmd:byteS cmdLenth:sizeof(byteS)];
    }
    return 0;
}
- (Boolean)systemFeedLine
{
    Byte byteL[] = {27, 83};
    return [self.bleManager writeCmd:byteL cmdLenth:sizeof(byteL)];
}
/**
 打印纸张

 @param PaperType 0.标签纸 1，黑标纸
 @return 执行结果
 */
-(Boolean)esc_systemSelectPaperType:(int)PaperType
{
    Byte pszCommand[] = {27, 99, 48, 0};
    if(PaperType==0)
    {
        pszCommand[3] = (Byte)PaperType;
     //   return [self.bleManager writeCmd:pszCommand cmdLenth:sizeof(pszCommand)];
    }
    if(PaperType==1)
    {
        pszCommand[3] = (Byte)PaperType;
     //   return [self.bleManager writeCmd:pszCommand cmdLenth:sizeof(pszCommand)];
    }
    if(PaperType==2)
    {
         pszCommand[3] = (Byte)PaperType;
      //  return [self.bleManager writeCmd:pszCommand cmdLenth:sizeof(pszCommand)];
    }
    [self.finalData appendBytes:pszCommand length:sizeof(pszCommand)];
    return 0;
}

/**
 打印区域

 @param X x
 @param Y y
 @param AreaWidth 宽
 @param AreaHeight 高
 @return 执行结果
 */
-(Boolean)pageModeSetPrintAreawithX:(int)X Y:(int)Y AreaWidth:(int)AreaWidth AreaHeight:(int)AreaHeight
{
    
    Byte pszCommand[10];
    int nOrgxH = X / 256;
    int nOrgxL = X % 256;
    int nOrgyH = Y / 256;
    int nOrgyL = Y % 256;
    int nWidthH = AreaWidth / 256;
    int nWidthL = AreaWidth % 256;
    int nHighH = AreaHeight / 256;
    int nHighL = AreaHeight % 256;
    pszCommand[0] = 27;
    pszCommand[1] = 87;
    pszCommand[2] = (Byte)nOrgxL;
    pszCommand[3] = (Byte)nOrgxH;
    pszCommand[4] = (Byte)nOrgyL;
    pszCommand[5] = (Byte)nOrgyH;
    pszCommand[6] = (Byte)nWidthL;
    pszCommand[7] = (Byte)nWidthH;
    pszCommand[8] = (Byte)nHighL;
    pszCommand[9] = (Byte)nHighH;
    
    [self.finalData appendBytes:pszCommand length:sizeof(pszCommand)];
    
   return 0;
}

/**
 打印起点

 @param X x
 @param Y y
 @return 执行结果
 */
-(Boolean)standardModeSetHorStartingPositionX:(int)X Y:(int)Y
{
    
    Byte pszCommandx[4];
    int nHigh = X / 256;
    int nLow = X % 256;
    pszCommandx[0] = 27;
    pszCommandx[1] = 36;
    pszCommandx[2] = (Byte)nLow;
    pszCommandx[3] = (Byte)nHigh;
    
      [self.finalData appendBytes:pszCommandx length:sizeof(pszCommandx)];
    //[self.bleManager writeCmd:pszCommandx cmdLenth:sizeof(pszCommandx)];
    
    
    Byte pszCommandY[4];
    int nHighY = Y / 256;
    int nLowY = Y % 256;
    pszCommandY[0] = 29;
    pszCommandY[1] = 36;
    pszCommandY[2] = (Byte)nLowY;
    pszCommandY[3] = (Byte)nHighY;
    
      [self.finalData appendBytes:pszCommandY length:sizeof(pszCommandY)];
    
   return 0;
    
}

/**
 打印字符串

 @param Text 字符串
 @return  执行结果
 */
-(Boolean)textPrint:(NSString *)Text
{
    

    
    NSData *testData = [Text dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    
    Byte *testByte = (Byte *)[testData bytes];
    [self.finalData appendBytes:testByte length:sizeof(testByte)];
    return 0;
    
}
/**
 打印字符串
 
 @param Text 字符串
 @return  执行结果
 */
-(Boolean)esc_printtext:(NSString *)text
{
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *data = [text dataUsingEncoding:enc];
    NSUInteger size = data.length;
    void *textdata = malloc(size);
    [data getBytes:textdata length:size];
     return [self.bleManager writeCmd:textdata cmdLenth:sizeof(size)];
 
    
}
/**
打印命令
 
 @return  执行结果
 */
-(Boolean)esc_prints
{
    Byte esc_print_enter[] = {0x0c};
    
    [self.finalData appendBytes:esc_print_enter length:sizeof(esc_print_enter)];
    [self.bleManager writeData:self.finalData];
    return 0;
  //  return [self.bleManager writeCmd:esc_print_enter cmdLenth:sizeof(esc_print_enter)];
}
/**
 打印命令
 
 @return  执行结果
 */
-(Boolean)esc_pageModePrint
{
    Byte pageModePrint[] = {27, 12};
    return [self.bleManager writeCmd:pageModePrint cmdLenth:sizeof(pageModePrint)];
}

/**
 * 18、设置行高
 * 设置行高为[n×纵向或横向移动单位]英寸。
 *  @param n n表示行高值。当n＜0时设置行高为0，当n＞255时设置行高为255[n×纵向或横向移动单位]英寸，
 *           当0≤n≤255时设置行高为[n×纵向或横向移动单位]英寸。
 */
- (Boolean)esc_line_height:(NSInteger)n {
    Byte esc_line_height[3];
    esc_line_height[0] = 0x1B;
    esc_line_height[1] = 0x33;
    if(n < 0) esc_line_height[2] = 0x00;
    else if(n > 255) esc_line_height[2] = 0xFF;
    else esc_line_height[2] = n;
    return [self.bleManager writeCmd:esc_line_height cmdLenth:sizeof(esc_line_height)];
}

/**
 * 19、设置水平制表符位置。
 * @param n n的长度表示横向跳格数，n[k]表示第k个跳格位置的值。当n的长度大于32时，只取前32个值；当n[k]大于等于n[k-1]时忽略该命令。
 *          当n[k]≤0或n[k]≥255时，忽略该命令。
 */
- (Boolean)esc_horizontal_tab_position:(NSArray *)n {
    Byte esc_horizontal_tab_position_top[] = {0x1B, 0x44};
    NSMutableArray *targetB = [NSMutableArray arrayWithCapacity:32];
    
    if (n.count > 32) {
        NSArray *targetI = [n subarrayWithRange:NSMakeRange(0, 32)];
        targetB[0] = targetI.firstObject;
        for (int i = 1; i < targetI.count; i++) {
            if (targetI[i] <= targetI[i - 1]) return false;
            targetB[i] = targetI[i];
        }
        
        [self.bleManager writeCmd:esc_horizontal_tab_position_top cmdLenth:sizeof(esc_horizontal_tab_position_top)];
        NSMutableData *data = [NSMutableData data];
        for (NSNumber *object in targetB) {
            Byte element = [object unsignedCharValue];
            [data appendBytes:&element length:1];
        }
        return [self.bleManager writeData:data];
    } else {
        NSMutableArray *target = [NSMutableArray arrayWithCapacity:n.count];
        target[0] = n[0];
        for (int i = 1; i < n.count; i++) {
            if (n[i] <= n[i - 1]) return false;
            target[i] = n[i];
        }
        [self.bleManager writeCmd:esc_horizontal_tab_position_top cmdLenth:sizeof(esc_horizontal_tab_position_top)];
        NSMutableData *data = [NSMutableData data];
        for (NSNumber *object in target) {
            Byte element = [object unsignedCharValue];
            [data appendBytes:&element length:1];
        }
        return [self.bleManager writeData:data];
    }
}

/**
 * 20、打印并进纸。
 * @param n 当0≤n≤255时打印缓冲区数据并进纸【n×纵向或横向移动单位】英寸。当n＜0时进纸0，当n＞255时进纸【255×纵向或横向移动单位】英寸。
 */
- (Boolean)esc_print_formfeed:(NSInteger)n {
    Byte esc_print_formfeed[3];
    esc_print_formfeed[0] = 0x1B;
    esc_print_formfeed[1] = 0x4A;
    if(n < 0) esc_print_formfeed[2] = 0x00;
    else if(n > 255) esc_print_formfeed[2] = 0xFF;
    else esc_print_formfeed[2] = n;
    return [self.bleManager writeCmd:esc_print_formfeed cmdLenth:sizeof(esc_print_formfeed)];
}

// 不生效
/**
 * 21、选择字体。
 * @param n 当n=1或n=49时选择字体B，当n=2或n=50时选择字体C，当n=3或n=51时选择字体D，当n为其他值时选择字体A。
 */
- (Boolean)esc_font:(NSInteger)n {
    Byte esc_font[] = {0x1B, 0x4D, 0x00};
    esc_font[0] = 0x1B;
    esc_font[1] = 0x4D;
    if(n == 1 || n == 49) esc_font[2] = 0x01;
    else if(n == 2 || n == 50) esc_font[2] = 0x02;
    else if(n == 3 || n == 51) esc_font[2] = 0x03;
    else esc_font[2] = 0x00;
    return [self.bleManager writeCmd:esc_font cmdLenth:sizeof(esc_font)];
}

/**
 * 22、选择国际字符集。
 * @param n 当n≤0或n＞13时选择America字符集，当n=1时选择France字符集，当n=2时选择German字符集，当n=3时选择UK字符集，
 *          当n=4时选择Denmar字符集，当n=5时选择Sweden字符集，当n=6时选择Italy字符集，当n=7时选择Spain I字符集，当n=8时选择Japan字符集，
 *          当n=9时选择Norway字符集，当n=10时选择Denmar字符集，当n=11时选择Spain II字符集，当n=12时选择Latin字符集，当n=13时选择Korea字符集。
 */
- (Boolean)esc_national_character_set:(NSInteger)n {
    Byte esc_national_character_set[3];
    esc_national_character_set[0] = 0x1B;
    esc_national_character_set[1] = 0x52;
    if(n == 1) esc_national_character_set[2] = 0x01;
    else if(n == 2) esc_national_character_set[2] = 0x02;
    else if(n == 3) esc_national_character_set[2] = 0x03;
    else if(n == 4) esc_national_character_set[2] = 0x04;
    else if(n == 5) esc_national_character_set[2] = 0x05;
    else if(n == 6) esc_national_character_set[2] = 0x06;
    else if(n == 7) esc_national_character_set[2] = 0x07;
    else if(n == 8) esc_national_character_set[2] = 0x08;
    else if(n == 9) esc_national_character_set[2] = 0x09;
    else if(n == 10) esc_national_character_set[2] = 0x0A;
    else if(n == 11) esc_national_character_set[2] = 0x0B;
    else if(n == 12) esc_national_character_set[2] = 0x0C;
    else if(n == 13) esc_national_character_set[2] = 0x0D;
    else esc_national_character_set[2] = 0x00;
    return [self.bleManager writeCmd:esc_national_character_set cmdLenth:sizeof(esc_national_character_set)];
}

// 通过
/**
 * 23、选择/取消顺时针旋转90°。
 * @param n 当n=1或n=49时设置90°顺时针旋转模式，当n=2或n=50时设置180°顺时针旋转模式，当n=3或n=51时设置270°顺时针旋转模式，
 *          当n取其他值时取消旋转模式。
 */
- (Boolean)esc_rotate:(NSInteger)n {
    Byte esc_rotate[3];
    esc_rotate[0] = 0x1B;
    esc_rotate[1] = 0x56;
    if(n == 1 || n == 49) esc_rotate[2] = 0x01;
    else if(n == 2 || n == 50) esc_rotate[2] = 0x02;
    else if(n == 3 || n == 51) esc_rotate[2] = 0x03;
    else esc_rotate[2] = 0x00;
    return [self.bleManager writeCmd:esc_rotate cmdLenth:sizeof(esc_rotate)];
}

/**
 * 24、设定相对打印位置。
 * 将打印位置从当前位置移至（nL+nH×256）×（水平或垂直运动单位）。当nL＜0时设置nL=0，当nL＞255时设置nL=255。
 * 当nH＜0时设置nH=0，当nH＞255时设置nH=255。
 */
- (Boolean)esc_relative_print_position:(NSInteger)nL nH:(NSInteger)nH {
    Byte esc_relative_print_position[4];
    esc_relative_print_position[0] = 0x1B;
    esc_relative_print_position[1] = 0x5C;
    
    if(nL < 0) esc_relative_print_position[2] = 0x00;
    else if(nL > 255) esc_relative_print_position[2] = 0xFF;
    else esc_relative_print_position[2] = nL;
    
    if(nH < 0) esc_relative_print_position[3] = 0x00;
    else if(nH > 255) esc_relative_print_position[3] = 0xFF;
    else esc_relative_print_position[3] = nH;
    return [self.bleManager writeCmd:esc_relative_print_position cmdLenth:sizeof(esc_relative_print_position)];
}

// 通过
/**
 * 25、选择对齐模式。
 * @param n 当n=1或n=49时选择居中对齐，当n=2或n=50时选择右对齐，当n取其他值时选择左对齐。
 */
- (Boolean)esc_align:(NSInteger)n {
    Byte esc_align[3];
    esc_align[0] = 0x1B;
    esc_align[1] = 0x61;
    if(n == 1 || n == 49) esc_align[2] = 0x01;
    else if(n == 2 || n == 50) esc_align[2] = 0x02;
    else esc_align[2] = 0x00;
    return [self.bleManager writeCmd:esc_align cmdLenth:sizeof(esc_align)];
}

/**
 * 26、打印并向前走纸n行。
 * @param n 当n＜0时进纸0行，当n＞255时进纸255行，当0≤n≤255时进纸n行。
 */
- (Boolean)esc_print_formfeed_row:(NSInteger)n {
    Byte esc_print_formfeed_row[3];
    esc_print_formfeed_row[0] = 0x1B;
    esc_print_formfeed_row[1] = 0x64;
    if(n < 0) esc_print_formfeed_row[2] = 0x00;
    else if(n > 255) esc_print_formfeed_row[2] = 0xFF;
    else esc_print_formfeed_row[2] = n;
    return [self.bleManager writeCmd:esc_print_formfeed_row cmdLenth:sizeof(esc_print_formfeed_row)];
}

/**
 * 27、选择字符代码页。
 * @param n 当n=1时选择Page 1 Katakana，当n=2时选择Page 2 Multilingual(Latin-1) [CP850]，当n=3时选择Page 3 Portuguese [CP860]，
 *          当n=4时选择Page 4 Canadian-French [CP863]，当n=5时选择Page 5 Nordic [CP865]，当n=6时选择Page 6 Slavic(Latin-2) [CP852]，
 *          当n=7时选择Page 7 Turkish [CP857]，当n=8时选择Page 8 Greek [CP737]，当n=9时选择Page 9 Russian(Cyrillic) [CP866]，
 *          当n=10时选择Page 10 Hebrew [CP862]，当n=11时选择Page 11 Baltic [CP775]，当n=12时选择Page 12 Polish，
 *          当n=13时选择Page 13 Latin-9 [ISO8859-15]，当n=14时选择Page 14 Latin1[Win1252]，当n=15时选择Page 15 Multilingual Latin I + Euro[CP858]，
 *          当n=16时选择Page 16 Russian(Cyrillic)[CP855]，当n=17时选择Page 17 Russian(Cyrillic)[Win1251]，当n=18时选择Page 18 Central Europe[Win1250]，
 *          当n=19时选择Page 19 Greek[Win1253]，当n=20时选择Page 20 Turkish[Win1254]，当n=21时选择Page 21 Hebrew[Win1255]，
 *          当n=22时选择Page 22 Vietnam[Win1258]，当n=23时选择Page 23 Baltic[Win1257]，当n=24时选择Page 24 Azerbaijani，
 *          当n=30时选择Thai[CP874]Thai[CP874]，当n=40时选择Page 25 Arabic [CP720]，当n=41时选择Page 26 Arabic [Win 1256]，
 *          当n=42时选择Page 27 Arabic (Farsi)，当n=43时选择Page 28 Arabic presentation forms B，当n=50时选择Page 29 Page 25 Hindi_Devanagari，
 *          当n=252时选择Page 30 Japanese[CP932]，当n=253时选择Page 31 Korean[CP949]，当n=254时选择Page 32 Traditional Chinese[CP950]，
 *          当n=255时选择Page 33 Simplified Chinese[CP936]。
 *          当n取其他值时选择else if(n == 252) esc_character_code_page[2] = 0x01。
 */
- (Boolean)esc_character_code_page:(NSInteger)n {
    Byte esc_character_code_page[3];
    esc_character_code_page[0] = 0x1B;
    esc_character_code_page[1] = 0x74;
    if(n == 1) esc_character_code_page[2] = 1;
    else if(n == 2) esc_character_code_page[2] = 2;
    else if(n == 3) esc_character_code_page[2] = 3;
    else if(n == 4) esc_character_code_page[2] = 4;
    else if(n == 5) esc_character_code_page[2] = 5;
    else if(n == 6) esc_character_code_page[2] = 6;
    else if(n == 7) esc_character_code_page[2] = 7;
    else if(n == 8) esc_character_code_page[2] = 8;
    else if(n == 9) esc_character_code_page[2] = 9;
    else if(n == 10) esc_character_code_page[2] = 10;
    else if(n == 11) esc_character_code_page[2] = 11;
    else if(n == 12) esc_character_code_page[2] = 12;
    else if(n == 13) esc_character_code_page[2] = 13;
    else if(n == 14) esc_character_code_page[2] = 14;
    else if(n == 15) esc_character_code_page[2] = 15;
    else if(n == 16) esc_character_code_page[2] = 16;
    else if(n == 17) esc_character_code_page[2] = 17;
    else if(n == 18) esc_character_code_page[2] = 18;
    else if(n == 19) esc_character_code_page[2] = 19;
    else if(n == 20) esc_character_code_page[2] = 20;
    else if(n == 21) esc_character_code_page[2] = 21;
    else if(n == 22) esc_character_code_page[2] = 22;
    else if(n == 23) esc_character_code_page[2] = 23;
    else if(n == 24) esc_character_code_page[2] = 24;
    else if(n == 30) esc_character_code_page[2] = 30;
    else if(n == 40) esc_character_code_page[2] = 40;
    else if(n == 41) esc_character_code_page[2] = 41;
    else if(n == 42) esc_character_code_page[2] = 42;
    else if(n == 43) esc_character_code_page[2] = 43;
    else if(n == 50) esc_character_code_page[2] = 50;
    else if(n == 252) esc_character_code_page[2] = 252;
    else if(n == 253) esc_character_code_page[2] = 253;
    else if(n == 254) esc_character_code_page[2] = 254;
    else if(n == 255) esc_character_code_page[2] = 255;
    else esc_character_code_page[2] = 0x00;
    return [self.bleManager writeCmd:esc_character_code_page cmdLenth:sizeof(esc_character_code_page)];
}

// 4倍不生效
/**
 * 28、选择字符大小。
 * @param n 当n=2时2倍高，当n=3时3倍高，当n=4时4倍高，当n=20时2倍宽，当n=30时3倍宽，当n=40时4倍宽，当n=22时2倍宽高，当n=33时3倍宽高，
 *          当n=44时4倍宽高，当n取其他值时1倍宽高。
 */
- (Boolean)esc_character_size:(NSInteger)n {
    Byte esc_character_size[3];
    esc_character_size[0] = 0x1D;
    esc_character_size[1] = 0x21;
    if(n == 2) esc_character_size[2] = 0x01;
    else if(n == 3) esc_character_size[2] = 0x02;
    else if(n == 4) esc_character_size[2] = 0x03;
    else if(n == 20) esc_character_size[2] = 0x10;
    else if(n == 30) esc_character_size[2] = 0x20;
    else if(n == 40) esc_character_size[2] = 0x30;
    else if(n == 22) esc_character_size[2] = 0x11;
    else if(n == 33) esc_character_size[2] = 0x22;
    else if(n == 44) esc_character_size[2] = 0x33;
    else esc_character_size[2] = 0x00;
    return [self.bleManager writeCmd:esc_character_size cmdLenth:sizeof(esc_character_size)];
}

/**
 * 29、定义并打印下载位图。
 * @param x x表示位图的横向点数（1≤x≤255），
 * @param y y表示位图的纵向点数（1≤y≤48）。
 * @param data data的长度等于x*y*8（1≤x*y≤1536），表示位图字节数，除以上取值外其他取值均忽略此命令。
 * @param m m表示打印下载位图的模式，当m=1或m=49时设置倍宽模式，当m=2或m=50时设置倍高模式，当m=3或m=51时设置倍宽倍高模式，
 *          当m取其他值时设置普通模式打印所下载的位图。
 */
//- (Boolean)esc_define_print_download_bitmap(int x,int y,int[] data,int m){
- (Boolean)esc_define_print_download_bitmap:(NSInteger)x y:(NSInteger)y data:(NSArray *)data mode:(NSInteger)m {
    Byte esc_define_download_bitmap[4];
    esc_define_download_bitmap[0] = 0x1D;
    esc_define_download_bitmap[1] = 0x2A;
    if(x<1 || x>255 || y<1 || y>48 || (x*y)>1536 || data.count!=(x*y*8)) return false;
    esc_define_download_bitmap[2] = x;
    esc_define_download_bitmap[3] = y;
    
    NSMutableData *tempData = [NSMutableData data];
    for (NSNumber *object in data) {
        Byte element = [object unsignedCharValue];
        [tempData appendBytes:&element length:1];
    }
    
    [self.bleManager writeCmd:esc_define_download_bitmap cmdLenth:sizeof(esc_define_download_bitmap)];
    [self.bleManager writeData:tempData];
    
    Byte esc_print_download_bitmap[3];
    esc_print_download_bitmap[0] = 0x1D;
    esc_print_download_bitmap[1] = 0x2F;
    if(m == 1 || m == 49) esc_print_download_bitmap[2] = 0x01;
    else if(m == 2 || m == 50) esc_print_download_bitmap[2] = 0x02;
    else if(m == 3 || m == 51) esc_print_download_bitmap[2] = 0x03;
    else esc_print_download_bitmap[2] = 0x00;
    return [self.bleManager writeCmd:esc_print_download_bitmap cmdLenth:sizeof(esc_print_download_bitmap)];
}

// 通过
/**
 * 30、选择/取消黑白反显打印模式。
 * @param b 当b为true时选择黑白反显打印模式，当b为false时取消黑白反显打印模式。
 */
- (Boolean)esc_black_white_reverse:(Boolean)b {
    Byte esc_black_white_reverse[3];
    esc_black_white_reverse[0] = 0x1D;
    esc_black_white_reverse[1] = 0x42;
    if(!b) esc_black_white_reverse[2] = 0x00;
    else if(b) esc_black_white_reverse[2] = 0x01;
    return [self.bleManager writeCmd:esc_black_white_reverse cmdLenth:sizeof(esc_black_white_reverse)];
}

/**
 * 31、设定左边距。
 * 当0≤nL≤255且0≤nH≤255时，将左边距设为【(nL+nH×256)×(水平移动单位)】。当nL和nH取其他值时将左边距设为0。
 */
- (Boolean)esc_left_margin:(NSInteger)nL nH:(NSInteger)nH {
    Byte esc_left_margin[4];
    esc_left_margin[0] = 0x1D;
    esc_left_margin[1] = 0x4C;
    if(0 <= nL && nL <= 255 && 0 <= nH && nH <= 255) {
        esc_left_margin[2] = nL;
        esc_left_margin[3] = nH;
    }
    else {
        esc_left_margin[2] = 0x00;
        esc_left_margin[3] = 0x00;
    }
    return [self.bleManager writeCmd:esc_left_margin cmdLenth:sizeof(esc_left_margin)];
}

/**
 * 32、设定横向和纵向移动单位。
 * 当0≤x≤255且0≤y≤255时分别将水平和垂直移动单位设为25.4/x毫米和25.4/y毫米。当x和y取其他值时取x=0和Y=0。
 */
- (Boolean)esc_move_unit:(NSInteger)x y:(NSInteger)y {
    Byte esc_move_unit[4];
    esc_move_unit[0] = 0x1D;
    esc_move_unit[1] = 0x50;
    if(0 <= x && x <= 255 && 0 <= y && y <= 255) {
        esc_move_unit[2] = (Byte)x;
        esc_move_unit[3] = (Byte)y;
    }
    else {
        esc_move_unit[2] = 0x00;
        esc_move_unit[3] = 0x00;
    }
    return [self.bleManager writeCmd:esc_move_unit cmdLenth:sizeof(esc_move_unit)];
}

/**
 * 33、设定打印区域宽度。
 * 当0≤nL≤255且0≤nH≤255时,将打印区域宽度设为（nL+nH×256）×（水平移动单位）。当nL和nH取其他值时取nL=0和nH=0。
 */
- (Boolean)esc_print_area_width:(NSInteger)nL nH:(NSInteger)nH {
    Byte esc_print_area_width[4];
    esc_print_area_width[0] = 0x1D;
    esc_print_area_width[1] = 0x57;
    if(0 <= nL && nL <= 255 && 0 <= nH && nH <= 255) {
        esc_print_area_width[2] = (Byte) nL;
        esc_print_area_width[3] = (Byte) nH;
    }
    else {
        esc_print_area_width[2] = 0x00;
        esc_print_area_width[3] = 0x00;
    }
    return [self.bleManager writeCmd:esc_print_area_width cmdLenth:sizeof(esc_print_area_width)];
}

/**
 * 34、设定汉字模式。
 * @param b 当b为true时选择汉字模式，当b为false时取消汉字模式。
 */
- (Boolean)esc_chinese_mode:(Boolean)b {
    Byte esc_chinese_mode[2];
    esc_chinese_mode[0] = 0x1C;
    if(!b) esc_chinese_mode[1] = 0x2E;
    else esc_chinese_mode[1] = 0x26;
    return [self.bleManager writeCmd:esc_chinese_mode cmdLenth:sizeof(esc_chinese_mode)];
}

/**
 * 35、设置汉字字符模式。
 * @param n 当n=4时选择倍宽，当n=8时选择倍高，当n=128时选择下划线，当n=12时选择倍高倍宽，当n=132时选择倍宽下划线，当n=136时选择倍高下划线，
 *          当n=140时选择倍宽倍高下划线，当n取其他值时不选择倍高倍宽下划线。
 *          倍高、倍宽、下划线模式同时设置。
 */
- (Boolean)esc_chinese_character_mode:(NSInteger)n {
    Byte esc_chinese_character_mode[3];
    esc_chinese_character_mode[0] = 0x1C;
    esc_chinese_character_mode[1] = 0x21;
    if(n == 4) esc_chinese_character_mode[2] = 0x04;
    else if(n == 8) esc_chinese_character_mode[2] = 0x08;
    else if(n == 128) esc_chinese_character_mode[2] = (Byte) 128;
    else if(n == 12) esc_chinese_character_mode[2] =12;
    else if(n == 132) esc_chinese_character_mode[2] = (Byte) 132;
    else if(n == 136) esc_chinese_character_mode[2] = (Byte) 136;
    else if(n == 140) esc_chinese_character_mode[2] = (Byte) 140;
    else esc_chinese_character_mode[2] = 0x00;
    return [self.bleManager writeCmd:esc_chinese_character_mode cmdLenth:sizeof(esc_chinese_character_mode)];
}

/**
 * 36、选择/取消汉字下划线模式。
 * @param n 当n=1或n=49时选择汉字下划线（1点宽），当n=2或n=50时选择汉字下划线（2点宽），当n为其他值时不加下划线。
 */
- (Boolean)esc_chinese_character_underline_mode:(NSInteger)n {
    Byte esc_chinese_character_underline_mode[3];
    esc_chinese_character_underline_mode[0] = 0x1C;
    esc_chinese_character_underline_mode[1] = 0x2D;
    if(n == 1 || n== 49) esc_chinese_character_underline_mode[2] = 0x01;
    else if(n == 2 || n== 50) esc_chinese_character_underline_mode[2] = 0x02;
    else esc_chinese_character_underline_mode[2] = 0x00;
    return [self.bleManager writeCmd:esc_chinese_character_underline_mode cmdLenth:sizeof(esc_chinese_character_underline_mode)];
}

/**
 * 37、定义自定义汉字。
 * @param c2 c2表示自定义字符编码第二个字节,取值范围为A1H≤c2≤FEH，第一个字节为FEH，
 * @param data data表示自定义汉字的数据，1表示打印一个点，0表示不打印点。
 *             data的长度为72，若data的长度不等于72或data的每个元素值出现小于0或大于255的情况，则忽略该命令。
 */
- (Boolean)esc_define_chinese_character:(NSInteger)c2 data:(NSArray *)data {
    Byte esc_define_chinese_character[4];
    esc_define_chinese_character[0] = 0x1C;
    esc_define_chinese_character[1] = 0x32;
    esc_define_chinese_character[2] = (Byte) 0xFE;
    if(c2 < 0xA1 || c2 > 0xFE || (data.count != 72)) return false;
    for (NSNumber *value in data) {
        if (value.unsignedCharValue < 0 || value.unsignedCharValue > 255) {
            return false;
        }
    }
    esc_define_chinese_character[3] = (Byte) c2;
    [self.bleManager writeCmd:esc_define_chinese_character cmdLenth:sizeof(esc_define_chinese_character)];
    
    NSMutableData *tempData = [NSMutableData data];
    for (NSNumber *object in data) {
        Byte element = [object unsignedCharValue];
        [tempData appendBytes:&element length:1];
    }
    return [self.bleManager writeData:tempData];
}

/**
 * 38、选择/取消汉字倍高倍宽。
 * @param b 当b为true时选择汉字倍高倍宽模式，当b为false时取消汉字倍高倍宽模式。
 */
- (Boolean)esc_chinese_character_twice_height_width:(Boolean)b {
    Byte esc_chinese_character_twice_height_width[3];
    esc_chinese_character_twice_height_width[0] = 0x1C;
    esc_chinese_character_twice_height_width[1] = 0x57;
    if(!b) esc_chinese_character_twice_height_width[2] = 0x00;
    else esc_chinese_character_twice_height_width[2] = 0x01;
    return [self.bleManager writeCmd:esc_chinese_character_twice_height_width cmdLenth:sizeof(esc_chinese_character_twice_height_width)];
}

/**
 * 39、打印并走纸到右黑标处。
 */
- (Boolean)esc_print_to_right_black_label {
    Byte esc_print_to_right_black_label[] = {0x0E};
    return [self.bleManager writeCmd:esc_print_to_right_black_label cmdLenth:sizeof(esc_print_to_right_black_label)];
}

/**
 * 40、走纸到标签处。
 */
- (Boolean)esc_print_to_label {
    Byte esc_print_to_label[] = {0x1D, 0x0C};
    return [self.bleManager writeCmd:esc_print_to_label cmdLenth:sizeof(esc_print_to_label)];
}

/**
 * 41、打印光栅位图。
 * @param m m表示光栅位图模式，当m=1或m=49时选择倍宽模式，当m=2或m=50时选择倍高模式，当m=3或m=51时选择倍宽倍高模式。
 *           data表示要打印的光栅位图的数据，data的长度等于(xL+xH*256)*(yL+yH*256)，表示要打印的光栅位图数据长度，
 *           当xL<0或xL>255或xH<0或xH>255或yL<0或yL>255或yH<0或yH>255或data的长度不等于((xL+xH*256)*(yL+yH*256))或((xL+xH*256)*(yL+yH*256))等于0时忽略该命令。
 */
- (Boolean)esc_print_grating_bitmap:(NSInteger)m xL:(NSInteger)xL xH:(NSInteger)xH yL:(NSInteger)yL yH:(NSInteger)yH data:(NSArray *)data {
    Byte esc_print_grating_bitmap[8];
    esc_print_grating_bitmap[0] = 0x1D;
    esc_print_grating_bitmap[1] = 0x76;
    esc_print_grating_bitmap[2] = 0x30;
    if(m == 1 || m == 49) esc_print_grating_bitmap[3] = 0x01;
    else if(m == 2 || m == 50) esc_print_grating_bitmap[3] = 0x02;
    else if(m == 3 || m == 51) esc_print_grating_bitmap[3] = 0x03;
    else esc_print_grating_bitmap[3] = 0x00;
    if(xL < 0 || xL > 255 || xH < 0 || xH > 255 || yL < 0 || yL > 255 || yH < 0 || yH > 255 ||
       (data.count != (xL+xH*256)*(yL+yH*256)) || ((xL+xH*256)*(yL+yH*256)) == 0) return false;
    esc_print_grating_bitmap[4] = (Byte) xL;
    esc_print_grating_bitmap[5] = (Byte) xH;
    esc_print_grating_bitmap[6] = (Byte) yL;
    esc_print_grating_bitmap[7] = (Byte) yH;

    [self.bleManager writeCmd:esc_print_grating_bitmap cmdLenth:sizeof(esc_print_grating_bitmap)];
    
    NSMutableData *tempData = [NSMutableData data];
    for (NSNumber *object in data) {
        Byte element = [object unsignedCharValue];
        [tempData appendBytes:&element length:1];
    }
    return [self.bleManager writeData:tempData];
}

/**
 * 42、设置参数打印条码。
 * @param HRI_position HRI_position表示HRI字符打印位置(当HRI_position=1或HRI_position=49时HRI字符显示在条形码上方；
 *                     当HRI_position=2或HRI_position=50时HRI字符显示在条形码下方；当HRI_position取其他值时HRI字符不显示)。
 * @param HRI_font HRI_font表示HRI字符字体（当HRI_font=1或HRI_font=49时选择字体B，当HRI_font取其他值时选择字体A）。
 * @param width width表示条码宽度（当width=2时设置条形码宽度为2，当width=3时设置条形码宽度为3，当width取其他值时设置条形码宽度为1），
 * @param height height表示条码高度（当1<=height<=255时设置条码高度为height，当height取其他值时设置条码高度为162），
 * @param type type表示条码类型（当type=0或type=65时选择条码类型为UPC-A，当type=1或type=66时选择条码类型为UPC-E，
 *             当type=2或type=67时选择条码类型为EAN13，当type=3或type=68时选择条码类型为EAN8，当type=4或type=69时选择条码类型为CODE39，
 *             当type=5或type=70时选择条码类型为ITF，当type=6或type=71时选择条码类型为CODABAR，当type=7或type=72时选择条码类型为CODE93，
 *             当type=8或type=73时选择条码类型为CODE128），
 * @param content content表示条码内容（UPC-A（长度为11、12）、UPC-E（长度为7、8、11、12）、EAN13（长度为12、13）、EAN8（长度为7、8）、
 *                ITF（长度为大于2的偶数）只支持数字；
 *                CODE39（长度大于1且小于255，支持数字、英文、空格、‘$’、‘%’、‘*’、‘+’、‘-’、‘.’、‘/’）；
 *                CODE93（长度大于1且小于255，支持数字、英文、空格、‘$’、‘%’、‘+’、‘-’、‘.’、‘/’）；
 *                CODABAR（长度大于2且小于255，支持数字、英文ABCDabcd、‘$’、‘+’、‘-’、‘.’、‘/’、‘:’）；
 *                CODE128（长度大于2且小于255，支持所有英文）。
 */
- (Boolean)esc_barcode_1d:(NSInteger)HRI_position HRI_font:(NSInteger)HRI_font width:(NSInteger)width height:(NSInteger)height type:(NSInteger)type content:(NSString *)content {
    Byte esc_barcode_1d_HRI_position[] = {0x1D, 0x48, 0x00};
    if(HRI_position == 1 || HRI_position ==49) esc_barcode_1d_HRI_position[2] = 0x01;
    if(HRI_position == 2 || HRI_position ==50) esc_barcode_1d_HRI_position[2] = 0x02;
    else esc_barcode_1d_HRI_position[2] = 0x00;
    [self.bleManager writeCmd:esc_barcode_1d_HRI_position cmdLenth:sizeof(esc_barcode_1d_HRI_position)];
    
    Byte esc_barcode_1d_HRI_font[] = {0x1D, 0x66, 0x00};
    if(HRI_font == 1 || HRI_font ==49) esc_barcode_1d_HRI_font[2] = 0x01;
    else esc_barcode_1d_HRI_font[2] = 0x00;
    [self.bleManager writeCmd:esc_barcode_1d_HRI_font cmdLenth:sizeof(esc_barcode_1d_HRI_font)];
    
    Byte esc_barcode_1d_width[] = {0x1D, 0x77, 0x00};
    if(width == 2) esc_barcode_1d_width[2] = 0x02;
    if(width == 3) esc_barcode_1d_width[2] = 0x03;
    else esc_barcode_1d_width[2] = 0x01;
    [self.bleManager writeCmd:esc_barcode_1d_width cmdLenth:sizeof(esc_barcode_1d_width)];
    
    Byte esc_barcode_1d_height[] = {0x1D,0x68, (Byte)0xA2};
    if(height <= 0 || height > 255) esc_barcode_1d_height[2] = (Byte) 0xA2;
    else esc_barcode_1d_height[2] = (Byte) height;
    [self.bleManager writeCmd:esc_barcode_1d_height cmdLenth:sizeof(esc_barcode_1d_height)];
    
    if(type == 0 || type == 65) type = 0;
    else if(type == 1 || type == 66) type = 1;
    else if(type == 2 || type == 67) type = 2;
    else if(type == 3 || type == 68) type = 3;
    else if(type == 4 || type == 69) type = 4;
    else if(type == 5 || type == 70) type = 5;
    else if(type == 6 || type == 71) type = 6;
    else if(type == 7 || type == 72) type = 7;
    else if(type == 8 || type == 73) type = 8;
    else type = 8 ;
    Byte esc_barcode_1d_type[] = {0x1D, 0x6B, (Byte)type};
    [self.bleManager writeCmd:esc_barcode_1d_type cmdLenth:sizeof(esc_barcode_1d_type)];
    
    Byte esc_barcode_1d_content_end[] = {0x00};
    [self.bleManager writeText:content];
    return [self.bleManager writeCmd:esc_barcode_1d_content_end cmdLenth:sizeof(esc_barcode_1d_content_end)];
}

/**
 * 43、打印二维码。
 * @param type type表示二维码类型，当type=0时选择PDF417，当type=2时选择DATAMATRIX，当type取其他值时选择QRCODE。
 * @param content content表示要打印的二维码内容。
 */
- (Boolean)esc_print_barcode_2d:(NSInteger)type content:(NSString *)content {
    if(type == 0) type = 10;
    else if(type == 2) type = 12;
    else type = 11;
    Byte esc_print_barcode_2d_type[] = {0x1D,0x6B, (Byte)type};
    [self.bleManager writeCmd:esc_print_barcode_2d_type cmdLenth:sizeof(esc_print_barcode_2d_type)];
    
    [self.bleManager writeText:content];
    
    Byte esc_barcode_1d_content_end[] = {0x00};
    return [self.bleManager writeCmd:esc_barcode_1d_content_end cmdLenth:sizeof(esc_barcode_1d_content_end)];
}
/**
 * 44、打印矩形
 * @param lineWith  线条的宽度
 * @param startX    水平起始位置
 * @param endX      水平结束位置
 * @param startY    垂直起始位置
 * @param endY      垂直结束位置
 **/
-(void)esc_print_boxWithLineWith:(NSInteger)lineWith startX:(NSInteger)startX endX:(NSInteger)endX startY:(NSInteger)startY andEndY:(NSInteger)endY{
    NSString *BOX_CMD_TEMPLATE = [NSString stringWithFormat:@"BOX %ld %ld %ld %ld %ld\n",startX,startY,endX,endY,lineWith];
    NSLog(@"BOX_CMD_TEMPLATE:%@",BOX_CMD_TEMPLATE);
    NSData *bytesData = [BOX_CMD_TEMPLATE dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:bytesData];
}
/**
 * 45、带参数的打印文字
 * @param text            需要打印的文字
 * @param font            字体编号，一共有0 1 2 4 5 6 7  英文字体，55 16点阵中文字体，其他编号之外的字体为，中文24点阵字体
 * @param size            字体的大小识别符
 * @param x               X轴起始位置
 * @param y               Y轴起始位置
 **/

-(void)esc_print_text:(NSString *)text
                    font:(NSInteger)font
                    size:(NSInteger)size
                       x:(NSInteger)x
                       y:(NSInteger)y{
    NSString *TEXT_CMD_TEMPLATE = [NSString stringWithFormat:@"TEXT %ld %ld %ld %ld %@\n",font,size,x,y,text];
    NSLog(@"TEXT_CMD_TEMPLATE:%@",TEXT_CMD_TEMPLATE);
    NSData *bytesData = [TEXT_CMD_TEMPLATE dataUsingEncoding:GBK_Encoding];
//    NSData *bytesData = [TEXT_CMD_TEMPLATE dataUsingEncoding:NSUTF8StringEncoding];
    [self.finalData appendData:bytesData];
}
/**
 * 46、垂直方向打印文字 带参数
 * @param text            需要打印的文字
 * @param font            字体编号，一共有0 1 2 4 5 6 7  英文字体，55 16点阵中文字体，其他编号之外的字体为，中文24点阵字体
 * @param size            字体的大小识别符
 * @param x               X轴起始位置
 * @param y               Y轴起始位置
 * @param width           水平宽度
 * @param height          垂直高度
 **/
-(void)esc_print_VerticalText:(NSString *)text
                         font:(NSInteger)font
                         size:(NSInteger)size
                            x:(NSInteger)x
                            y:(NSInteger)y
                        width:(NSInteger)width
                       height:(NSInteger)height{
    NSUInteger length = text.length;
    NSInteger itemY = height/length;
    for (NSUInteger i=0; i<length; i++) {
        NSString *subStr = [text substringWithRange:NSMakeRange(i, 1)];
        [self esc_print_text:subStr font:font size:size x:x y:i*itemY];
    }
}
/**
 * 47、一维条形码打印 带参数
 * @param type            从下面列表中选择
 条码                        Type
 UPC-A                      UPCA
 UPC-E                      UPCE
 EAN13                      EAN13
 EAN8                       EAN8
 Code 39                    39
 Code 93                    93
 Interleaved 2 of 5         I2OF5
 Code 128 (Auto)            128
 Codabar                    CODABAR,
 * @param width            窄条码的宽度点数
 * @param ratio            宽条码和窄条码的比率
 * @param height           条码高度点数(8点/mm)
 * @param x                条码开始的X轴坐标
 * @param y                条码开始的Y轴坐标
 * @param code             条码数据
 **/
-(void)esc_print_barcodeWithType:(NSString *)type
                           width:(NSInteger)width
                           ratio:(NSInteger)ratio
                          height:(NSInteger)height
                               x:(NSInteger)x
                               y:(NSInteger)y
                            code:(NSString *)code{
    
    NSString *BARCODE_CMD_TEMPLATE = [NSString stringWithFormat:@"BARCODE %@ %ld %ld %ld %ld %ld %@\n",type,width,ratio,height,x,y,code];
    NSLog(@"BARCODE_CMD_TEMPLATE:%@",BARCODE_CMD_TEMPLATE);
    NSData *barData = [BARCODE_CMD_TEMPLATE dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:barData];
}
/**
 * 48、打印二维码 带参数   type 为QR，所以这里就不用再传了
 * @param x            条码开始的X轴坐标
 * @param y            条码开始的Y轴坐标
 * @param Mn           QR代码型号，值的范围是1-2，默认为2
 * @param Un           高度/宽度的模块点数，值的范围是1-32，默认是6
 * @param code         二维码数据
 QR条码数据,在数据中会包括一些模式选择。
 <纠错等级>:H(非常高的可靠和密度等级),Q(高可靠等级),M(标准等级),L(高密度等级)         <掩码> None(自动选择)  0-7(相应的掩码)  8(无掩码)
 <数据输入形式> A(自动) M(需要选择相应的数据形式，有N(数字)A(文本和数字)BXXX(二
 进制)K(日本汉字)等)      <数据字符串>
 **/
-(void)esc_print_QR_codeWithX:(NSInteger)x
                            y:(NSInteger)y
                           Mn:(NSInteger)Mn
                           Un:(NSInteger)Un
                         code:(NSString*)code{
    NSString *QR_CODE_TEMPLATE1 = [NSString stringWithFormat:@"B QR %ld %ld M %ld U %ld\n",x,y,Mn,Un];
    NSData   *qrTemplate1Data = [QR_CODE_TEMPLATE1 dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:qrTemplate1Data];
    NSString *QR_CODE_TEMPLATE2 = [NSString stringWithFormat:@"MA,QR code %@\n",code];// MA一些模式选择
    NSData   *qrTGemplate2Data = [QR_CODE_TEMPLATE2 dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:qrTGemplate2Data];
    NSString *ENDQR = @"ENDQR\n";
    NSData   *endQRData = [ENDQR dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:endQRData];
}
/**
 * 49、打印图片 带参数
 * @param width           位图的字节宽度 保留参数
 * @param height          位图的点高度   保留参数
 * @param x               位图开始的X坐标
 * @param y               位图开始的Y坐标
 * @param imageName       图片的名字
 *  目前有一个bug，情况是 当cmd 字符串放在一个格式化的时候 NSString *IMAGE_PRINT_CMD_TEMPLATE = [NSString stringWithFormat:@"CG %ld %ld %ld %ld %@",wid,hei,x,y,hex];
    点击一次就能够打印出来图片，但是图片是乱码，条纹状
                      当cmd 字符串先格式化命令 NSString *IMAGE_PRINT_CMD_TEMPLATE = [NSString stringWithFormat:@"CG %ld %ld %ld %ld ",wid,hei,x,(long)y];
                    然后转data，添加到finalData中，然后再追加图片data到finalData中，需要点击两次图片才能显示，不过图片是清晰，正确的！！！！！！！！
 -------------------------
 用byte编码发命令可以点击一次就打印，但是还是显示不了图片
 用NSString编码必须调用两次PRINT命令才能打印，但是图片显示正常
 **/
-(void)esc_print_ImageWithWidth:(NSInteger)width
                         height:(NSInteger)height
                              x:(NSInteger)x
                              y:(NSInteger)y
                      imageName:(NSString *)imageName{
    UIImage *image = [UIImage imageNamed:imageName];
//    NSString *hex = [self picToBitmbp:image];
    
    NSInteger hei = image.size.height;
    NSInteger wid = image.size.width;
    if (wid % 8 > 0) {
        wid = wid / 8;
    }else{
        wid = wid / 8 - 1;
    }
    
    NSString *IMAGE_PRINT_CMD_TEMPLATE = [NSString stringWithFormat:@"CG %ld %ld %ld %ld ",wid,hei,x,(long)y];
    NSData   *cmdData = [IMAGE_PRINT_CMD_TEMPLATE dataUsingEncoding:GBK_Encoding];
//    NSLog(@"IMAGE_PRINT_CMD_TEMPLATE:%@",IMAGE_PRINT_CMD_TEMPLATE);
    [self.finalData appendData:cmdData];
//    NSData   *imageData = [self dataFormHexString:hex];
    NSData  *imageData = [self pictureToBitMap:image];
//    NSLog(@"imageData.lenght:%@",imageData);
    [self.finalData appendData:imageData];
    //再添加一个换行
    NSData *enterData = [@"\r\n" dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:enterData];
    
}
/**
 *  图片打印测试
 */
-(void)cpcl_print_imageWithX:(NSInteger)x
                           y:(NSInteger)y
                   imageName:(NSString *)imageName{
    //如果图片过大则可以先缩小下图片再获取图片的数据
     UIImage *image = [UIImage imageNamed:imageName];
//    NSData  *imageData = [self pictureToBitMap:image];
    NSString *hex = [self picToBitmbp:image];
    NSInteger hei = image.size.height;
    NSInteger wid = image.size.width;
    if (wid % 8 > 0) {
        wid = wid / 8;
    }else{
        wid = wid / 8 - 1;
    }
//    NSString *cgStr = @"CG ";
//    // "CG "
//    NSData *cg_byteData = [cgStr dataUsingEncoding:GBK_Encoding];
//    NSString *widStr = [NSString stringWithFormat:@"%ld",wid];
//    // 宽
//    NSData *widData = [widStr dataUsingEncoding:GBK_Encoding];
//    NSString *space = @" ";
//    NSData *spaceData = [space dataUsingEncoding:GBK_Encoding];
//    // " "
////    Byte space[] = {0x20};
//    //高
//    NSString *heiStr = [NSString stringWithFormat:@"%ld",hei];
//    NSData *heiData = [heiStr dataUsingEncoding:GBK_Encoding];
//    // x
//    NSString *xStr = [NSString stringWithFormat:@"%ld",x];
//    NSData *xData = [xStr dataUsingEncoding:GBK_Encoding];
//    // y
//    NSString *yStr = [NSString stringWithFormat:@"%ld",y];
//    NSData *yData = [yStr dataUsingEncoding:GBK_Encoding];
//    // 要组装的格式为:CG 8 8 0 10 0F 0F
//    [self.finalData appendData:cg_byteData];//"CG "
//    [self.finalData appendData:widData];//"8"
//    [self.finalData appendData:spaceData];//" "
//    [self.finalData appendData:heiData];// "8"
//    [self.finalData appendData:spaceData];;//" "
//    [self.finalData appendData:xData];// "0"
//    [self.finalData appendData:spaceData];;//" "
//    [self.finalData appendData:yData];// "10"
//    [self.finalData appendData:spaceData];;//" "
//    [self.finalData appendData:imageData]; // "0F 0F .. .. .."
    NSString *IMAGE_PRINT_CMD_TEMPLATE = [NSString stringWithFormat:@"CG %ld %ld %ld %ld %@",wid,hei,x,y,hex];
//    NSLog(@"IMAGE_PRINT_CMD_TEMPLATE:%@",IMAGE_PRINT_CMD_TEMPLATE);
    NSData   *printData2 = [IMAGE_PRINT_CMD_TEMPLATE dataUsingEncoding:GBK_Encoding];
//    Byte *tmpB = (Byte *)[printData2 bytes];
//    NSData *printData = [NSData dataWithBytes:tmpB length:sizeof(tmpB)];
    [self.finalData appendData:printData2];
    //再添加一个换行
    NSData *enterData = [@"\r\n" dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:enterData];
//    NSLog(@"self.finalData");
//    [self esc_print_commond];
}
/**
 *  50、设置对齐方式
 *
 *  @param alignment 对齐方式：居左、居中、居右
 */
- (void)setAlignment:(HLTextAlignment)alignment{
    Byte alignBytes[] = {0x1B,0x61,alignment};
    [self.finalData appendBytes:alignBytes length:sizeof(alignBytes)];
}
/**
 *  51、 换行
 */
- (void)appendNewLine{
    Byte nextRowBytes[] = {0x0A};
    [self.finalData appendBytes:nextRowBytes length:sizeof(nextRowBytes)];
}
/**
 * final
 * 最终调用打印命令
 **/
-(void)esc_print_commond{
    NSString *PRINT = @"PRINT\r\n";
    NSData *printData = [PRINT dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:printData];
    NSLog(@"最终调用打印命令-self.finalData:%ld",self.finalData.length);
    [self.bleManager writeData:self.finalData];
}

/**
 * 打印前的初始化功能，设置进入控制指令，设置打印分辨率等打印参数
 * @param offset                水平补偿点数，一般设置为:0  。
 * @param horizontalResolution  水平分辨率  (每英寸点数)。
 * @param verticalResolution    竖直分辨率  (每英寸点数)。
 * @param height                打印标签的最大高度点数(8点/mm)。
 * @param qty                   打印标签数量.  最大为  1024
 **/
-(void)esc_init_print_commondWithOffset:(NSInteger)offset
                   horizontalResolution:(NSInteger)horizontalResolution
                     verticalResolution:(NSInteger)verticalResolution
                                 height:(NSInteger)height
                                    qty:(NSInteger)qty{
    NSString *INIT_PRINT_COMMOND_TEMPLATE = [NSString stringWithFormat:@"! %ld %ld %ld %ld %ld\n",offset,horizontalResolution,verticalResolution,height,qty];
    NSLog(@"INIT_PRINT_COMMOND_TEMPLATE :%@",INIT_PRINT_COMMOND_TEMPLATE);
    NSData *initData = [INIT_PRINT_COMMOND_TEMPLATE dataUsingEncoding:GBK_Encoding];
    [self.finalData appendData:initData];
}
//MARK:图片相关函数
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

- (NSInteger) getPixelColorAtLocation:(CGPoint)point image:(UIImage*)image{
//    UIColor* color = nil;
    NSInteger back = 0;
    CGImageRef inImage = image.CGImage;
    // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL) {
        return 0; /* error */
    }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char* data = CGBitmapContextGetData (cgctx);
    if (data != NULL) {
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        int offset = 4*((w*round(point.y))+round(point.x));
        int alpha =  data[offset];
        int red = data[offset+1];
        int green = data[offset+2];
        int blue = data[offset+3];
        //        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
        if (alpha == 0) {
            back = 0;
        }else{
            back = 255 - (alpha + red + green + blue) / 4;
        }
        
       // NSLog(@"offset: %i colors: RGB A %i %i %i  %i  %lu",offset,red,green,blue,alpha,back);
        
    }
    
    // When finished, release the context
    CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data) { free(data); }
    return back;
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
// 缩放图片
- (UIImage *)createCurrentImage:(UIImage *)inImage width:(CGFloat)width height:(CGFloat)height {
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(size);
    [inImage drawInRect:CGRectMake(0, 0, width, height)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}
#pragma mark -- lazy load
-(NSMutableData  *)finalData{
    if (_finalData == nil) {
        _finalData = [NSMutableData new];
    }
    return _finalData;
}
@end
