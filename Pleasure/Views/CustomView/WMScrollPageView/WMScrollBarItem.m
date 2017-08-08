//
//  WMScrollBarItem.m
//  AllDemo
//
//  Created by Sper on 2017/7/28.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMScrollBarItem.h"

#define fastPercent 0.5

typedef NS_ENUM(NSInteger , wm_titleColorType) {
    wm_titleColorType_HighLight = 0,   /// 高亮颜色
    wm_titleColorType_normal   /// 正常颜色
};

@interface WMScrollBarItem()<UIScrollViewDelegate>

@property (nonatomic , strong) UIScrollView * scrollView;

@property (nonatomic , strong) WMScrollBarItemStyle *barItemStyle;

@property (nonatomic , strong) NSMutableArray<UIButton *> *itemsButtonArray;

/// 线条视图
@property (nonatomic , strong) UIView * moveLine;

@property (nonatomic , strong) UILabel *bottomLine;

/// 当前选中的item
@property (nonatomic , assign) NSInteger selectedSegmentIndex;

//R/G/B   1 1 1 1;
@property (nonatomic, strong) NSArray <NSNumber *> *highLightColors;
@property (nonatomic, strong) NSArray <NSNumber *> *defaultColors;

/// 存储两个相邻标签的距离
@property (nonatomic, strong) NSMutableArray<NSNumber *> *distances;

@end

@implementation WMScrollBarItem

- (void)layoutSubviews{
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
}

- (void)wm_configBarItemsWithCount:(NSInteger)count barItemStyle:(WMScrollBarItemStyle *)barItemStyle{
    NSAssert(barItemStyle, @"不可以为空");
    
    _barItemStyle = barItemStyle;
    
    NSAssert(count >= 0, @"创建的 batItem 的个数不能是负数");
    
    [self.itemsButtonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.superview){
            [obj removeFromSuperview];
            obj = nil;
        }
    }];
    
    [self.itemsButtonArray removeAllObjects];
    
    CGFloat width = 0.0;
    CGFloat height = self.frame.size.height;
    
    CGFloat totleWidth = 0.0;
    for (int i = 0 ; i < count ; i++){
        
        /// barItem  可能不是等分的  也有可能是时根据屏幕宽度等分  也有可能根据文案确定宽度
        NSString *title = [self titleWithColumn:i];
        
        if (self.barItemStyle.itemSizeStyle == wm_itemSizeStyle_equal_width){
            width = self.frame.size.width / count;
            
        }else {
            width = [self getSizeOfContent:title width:MAXFLOAT font:self.barItemStyle.titleFont].width + 20;
            
        }
        UIButton * columnButton = [[UIButton alloc] initWithFrame:CGRectMake(totleWidth, 0, width, height)];
        
        totleWidth += width;
        
        
        [columnButton setTitleColor:self.barItemStyle.normalTitleColor forState:UIControlStateNormal];
        
        columnButton.tag = i;
        [columnButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        columnButton.titleLabel.font = self.barItemStyle.titleFont;
        [self.itemsButtonArray addObject:columnButton];
        [self.scrollView addSubview:columnButton];
        
        
        /// 设置存储rgb颜色的数组
        self.defaultColors = [self setDefaultRGBColors:self.barItemStyle.normalTitleColor];
        self.highLightColors = [self setDefaultRGBColors:self.barItemStyle.selectedTitleColor];
        
        
        /// 这一句必须放到最后。因为需要回调返回数据去更改标题颜色
        [columnButton setTitle:title forState:UIControlStateNormal];
    }
    self.scrollView.contentSize = CGSizeMake(totleWidth, 0);
    [self wm_configUI];
    
}

- (void)wm_configUI{
    
    [self addSubview:self.scrollView];
    //添加滚动条
    [self.scrollView addSubview:self.moveLine];
    
    UIButton * button = self.itemsButtonArray[_selectedSegmentIndex];


    CGFloat width = self.barItemStyle.scrollLineWidth;
    CGFloat height = self.barItemStyle.scrollLineHeight;
    
    self.moveLine.backgroundColor = self.barItemStyle.scrollLineColor;
    self.moveLine.frame = CGRectMake(button.center.x -  width / 2 , CGRectGetMaxY(self.scrollView.frame) - height, width , height);
    
    if (self.barItemStyle.allowShowBottomLine){
    
        self.bottomLine.backgroundColor = self.barItemStyle.bottomLineColor;
        self.bottomLine.frame = CGRectMake(0, self.barItemStyle.segmentHeight - self.barItemStyle.bottomLineHeight, self.frame.size.width, self.barItemStyle.bottomLineHeight);
        
        [self addSubview:self.bottomLine];
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

- (void)adjustUIWithProgress:(CGFloat)progress currentIndex:(NSInteger)currentIndex{
    
    _selectedSegmentIndex = currentIndex;
    
    self.scrollAnimating = YES;
    
//    NSLog(@"progress -------------  %f  currentIndex ---------- %ld \n" ,progress, currentIndex);
    
    if (currentIndex == 0 && progress <= 0) {
        return;
    }
    if (currentIndex == self.itemsButtonArray.count - 1 && progress >= 0) {
        return;
    }
    
    if (progress >= 1){
        progress = 1;
    }else if(progress <= -1){
        progress = -1;
    }
    
    [self changeTitleColorWithProgress:progress];
    
    [self changeMoveLineWithProgress:progress];
    
}

/// 改变标题的颜色渐变
- (void)changeTitleColorWithProgress:(CGFloat)progress{
    
    NSInteger currentIndex = self.selectedSegmentIndex;
    
    UIButton * currentButton = self.itemsButtonArray[currentIndex];
    
    [currentButton setTitleColor:[self gradientHighLightToNormal:progress] forState:UIControlStateNormal];
    
    if (progress < 0) {  //调整当前和左侧文字颜色
        
        if (currentIndex > 0){
            
            UIButton * frontButton = self.itemsButtonArray[currentIndex - 1];
            
            [frontButton setTitleColor:[self gradientHighLightToNormal:1.0 + progress] forState:UIControlStateNormal];
            
            
        }
        
    }else  {  // 调整当前和右侧文字颜色
        
        if (currentIndex < self.itemsButtonArray.count - 1){
            
            UIButton *afterButton = self.itemsButtonArray[currentIndex + 1];
            
            [afterButton setTitleColor:[self gradientHighLightToNormal:1.0 - progress] forState:UIControlStateNormal];
            
            
        }
    }
}

/// 改变底部线条的移动位置和宽度
- (void)changeMoveLineWithProgress:(CGFloat)progress{
    CGFloat startDistance = 0;
    CGFloat endDistance = 0;
    
    CGFloat lineWidth = self.barItemStyle.scrollLineWidth;
    
    NSInteger currentIndex = self.selectedSegmentIndex;
    
    UIButton *currentButton = self.itemsButtonArray[currentIndex];
    
    CGFloat x = 0.0;
    CGFloat y = self.moveLine.frame.origin.y;
    CGFloat width = 0.0;
    CGFloat height = self.moveLine.frame.size.height;
    
    if (progress > 0){  /// 向右滑动
        if (currentIndex >= self.distances.count){
            return;
        }
        //快速滑行长度 0.5的偏移量滑完
        CGFloat fastDistace = self.distances[currentIndex].floatValue - lineWidth / 2.0;
        //慢速滑行长度 0.5的偏移量滑完
        CGFloat slowDistace = lineWidth / 2.0;
        
        if (progress < fastPercent) {
            //右滑半屏以前
            //起始端
            startDistance = (progress) / fastPercent*fastDistace;
            //终止端
            endDistance = progress / (1-fastPercent)*slowDistace;
        }
        else{
            //右滑半屏以后
            startDistance = fastDistace + (progress-fastPercent)/(1-fastPercent)*slowDistace;
            endDistance = slowDistace + (progress-(1-fastPercent))/fastPercent*fastDistace;
        }
        
        
        x = currentButton.center.x - lineWidth / 2.0 + endDistance;
        width = currentButton.center.x + lineWidth / 2.0  + startDistance - x;
        

    }else {   /// 向左滑动
        if (currentIndex < 1){
            return;
        }
        //快速滑行长度 0.8的偏移量滑完
        CGFloat fastDistace = self.distances[currentIndex - 1].floatValue - lineWidth / 2.0;
        //慢速滑行长度 0.2的偏移量滑完
        CGFloat slowDistace = lineWidth / 2.0;
        if (progress > -fastPercent) {
            //左滑半屏以前
            startDistance = (progress)/fastPercent*fastDistace;
            endDistance = progress/(1-fastPercent)*slowDistace;
        }
        else{
            //左滑半屏以后
            startDistance = -fastDistace + (progress+fastPercent)/(1-fastPercent)*slowDistace;
            endDistance = -slowDistace + (progress+(1-fastPercent))/fastPercent*fastDistace;
        }
        
        
        x = currentButton.center.x - lineWidth / 2.0 + startDistance;
        width = currentButton.center.x + lineWidth / 2.0 + endDistance - x;
    }
    
    self.moveLine.frame = CGRectMake(x, y, width, height);
    
    /// 更新滚动视图位置
    [self wm_adjustTitleOffSet:self.selectedSegmentIndex];
    
//    NSLog(@"startDistance  ====   %f  endDistance  ====   %f \n",  startDistance , endDistance );
}
- (void)wm_adjustTitleOffSet:(NSInteger)toIndex{
    if (toIndex < self.itemsButtonArray.count){
     
        UIButton *toButton = self.itemsButtonArray[toIndex];
        CGFloat offX = CGRectGetMidX(toButton.frame) - self.frame.size.width/2.0;
        if (offX <= 0){
            offX = 0;
        }
        if (offX >= self.scrollView.contentSize.width - self.frame.size.width){
            offX = self.scrollView.contentSize.width - self.frame.size.width;
        }
        [self.scrollView setContentOffset:CGPointMake(offX, 0) animated:YES];
    }
    
}

/// 0.0 -- 1.0  或 -0.0 -- -1.0   数字越小越偏向高亮颜色   数值越大越偏向原本颜色
- (UIColor *)gradientHighLightToNormal:(CGFloat)percent{
    CGFloat r = self.defaultColors[0].floatValue + (1-ABS(percent))*(self.highLightColors[0].floatValue-self.defaultColors[0].floatValue);
    CGFloat g = self.defaultColors[1].floatValue + (1-ABS(percent))*(self.highLightColors[1].floatValue-self.defaultColors[1].floatValue);
    CGFloat b = self.defaultColors[2].floatValue + (1-ABS(percent))*(self.highLightColors[2].floatValue-self.defaultColors[2].floatValue);
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

#pragma mark -- 获取按钮显示的文案
- (NSString *)titleWithColumn:(NSInteger)index{
    NSString * title;
    if ([self.delegate respondsToSelector:@selector(barItem:titleForItemAtIndex:)]){
        title = [self.delegate barItem:self titleForItemAtIndex:index];
    }
    return title;
}

- (void)btnClick:(UIButton *)button{
    if (!self.scrollAnimating){  /// 正在滚动pageViewScrollView不允许点击
        
        [self scrollToIndex:button.tag currentIndex:_selectedSegmentIndex animated:YES];
        
        if ([self.delegate respondsToSelector:@selector(barItem:didSelectIndex:)]){
            [self.delegate barItem:self didSelectIndex:button.tag];
        }
    }
}

- (void)scrollToIndex:(NSInteger)toIndex currentIndex:(NSInteger)currentIndex animated:(BOOL)animated{
    __weak typeof(self) weakself = self;
    self.selectedSegmentIndex = toIndex;
    
    UIButton *toButton = self.itemsButtonArray[toIndex];
    UIButton *currentButton = self.itemsButtonArray[currentIndex];

    CGFloat width = self.barItemStyle.scrollLineWidth;
    CGFloat height = self.barItemStyle.scrollLineHeight;
    
    if (animated){
        [UIView animateWithDuration:0.20 animations:^{
            
            weakself.moveLine.frame = CGRectMake(toButton.center.x -  width / 2, CGRectGetMaxY(weakself.scrollView.frame) - height, width , height);
            
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            
            [self wm_adjustTitleOffSet:toIndex];
            [currentButton setTitleColor:[self gradientHighLightToNormal:wm_titleColorType_normal] forState:UIControlStateNormal];
            [toButton setTitleColor:[self gradientHighLightToNormal:wm_titleColorType_HighLight] forState:UIControlStateNormal];
        }];
    }else {

        [self wm_adjustTitleOffSet:toIndex];
        weakself.moveLine.frame = CGRectMake(toButton.center.x -  width / 2, CGRectGetMaxY(weakself.scrollView.frame) - height, width , height);
        [currentButton setTitleColor:[self gradientHighLightToNormal:wm_titleColorType_normal] forState:UIControlStateNormal];
        [toButton setTitleColor:[self gradientHighLightToNormal:wm_titleColorType_HighLight] forState:UIControlStateNormal];
    }
    
}

#pragma mark -- getter and setter 
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

- (UIScrollView *)scrollView{
    if (_scrollView == nil){
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        
    }
    return _scrollView;
}
- (NSMutableArray<UIButton *> *)itemsButtonArray{
    if (_itemsButtonArray == nil){
        _itemsButtonArray = [NSMutableArray array];
        
        
    }
    return _itemsButtonArray;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end


