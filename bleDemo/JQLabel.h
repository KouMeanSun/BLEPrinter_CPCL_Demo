//
//  JQLabel.h
//  bleDemo
//
//  Created by wuyaju on 16/4/9.
//  Copyright © 2016年 wuyaju. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JQLabelFontSize) {
    JQLabelFontSize16 = 1,  // 16点阵
    JQLabelFontSize24,      // 24点阵
    JQLabelFontSize32,      // 32点阵
    JQLabelFontSize24X1,    // 24点阵放大一倍
    JQLabelFontSize32X1,    // 32点阵放大一倍
    JQLabelFontSize24X2,    // 24点阵放大两倍
    JQLabelFontSize32X2,    // 32点阵放大两倍
    JQLabelFontSizeOther,   // 其他：24点阵
};

typedef NS_ENUM(NSInteger, JQLabelRotate) {
    JQLabelRotateNone = 0,  // 不旋转
    JQLabelRotate90 = 0,    // 旋转90度
    JQLabelRotate180 = 0,   // 旋转180度
    JQLabelRotate270 = 0,   // 旋转270度
};

@interface JQLabel : UILabel

@property (nonatomic, assign)JQLabelFontSize fontSize;
@property (nonatomic, assign)JQLabelRotate rotate;

//是否粗体
@property (nonatomic, assign)BOOL bold;
//是否反白
@property (nonatomic, assign)BOOL reverse;
//是否有下划线
@property (nonatomic, assign)BOOL underline;

- (instancetype)initWithStartPoint:(CGPoint)startPoint text:(NSString *)text fontSize:(JQLabelFontSize)fontSize rotate:(JQLabelRotate)rotate bold:(BOOL)bold reverse:(BOOL)reverse underline:(BOOL)underline;
- (void)sendCmd;

@end
