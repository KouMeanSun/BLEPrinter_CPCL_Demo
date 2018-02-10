//
//  JQBox.h
//  bleDemo
//
//  Created by wuyaju on 16/4/9.
//  Copyright © 2016年 wuyaju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JQBaseLine.h"

@interface JQBox :JQBaseLine

- (instancetype)initWithFrame:(CGRect)frame lineWidth:(int)lineWidth;
- (void)sendCmd;

@end
