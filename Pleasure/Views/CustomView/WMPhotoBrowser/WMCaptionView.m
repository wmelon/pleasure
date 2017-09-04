//
//  WMCaptionView.m
//  Pleasure
//
//  Created by Sper on 2017/8/10.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMCaptionView.h"

static const CGFloat labelPadding = 10;

@interface WMCaptionView(){
    UILabel *_label;
}
@property (nonatomic , strong) WMPhotoModel *photo;
@end

@implementation WMCaptionView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        [self wm_configView];
    }
    return self;
}
- (instancetype)init{
    if (self = [super init]){
        [self wm_configView];
    }
    return self;
}

- (void)wm_configView{
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [self setupCaption];
}

- (void)setupCaption {
    _label = [[UILabel alloc] init];
    _label.opaque = NO;
    _label.backgroundColor = [UIColor clearColor];
    _label.textAlignment = NSTextAlignmentLeft;
    _label.lineBreakMode = NSLineBreakByWordWrapping;
    
    _label.numberOfLines = 0;
    _label.textColor = [UIColor whiteColor];
    _label.font = [UIFont systemFontOfSize:17];
    [self addSubview:_label];
}

- (CGSize)captionViewSizeWithPhoto:(WMPhotoModel *)photo currentIndex:(NSInteger)currentIndex count:(NSInteger)count captionWidth:(CGFloat)width{
    _photo = photo;

    NSString * caption;
    CGSize scaptionViewSize = CGSizeZero;
    if (photo.caption && [_photo respondsToSelector:@selector(caption)]){
        caption = [NSString stringWithFormat:@"%ld/%ld %@" , currentIndex ,count ,photo.caption];
        
        _label.text = caption;
        scaptionViewSize = [self wm_sizeThatFits:width];
        
        _label.frame = CGRectMake(labelPadding, labelPadding,
                                  scaptionViewSize.width - labelPadding*2,
                                  scaptionViewSize.height - labelPadding*2);
    }
    return scaptionViewSize;
}


- (CGSize)wm_sizeThatFits:(CGFloat)width {
    CGFloat maxHeight = 9999;
    if (_label.numberOfLines > 0) maxHeight = _label.font.leading*_label.numberOfLines;
    CGSize textSize = [_label.text boundingRectWithSize:CGSizeMake(width - labelPadding*2, maxHeight)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:_label.font}
                                                context:nil].size;
    return CGSizeMake(width, textSize.height + labelPadding * 2);
}


@end
