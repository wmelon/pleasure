//
//  RootViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/3.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "RootViewController.h"
#import "AppTabBar.h"
#import "AppNavigationBar.h"
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
    [self setViewControllers:[self rootViewControllers]];
}

- (NSArray *)rootViewControllers{
    HomeViewController * homeVc = [HomeViewController new];
    homeVc.title = @"首页";
    homeVc.tabBarItem.image = [UIImage imageNamed:@"train"];
    homeVc.tabBarItem.badgeValue = @"99";
    
    BaseNavigationController * homeNavi = [[BaseNavigationController alloc] initWithRootViewController:homeVc];
    [homeNavi setValue:[AppNavigationBar new] forKey:@"navigationBar"];
    
    
    MineViewController * mineVc = [MineViewController new];
    mineVc.title = @"我的";
    mineVc.tabBarItem.image = [UIImage imageNamed:@"personal"];
    mineVc.tabBarItem.badgeValue = @"1";
    
    BaseNavigationController * mineNavi = [[BaseNavigationController alloc] initWithRootViewController:mineVc];
    [mineNavi setValue:[AppNavigationBar new] forKey:@"navigationBar"];
    
    return @[homeNavi , mineNavi];
}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(nonnull UIViewController *)viewController{
    UIViewController *vc = tabBarController.selectedViewController;
    if (vc == viewController){
        
        if ([vc isKindOfClass:[UINavigationController class]]){
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
