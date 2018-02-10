//
//  JQBox.m
//  bleDemo
//
//  Created by wuyaju on 16/4/9.
//  Copyright © 2016年 wuyaju. All rights reserved.
//

#import "JQBox.h"

@implementation JQBox

- (instancetype)initWithFrame:(CGRect)frame lineWidth:(int)lineWidth{
    self = [super initWithFrame:frame];
    if (self) {
        self.lineWidth = lineWidth;

    }
    
    return self;
}

- (void)sendCmd{
    CGFloat x = self.x;
    CGFloat y = self.y;
    CGFloat bottomRightX = self.bottomRightX;
    CGFloat bottomRightY = self.bottomRightY;
    
    // 当存在父控件时，需要对坐标重新计算，因为实际发送的坐标都是相对原点的
    if (self.superview != nil) {
        // 只有父控件是box类，计算相对坐标才有实际意义
        if ([self.superview isKindOfClass:[JQBox class]]) {
            JQBox *superBox = (JQBox *)self.superview;
            x = superBox.x + self.x + superBox.lineWidth;
            y = superBox.y + self.y + superBox.lineWidth;
            bottomRightX = x + self.width - 1;
            bottomRightY = y + self.height - 1;
        }
    }
    
//    [[JQCPCLTool CPCLManager] drawBox:self.lineWidth top_left_x:x top_left_y:y bottom_right_x:bottomRightX bottom_right_y:bottomRightY];
}

@end
