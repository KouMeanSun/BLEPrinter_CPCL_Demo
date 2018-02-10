//
//  JQPrintTool.m
//  bleDemo
//
//  Created by wuyaju on 2017/6/22.
//  Copyright © 2017年 wuyaju. All rights reserved.
//

#import "JQPrintTool.h"
#import "BleDeviceManager.h"

@interface JQPrintTool ()

@property (nonatomic, strong)BleDeviceManager *bleManager;

@end

@implementation JQPrintTool

+ (instancetype)PrintManager{
    static JQPrintTool *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JQPrintTool alloc] init];
    });
    
    return manager;
}

- (instancetype)init{
    self = [super init];
    
    self.bleManager = [BleDeviceManager bleManager];
    
    return self;
}

/**
 * 打印文字
 *
 * @param text 要打印的文字
 */
- (void)printText:(NSString *)text {
    [self.bleManager writeText:text];
}

/**
 * 打印一维条码
 *
 * @param text 要打印的条码内容,
 * @param barcodeType 条码类型(0-8,10-12,65-73),HRI字符打印位置(0-3),HRIFont HRI字符字体(0-1),height 条形码高度（0-255）,width 条形码宽度（2-6）
 */
//- (void)printBarcode1d(String text,int barcodeType,int HRILocation,int HRIFont,int height,int width) {
//    try {
//        outputStream.write(new Byte{0x1d,0x48,(byte) HRILocation});
//        Log.i("printBarcode1d",""+(byte) HRILocation);
//        outputStream.write(new Byte{0x1d,0x66,(byte) HRIFont});
//        Log.i("printBarcode1d",""+(byte) HRIFont);
//        outputStream.write(new Byte{0x1d,0x68,(byte) height});
//        Log.i("printBarcode1d",""+(byte) height);
//        outputStream.write(new Byte{0x1d,0x77,(byte) width});
//        Log.i("printBarcode1d",""+(byte) width);
//        if((0<=barcodeType && barcodeType<=8) || (10<=barcodeType && barcodeType<=12)){
//            outputStream.write(new Byte{0x1d,0x6b,(byte) barcodeType});
//            Log.i("printBarcode1d",""+(byte) barcodeType);
//            Byte data = text.getBytes();
//            outputStream.write(data);
//            outputStream.write(new Byte{0x00});
//        }else if(65<=barcodeType && barcodeType<=73){
//            outputStream.write(new Byte{0x1d,0x6b,(byte) barcodeType,(byte) text.length()});
//            Byte data = text.getBytes();
//            outputStream.write(data);
//        }
//        outputStream.write(new Byte{0x1b,0x64,0x02});
//        outputStream.flush();
//    } catch (IOException e) {
//        //Toast.makeText(this.context, "发送失败！", Toast.LENGTH_SHORT).show();
//        e.printStackTrace();
//    }
//}

///**
// * 设置打印格式
// *
// * @param command 格式指令
// */
//- (void)selectCommand:(Byte *)command {
//    try {
//        outputStream.write(command);
//        outputStream.flush();
//    } catch (IOException e) {
//        //Toast.makeText(this.context, "发送失败！", Toast.LENGTH_SHORT).show();
//        e.printStackTrace();
//    }
//}

/**
 * 复位打印机
 */
 static Byte RESET[] = {0x1b, 0x40};

/**
 * 左对齐
 */
 static Byte ALIGN_LEFT[] = {0x1b, 0x61, 0x00};

/**
 * 中间对齐
 */
 static Byte ALIGN_CENTER[] = {0x1b, 0x61, 0x01};

/**
 * 右对齐
 */
 static Byte ALIGN_RIGHT[] = {0x1b, 0x61, 0x02};

/**
 * 选择加粗模式
 */
 static Byte BOLD[] = {0x1b, 0x45, 0x01};

/**
 * 取消加粗模式
 */
 static Byte BOLD_CANCEL[] = {0x1b, 0x45, 0x00};

/**
 * 宽高加倍
 */
 static Byte DOUBLE_HEIGHT_WIDTH[] = {0x1d, 0x21, 0x11};

/**
 * 3倍宽高
 */
 static Byte TRIPLE_HEIGHT_WIDTH[] = {0x1d, 0x21, 0x22};

/**
 * 4倍宽高
 */
 static Byte FOURFOLD_HEIGHT_WIDTH[] = {0x1d, 0x21, 0x33};

/**
 * 宽加倍
 */
 static Byte DOUBLE_WIDTH[] = {0x1d, 0x21, 0x10};

/**
 * 高加倍
 */
 static Byte DOUBLE_HEIGHT[] = {0x1d, 0x21, 0x01};

/**
 * 字体不放大
 */
 static Byte NORMAL[] = {0x1d, 0x21, 0x00};

/**
 * 设置默认行间距
 */
 static Byte LINE_SPACING_DEFAULT[] = {0x1b, 0x32};

/**
 * 设置行间距
 */
//	 static Byte LINE_SPACING[] = {0x1b, 0x32};//{0x1b, 0x33, 0x14};  // 20的行间距（0，255）

/**
 * 选择下划线模式
 */
 static Byte UNDERLINE[] = {0x1b, 0x2D, 0x01};

/**
 * 取消下划线模式
 */
 static Byte UNDERLINE_CANCEL[] = {0x1b, 0x2D, 0x00};

/**
 * 打印并进纸一行
 */
 static Byte PRINT_FORMFEED= {0x0a};

/**
 * 跳到下一水平制表符位置
 */
 static Byte NEXT_LEVEL_TAB[] = {0x09};

/**
 * 选择字符字体A
 */
 static Byte CHARACTER_FONT_A[] = {0x1b,0x4d,0x00};

/**
 * 选择字符字体B
 */
 static Byte CHARACTER_FONT_B[] = {0x1b,0x4d,0x01};

/**
 * 打开90°顺时针旋转模式
 */
 static Byte ROTATE_90[] = {0x1b, 0x56, 0x01};

/**
 * 打开180°顺时针旋转模式
 */
 static Byte ROTATE_180[] = {0x1b, 0x56, 0x02};

/**
 * 打开270°顺时针旋转模式
 */
 static Byte ROTATE_270[] = {0x1b, 0x56, 0x03};

/**
 * 取消90°顺时针旋转模式
 */
 static Byte ROTATE_CANCEL[] = {0x1b, 0x56, 0x00};

/**
 * 打开颠倒打印模式
 */
 static Byte REVERSE[] = {0x1b, 0x7B, 0x01};

/**
 * 关闭颠倒打印模式
 */
 static Byte REVERSE_CANCEL[] = {0x1b, 0x7B, 0x00};

/**
 * 打开白/黑颠倒打印模式
 */
 static Byte WHITE_BLACK_REVERSE[] = {0x1d, 0x42, 0x01};

/**
 * 关闭白/黑颠倒打印模式
 */
 static Byte WHITE_BLACK_REVERSE_CANCEL[] = {0x1d, 0x42, 0x00};


//	Byte[] byteCommands[] = {
//	{ 0x1b, 0x61, 0x00 }, // 左对齐
//	{ 0x1b, 0x61, 0x01 }, // 中间对齐
//	{ 0x1b, 0x61, 0x02 }, // 右对齐
//	{ 0x1b, 0x40 },// 复位打印机
//	{ 0x1b, 0x4d, 0x00 },// 标准ASCII字体
//	{ 0x1b, 0x4d, 0x01 },// 压缩ASCII字体
//	{ 0x1d, 0x21, 0x00 },// 字体不放大
//	{ 0x1d, 0x21, 0x11 },// 宽高加倍
//	{ 0x1b, 0x45, 0x00 },// 取消加粗模式
//	{ 0x1b, 0x45, 0x01 },// 选择加粗模式
//	{ 0x1b, 0x7b, 0x00 },// 取消倒置打印
//	{ 0x1b, 0x7b, 0x01 },// 选择倒置打印
//	{ 0x1d, 0x42, 0x00 },// 取消黑白反显
//	{ 0x1d, 0x42, 0x01 },// 选择黑白反显
//	{ 0x1b, 0x56, 0x00 },// 取消顺时针旋转90°
//	{ 0x1b, 0x56, 0x01 },// 选择顺时针旋转90°
//	};



/**
 * 打印纸一行最大的字节
 */
static int LINE_BYTE_SIZE = 32;

static int LEFT_LENGTH = 20;

static int RIGHT_LENGTH = 12;

/**
 * 左侧汉字最多显示几个文字
 */
static int LEFT_TEXT_MAX_LENGTH = 8;

/**
 * 小票打印菜品的名称，上限调到8个字
 */
 static int MEAL_NAME_MAX_LENGTH = 8;

///**
// * 打印两列
// *
// * @param leftText  左侧文字
// * @param rightText 右侧文字
// * @return
// */
// static String printTwoData(String leftText, String rightText) {
//    StringBuilder sb = new StringBuilder();
//    int leftTextLength = getBytesLength(leftText);
//    int rightTextLength = getBytesLength(rightText);
//    sb.append(leftText);
//    
//    // 计算两侧文字中间的空格
//    int marginBetweenMiddleAndRight = LINE_BYTE_SIZE - leftTextLength - rightTextLength;
//    
//    for (int i = 0; i < marginBetweenMiddleAndRight; i++) {
//        sb.append(" ");
//    }
//    sb.append(rightText);
//    return sb.toString();
//}
//
///**
// * 打印三列
// *
// * @param leftText   左侧文字
// * @param middleText 中间文字
// * @param rightText  右侧文字
// * @return
// */
//@SuppressLint("NewApi")
// static String printThreeData(String leftText, String middleText, String rightText) {
//    StringBuilder sb = new StringBuilder();
//    // 左边最多显示 LEFT_TEXT_MAX_LENGTH 个汉字 + 两个点
//    if (leftText.length() > LEFT_TEXT_MAX_LENGTH) {
//        leftText = leftText.substring(0, LEFT_TEXT_MAX_LENGTH) + "..";
//    }
//    int leftTextLength = getBytesLength(leftText);
//    int middleTextLength = getBytesLength(middleText);
//    int rightTextLength = getBytesLength(rightText);
//    
//    sb.append(leftText);
//    // 计算左侧文字和中间文字的空格长度
//    int marginBetweenLeftAndMiddle = LEFT_LENGTH - leftTextLength - middleTextLength / 2;
//    
//    for (int i = 0; i < marginBetweenLeftAndMiddle; i++) {
//        sb.append(" ");
//    }
//    sb.append(middleText);
//    
//    // 计算右侧文字和中间文字的空格长度
//    int marginBetweenMiddleAndRight = RIGHT_LENGTH - middleTextLength / 2 - rightTextLength;
//    
//    for (int i = 0; i < marginBetweenMiddleAndRight; i++) {
//        sb.append(" ");
//    }
//    
//    // 打印的时候发现，最右边的文字总是偏右一个字符，所以需要删除一个空格
//    sb.delete(sb.length() - 1, sb.length()).append(rightText);
//    return sb.toString();
//}
//
///**
// * 获取数据长度
// *
// * @param msg
// * @return
// */
//@SuppressLint("NewApi")
//private static int getBytesLength(String msg) {
//    return msg.getBytes(Charset.forName("GB2312")).length;
//}
//
///**
// * 格式化菜品名称，最多显示MEAL_NAME_MAX_LENGTH个数
// *
// * @param name
// * @return
// */
// static String formatMealName(String name) {
//    if (TextUtils.isEmpty(name)) {
//        return name;
//    }
//    if (name.length() > MEAL_NAME_MAX_LENGTH) {
//        return name.substring(0, 8) + "..";
//    }
//    return name;
//}

@end
