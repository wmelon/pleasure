//
//  WMDebugView.m
//  Pleasure
//
//  Created by Sper on 2018/3/6.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMDebugView.h"
#import "WMFpsMonitor.h"
#import "WMResourceMonitor.h"
#import "WMDebugManager.h"

@interface WMTextLabel : UILabel
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@end
@implementation WMTextLabel
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        self.edgeInsets = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
        self.userInteractionEnabled = YES;
        [self setFont:[UIFont systemFontOfSize:12.0f]];
        [self setBackgroundColor:[UIColor blackColor]];
        [self setTextColor:[UIColor whiteColor]];
        [self setTextAlignment:NSTextAlignmentCenter];
    }
    return self;
}
- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}
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
@property (nonatomic, strong) WMTextLabel *fpsTextLabel;
@property (nonatomic, strong) WMTextLabel *cpuTextLabel;
@property (nonatomic, strong) WMTextLabel *memoryTextLabel;
@property (nonatomic, assign) double cpuUsage;
@property (nonatomic, assign) double memoryUsage;
@property (nonatomic, assign) int fpsUsage;
@property (nonatomic, strong) UIWindow *window;
@end
@implementation WMDebugView

+ (void)showDebugView{
    if (debugView == nil){
        CGFloat offY = 150;
        CGFloat maxWidth = 100;
        CGFloat maxHeight = 54;
        
        UIViewController *debugVc = [[UIViewController alloc] init];
        UIWindow *window = [[UIWindow alloc] initWithFrame: CGRectMake([UIScreen mainScreen].bounds.size.width - maxWidth, offY, maxWidth, maxHeight)];
        window.windowLevel = UIWindowLevelStatusBar + 1;
        [window setClipsToBounds:YES];
        window.backgroundColor = [UIColor clearColor];
        [window makeKeyAndVisible];
        window.rootViewController = debugVc;
        
        debugView = [[WMDebugView alloc] initWithFrame:window.bounds];
        [debugView.layer setCornerRadius:5.0f];
        [debugView setClipsToBounds:YES];
        [window addSubview:debugView];
        debugView.window = window;
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:debugView action:@selector(doHandlePanAction:)];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:debugView action:@selector(doHandleTapAction:)];
        [window addGestureRecognizer:tapGestureRecognizer];
        [window addGestureRecognizer:panGestureRecognizer];
    }
}
+ (void)hiddenDebugView{
    if (debugView){
        // 如果隐藏debug视图说明要隐藏所有的监控界面
        [WMDebugManager hiddenDebugController];
        // 移除隐藏显示的debug视图
        debugView.window.hidden = YES;
        debugView.window.rootViewController = nil;
        [debugView stopDeviceUsage];
    }
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        [self setupTextLayers];
        [self startDeviceUsage];
    }
    return self;
}
- (void)setupTextLayers {
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height / 3;
    self.fpsTextLabel = [[WMTextLabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [self addSubview:self.fpsTextLabel];
    
    self.memoryTextLabel = [[WMTextLabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.fpsTextLabel.frame), width, height)];
    [self addSubview:self.memoryTextLabel];
    
    self.cpuTextLabel = [[WMTextLabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.memoryTextLabel.frame), width, height)];
    [self addSubview:self.cpuTextLabel];
}
// 显示监控详情
- (void)doHandleTapAction:(UIGestureRecognizer *)tapAction{
    [WMDebugManager showDebugController];
}
- (void)doHandlePanAction:(UIPanGestureRecognizer *)panAction{
    UIView *panView = panAction.view;
    /// 拖动视图位置
    CGPoint point = [panAction translationInView:panView];
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
    [panAction setTranslation:CGPointMake(0, 0) inView:panView];
    
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
    [WMResourceMonitor startResourceMonitor:^(double cpuUsage, double memoryUsage) {
        weakself.cpuUsage = cpuUsage;
        weakself.memoryUsage = memoryUsage;
        [weakself showResouseInfo];
    }];
    [WMFpsMonitor startFpsMonitor:^(int fpsUsage) {
        weakself.fpsUsage = fpsUsage;
        [weakself showResouseInfo];
    }];
}
- (void)showResouseInfo{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.fpsTextLabel.text = [NSString stringWithFormat:@"FPS:%d" , self.fpsUsage];
        self.memoryTextLabel.text = [NSString stringWithFormat:@"ME:%.1fM" , self.memoryUsage];
        self.cpuTextLabel.text = [NSString stringWithFormat:@"CPU:%.1f%%" , self.cpuUsage];
    });
}
/// 停止资源监控
- (void)stopDeviceUsage{
    [WMResourceMonitor stopResourceMonitor];
    [WMFpsMonitor stopFpsMonitor];
}

@end
