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

@interface RootViewController ()<UITabBarControllerDelegate>
@property(strong, nonatomic)UITabBarController* tabBarController;
@end

@implementation RootViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)init{
    if (self = [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabBarControllerSelectedIndex:) name:KNotificationStringTabBarController object:nil];
    }
    return self;
}

- (void)tabBarControllerSelectedIndex:(NSNotification *)notification{
    NSInteger index = [notification.object integerValue];
    [[SwitchViewController sharedSVC] popToRootViewController];
    if (index < self.tabBarController.viewControllers.count){
        UIViewController * viewController = self.tabBarController.viewControllers[index];
//        [viewController setIntentDic:notification.userInfo];
        [self tabBarController:self.tabBarController didSelectViewController:viewController];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fd_prefersNavigationBarHidden = YES;
    
    // Do any additional setup after loading the view.
    _tabBarController = [[UITabBarController alloc] init];
    [_tabBarController setValue:[[AppTabBar alloc] init] forKeyPath:@"tabBar"];
    
    [_tabBarController willMoveToParentViewController:self];
    [self addChildViewController:_tabBarController];
    [_tabBarController didMoveToParentViewController:self];
    
    _tabBarController.delegate = self;
    [_tabBarController setViewControllers:[self viewControllers] animated:NO];
    
    
    //[[[SwitchViewController sharedSVC] topNavigationController] pushViewController:<#(nonnull UIViewController *)#> animated:<#(BOOL)#>]
    _tabBarController.view.frame = self.view.bounds;
    [self.view addSubview:_tabBarController.view];
    
//    [_tabBarController setSelectedIndex:0];
//    [self tabBarController:_tabBarController didSelectViewController:_tabBarController.selectedViewController];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
}

- (NSArray *)viewControllers{
    HomeViewController * homeVc = [HomeViewController new];
    homeVc.title = @"首页";
    homeVc.tabBarItem.image = [UIImage imageNamed:@"train"];
    homeVc.tabBarItem.badgeValue = @"99";
    [homeVc showCustomNavigationBar];
    
    
    MineViewController * mineVc = [MineViewController new];
    mineVc.title = @"我的";
    mineVc.tabBarItem.image = [UIImage imageNamed:@"personal"];
    mineVc.tabBarItem.badgeValue = @"1";
    [mineVc showCustomNavigationBar];
    
    return @[homeVc , mineVc];
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
