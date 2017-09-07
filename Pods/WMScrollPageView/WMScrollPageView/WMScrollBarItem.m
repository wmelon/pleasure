//
//  WMScrollBarItem.m
//  AllDemo
//
//  Created by Sper on 2017/7/28.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMScrollBarItem.h"
#import "WMScrollPageView.h"

@interface UIImage (MyBundle)
+ (UIImage *)imageNamedFromMyBundle:(NSString *)name;
@end

@implementation UIImage (MyBundle)

+ (UIImage *)imageNamedFromMyBundle:(NSString *)name {
    NSBundle *bundle = [NSBundle bundleForClass:[WMScrollPageView class]];
    NSURL *url = [bundle URLForResource:@"WMScrollPageView" withExtension:@"bundle"];
    bundle = [NSBundle bundleWithURL:url];
    
    NSBundle *imageBundle = bundle;
    name = [name stringByAppendingString:@"@2x"];
    NSString *imagePath = [imageBundle pathForResource:name ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (!image) {
        // 兼容业务方自己设置图片的方式
        name = [name stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
        image = [UIImage imageNamed:name];
    }
    return image;
}

@end



#define fastPercent 0.5

typedef NS_ENUM(NSInteger , wm_titleColorType) {
    wm_titleColorType_HighLight = 0,   /// 高亮颜色
    wm_titleColorType_normal   /// 正常颜色
};

@interface WMScrollBarItem()<UIScrollViewDelegate>

/// 滚动的标题视图
@property (nonatomic , strong) UIScrollView * scrollView;

/// 所有显示的样式
@property (nonatomic , strong) WMScrollBarItemStyle *barItemStyle;

/// 存储所有标题按钮
@property (nonatomic , strong) NSArray<UIButton *> *itemsButtonArray;

// 缓存计算出来的每个标题下面线条的宽度
@property (nonatomic, strong) NSArray *scrollLineWidths;

/// 线条视图
@property (nonatomic , strong) UIView * moveLine;

/// 底部分割线条
@property (nonatomic , strong) UILabel *bottomLine;

/// 右边加号按钮
@property (nonatomic, strong) UIButton *plusButton;

/// 当前选中的item
@property (nonatomic , assign) NSInteger selectedSegmentIndex;

//R/G/B   1 1 1 1;
@property (nonatomic, strong) NSArray <NSNumber *> *highLightColors;
@property (nonatomic, strong) NSArray <NSNumber *> *defaultColors;

/// 存储两个相邻标签的距离
@property (nonatomic, strong) NSMutableArray<NSNumber *> *distances;

/// 正在手势滚动 不允许点击
@property (nonatomic, assign) BOOL scrollAnimating;

@end

@implementation WMScrollBarItem

- (void)wm_configBarItemsWithCount:(NSInteger)count currentIndex:(NSInteger)currentIndex barItemStyle:(WMScrollBarItemStyle *)barItemStyle{
    NSAssert(barItemStyle, @"不可以为空");
    
    _barItemStyle = barItemStyle;
    
    NSAssert(count >= 0, @"创建的 batItem 的个数不能是负数");
    
    NSAssert(currentIndex < count, @"当前选中的不能大于总个数");
    
    _selectedSegmentIndex = currentIndex;
    
    [self.itemsButtonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.superview){
            [obj removeFromSuperview];
            obj = nil;
        }
    }];
    
    NSMutableArray * buttonsArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0 ; i < count ; i++){
        
        NSString *title = [self titleWithColumn:i];

        UIButton * columnButton = [UIButton new];
        
        [columnButton setTitleColor:self.barItemStyle.normalTitleColor forState:UIControlStateNormal];
        
        columnButton.tag = i;
        [columnButton addTarget:self action:@selector(titleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        columnButton.titleLabel.font = self.barItemStyle.titleFont;
        [buttonsArray addObject:columnButton];
        [self.scrollView addSubview:columnButton];
        
        
        /// 设置存储rgb颜色的数组
        self.defaultColors = [self setDefaultRGBColors:self.barItemStyle.normalTitleColor];
        self.highLightColors = [self setDefaultRGBColors:self.barItemStyle.selectedTitleColor];
        
        
        /// 这一句必须放到最后。因为需要回调返回数据去更改标题颜色
        [columnButton setTitle:title forState:UIControlStateNormal];
    }
    self.itemsButtonArray = buttonsArray;
    [self wm_configUI];
    
}

- (void)wm_configUI{
    /// 添加标题滚动视图
    [self addSubview:self.scrollView];
    
    /// 显示底部滚动线条
    if (self.barItemStyle.isShowLine){
        //添加滚动条
        [self.scrollView addSubview:self.moveLine];
        self.moveLine.backgroundColor = self.barItemStyle.scrollLineColor;
    }
    
    /// 显示底部分割线条
    if (self.barItemStyle.isAllowShowBottomLine){
        self.bottomLine.backgroundColor = self.barItemStyle.bottomLineColor;
        [self addSubview:self.bottomLine];
    }
    
    /// 是否显示右边添加按钮
    if (self.barItemStyle.isShowExtraButton){
        [self addSubview:self.plusButton];
    }
}

/// 根据文本获取宽度
- (CGSize)getSizeOfContent:(NSString *)str width:(CGFloat)width font:(UIFont *)font{
    CGSize size =CGSizeMake(width,CGFLOAT_MAX);
    
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    CGSize  actualsize = CGSizeMake(0, 0);
    if(([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)){
        actualsize =[str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    }
    //强制转化为整型(比初值偏小)，因为float型size转到view上会有一定的偏移，导致view setBounds时候 错位
    CGSize contentSize =CGSizeMake(ceil(actualsize.width), ceil(actualsize.height));
    return contentSize;
}

/// 0.0 -- 1.0  或 -0.0 -- -1.0   数字越小越偏向高亮颜色   数值越大越偏向原本颜色
- (UIColor *)gradientHighLightToNormal:(CGFloat)percent{
    CGFloat r = self.defaultColors[0].floatValue + (1-ABS(percent))*(self.highLightColors[0].floatValue-self.defaultColors[0].floatValue);
    CGFloat g = self.defaultColors[1].floatValue + (1-ABS(percent))*(self.highLightColors[1].floatValue-self.defaultColors[1].floatValue);
    CGFloat b = self.defaultColors[2].floatValue + (1-ABS(percent))*(self.highLightColors[2].floatValue-self.defaultColors[2].floatValue);
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

- (NSArray *)setDefaultRGBColors:(UIColor *)color{
    
    NSMutableArray * array = [NSMutableArray array];
    CGFloat R = 1.0, G = 1.0, B = 1.0;
    NSInteger numComponents = CGColorGetNumberOfComponents([color CGColor]);
    
    if (numComponents == 4)
    {
        const CGFloat *components = CGColorGetComponents([color CGColor]);
        R = components[0];
        G = components[1];
        B = components[2];
    }
    
    [array addObject:@(R)];
    [array addObject:@(G)];
    [array addObject:@(B)];
    
    return array;
}

- (void)wm_scrollViewDidEndDecelerating{
    self.scrollAnimating = NO;
    /// 更新滚动视图位置
    [self wm_adjustTitleOffSet:_selectedSegmentIndex];
}
- (void)adjustUIWithProgress:(CGFloat)progress currentIndex:(NSInteger)currentIndex{
    
    _selectedSegmentIndex = currentIndex;
    
    self.scrollAnimating = YES;
    
    [self wm_barItemStyleSettingWithProgress:progress];
    
}

- (void)wm_barItemStyleSettingWithProgress:(CGFloat)progress{
    [self wm_changeTitleBigSmallWithProgress:progress];
    [self changeTitleColorWithProgress:progress];
    if (self.barItemStyle.isShowLine){
        [self changeMoveLineWithProgress:progress];
    }
}

/// 改变文字的大小
- (void)wm_changeTitleBigSmallWithProgress:(CGFloat)progress{
    // 缩放, 设置初始的label的transform
    if (self.barItemStyle.isScaleTitle) {
        NSInteger currentIndex = self.selectedSegmentIndex;
        
        UIButton * currentButton = self.itemsButtonArray[currentIndex];
        CGFloat tempProgress = progress - (int)progress;

        CGFloat scale = tempProgress * (self.barItemStyle.titleBigScale - 1.0);
        
        if (tempProgress < fastPercent){  //半屏以前
            
            currentButton.transform = CGAffineTransformMakeScale(self.barItemStyle.titleBigScale - scale, self.barItemStyle.titleBigScale - scale);
            
            if (currentIndex < self.itemsButtonArray.count - 1){
                
                UIButton *afterButton = self.itemsButtonArray[currentIndex + 1];
                
                afterButton.transform = CGAffineTransformMakeScale(1.0 + scale, 1.0 + scale);
                
            }
            
        }else {   /// 半屏以后
            
            currentButton.transform = CGAffineTransformMakeScale(1.0 + scale, 1.0 + scale);
            
            if (currentIndex > 0){
                
                UIButton * frontButton = self.itemsButtonArray[currentIndex - 1];
                
                frontButton.transform = CGAffineTransformMakeScale(self.barItemStyle.titleBigScale - scale, self.barItemStyle.titleBigScale - scale);
                
            }
        }
    }
}
/// 改变标题的颜色渐变
- (void)changeTitleColorWithProgress:(CGFloat)progress{
    
    NSInteger currentIndex = self.selectedSegmentIndex;
    
    UIButton * currentButton = self.itemsButtonArray[currentIndex];
    
    if (progress - (int)progress < fastPercent){  //半屏以前
        
        [currentButton setTitleColor:[self gradientHighLightToNormal:progress - (int)progress] forState:UIControlStateNormal];
        
        if (currentIndex < self.itemsButtonArray.count - 1){
            
            UIButton *afterButton = self.itemsButtonArray[currentIndex + 1];
            [afterButton setTitleColor:[self gradientHighLightToNormal:1 - (progress - (int)progress)] forState:UIControlStateNormal];
            
        }
        
    }else {   /// 半屏以后
        
        [currentButton setTitleColor:[self gradientHighLightToNormal:1 - (progress - (int)progress)] forState:UIControlStateNormal];
        
        if (currentIndex > 0){
            
            UIButton * frontButton = self.itemsButtonArray[currentIndex - 1];
            
            [frontButton setTitleColor:[self gradientHighLightToNormal:progress - (int)progress] forState:UIControlStateNormal];
            
        }
    }
}

/// 改变线条滚动位置
- (void)changeMoveLineWithProgress:(CGFloat)progress{
    CGFloat startDistance = 0;
    CGFloat endDistance = 0;
    
    NSInteger currentIndex = self.selectedSegmentIndex;
    CGFloat lineWidth = [self wm_getScrollLineWidthWithIndex:currentIndex];
    UIButton *currentButton = self.itemsButtonArray[currentIndex];
    
    CGFloat x = 0.0;
    CGFloat y = self.moveLine.frame.origin.y;
    CGFloat width = 0.0;
    CGFloat height = self.moveLine.frame.size.height;
    
    //慢速滑行长度 0.5的偏移量滑完
    CGFloat slowDistace = lineWidth / 2.0;

    CGFloat tempProgress = progress - (int)progress;
    if (tempProgress < fastPercent) {
        
        if (currentIndex < self.distances.count){
            //快速滑行长度 0.5的偏移量滑完
            CGFloat fastDistace = self.distances[currentIndex].floatValue - lineWidth / 2.0;
            
            //右滑半屏以前
            //起始端
            startDistance = (tempProgress) / fastPercent*fastDistace;
            //终止端
            endDistance = tempProgress / (1-fastPercent)*slowDistace;
        }

    }else{
        
        if (currentIndex > 0){
            //快速滑行长度 0.5的偏移量滑完
            CGFloat fastDistace = self.distances[currentIndex - 1].floatValue - lineWidth / 2.0;
            
            //右滑半屏以后
            startDistance = fastDistace + (tempProgress-fastPercent)/(1-fastPercent)*slowDistace;
            endDistance = slowDistace + (tempProgress-(1-fastPercent))/fastPercent*fastDistace;
            
            currentButton = self.itemsButtonArray[currentIndex - 1];

        }
    }
    
    x = currentButton.center.x - lineWidth / 2.0 + endDistance;
    width = lineWidth + startDistance - endDistance;

    self.moveLine.frame = CGRectMake(x, y, width, height);
}

- (void)wm_adjustTitleOffSet:(NSInteger)toIndex{
    if (toIndex < self.itemsButtonArray.count){
     
        UIButton *toButton = self.itemsButtonArray[toIndex];
        CGFloat offX = CGRectGetMidX(toButton.frame) - self.scrollView.frame.size.width/2.0;
        if (offX <= 0){
            offX = 0;
        }
        if (offX >= self.scrollView.contentSize.width - self.scrollView.frame.size.width){
            offX = self.scrollView.contentSize.width - self.scrollView.frame.size.width;
        }
        [self.scrollView setContentOffset:CGPointMake(offX, 0) animated:YES];
    }
    
}

#pragma mark -- 获取按钮显示的文案
- (NSString *)titleWithColumn:(NSInteger)index{
    NSString * title;
    if ([self.delegate respondsToSelector:@selector(barItem:titleForItemAtIndex:)]){
        title = [self.delegate barItem:self titleForItemAtIndex:index];
    }
    return title;
}

/// 标题按钮点击事件
- (void)titleButtonClick:(UIButton *)button{
    if (!self.scrollAnimating){  /// 正在滚动pageViewScrollView不允许点击
        
        [self scrollToIndex:button.tag currentIndex:_selectedSegmentIndex animated:YES];
        
        if ([self.delegate respondsToSelector:@selector(barItem:didSelectIndex:)]){
            [self.delegate barItem:self didSelectIndex:button.tag];
        }
    }
}
/// 右边加号按钮点击
- (void)plusButtonAction:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(plusButtonClickAtBarItem:)]){
        [self.delegate plusButtonClickAtBarItem:self];
    }
}

- (void)scrollToIndex:(NSInteger)toIndex currentIndex:(NSInteger)currentIndex animated:(BOOL)animated{
    __weak typeof(self) weakself = self;
    self.selectedSegmentIndex = toIndex;
    
    UIButton *currentButton;
    UIButton *toButton;
    if (currentIndex < self.itemsButtonArray.count){
        currentButton = self.itemsButtonArray[currentIndex];
    }
    if (toIndex < self.itemsButtonArray.count){
        toButton = self.itemsButtonArray[toIndex];
    }
    
    CGFloat width = [self wm_getScrollLineWidthWithIndex:toIndex];
    CGFloat height = [self wm_getScrollLineHeight];
    
    if (animated){
        [UIView animateWithDuration:0.20 animations:^{
            
            weakself.moveLine.frame = CGRectMake(toButton.center.x -  width / 2, CGRectGetMaxY(weakself.scrollView.frame) - height, width , height);
            
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self wm_adjustTitleOffSet:toIndex];
            [currentButton setTitleColor:[self gradientHighLightToNormal:wm_titleColorType_normal] forState:UIControlStateNormal];
            [toButton setTitleColor:[self gradientHighLightToNormal:wm_titleColorType_HighLight] forState:UIControlStateNormal];
            if (self.barItemStyle.isScaleTitle){
                [UIView animateWithDuration:0.20 animations:^{
                    currentButton.transform =  CGAffineTransformMakeScale(1.0, 1.0);
                    toButton.transform = CGAffineTransformMakeScale(self.barItemStyle.titleBigScale, self.barItemStyle.titleBigScale);
                }];
            }
            
        }];
    }else {
        [self wm_adjustTitleOffSet:toIndex];
        weakself.moveLine.frame = CGRectMake(toButton.center.x -  width / 2, CGRectGetMaxY(weakself.scrollView.frame) - height, width , height);
        [currentButton setTitleColor:[self gradientHighLightToNormal:wm_titleColorType_normal] forState:UIControlStateNormal];
        [toButton setTitleColor:[self gradientHighLightToNormal:wm_titleColorType_HighLight] forState:UIControlStateNormal];
        if (self.barItemStyle.isScaleTitle){
            [UIView animateWithDuration:0.20 animations:^{
                currentButton.transform =  CGAffineTransformMakeScale(1.0, 1.0);
                toButton.transform = CGAffineTransformMakeScale(self.barItemStyle.titleBigScale, self.barItemStyle.titleBigScale);
            }];
        }
    }
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    __block CGFloat width = 0.0;
    __block CGFloat height = self.frame.size.height;
    
    __block CGFloat totleWidth = 0.0;
    NSInteger count = self.itemsButtonArray.count;
    
    NSMutableArray * linesArray = [NSMutableArray arrayWithCapacity:count];
    
    [self.itemsButtonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull columnButton, NSUInteger i, BOOL * _Nonnull stop) {
       
        NSString *title = columnButton.titleLabel.text;
        
        /// barItem  可能不是等分的  也有可能是时根据屏幕宽度等分  也有可能根据文案确定宽度
        if (self.barItemStyle.itemSizeStyle == wm_itemSizeStyle_equal_width){
            width = self.frame.size.width / count;
            
        }else {
            width = [self getSizeOfContent:title width:MAXFLOAT font:self.barItemStyle.titleFont].width + self.barItemStyle.titleMargin * 2;
            
        }
        if (self.barItemStyle.scrollLineWidth > 0){
            [linesArray addObject:@(self.barItemStyle.scrollLineWidth)];
        }else {
            if (self.barItemStyle.isScaleTitle){ /// 如果文案是可以放大的话就必须设置线条的宽度为文字放大后的宽度
                [linesArray addObject:@((width - self.barItemStyle.titleMargin * 2) * self.barItemStyle.titleBigScale)];
            }else {
                [linesArray addObject:@(width - self.barItemStyle.titleMargin * 2)];
            }
            
        }
        if (i == 0){  /// 第一个按钮的前面留出空白
            totleWidth += self.barItemStyle.titleMargin;
        }
        columnButton.frame = CGRectMake(totleWidth, 0, width, height);
        totleWidth += width;

    }];
    self.scrollLineWidths = linesArray;
    
    
    CGFloat maxContentWidth = totleWidth + self.barItemStyle.titleMargin;
    if (self.barItemStyle.isShowExtraButton){
        maxContentWidth += self.frame.size.height;
    }
    if (maxContentWidth <= self.frame.size.width){
        maxContentWidth = self.frame.size.width;
    }
    self.scrollView.contentSize = CGSizeMake(maxContentWidth, 0);
    
    
    self.scrollView.frame = self.bounds;
    
    if (_selectedSegmentIndex < self.itemsButtonArray.count){
        UIButton * button = self.itemsButtonArray[_selectedSegmentIndex];
        
        CGFloat scrollLineWidth = [self wm_getScrollLineWidthWithIndex:_selectedSegmentIndex];
        CGFloat scrollLineheight = [self wm_getScrollLineHeight];
        self.moveLine.frame = CGRectMake(button.center.x -  scrollLineWidth / 2 , CGRectGetMaxY(self.scrollView.frame) - scrollLineheight, scrollLineWidth , scrollLineheight);
        self.bottomLine.frame = CGRectMake(0, self.frame.size.height - self.barItemStyle.bottomLineHeight, self.frame.size.width, self.barItemStyle.bottomLineHeight);
        self.plusButton.frame = CGRectMake(self.frame.size.width - self.frame.size.height, 0, self.frame.size.height, self.frame.size.height - CGRectGetHeight(self.bottomLine.frame));
    }
}

#pragma mark -- getter and setter

- (CGFloat)wm_getScrollLineWidthWithIndex:(NSInteger)index{
    if (self.barItemStyle.scrollLineWidth > 0){
        return self.barItemStyle.scrollLineWidth;
    }else {
        if (index < self.scrollLineWidths.count){
            return [self.scrollLineWidths[index] floatValue];
        }
        return 20;
    }
}
- (CGFloat)wm_getScrollLineHeight{
    return self.barItemStyle.scrollLineHeight;
}

- (NSMutableArray *)distances{
    if (!_distances) {
        __weak typeof(self) weakself = self;
        _distances = [[NSMutableArray alloc] init];
        [self.itemsButtonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx < self.itemsButtonArray.count-1) {
                UIButton *button1 = obj;
                UIButton *button2 = weakself.itemsButtonArray[idx+1];
                CGFloat distance = CGRectGetMidX(button2.frame) - CGRectGetMidX(button1.frame);
                [weakself.distances addObject:@(distance)];
            }
        }];
    }
    return _distances;
}

- (UIView *)moveLine{
    if (!_moveLine) {
        _moveLine = [[UIView alloc] init];
    }
    return _moveLine;
}
- (UILabel *)bottomLine{
    if (_bottomLine == nil){
        
        _bottomLine = [UILabel new];
        
    }
    return _bottomLine;
}
- (UIButton *)plusButton {
    if (!_plusButton) {
        _plusButton = [[UIButton alloc] init];
        [_plusButton setImage:[UIImage imageNamedFromMyBundle:@"add_channel_titlbar_thin_new_16x16_"] forState:UIControlStateNormal];
        _plusButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        _plusButton.layer.shadowColor = [UIColor grayColor].CGColor;
        _plusButton.layer.shadowOffset = CGSizeMake(-1, 0);
        _plusButton.layer.shadowRadius = 1;
        _plusButton.layer.shadowOpacity = 0.1;
        _plusButton.layer.shouldRasterize = YES;
        _plusButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [_plusButton addTarget:self action:@selector(plusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _plusButton;
}

- (UIScrollView *)scrollView{
    if (_scrollView == nil){
        
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        
    }
    return _scrollView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end


