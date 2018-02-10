//
//  QRCodeController.h
//  eCarry
//
//  Created by whde on 15/8/14.
//  Copyright (c) 2015年 Joybon. All rights reserved.
//

#import <UIKit/UIKit.h>
#define IS_VAILABLE_IOS8  ([[[UIDevice currentDevice] systemVersion] intValue] >= 8)

@interface QRCodeController : UIViewController
typedef void (^QRCodeDidReceiveBlock)(NSString *result);
@property (nonatomic, copy, readonly) QRCodeDidReceiveBlock didReceiveBlock;
- (void)setDidReceiveBlock:(QRCodeDidReceiveBlock)didReceiveBlock;
@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com