//
//  WMTextView.m
//  Pleasure
//
//  Created by Sper on 2017/8/14.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMTextView.h"

@interface WMTextView()
@property (nonatomic , strong) UILabel *placeHodlerLabel;
@end

@implementation WMTextView

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
    
        _placeHodlerLabel = [[UILabel alloc] init];
        _placeHodlerLabel.textColor = [UIColor darkGrayColor];
        _placeHodlerLabel.font = self.font;
        _placeHodlerLabel.backgroundColor = [UIColor clearColor];
        _placeHodlerLabel.numberOfLines = 0; //设置可以输入多行文字时可以自动换行
        
        [self addSubview:_placeHodlerLabel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self]; //通知:监听文字的改变
        
        self.textContainerInset = UIEdgeInsetsMake(16, 14, 0, 16);
    }
    return self;
}

- (void)setMyPlaceHolder:(NSString *)myPlaceHolder{
    _myPlaceHolder = myPlaceHolder;
    
    _placeHodlerLabel.text = myPlaceHolder;
    [self setNeedsLayout];
}

- (void)setMyPlaceHodlerColor:(UIColor *)myPlaceHodlerColor{
    _myPlaceHodlerColor = myPlaceHodlerColor;
    
    _placeHodlerLabel.textColor = _myPlaceHodlerColor;
    [self setNeedsLayout];
}

- (void)setFont:(UIFont *)font{
    [super setFont:font];
    _placeHodlerLabel.font = font;
    [self setNeedsLayout];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    
    CGFloat x = self.textContainerInset.left + 5;  //设置 UILabel 的 x 值
    CGFloat y = self.textContainerInset.top - 8 + 7;  //设置UILabel 的 y值  得减去原本textView的顶部内边距
    CGFloat width = self.frame.size.width - x * 2.0;  //设置 UILabel 的 x
    
    //根据文字计算高度
    CGSize maxSize = CGSizeMake(width , MAXFLOAT);
    
    CGFloat height = [self.placeHodlerLabel.text boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.placeHodlerLabel.font} context:nil].size.height;
    
    self.placeHodlerLabel.frame = CGRectMake(x, y, width, height);
}


- (void)textDidChange{
    
    self.placeHodlerLabel.hidden = self.hasText;
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
