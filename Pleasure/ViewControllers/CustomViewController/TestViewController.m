//
//  TestViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/13.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    bgView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:bgView];
    
    
//    UIView *purpleView = bgView;
//    // 禁止将 AutoresizingMask 转换为 Constraints
//    purpleView.translatesAutoresizingMaskIntoConstraints = NO;
//    // 添加 width 约束
//    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:purpleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:self.view.frame.size.width];
//    [purpleView addConstraint:widthConstraint];
//    // 添加 height 约束
//    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:purpleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:64];
//    [purpleView addConstraint:heightConstraint];
//    // 添加 left 约束
//    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:purpleView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
//    [self.view addConstraint:leftConstraint];
//    // 添加 top 约束
//    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:purpleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
//    [self.view addConstraint:topConstraint];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.title = @"testView";
}

- (UIView *)loadNavigationHeaderView{
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor orangeColor];
    return view;
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
