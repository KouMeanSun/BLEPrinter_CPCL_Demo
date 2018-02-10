//
//  HLPickView.m
//  ActionSheet
//
//  Created by 赵子辉 on 15/10/22.
//  Copyright © 2015年 zhaozihui. All rights reserved.
//

#import "ZHPickView.h"
#define SCREENSIZE UIScreen.mainScreen.bounds.size
@implementation ZHPickView {
    UIView *bgView;
    NSArray *proTitleList;
    NSString *selectedStr;
}

@synthesize block;
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (void)showPickView:(UIView *)view {
    bgView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0;
    [view addSubview:bgView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [bgView addGestureRecognizer:tapGesture];
    
    CGRect frame = self.frame ;
    self.frame = CGRectMake(0,SCREENSIZE.height + frame.size.height, SCREENSIZE.width, frame.size.height);
    [view addSubview:self];
    [UIView animateWithDuration:0.5f
                     animations:^{
                         bgView.alpha = 0.3f;
                         self.frame = frame;
                     }
                     completion:nil];
}

- (void)hide {
    [bgView removeFromSuperview];
    [self removeFromSuperview];
}

- (void)setDataViewWithItem:(NSArray *)items {
    proTitleList = items;
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENSIZE.width, 40)];
    header.backgroundColor = [UIColor whiteColor];
    
    UIButton *submit = [[UIButton alloc] initWithFrame:CGRectMake(SCREENSIZE.width - 50, 10, 50 ,29.5)];
    [submit setTitle:@"确定" forState:UIControlStateNormal];
    [submit setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    submit.titleLabel.font = [UIFont systemFontOfSize:16];
    [submit addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:submit];
    
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, 50 ,29.5)];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    cancel.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:cancel];

    [self addSubview:header];
    UIPickerView *pick = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, SCREENSIZE.width, 250)];
    
    pick.delegate = self;
    pick.backgroundColor = [UIColor whiteColor];
    [self addSubview:pick];
    
    float height = 290;
    self.frame = CGRectMake(0, SCREENSIZE.height - height, SCREENSIZE.width, height);
}
#pragma mark DatePicker监听方法
- (void)cancel:(UIButton *)btn {
    [self hide];
}

- (void)submit:(UIButton *)btn {
    NSString *pickStr = selectedStr;
    if (!pickStr || pickStr.length == 0) {
        if([proTitleList count] > 0) {
            selectedStr = proTitleList[0];
        }
    }
    block(selectedStr);
    [self hide];
}

// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [proTitleList count];
}

// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return SCREENSIZE.width;
}
// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    selectedStr = [proTitleList objectAtIndex:row];
    
}

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [proTitleList objectAtIndex:row];
}

- (UIColor *)getColor:(NSString*)hexColor {
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&red];
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&green];
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&blue];
    return [UIColor colorWithRed:(float)(red/255.0f)green:(float)(green / 255.0f) blue:(float)(blue / 255.0f)alpha:1.0f];
}

- (CGSize)workOutSizeWithStr:(NSString *)str andFont:(NSInteger)fontSize value:(NSValue *)value {
    CGSize size;
    if (str) {
        NSDictionary *attribute = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:fontSize],NSFontAttributeName, nil];
        size=[str boundingRectWithSize:[value CGSizeValue] options:NSStringDrawingUsesFontLeading |NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingTruncatesLastVisibleLine attributes:attribute context:nil].size;
    }
    return size;
}
@end

