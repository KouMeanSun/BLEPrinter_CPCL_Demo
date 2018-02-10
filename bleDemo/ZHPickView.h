//
//  HLPickView.h
//  ActionSheet
//
//  Created by 赵子辉 on 15/10/22.
//  Copyright © 2015年 zhaozihui. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZHPickView;
typedef void (^HLPickViewSubmit)(NSString*);

@interface ZHPickView : UIView<UIPickerViewDelegate>

- (void)setDataViewWithItem:(NSArray *)items;
- (void)showPickView:(UIView *)view;
@property(nonatomic,copy)HLPickViewSubmit block;

@end
