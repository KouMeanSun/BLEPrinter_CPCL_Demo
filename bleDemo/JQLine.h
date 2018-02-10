//
//  JQLine.h
//  bleDemo
//
//  Created by wuyaju on 16/4/9.
//  Copyright © 2016年 wuyaju. All rights reserved.
//

#import "JQBaseLine.h"

typedef NS_ENUM(NSInteger, JQLineType) {
    JQLineTypeDashLine = 0, // 虚线
    JQLineTypeFullLine = 1, // 实线
};

@interface JQLine : JQBaseLine

@property (nonatomic, assign)JQLineType lineType;
@property (nonatomic, assign)CGPoint endPoint;

- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint lineWidth:(int)lineWidth lineType:(JQLineType)lineType;
- (void)sendCmd;

@end
