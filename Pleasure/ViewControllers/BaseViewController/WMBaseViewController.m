//
//  WMBaseViewController.m
//  Pleasure
//
//  Created by Sper on 2017/8/30.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMBaseViewController.h"
#import "WMAppNavigationBar.h"

@interface WMNaviBarBlurBackView : UIView
@end

@implementation WMNaviBarBlurBackView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = CGRectMake(0, 0, kScreenWidth, kNavBarHeight);
        gradientLayer.colors = @[(__bridge id)UIColorFromARGB(0x040012, 0.76).CGColor,(__bridge id)UIColorFromARGB(0x040012, 0.28).CGColor];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1.0);
        [self.layer addSublayer:gradientLayer];
        self.userInteractionEnabled = NO;
    }
    return self;
}
@end


@interface WMBaseViewController ()
@property (nonatomic , strong) WMNaviBarBlurBackView *blurBackView;
@end

@implementation WMBaseViewController

- (void)dealloc{
    NSLog(@"----------界面销毁了 %@" ,self);
}

- (instancetype)init{
    if (self = [super init]){
        _svc = [SwitchViewController sharedSVC];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.fd_prefersNavigationBarHidden == NO && [self.navigationController.viewControllers lastObject] == self){ /// 只有在没有隐藏导航栏的时候才添加视图
        if (!self.blurBackView.superview && self.blurBackView){
            //确保header视图层级，不然会盖住子类在viewDidLoad时添加到view的视图
            [self.view addSubview:self.blurBackView];
            [self.view bringSubviewToFront:self.blurBackView];
        }
    }
}

/// 布局视图frame
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    if (self.fd_prefersNavigationBarHidden == NO){
        [self setHeaderViewFrame];
        /// 这里保证头部视图永远在最上层不被覆盖
        [self.view bringSubviewToFront:self.blurBackView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor pageBackgroundColor];
    
    //    if ([self shouldShowBackItem]) {
    //        [self showBackItem];
    //    }
}
/// 监听横竖屏切换 更新子视图的frame
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [self setHeaderViewFrame];
}

- (void)setHeaderViewFrame{
    if (!self.blurBackView || !self.blurBackView.superview){
        return;
    }
    UIView *purpleView = self.blurBackView;
    purpleView.frame = CGRectMake(0, 0, self.view.frame.size.width, CGRectGetMaxY(self.navigationController.navigationBar.frame));
}

//- (void)showBackItem {
//    UIImage * image = [UIImage imageNamed:@"icon_white_back"];
//    UIButton* btn = [UIButton buttonWithImage:image title:@"返回" target:self action:@selector(backItemAction:)];
//    btn.frame = CGRectMake(btn.frame.origin.x, btn.frame.origin.y, 56, 28);
//    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:btn];
//    btn.adjustsImageWhenHighlighted = NO;
//    [self addItemForLeft:YES withItem:item spaceWidth:-8];
//}
//-(void)addItemForLeft:(BOOL)left withItem:(UIBarButtonItem*)item spaceWidth:(CGFloat)width {
//    UIBarButtonItem *space = [[UIBarButtonItem alloc]
//                              initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                              target:nil action:nil];
//    space.width = width;
//    if (left) {
//        self.navigationItem.leftBarButtonItems = @[space,item];
//    } else {
//        self.navigationItem.rightBarButtonItems = @[space,item];
//    }
//}
//
//- (void)backItemAction:(UIButton*)button {
//    if (_svc.rootShowViewController) {
//        if (self.navigationController.viewControllers.count > 1) {
//            [self.navigationController popViewControllerAnimated:YES];
//        } else {
////            [_svc dismissTopViewControllerCompletion:NULL];
//            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//        }
//    } else {
////        [_svc dismissTopViewControllerCompletion:NULL];
//        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    }
//}
//
//- (BOOL)shouldShowBackItem{
//    return YES;
//}


#pragma mark - Navigation

- (UIButton *)showRightItem:(NSString *)title image:(UIImage *)image{
    UIButton *button = [UIButton buttonWithImage:image title:title target:self action:@selector(rightAction:)];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    button.contentEdgeInsets = UIEdgeInsetsZero;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addItemForLeft:NO withItem:item spaceWidth:0];
    return button;
}
-(void)addItemForLeft:(BOOL)left withItem:(UIBarButtonItem*)item spaceWidth:(CGFloat)width {
    UIBarButtonItem *space = [[UIBarButtonItem alloc]
                              initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                              target:nil action:nil];
    space.width = width;
    
    if (left) {
        self.navigationItem.leftBarButtonItems = @[space,item];
    } else {
        self.navigationItem.rightBarButtonItems = @[space,item];
    }
}
- (void)wm_setElementsAlpha:(CGFloat)alpha{
    self.blurBackView.alpha = alpha;
}
- (WMNaviBarBlurBackView *)blurBackView{
    if (_blurBackView == nil){
        _blurBackView = [[WMNaviBarBlurBackView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavBarHeight)];
        _blurBackView.userInteractionEnabled = NO;
        _blurBackView.autoresizingMask = UIViewAutoresizingFlexibleWidth;    // Should not set `UIViewAutoresizingFlexibleHeight`
        _blurBackView.backgroundColor = [self naviBarBackgroundColor];
    }
    return _blurBackView;
    
}
- (void)rightAction:(UIButton *)button{
    NSLog(@"%@ 子类需要重写" , self);
}
- (UIColor *)naviBarBackgroundColor{
    return [UIColor mainColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
