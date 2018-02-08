//
//  WMBaseNavigationController.m
//  Pleasure
//
//  Created by Sper on 2017/8/30.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMBaseNavigationController.h"
#import "WMAppNavigationBar.h"
#import "WMTransitionProtocol.h"
#import "WMTransitionAnimator.h"

@interface WMBaseNavigationController ()<UINavigationControllerDelegate,UIGestureRecognizerDelegate>
//是否开启系统右滑返回
@property(nonatomic,assign) BOOL isSystemSlidBack;
/// 手势返回进度
@property (nonatomic,strong) UIPercentDrivenInteractiveTransition *interactivePopTransition;
/// 全屏手势动画
@property (nonatomic,strong) UIScreenEdgePanGestureRecognizer *popRecognizer;
@end

@implementation WMBaseNavigationController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    
    //只有在使用转场动画时，禁用系统手势，开启自定义右划手势
    _popRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleNavigationTransition:)];
    //下面是全屏返回
    //        _popRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleNavigationTransition:)];
    _popRecognizer.edges = UIRectEdgeLeft;
    [_popRecognizer setEnabled:NO];
    [self.view addGestureRecognizer:_popRecognizer];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    if (self.viewControllers.count > 0) {
        if ([viewController conformsToProtocol:@protocol(WMTransitionProtocol)]) {
            viewController.hidesBottomBarWhenPushed = NO;
        }else{
            viewController.hidesBottomBarWhenPushed = YES;
        }
    }
    [super pushViewController:viewController animated:animated];
    // 修改tabBra的frame
    CGRect frame = self.tabBarController.tabBar.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
    self.tabBarController.tabBar.frame = frame;
}

//解决手势失效问题
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.fd_fullscreenPopGestureRecognizer.enabled = _isSystemSlidBack;
    [_popRecognizer setEnabled:!_isSystemSlidBack];
}
#pragma mark -- NavitionContollerDelegate  push 和 pop 转场动画区
//navigation切换是会走这个代理
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    self.isSystemSlidBack = YES;
    //如果来源VC和目标VC都实现协议，那么都做动画
    if ([fromVC conformsToProtocol:@protocol(WMTransitionProtocol)] && [toVC conformsToProtocol:@protocol(WMTransitionProtocol)]) {
        WMTransitionAnimator *transion = [WMTransitionAnimator transitionAnimatorWithController:(UIViewController<WMTransitionProtocol> *)fromVC];
        if (operation == UINavigationControllerOperationPush) {
            transion.operation = WMControllerOperation_Push;
        }
        else if(operation == UINavigationControllerOperationPop){
            transion.operation = WMControllerOperation_Pop;
        }
        else{
            return nil;
        }
        //暂时屏蔽系统带动画的右划返回
        self.isSystemSlidBack = NO;
        return transion;
    }
    return nil;
}
- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    if (!self.interactivePopTransition) { return nil; }
    return self.interactivePopTransition;
}

#pragma mark UIGestureRecognizer handlers

- (void)handleNavigationTransition:(UIScreenEdgePanGestureRecognizer*)recognizer
{
    CGFloat progress = [recognizer translationInView:self.view].x / (self.view.bounds.size.width);
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        [self popViewControllerAnimated:YES];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self.interactivePopTransition updateInteractiveTransition:progress];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGPoint velocity = [recognizer velocityInView:recognizer.view];
        
        if (progress > 0.5 || velocity.x >100) {
            [self.interactivePopTransition finishInteractiveTransition];
        }
        else {
            [self.interactivePopTransition cancelInteractiveTransition];
        }
        self.interactivePopTransition = nil;
    }
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
