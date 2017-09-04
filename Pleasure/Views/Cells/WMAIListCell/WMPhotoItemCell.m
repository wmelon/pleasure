//
//  WMPhotoItemCell.m
//  Pleasure
//
//  Created by Sper on 2017/9/4.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMPhotoItemCell.h"
#import <UIButton+WebCache.h>

@implementation WMPhotoItemCell
- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]){
        
        UIButton * button = [[UIButton alloc] initWithFrame:self.bounds];
        [button addTarget:self action:@selector(photoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [button.imageView setClipsToBounds:YES];
        button.contentEdgeInsets = UIEdgeInsetsZero;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        [self.contentView addSubview:button];
        
        self.photoButton = button;
    }
    
    return self;
}

- (void)photoButtonClick:(UIButton *)button{
    if (_handle){
        _handle(self.photoButton.imageView);
    }
}
- (void)setIndex:(NSInteger)index clickHandle:(ClickHandle)handle{
    _index = index;
    _handle = handle;
    
}
- (void)setPhotoUrl:(NSString *)photoUrl{
    [self.photoButton sd_setImageWithURL:[NSURL URLWithString:photoUrl] forState:UIControlStateNormal completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
    }];
    
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    self.photoButton.frame = self.bounds;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
