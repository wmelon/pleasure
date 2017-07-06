//
//  DemoTableViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/5.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "DemoTableViewController.h"

@interface DemoTableViewController ()

@end

@implementation DemoTableViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    
    UIAlertView *a  = [UIAlertView alloc]initWithTitle:<#(nullable NSString *)#> message:<#(nullable NSString *)#> delegate:<#(nullable id)#> cancelButtonTitle:<#(nullable NSString *)#> otherButtonTitles:<#(nullable NSString *), ...#>, nil
    
    
    [self testWithTitles:<#(nullable NSString *), ...#>];
    
    
    UIImage *_storedBackgroundImage = [UIImage buildImageWithColor:[UIColor yellowColor]];
    [self.navigationController.navigationBar setBackgroundImage:_storedBackgroundImage forBarMetrics:UIBarMetricsDefault];
}


- (void)testWithTitles:(nullable NSString *)otherButtonTitles, ...{
    
}
//- (instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message delegate:(nullable id)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... {
//
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"table";
    
    
    
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
