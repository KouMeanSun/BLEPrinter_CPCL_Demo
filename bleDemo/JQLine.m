//
//  JQLine.m
//  bleDemo
//
//  Created by wuyaju on 16/4/9.
//  Copyright © 2016年 wuyaju. All rights reserved.
//

#import "JQLine.h"
#import "JQBox.h"

@implementation JQLine

- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint lineWidth:(int)lineWidth lineType:(JQLineType)lineType{
    self = [super init];
    if (self) {
        self.lineWidth = lineWidth;
        self.lineType = lineType;
        self.x = startPoint.x;
        self.y = startPoint.y;
        self.endPoint = endPoint;
    }
    
    return self;
}

- (void)sendCmd{
    CGFloat x = self.x;
    CGFloat y = self.y;
    CGFloat endx = self.endPoint.x;
    CGFloat endy = self.endPoint.y;
    
    // 当存在父控件时，需要对坐标重新计算，因为实际发送的坐标都是相对原点的
    if (self.superview != nil) {
        // 只有父控件是box类，计算相对坐标才有实际意义
        if ([self.superview isKindOfClass:[JQBox class]]) {
            JQBox *superBox = (JQBox *)self.superview;
            x = self.x + superBox.x + superBox.lineWidth;
            y = self.y + superBox.y + superBox.lineWidth;
            endx = self.endPoint.x + superBox.x + superBox.lineWidth;
            endy = self.endPoint.y + superBox.y + superBox.lineWidth;
        }
    }
    
//    [[JQCPCLTool CPCLManager] drawLine:self.lineWidth start_x:x start_y:y end_x:endx end_y:endy fullline:self.lineType];
}

@end
