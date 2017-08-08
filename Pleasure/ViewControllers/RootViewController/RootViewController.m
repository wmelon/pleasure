//
//  RootViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/3.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "RootViewController.h"
#import "AppTabBar.h"
#import "BaseNavigationController.h"

@interface RootViewController ()<UITabBarControllerDelegate>
@end

@implementation RootViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)init{
    if (self = [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabBarControllerSelectedIndex:) name:KNotificationStringTabBarController object:nil];
        
        self.delegate = self;
    }
    return self;
}

- (void)tabBarControllerSelectedIndex:(NSNotification *)notification{
    NSInteger index = [notification.object integerValue];
    
    UINavigationController * navi = [self selectedViewController];
    
    if (index < self.viewControllers.count){
        self.selectedIndex = index;
        
//        UIViewController * viewController = self.tabBarController.viewControllers[index];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.selectedIndex = index;
//        });
    }
    [navi popToRootViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppTabBar * tabBar = [[AppTabBar alloc] initWithFrame:self.tabBar.bounds];
    [self setValue:tabBar forKey:@"tabBar"];
    
    [self setViewControllers:[self rootViewControllers]];
}

- (NSArray *)rootViewControllers{
    HomeViewController * homeVc = [HomeViewController new];
    homeVc.title = @"首页";
    homeVc.tabBarItem.image = [UIImage imageNamed:@"train"];
    BaseNavigationController * homeNavi = [[BaseNavigationController alloc] init];
//    [homeNavi setViewControllers:@[homeVc]];
    [homeNavi pushViewController:homeVc animated:NO];
    
    
    WMFoundViewController * foundVc = [WMFoundViewController new];
    foundVc.title = @"发现";
    foundVc.tabBarItem.image = [UIImage imageNamed:@"discovery"];
    BaseNavigationController *foundNavi = [BaseNavigationController new];
//    [foundNavi setViewControllers:@[foundVc]];
    [foundNavi pushViewController:foundVc animated:NO];
    
    
    WMRecordViewController * recordVc = [WMRecordViewController new];
    recordVc.title = @"趣记录";
    recordVc.tabBarItem.image = [UIImage imageNamed:@"trends"];
    BaseNavigationController * recordNavi = [BaseNavigationController new];
//    [recordNavi setViewControllers:@[recordVc]];
    [recordNavi pushViewController:recordVc animated:NO];
    
    
    MineViewController * mineVc = [MineViewController new];
    mineVc.title = @"我的";
    mineVc.tabBarItem.image = [UIImage imageNamed:@"personal"];
    BaseNavigationController * mineNavi = [[BaseNavigationController alloc] init];
//    [mineNavi setViewControllers:@[mineVc]];
    [mineNavi pushViewController:mineVc animated:NO];
    
    
    return @[homeNavi ,foundNavi , recordNavi , mineNavi];
}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(nonnull UIViewController *)viewController{
    UIViewController *vc = tabBarController.selectedViewController;
    if (vc == viewController){
        
        if ([vc isKindOfClass:[UINavigationController class]]){  /// 处理双击刷新数据
            UINavigationController * navi = (UINavigationController *)vc;
            if ([navi viewControllers].count){
                UIViewController * firstVc = [navi.viewControllers firstObject];
                
                if ([firstVc isKindOfClass:[WMBaseTableCollectionControlController class]]){
                    WMBaseTableCollectionControlController * scrollerVc = (WMBaseTableCollectionControlController *)firstVc;
                    [scrollerVc beginRefresh];
                }
            }
        }
        return NO;
    }
    
    return YES;
}



/// 当前选中的tabbar
- (UINavigationController *)currentSelectedNavigationController{
    return [self selectedViewController];
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
