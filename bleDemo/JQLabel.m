//
//  JQLabel.m
//  bleDemo
//
//  Created by wuyaju on 16/4/9.
//  Copyright © 2016年 wuyaju. All rights reserved.
//

#import "JQLabel.h"
#import "JQBox.h"
#import "UIView+Extension.h"
#import "NSString+Extension.h"

@implementation JQLabel

- (instancetype)initWithStartPoint:(CGPoint)startPoint text:(NSString *)text fontSize:(JQLabelFontSize)fontSize rotate:(JQLabelRotate)rotate bold:(BOOL)bold reverse:(BOOL)reverse underline:(BOOL)underline{
    self = [super init];
    if (self) {
        self.x = startPoint.x;
        self.y = startPoint.y;
        self.text = text;
        self.fontSize = fontSize;
        self.rotate = rotate;
        self.bold = bold;
        self.reverse = reverse;
        self.underline = underline;
        
        NSInteger length = [text charLength];
        CGFloat width  = 0;
        CGFloat height = 0;
        
        switch (fontSize) {
            case JQLabelFontSize16:
                width = length * 16;
                height = 16;
                break;
            case JQLabelFontSize24:
                width = length * 24;
                height = 24;
                break;
            case JQLabelFontSize32:
                width = length * 32;
                height = 32;
                break;
            case JQLabelFontSize24X1:
                width = length * 24 *2;
                height = 24 * 2;
                break;
            case JQLabelFontSize32X1:
                width = length * 32 *2;
                height = 32 * 2;
                break;
            case JQLabelFontSize24X2:
                width = length * 24 * 3;
                height = 24 * 3;
                break;
            case JQLabelFontSize32X2:
                width = length * 32 * 3;
                height = 32 *3;
                break;
            case JQLabelFontSizeOther:
                width = length * 24;
                height = 24;
                break;
            default:
                width = length * 24;
                height = 24;
                break;
        }
        
        self.frame = CGRectMake(self.x, self.y, width/2, height);
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
    
//    [[JQCPCLTool CPCLManager] drawText:x text_y:y text:self.text fontSize:self.fontSize rotate:self.rotate bold:self.bold reverse:self.reverse underline:self.underline];
}

@end
