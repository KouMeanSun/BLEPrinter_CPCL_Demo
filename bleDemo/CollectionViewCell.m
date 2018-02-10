//
//  CollectionViewCell.m
//  collectionView
//
//  Created by Lansum Stuff on 16/3/17.
//  Copyright © 2016年 Lansum Stuff. All rights reserved.
//

#import "CollectionViewCell.h"
#import "Masonry.h"

@interface CollectionViewCell ()

@property(nonatomic, strong)UILabel *label;
@property (nonatomic, strong)UIImageView *imgView;

@end

@implementation CollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1];
        view.layer.cornerRadius = 8;
        view.layer.masksToBounds = YES;
        [self.contentView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        [view addSubview:imgView];
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view);
        }];
        self.imgView = imgView;
        
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:20];
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view);
        }];
        self.label = label;
    }
    
    return self;
}


- (void)setTitle:(NSString *)title{
    _title = [title copy];
    self.label.text = _title;
}

- (void)setImage:(NSString *)image{
    _image = [image copy];
    self.imgView.image = [UIImage imageNamed:image];
}

@end
