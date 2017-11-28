//
//  WMFoundViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/25.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMFoundViewController.h"

@interface WMFoundViewController ()
@end

@implementation WMFoundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    WMRequestAdapter *request = [WMRequestAdapter requestWithUrl:@"123" requestMethod:(WMRequestMethodGET)];
    
    WMRequestAdapter *request1 = [WMRequestAdapter requestWithUrl:@"123w" requestMethod:(WMRequestMethodPOST)];
    
    WMRequestAdapter *request2 = [WMRequestAdapter requestWithUrl:@"123wr" requestMethod:(WMRequestMethodGET)];
    
    WMRequestAdapter *request3 = [WMRequestAdapter requestWithUrl:@"123rwr" requestMethod:(WMRequestMethodPOST)];
    
    [WMRequestManager requestBatchWithSuccessHandler:^(NSArray<WMRequestAdapter *> *requests) {
        
    } failureHandler:^(NSArray<WMRequestAdapter *> *requests) {
        
    } requestAdapter:request ,request1 ,request2 , request3, nil];

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
