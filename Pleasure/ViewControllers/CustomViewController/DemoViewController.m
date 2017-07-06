//
//  DemoViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/4.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "DemoViewController.h"
#import "Demo2ViewController.h"
#import "DemoTableViewController.h"

@interface DemoViewController ()

@end

@implementation DemoViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    UIImage *_storedBackgroundImage = [UIImage buildImageWithColor:[UIColor grayColor]];
    //    [[UINavigationBar appearance] setBackgroundImage:_storedBackgroundImage forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:_storedBackgroundImage forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //self.title = @"Demo";
    self.navigationItem.title = @"这是demo一";
    
    UIButton * nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [nextBtn addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:nextBtn];
    
    
    UIButton * tabBtn = [[UIButton alloc] initWithFrame:CGRectMake(150, 0, 100, 100)];
    [tabBtn addTarget:self action:@selector(tabClick:) forControlEvents:UIControlEventTouchUpInside];
    tabBtn.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:tabBtn];
}

- (void)tabClick:(UIButton *)button{
    [_svc.topNavigationController pushViewController:[DemoTableViewController new] animated:YES];
}

- (void)nextClick:(UIButton *)button{
    Demo2ViewController * vc = [Demo2ViewController new];
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
