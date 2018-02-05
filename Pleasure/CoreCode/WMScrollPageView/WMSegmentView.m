//
//  WMSegmentView.m
//  WMScrollPageView
//
//  Created by Sper on 2018/1/20.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMSegmentView.h"
#import "WMScrollPageView.h"

@interface UIImage (WMMyBundle)
+ (UIImage *)wm_imageNamedFromMyBundle:(NSString *)name;
@end

@implementation UIImage (WMMyBundle)
+ (UIImage *)wm_imageNamedFromMyBundle:(NSString *)name {
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

@interface WMSegmentView()<UIScrollViewDelegate>
@property (nonatomic , strong) UIScrollView *scrollerView;
@property (nonatomic , strong) UIView *moveLine;
@property (nonatomic , strong) UIView *bottomLine;
@property (nonatomic , strong) UIButton *plusButton;
@property (nonatomic , strong) WMSegmentStyle *segmentStyle;
@property (nonatomic , strong) NSMutableArray<UIButton *> *itemsArray;
/// 存储默认颜色rgb个高亮下的rgb值
@property (nonatomic , strong) NSMutableArray <NSNumber *> *highLightColors;
@property (nonatomic , strong) NSMutableArray <NSNumber *> *defaultColors;
/// 存储两个相邻标签的距离
@property (nonatomic , strong) NSMutableArray<NSNumber *> *distances;
// 缓存计算出来的每个标题下面线条的宽度
@property (nonatomic , strong) NSArray *scrollLineWidths;
/// 当前选中的item
@property (nonatomic , assign) NSInteger selectedSegmentIndex;
/// 正在手势滚动 不允许点击
@property (nonatomic , assign) BOOL scrollAnimating;

- (WMSegmentStyle *)wm_getSegmentStyle;
- (void)wm_configSegmentItems;
- (NSInteger)wm_numberOfCountItems;
- (NSString *)wm_titleOfButtonAtIndex:(NSInteger)index;
- (void)wm_didSelectItemButton:(UIButton *)button;
- (void)wm_plusButtonAction:(UIButton *)button;
- (UIColor *)wm_normalTitleColor;
- (UIColor *)wm_highLightTitleColor;
- (UIFont *)wm_titleFont;
- (void)wm_configViewStyle;
- (void)wm_configDefault;
- (NSArray *)wm_setRGBColors:(UIColor *)color;
- (CGSize)wm_getSizeOfContent:(NSString *)str width:(CGFloat)width font:(UIFont *)font;
- (UIColor *)gradientHighLightToNormal:(CGFloat)percent;
- (CGFloat)wm_getScrollLineWidthWithIndex:(NSInteger)index;
- (void)wm_adjustTitleOffSet:(NSInteger)toIndex;
- (void)wm_changeTitleBigSmallWithProgress:(CGFloat)progress;
- (void)wm_changeTitleColorWithProgress:(CGFloat)progress;
- (void)wm_changeMoveLineWithProgress:(CGFloat)progress;
/// 滑动切换标题
- (void)wm_scrollToIndex:(NSInteger)toIndex currentIndex:(NSInteger)currentIndex;
@end

@implementation WMSegmentView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.scrollerView];
        /// 显示底部滚动线条
        [self.scrollerView addSubview:self.moveLine];
        /// 显示底部分割线条
        [self addSubview:self.bottomLine];
        /// 是否显示右边添加按钮
        [self addSubview:self.plusButton];
    }
    return self;
}
#pragma mark -- public method
- (void)wm_reloadSegmentView{
    [self setDelegate:self.delegate];
}
- (void)setDelegate:(id<WMSegmentViewDelegate>)delegate{
    _delegate = delegate;
    [self wm_configSegmentItems];
    [self wm_configViewStyle];
    [self wm_configDefault];
}
- (void)wm_scrollViewDidEndDecelerating{
    self.scrollAnimating = NO;
    /// 更新滚动视图位置
    [self wm_adjustTitleOffSet:_selectedSegmentIndex];
}
- (void)adjustUIWithProgress:(CGFloat)progress currentIndex:(NSInteger)currentIndex{
    self.scrollAnimating = YES;
    _selectedSegmentIndex = currentIndex;
    
    [self wm_changeTitleBigSmallWithProgress:progress];
    [self wm_changeTitleColorWithProgress:progress];
    [self wm_changeMoveLineWithProgress:progress];
}

#pragma mark -- private method
- (void)wm_configSegmentItems{
    [self.itemsArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.superview){
            [obj removeFromSuperview];
        }
    }];
    [self.itemsArray removeAllObjects];
    NSInteger count = [self wm_numberOfCountItems];
    for (int i = 0 ; i < count ; i++){
        NSString *title = [self wm_titleOfButtonAtIndex:i];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
        button.tag = i;
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[self wm_normalTitleColor] forState:UIControlStateNormal];
        button.titleLabel.font = [self wm_titleFont];
        [button addTarget:self action:@selector(wm_didSelectItemButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.itemsArray addObject:button];
        [self.scrollerView addSubview:button];
    }
    [self setNeedsLayout];
}
- (WMSegmentStyle *)wm_getSegmentStyle{
    WMSegmentStyle *style;
    if ([self.delegate respondsToSelector:@selector(segmentStyleAtSegmentView:)]){
        style = [self.delegate segmentStyleAtSegmentView:self];
    }
    if (style == nil){
        style = [[WMSegmentStyle alloc] init];
    }
    return style;
}
- (NSInteger)wm_numberOfCountItems{
    NSInteger count = 0;
    if ([self.delegate respondsToSelector:@selector(numberOfCountAtSegmentView:)]){
        count = [self.delegate numberOfCountAtSegmentView:self];
    }
    return count;
}
- (NSString *)wm_titleOfButtonAtIndex:(NSInteger)index{
    NSString *title;
    if ([self.delegate respondsToSelector:@selector(segmentView:titleForItemAtIndex:)]){
        title = [self.delegate segmentView:self titleForItemAtIndex:index];
    }
    return title;
}
- (void)wm_didSelectItemButton:(UIButton *)button{
    NSInteger index = button.tag;
    [self wm_didSelectItemAtIndex:index];
}
- (void)wm_didSelectItemAtIndex:(NSInteger)index{
    if (self.scrollAnimating) return;
    /// 切换标题
    [self wm_scrollToIndex:index currentIndex:_selectedSegmentIndex];
    if ([self.delegate respondsToSelector:@selector(segmentView:didSelectIndex:)]){
        [self.delegate segmentView:self didSelectIndex:index];
    }
}
- (void)wm_plusButtonAction:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(plusButtonClickAtBarItem:)]){
        [self.delegate plusButtonClickAtBarItem:self];
    }
}
- (CGFloat)wm_getScrollLineWidthWithIndex:(NSInteger)index{
    if (index < self.scrollLineWidths.count){
        return [self.scrollLineWidths[index] floatValue];
    }
    return 20;
}
#pragma mark -- style setting
- (UIColor *)wm_normalTitleColor{
    return self.segmentStyle.normalTitleColor;
}
- (UIColor *)wm_highLightTitleColor{
    return self.segmentStyle.selectedTitleColor;
}
- (UIFont *)wm_titleFont{
    return self.segmentStyle.titleFont;
}
- (void)wm_configViewStyle{
    self.moveLine.hidden = !self.segmentStyle.isShowMoveLine;
    self.moveLine.backgroundColor = self.segmentStyle.scrollLineColor;
    self.bottomLine.hidden = !self.segmentStyle.isAllowShowBottomLine;
    self.bottomLine.backgroundColor = self.segmentStyle.bottomLineColor;
    self.plusButton.hidden = !self.segmentStyle.isShowExtraButton;
}
- (void)wm_configDefault{
    _selectedSegmentIndex = 0;
    if ([self.delegate respondsToSelector:@selector(defaultSelectedIndexAtSegmentView:)]){
        _selectedSegmentIndex = [self.delegate defaultSelectedIndexAtSegmentView:self];
    }
    /// 初始化切换标题
    [self wm_didSelectItemAtIndex:_selectedSegmentIndex];
}
- (void)wm_scrollToIndex:(NSInteger)toIndex currentIndex:(NSInteger)currentIndex{
    self.selectedSegmentIndex = toIndex;
    UIButton *currentButton;
    UIButton *toButton;
    if (currentIndex < self.itemsArray.count){
        currentButton = self.itemsArray[currentIndex];
    }
    if (toIndex < self.itemsArray.count){
        toButton = self.itemsArray[toIndex];
    }
    CGFloat width = [self wm_getScrollLineWidthWithIndex:toIndex];
    CGFloat height = self.segmentStyle.scrollLineHeight;
    [self wm_adjustTitleOffSet:toIndex];
    if (self.segmentStyle.isShowMoveLine){
        self.moveLine.frame = CGRectMake(toButton.center.x -  width / 2, CGRectGetMaxY(self.scrollerView.frame) - height, width , height);
    }
    if (self.segmentStyle.isChangeTitleColor){
        [currentButton setTitleColor:[self gradientHighLightToNormal:wm_titleColorType_normal] forState:UIControlStateNormal];
        [toButton setTitleColor:[self gradientHighLightToNormal:wm_titleColorType_HighLight] forState:UIControlStateNormal];
    }
    if (self.segmentStyle.isScaleTitle){
        [UIView animateWithDuration:0.20 animations:^{
            currentButton.transform =  CGAffineTransformMakeScale(1.0, 1.0);
            toButton.transform = CGAffineTransformMakeScale(self.segmentStyle.titleBigScale, self.segmentStyle.titleBigScale);
        }];
    }
}
#pragma mark -- Utils
- (NSArray *)wm_setRGBColors:(UIColor *)color{
    NSMutableArray * array = [NSMutableArray array];
    CGFloat R = 1.0, G = 1.0, B = 1.0;
    NSInteger numComponents = CGColorGetNumberOfComponents([color CGColor]);
    if (numComponents == 4){
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
- (void)wm_adjustTitleOffSet:(NSInteger)toIndex{
    if (toIndex < self.itemsArray.count){
        UIButton *toButton = self.itemsArray[toIndex];
        CGFloat offX = CGRectGetMidX(toButton.frame) - self.scrollerView.frame.size.width/2.0;
        if (offX <= 0){
            offX = 0;
        }
        if (offX >= self.scrollerView.contentSize.width - self.scrollerView.frame.size.width){
            offX = self.scrollerView.contentSize.width - self.scrollerView.frame.size.width;
        }
        [self.scrollerView setContentOffset:CGPointMake(offX, 0) animated:YES];
    }
}
// 缩放, 设置初始的label的放大
- (void)wm_changeTitleBigSmallWithProgress:(CGFloat)progress{
    if (self.segmentStyle.isScaleTitle == NO) return;
    NSArray<UIButton *> *buttonArray = self.itemsArray;
    NSInteger buttonCount = buttonArray.count;
    NSInteger currentIndex = self.selectedSegmentIndex;
    CGFloat titleBigScale = self.segmentStyle.titleBigScale;
    UIButton * currentButton = buttonArray[currentIndex];
    CGFloat tempProgress = progress - (int)progress;
    CGFloat scale = tempProgress * (titleBigScale - 1.0);
    if (tempProgress < fastPercent){  //半屏以前
        currentButton.transform = CGAffineTransformMakeScale(titleBigScale - scale, titleBigScale - scale);
        if (currentIndex < buttonCount - 1){
            UIButton *afterButton = buttonArray[currentIndex + 1];
            afterButton.transform = CGAffineTransformMakeScale(1.0 + scale, 1.0 + scale);
        }
    }else {   /// 半屏以后
        currentButton.transform = CGAffineTransformMakeScale(1.0 + scale, 1.0 + scale);
        if (currentIndex > 0){
            UIButton * frontButton = buttonArray[currentIndex - 1];
            frontButton.transform = CGAffineTransformMakeScale(titleBigScale - scale, titleBigScale - scale);
        }
    }
}
/// 设置标题颜色渐变
- (void)wm_changeTitleColorWithProgress:(CGFloat)progress{
    if (self.segmentStyle.isChangeTitleColor == NO) return;
    NSInteger currentIndex = self.selectedSegmentIndex;
    NSArray<UIButton *> *buttonArray = self.itemsArray;
    UIButton * currentButton = buttonArray[currentIndex];
    NSInteger buttonCount = buttonArray.count;
    CGFloat tempProgress = progress - (int)progress;
    if (progress - (int)progress < fastPercent){  //半屏以前
        [currentButton setTitleColor:[self gradientHighLightToNormal:tempProgress] forState:UIControlStateNormal];
        if (currentIndex < buttonCount - 1){
            UIButton *afterButton = buttonArray[currentIndex + 1];
            [afterButton setTitleColor:[self gradientHighLightToNormal:1 - tempProgress] forState:UIControlStateNormal];
        }
    }else {   /// 半屏以后
        [currentButton setTitleColor:[self gradientHighLightToNormal:1 - tempProgress] forState:UIControlStateNormal];
        if (currentIndex > 0){
            UIButton * frontButton = buttonArray[currentIndex - 1];
            [frontButton setTitleColor:[self gradientHighLightToNormal:tempProgress] forState:UIControlStateNormal];
        }
    }
}
/// 设置底部滚动视图滚动距离
- (void)wm_changeMoveLineWithProgress:(CGFloat)progress{
    if (self.segmentStyle.isShowMoveLine == NO) return;
    CGFloat startDistance = 0;
    CGFloat endDistance = 0;

    NSInteger currentIndex = self.selectedSegmentIndex;
    CGFloat lineWidth = [self wm_getScrollLineWidthWithIndex:currentIndex];
    UIButton *currentButton = self.itemsArray[currentIndex];

    CGFloat x = 0.0;
    CGFloat y = self.moveLine.frame.origin.y;
    CGFloat width = 0.0;
    CGFloat height = self.moveLine.frame.size.height;

    //慢速滑行长度 0.5的偏移量滑完
    CGFloat slowDistace = lineWidth / 2.0;
    CGFloat tempProgress = progress - (int)progress;
    if (tempProgress < fastPercent) { //右滑半屏以前
        if (currentIndex < self.distances.count){
            //快速滑行长度 0.5的偏移量滑完
            CGFloat fastDistace = self.distances[currentIndex].floatValue - lineWidth / 2.0;
            //起始端
            startDistance = (tempProgress) / fastPercent*fastDistace;
            //终止端
            endDistance = tempProgress / (1-fastPercent)*slowDistace;
        }
    }else{ //右滑半屏以后
        if (currentIndex > 0){
            //快速滑行长度 0.5的偏移量滑完
            CGFloat fastDistace = self.distances[currentIndex - 1].floatValue - lineWidth / 2.0;
            startDistance = fastDistace + (tempProgress-fastPercent)/(1-fastPercent)*slowDistace;
            endDistance = slowDistace + (tempProgress-(1-fastPercent))/fastPercent*fastDistace;
            currentButton = self.itemsArray[currentIndex - 1];
        }
    }
    x = currentButton.center.x - lineWidth / 2.0 + endDistance;
    width = lineWidth + startDistance - endDistance;
    self.moveLine.frame = CGRectMake(x, y, width, height);
}
/// 根据文本获取宽度
- (CGSize)wm_getSizeOfContent:(NSString *)str width:(CGFloat)width font:(UIFont *)font{
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
#pragma mark -- getter and setter
- (UIScrollView *)scrollerView{
    if (_scrollerView == nil){
        _scrollerView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollerView.showsVerticalScrollIndicator = NO;
        _scrollerView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollerView;
}
- (UIView *)moveLine{
    if (!_moveLine) {
        _moveLine = [[UIView alloc] init];
        _moveLine.hidden = YES;
    }
    return _moveLine;
}
- (UIView *)bottomLine{
    if (_bottomLine == nil){
        _bottomLine = [UIView new];
        _bottomLine.hidden = YES;
    }
    return _bottomLine;
}
- (UIButton *)plusButton {
    if (!_plusButton) {
        _plusButton = [[UIButton alloc] init];
        _plusButton.hidden = YES;
        [_plusButton setImage:[UIImage wm_imageNamedFromMyBundle:@"add_channel_titlbar_thin_new_16x16_"] forState:UIControlStateNormal];
        _plusButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        _plusButton.layer.shadowColor = [UIColor grayColor].CGColor;
        _plusButton.layer.shadowOffset = CGSizeMake(-1, 0);
        _plusButton.layer.shadowRadius = 1;
        _plusButton.layer.shadowOpacity = 0.1;
        _plusButton.layer.shouldRasterize = YES;
        _plusButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [_plusButton addTarget:self action:@selector(wm_plusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _plusButton;
}
- (WMSegmentStyle *)segmentStyle{
    if (_segmentStyle == nil){
        _segmentStyle = [self wm_getSegmentStyle];
    }
    return _segmentStyle;
}
- (NSMutableArray<UIButton *> *)itemsArray{
    if (_itemsArray == nil){
        _itemsArray = [NSMutableArray array];
    }
    return _itemsArray;
}
- (NSMutableArray<NSNumber *> *)defaultColors{
    if(_defaultColors == nil){
        _defaultColors = [NSMutableArray array];
        [_defaultColors setArray:[self wm_setRGBColors:self.segmentStyle.normalTitleColor]];
    }
    return _defaultColors;
}
- (NSMutableArray<NSNumber *> *)highLightColors{
    if (_highLightColors == nil){
        _highLightColors = [NSMutableArray array];
        [_highLightColors setArray:[self wm_setRGBColors:self.segmentStyle.selectedTitleColor]];
    }
    return _highLightColors;
}
- (NSMutableArray *)distances{
    if (!_distances) {
        __weak typeof(self) weakself = self;
        _distances = [[NSMutableArray alloc] init];
        [self.itemsArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx < self.itemsArray.count - 1) {
                UIButton *button1 = obj;
                UIButton *button2 = weakself.itemsArray[idx+1];
                CGFloat distance = CGRectGetMidX(button2.frame) - CGRectGetMidX(button1.frame);
                [weakself.distances addObject:@(distance)];
            }
        }];
    }
    return _distances;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat selfHeight = self.frame.size.height;
    CGFloat selfWidth = self.frame.size.width;
    __block CGFloat itemWidth = 0.0;
    __block CGFloat totleWidth = 0.0;
    NSInteger count = self.itemsArray.count;
    CGFloat titleMargin = self.segmentStyle.titleMargin;
    NSMutableArray * linesArray = [NSMutableArray arrayWithCapacity:count];
    [self.itemsArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull columnButton, NSUInteger i, BOOL * _Nonnull stop) {
        NSString *title = columnButton.titleLabel.text;
        UIFont *titleFont = columnButton.titleLabel.font;
        CGFloat titleBigScale = self.segmentStyle.titleBigScale;
        
        /// 可能不是等分的  也有可能是时根据屏幕宽度等分  也有可能根据文案确定宽度
        if (self.segmentStyle.itemSizeStyle == wm_itemSizeStyle_equal_textSize){
            itemWidth = [self wm_getSizeOfContent:title width:MAXFLOAT font:titleFont].width + titleMargin * 2;
        }else {
            itemWidth = self.frame.size.width / count;
        }
        if (self.segmentStyle.scrollLineWidth > 0){
            [linesArray addObject:@(self.segmentStyle.scrollLineWidth)];
        }else {
            /// 如果文案是可以放大的话就必须设置线条的宽度为文字放大后的宽度
            CGFloat scale = 1.0;
            if (self.segmentStyle.isScaleTitle){
                scale = titleBigScale;
            }
            if (self.segmentStyle.scrollLineWidthStyle == wm_scrollLineWidthStyle_equal_item){
                [linesArray addObject:@((itemWidth - titleMargin * 2) * scale)];
            }else {
                [linesArray addObject:@([self wm_getSizeOfContent:title width:MAXFLOAT font:titleFont].width * scale)];
            }
        }
        columnButton.frame = CGRectMake(totleWidth, 0, itemWidth, selfHeight);
        totleWidth += itemWidth;
    }];
    self.scrollLineWidths = linesArray;
    
    /// 设置滚动标题的最大滚动区域
    CGFloat maxContentWidth = totleWidth;
    if (self.segmentStyle.isShowExtraButton){
        maxContentWidth += self.frame.size.height;
    }
    if (maxContentWidth <= self.frame.size.width){
        maxContentWidth = self.frame.size.width;
    }
    self.scrollerView.contentSize = CGSizeMake(maxContentWidth, 0);
    self.scrollerView.frame = self.bounds;

    /// 默认选中样式
    if (_selectedSegmentIndex < self.itemsArray.count){
        UIButton * button = self.itemsArray[_selectedSegmentIndex];
        CGFloat scrollLineWidth = [self wm_getScrollLineWidthWithIndex:_selectedSegmentIndex];
        CGFloat scrollLineheight = self.segmentStyle.scrollLineHeight;
        CGFloat bottomLineHeight = self.segmentStyle.bottomLineHeight;
        self.moveLine.frame = CGRectMake(button.center.x -  scrollLineWidth / 2 , CGRectGetMaxY(self.scrollerView.frame) - scrollLineheight, scrollLineWidth , scrollLineheight);
        self.bottomLine.frame = CGRectMake(0, selfHeight - bottomLineHeight, selfWidth, bottomLineHeight);
        self.plusButton.frame = CGRectMake(selfWidth - selfHeight, 0, selfHeight, selfHeight - CGRectGetHeight(self.bottomLine.frame));
    }
}

@end
