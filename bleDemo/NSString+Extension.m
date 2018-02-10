//
//  NSString+Extension.m
//  bleDemo
//
//  Created by wuyaju on 16/4/9.
//  Copyright © 2016年 wuyaju. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

// 统计字符串中包含的字符数，中文按照GBK编码
- (NSInteger)charLength{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    const unsigned char *array = [self cStringUsingEncoding:enc];
    NSInteger count = 0;
    
    for (int i = 0; i < strlen(array); ){
        // 中文
        if(array[i] > 127){
            count += 2;
            i += 2;
        }else {
            count++;
            i ++;
        }
    }
    
    return count;
}

@end
