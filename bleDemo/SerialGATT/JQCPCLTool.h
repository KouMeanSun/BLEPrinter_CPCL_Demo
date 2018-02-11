//
//  JQCPCLTool.h
//  bleDemo
//
//  Created by 高明阳(01370716) on 2018/2/6.
//  Copyright © 2018年 wuyaju. All rights reserved.
//  提供打印服务

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JQCPCLTool : NSObject

@property (nonatomic,strong)NSMutableData    *finalData;


/**
 *  获取打印服务单例对象
 *
 *  @return 打印服务单例对象
 */
+ (instancetype)CPCLManager;

/**
 *  页模式下打印
 *
 *  @param horizontal 0:正常打印，不旋转；
 *                    1：整个页面顺时针旋转180°后，再打印
 *  @param skip       0：打印结束后不定位，直接停止；
 *                    1：打印结束后定位到标签分割线，如果无缝隙，最大进纸30mm后停止
 */
- (void)print:(int)horizontal skip:(int)skip;

/**
 *  设置打印纸张大小（打印区域）的大小
 *
 *  @param pageWidth  打印区域宽度
 *  @param pageHeight 打印区域高度
 *  @param qty        打印份数
 */
- (void)pageSetup:(int)pageWidth pageHeight:(int)pageHeight qty:(int)qty;

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
 bottom_right_x:(int)bottom_right_x bottom_right_y:(int)bottom_right_y;

/**
 *  打印线条
 *
 *  @param lineWidth 线条宽度
 *  @param start_x   线条起始点x坐标
 *  @param start_y   线条起始点y坐标
 *  @param end_x     线条结束点x坐标
 *  @param end_y     线条结束点y坐标
 *  @param fullline  true:实线  false: 虚线
 */
- (void)drawLine:(int)lineWidth start_x:(int)start_x start_y:(int)start_y end_x:(int)end_x end_y:(int)end_y fullline:(BOOL)fullline;

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
- (void)drawText:(int)text_x text_y:(int)text_y text:(NSString *)text fontSize:(int)fontSize rotate:(int)rotate bold:(int)bold reverse:(BOOL)reverse underline:(BOOL)underline;

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
          rotate:(int)rotate bold:(int)bold underline:(BOOL)underline reverse:(BOOL)reverse;

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
- (void)drawBarCode:(int)start_x start_y:(int)start_y text:(NSString *)text type:(int)type rotate:(int)rotate linewidth:(int)linewidth height:(int)height;

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
- (void)drawQrCode:(int)start_x start_y:(int)start_y text:(NSString *)text rotate:(int)rotate ver:(int)ver lel:(int)lel;

/**
 *  打印图片
 *
 *  @param start_x     图片起始点横坐标
 *  @param start_y     图片起始点纵坐标
 *  @param picName     图片名字
 */
- (void)drawGraphic:(int)start_x start_y:(int)start_y picName:(NSString *)picName;

-(void)drawGraphicWithX:(int)x y:(int)y imageName:(NSString *)imageName;

/**
 *  定位到标签
 */
- (void)feed;
/**
 *  重置打印机
 */
-(void)reset;
/**
 把图片转化成16进制字符串
 **/
- (NSMutableString *)picToBitmbp:(UIImage *)image;
@end
