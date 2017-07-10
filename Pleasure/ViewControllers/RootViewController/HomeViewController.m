//
//  HomeViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/3.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton * view = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    view.backgroundColor = [UIColor greenColor];
    
    [view addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:view];
}
- (void)click:(UIButton *)button{
    [_svc wm_pushViewController:[DemoViewController new]];
}

- (UIView *)loadNavigationHeaderView{
    UIView * view =[UIView new];
    view.backgroundColor = [UIColor orangeColor];
    return view;
}

- (BOOL)shouldShowBackItem{
    return NO;
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
