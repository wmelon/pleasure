//
//  WMBaseMonitorViewController.m
//  Pleasure
//
//  Created by Sper on 2018/3/13.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMBaseMonitorViewController.h"

@interface WMBaseMonitorViewController ()
@end

@implementation WMBaseMonitorViewController

- (void)dealloc{
    NSLog(@"deall ---- >>> %@" , self);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.frame = self.navigationController.view.bounds;
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
