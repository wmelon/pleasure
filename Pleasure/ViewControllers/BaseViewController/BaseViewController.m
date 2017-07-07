//
//  BaseViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/3.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()
@property (nonatomic , strong)UIView * headerView;
@property (nonatomic , assign)BOOL isHeaderViewLoaded;
@end

@implementation BaseViewController

- (void)dealloc{
    NSLog(@"界面销毁了 %@" ,self);
}
- (instancetype)init{
    if (self = [super init]){
        _svc = [SwitchViewController sharedSVC];
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.fd_prefersNavigationBarHidden == NO){ /// 只有在没有隐藏导航栏的时候才添加视图
        if (_isHeaderViewLoaded == NO){
            if (_headerView.superview){
                [_headerView removeFromSuperview];
            }
            _headerView = [self loadNavigationHeaderView];
            if (_headerView){
                //确保header视图层级，不然会盖住子类在viewDidLoad时添加到view的视图
                [self.view addSubview:_headerView];
                [self.view bringSubviewToFront:_headerView];
            }
            _isHeaderViewLoaded = YES;
        }
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor pageBackgroundColor];
    
    if ([self shouldShowBackItem]) {
        [self showBackItem];
    }
}

/// 子类需要重写
- (UIView *)loadNavigationHeaderView{
    UIView * view = [UIView new];
    view.backgroundColor = [UIColor tabBarColor];
    return view;
}
- (void)setHeaderViewFrame{
    if (!_headerView){
        return;
    }
    if ([_headerView isKindOfClass:[UINavigationBar class]]){
        _headerView.frame = CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, self.view.bounds.size.width, self.navigationController.navigationBar.bounds.size.height);
    }else {
        _headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height);
    }
    
}
//子类重写需要调用超类
- (void)viewWillLayoutSubviews{
    [self setHeaderViewFrame];
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

- (void)backItemAction:(UIButton*)button {
    if (_svc.rootShowViewController) {
        if (self.navigationController.viewControllers.count > 1) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
//            [_svc dismissTopViewControllerCompletion:NULL];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    } else {
//        [_svc dismissTopViewControllerCompletion:NULL];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
