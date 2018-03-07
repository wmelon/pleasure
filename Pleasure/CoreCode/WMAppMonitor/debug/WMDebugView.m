//
//  WMDebugView.m
//  Pleasure
//
//  Created by Sper on 2018/3/6.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMDebugView.h"
#import "WMCpuMonitor.h"
#import "WMMemoryMonitor.h"
#import "WMFpsMonitor.h"

@interface WMTextLabel : UILabel
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@end
@implementation WMTextLabel
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        self.edgeInsets = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
    }
    return self;
}
- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}
//- (CGSize)intrinsicContentSize {
//    CGSize size = [super intrinsicContentSize];
//    size.width += self.edgeInsets.left + self.edgeInsets.right;
//    size.height += self.edgeInsets.top + self.edgeInsets.bottom;
//    return size;
//}
//
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize sizeThatFits = [super sizeThatFits:size];
    sizeThatFits.width += self.edgeInsets.left + self.edgeInsets.right;
    sizeThatFits.height += self.edgeInsets.top + self.edgeInsets.bottom;
    return sizeThatFits;
}
@end

static WMDebugView *debugView;
@interface WMDebugView()
/// 显示监控数据的文本
@property (nonatomic, strong) WMTextLabel *monitoringTextLabel;
@property (nonatomic, assign) double cpuUsage;
@property (nonatomic, assign) double memoryUsage;
@property (nonatomic, assign) int fpsUsage;
@end
@implementation WMDebugView

+ (void)showDebugView{
    if (debugView == nil){
        CGFloat offY = 150;
        CGFloat maxWidth = 100;
        CGFloat maxHeight = 44;
        debugView = [[WMDebugView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - maxWidth, offY, maxWidth, maxHeight)];
        debugView.windowLevel = CGFLOAT_MAX;
        debugView.backgroundColor = [UIColor clearColor];
    }
    debugView.hidden = NO;
}
+ (void)hiddenDebugView{
    if (debugView){
        debugView.hidden = YES;
        [debugView stopDeviceUsage];
    }
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        [self setupWindowAndDefaultVariables];
        [self setupTextLayers];
        [self startDeviceUsage];
    }
    return self;
}
- (void)setupWindowAndDefaultVariables{
    UIViewController *rootViewController = [[UIViewController alloc] init];
    [self setRootViewController:rootViewController];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setClipsToBounds:YES];
    [self setHidden:YES];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doHandlePanAction:)];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doHandleTapAction:)];
    
    [self addGestureRecognizer:tapGestureRecognizer];
    [self addGestureRecognizer:panGestureRecognizer];
}
- (void)setupTextLayers {
    self.monitoringTextLabel = [[WMTextLabel alloc] init];
    self.monitoringTextLabel.userInteractionEnabled = YES;
    [self.monitoringTextLabel setTextAlignment:NSTextAlignmentCenter];
    [self.monitoringTextLabel setNumberOfLines:0];
    [self.monitoringTextLabel setBackgroundColor:[UIColor blackColor]];
    [self.monitoringTextLabel setTextColor:[UIColor whiteColor]];
    [self.monitoringTextLabel setClipsToBounds:YES];
    [self.monitoringTextLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [self.monitoringTextLabel.layer setBorderWidth:1.0f];
    [self.monitoringTextLabel.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [self.monitoringTextLabel.layer setCornerRadius:5.0f];
    [self addSubview:self.monitoringTextLabel];
}
- (void)doHandleTapAction:(UIGestureRecognizer *)tapAction{
    /// 展开更多监控信息
}
- (void)doHandlePanAction:(UIPanGestureRecognizer *)panAction{
    /// 拖动视图位置
    CGPoint point = [panAction translationInView:self.monitoringTextLabel];
    CGPoint currentPoint = CGPointMake(panAction.view.center.x + point.x, panAction.view.center.y + point.y);
    
    if (currentPoint.x <= panAction.view.size.width / 2){
        currentPoint.x = panAction.view.size.width / 2;
    }else if (currentPoint.x >= [UIScreen mainScreen].bounds.size.width - panAction.view.size.width / 2){
        currentPoint.x = [UIScreen mainScreen].bounds.size.width - panAction.view.size.width / 2;
    }
    if (currentPoint.y <= panAction.view.size.height / 2){
        currentPoint.y = panAction.view.size.height / 2;
    }else if (currentPoint.y >= [UIScreen mainScreen].bounds.size.height - panAction.view.size.height / 2){
        currentPoint.y = [UIScreen mainScreen].bounds.size.height - panAction.view.size.height / 2;
    }
    panAction.view.center = currentPoint;
    [panAction setTranslation:CGPointMake(0, 0) inView:self.monitoringTextLabel];
    
    /// 拖动完成之后视图让它靠边停留
    if (panAction.state == UIGestureRecognizerStateEnded){
        if (currentPoint.x >= [UIScreen mainScreen].bounds.size.width / 2){
            currentPoint.x = [UIScreen mainScreen].bounds.size.width - panAction.view.size.width / 2;
        }else {
            currentPoint.x = panAction.view.size.width / 2;
        }
        [UIView animateWithDuration:0.25 animations:^{
            panAction.view.center = currentPoint;
        }];
    }
}
/// 开启资源监控
- (void)startDeviceUsage{
    __weak typeof(self) weakself = self;
    [WMCpuMonitor startCpuMonitor:^(double cpuUsage) {
        weakself.cpuUsage = cpuUsage;
        [weakself showResouseInfo];
    }];
    [WMMemoryMonitor startMemoryMonitor:^(double memoryUsage) {
        weakself.memoryUsage = memoryUsage;
        [weakself showResouseInfo];
    }];
    [WMFpsMonitor startFpsMonitor:^(int fpsUsage) {
        weakself.fpsUsage = fpsUsage;
        [weakself showResouseInfo];
    }];
}
- (void)showResouseInfo{
    NSString *text = [NSString stringWithFormat:@"FPS:%d  CPU:%d  Me:%.1fMB" , self.fpsUsage , (int)self.cpuUsage , self.memoryUsage];
    [self.monitoringTextLabel setText:text];
    [self setNeedsLayout];
}
/// 停止资源监控
- (void)stopDeviceUsage{
    [WMCpuMonitor stopCpuMonitor];
    [WMMemoryMonitor stopMemoryMonitor];
    [WMFpsMonitor stopFpsMonitor];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat maxWidth = CGRectGetWidth(self.frame);
    CGFloat maxHeight = CGRectGetHeight(self.frame);
    CGFloat minHeight = 36;
    if (self.monitoringTextLabel.text.length > 0){
        CGSize labelSize = [self.monitoringTextLabel sizeThatFits:CGSizeMake(maxWidth, maxHeight)];
        if (labelSize.height < minHeight){
            labelSize = CGSizeMake(labelSize.width, minHeight);
        }else if (labelSize.height > maxHeight){
            labelSize = CGSizeMake(labelSize.width, maxHeight);
        }
        self.size = CGSizeMake(maxWidth, labelSize.height);
        [self.monitoringTextLabel setFrame:CGRectMake(0, 0, self.size.width, self.size.height)];
    }
}

@end
