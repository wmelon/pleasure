//
//  Demo2ViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/4.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "Demo2ViewController.h"
#import "DemoViewController.h"

@interface Demo2ViewController ()

@end

@implementation Demo2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.title = @"Demo2";
    self.navigationItem.title = @"Demo2";
    
    UIButton * nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [nextBtn addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:nextBtn];
}

- (UIView *)loadNavigationHeaderView{
    UIView * headerView = [UIView new];
    headerView.backgroundColor = [UIColor greenColor];
    
    return headerView;
}

- (void)nextClick:(UIButton *)button{
    DemoViewController * vc = [DemoViewController new];
    [self.navigationController pushViewController:vc animated:YES];
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
