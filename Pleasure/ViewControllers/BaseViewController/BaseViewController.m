//
//  BaseViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/3.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()
@end

@implementation BaseViewController

- (instancetype)init{
    if (self = [super init]){
        _svc = [SwitchViewController sharedSVC];
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self showCustomNavigationBarTitle:self.navigationItem.title];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor pageBackgroundColor];
    
    if ([self shouldShowBackItem]) {
        [self showBackItem];
    }
}

@synthesize appNavigationBar = _appNavigationBar;
- (AppNavigationBar *)appNavigationBar{
    self.fd_prefersNavigationBarHidden = YES;
    if (_appNavigationBar == nil){
        _appNavigationBar = [[AppNavigationBar alloc ] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
        UINavigationItem * customNavigationItem = [[UINavigationItem alloc] init];
        [_appNavigationBar setItems:@[customNavigationItem]];
    }
    return _appNavigationBar;
}

- (AppNavigationBar *)showCustomNavigationBar{
    AppNavigationBar *navBar = [self appNavigationBar];
    [self.view addSubview:navBar];
    [self.view bringSubviewToFront:navBar];
    
    return navBar;
}
- (void)showCustomNavigationBarTitle:(NSString *)title{
    UINavigationItem * item = [self getCustomNaviItem];
    item.title = title;
}

#pragma mark -- 重写方法
/// 重写setTitle方法
- (void)setTitle:(NSString *)title{
    [super setTitle:title];
    [self showCustomNavigationBarTitle:title];
}
/// 获取自定制的导航栏
- (UINavigationItem *)getCustomNaviItem{
    AppNavigationBar * appNaviBar = _appNavigationBar;
    UINavigationItem * item;
    if (appNaviBar && [appNaviBar superview]){
        if (appNaviBar.items.count){
            item = [appNaviBar.items firstObject];
        }
    }
    return item;
}
- (void)showBackItem {
    UIImage * image = [UIImage imageNamed:@"icon_white_back"];
    UIButton* btn = [UIButton buttonWithImage:image title:@"返回" target:self action:@selector(backItemAction:)];
    btn.frame = CGRectMake(btn.frame.origin.x, btn.frame.origin.y, 56, 28);
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    btn.adjustsImageWhenHighlighted = NO;
    [self addItemForLeft:YES withItem:item spaceWidth:-8];
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
-(void)backItemAction:(UIButton*)button {
    if (_svc.rootShowViewController) {
        if (_svc.topNavigationController.viewControllers.count > 1) {
//            [_svc popViewController];
        } else {
//            [_svc dismissTopViewControllerCompletion:NULL];
        }
    } else {
//        [_svc dismissTopViewControllerCompletion:NULL];
    }
}

- (BOOL)shouldShowBackItem{
    return YES;
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
