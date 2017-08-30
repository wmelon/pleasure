//
//  WMRootViewController.m
//  Pleasure
//
//  Created by Sper on 2017/8/30.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMRootViewController.h"
#import "WMAppTabBar.h"
#import "WMBaseNavigationController.h"

@interface WMRootViewController ()<UITabBarControllerDelegate>

@end

@implementation WMRootViewController

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
    }
    [navi popToRootViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    WMAppTabBar * tabBar = [[WMAppTabBar alloc] initWithFrame:self.tabBar.bounds];
    [self setValue:tabBar forKey:@"tabBar"];
    
    [self setViewControllers:[self rootViewControllers]];
}

- (NSArray *)rootViewControllers{
    return @[[self wm_createNaviControllerWithTitle:@"首页" imageName:@"train" viewController:[WMHomeViewController class]] ,
             [self wm_createNaviControllerWithTitle:@"发现" imageName:@"discovery" viewController:[WMFoundViewController class]] ,
             [self wm_createNaviControllerWithTitle:@"趣记录" imageName:@"trends" viewController:[WMRecordViewController class]] ,
             [self wm_createNaviControllerWithTitle:@"我的" imageName:@"personal" viewController:[WMMineViewController class]]
             ];
}

- (WMBaseNavigationController *)wm_createNaviControllerWithTitle:(NSString *)title imageName:(NSString *)imageName viewController:(Class)viewController{
    WMBaseViewController * vc = [viewController new];
    vc.title = title;
    vc.tabBarItem.image = [UIImage imageNamed:imageName];
    WMBaseNavigationController * naviVc = [[WMBaseNavigationController alloc] init];
//    [homeNavi setViewControllers:@[homeVc]];
    [naviVc pushViewController:vc animated:NO];
    
    return naviVc;
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
