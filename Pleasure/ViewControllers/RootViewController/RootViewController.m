//
//  RootViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/3.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()<UITabBarControllerDelegate>
@property(strong, nonatomic)UITabBarController* tabBarController;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tabBarController = [[UITabBarController alloc] init];
    _tabBarController.tabBar.translucent = NO;
    _tabBarController.tabBar.backgroundColor = [UIColor whiteColor];
    [_tabBarController willMoveToParentViewController:self];
    [self addChildViewController:_tabBarController];
    [_tabBarController didMoveToParentViewController:self];
    
    _tabBarController.delegate = self;
    //        _tabBarController.tabBar.tintColor = [AppAppearance sharedAppearance].tabBarColor;
    [_tabBarController setViewControllers:[self viewControllers] animated:NO];
    //        [_tabBarController setSelectedIndex:[self defaultSelectedIndex]];
    _tabBarController.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    [self.view addSubview:_tabBarController.view];
    
    [self tabBarController:_tabBarController didSelectViewController:_tabBarController.selectedViewController];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    NSLog(@"------%@" , viewController);
}

- (NSArray *)viewControllers{
    HomeViewController * homeVc = [HomeViewController new];
    homeVc.title = @"首页";
    UINavigationController * homeNav = [[UINavigationController alloc] initWithRootViewController:homeVc];
    
    
    MineViewController * mineVc = [MineViewController new];
    mineVc.title = @"我的";
    UINavigationController * mineNav = [[UINavigationController alloc] initWithRootViewController:mineVc];
    
    return @[homeNav , mineNav];
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
