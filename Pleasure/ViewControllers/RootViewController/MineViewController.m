//
//  MineViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/4.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "MineViewController.h"

@interface MineViewController ()

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"第二页的 %@" , [_svc topNavigationController]);
    
    
    UIButton * nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [nextBtn addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:nextBtn];
}
- (void)nextClick:(UIButton *)button{
    [self.navigationController pushViewController:[DemoViewController new] animated:YES];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationStringTabBarController object:@0];
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
