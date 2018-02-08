//
//  WMAppMonitorViewController.m
//  Pleasure
//
//  Created by Sper on 2018/2/6.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMAppMonitorViewController.h"

@interface WMAppMonitorViewController ()

@end

@implementation WMAppMonitorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSArray * urlStrings = @[@"https://www.google.com",
                             @"http://www.baidu.com",
                             @"https://taobao.com",
                             @"http://www.safsaf24---23423.com"];
    
    for (NSString *  urlString in urlStrings) {
        NSURL * url = [NSURL URLWithString:urlString];
        [self startWithRequest:url];
    }
}
-(void)startWithRequest:(NSURL *)url {
    if (!url) {
        return;
    }
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    NSURLSession * session = [NSURLSession sharedSession];
    
    NSURLSessionTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([response isMemberOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
            NSLog(@"收到 : %ld",httpResponse.statusCode);
        }
        if (error) {
            NSLog(@"network Errpr: %@",[error localizedDescription]);
        }
    }];
    [task resume];
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
