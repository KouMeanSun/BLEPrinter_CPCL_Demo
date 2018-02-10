//
//  LQLabelField.m
//  bleDemo
//
//  Created by wuyaju on 16/4/9.
//  Copyright © 2016年 wuyaju. All rights reserved.
//

#import "JQLabelField.h"
#import "JQBox.h"
#import "UIView+Extension.h"

@implementation JQLabelField

- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)text fontSize:(JQLabelFontSize)fontSize rotate:(JQLabelRotate)rotate bold:(BOOL)bold reverse:(BOOL)reverse underline:(BOOL)underline{
    self = [super initWithStartPoint:CGPointMake(frame.origin.x, frame.origin.y) text:text fontSize:fontSize rotate:rotate bold:bold reverse:reverse underline:underline];
    if (self) {
        self.width = frame.size.width;
        self.height = frame.size.height;
    }
    return self;
}

- (void)sendCmd{
    CGFloat x = self.x;
    CGFloat y = self.y;
    
    // 当存在父控件时，需要对坐标重新计算，因为实际发送的坐标都是相对原点的
    if (self.superview != nil) {
        // 只有父控件是box类，计算相对坐标才有实际意义
        if ([self.superview isKindOfClass:[JQBox class]]) {
            JQBox *superBox = (JQBox *)self.superview;
            x = self.x + superBox.x + superBox.lineWidth;
            y = self.y + superBox.y + superBox.lineWidth;
        }
    }
    
//    [[JQCPCLTool CPCLManager] drawText:x text_y:y width:self.width height:self.height str:self.text fontsize:self.fontSize rotate:self.rotate bold:self.bold underline:self.underline reverse:self.reverse];
}

@end
