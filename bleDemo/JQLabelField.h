//
//  LQLabelField.h
//  bleDemo
//
//  Created by wuyaju on 16/4/9.
//  Copyright © 2016年 wuyaju. All rights reserved.
//

#import "JQLabel.h"

@interface JQLabelField : JQLabel

- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)text fontSize:(JQLabelFontSize)fontSize rotate:(JQLabelRotate)rotate bold:(BOOL)bold reverse:(BOOL)reverse underline:(BOOL)underline;

@end
