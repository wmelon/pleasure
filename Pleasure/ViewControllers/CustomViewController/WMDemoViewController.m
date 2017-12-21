//
//  WMDemoViewController.m
//  Pleasure
//
//  Created by Sper on 2017/12/13.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMDemoViewController.h"

@interface WMDemoViewController ()
@end

@implementation WMDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];


    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(100, 300, 100, 100)];
    [btn1 setTitle:@"取消请求" forState:UIControlStateNormal];
    btn1.backgroundColor = [UIColor redColor];
    [btn1 addTarget:self action:@selector(canael:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
}


- (void)canael:(UIButton *)button{
    [self.view showLoadingType:(WMLoadingType_indicator)];

    WMRequestAdapter *requestAdapter = [WMRequestAdapter requestWithUrl:@"http://www.ecloudtm.com/cnnews/api/getStartAd.do" requestMethod:(WMRequestMethodGET)];

    __weak typeof(self) weakself = self;
    MKRequestTask *task = [WMRequestManager requestWithSuccessHandler:^(WMRequestAdapter *request) {
//        [weakself.view showLoadFailedWithRetryBlcok:^{
//            [weakself canael:nil];
//        }];
//        [self.view hiddenLoading];
        
    } cacheHandler:^(WMRequestAdapter *request) {

    } failureHandler:^(WMRequestAdapter *request) {

        [weakself.view showLoadFailedWithRetryBlcok:^{
            /// 加载失败重新加载
            [weakself canael:nil];
        }];

    } requestAdapter:requestAdapter];

    /// 界面销毁自动释放网络请求
    [self autoCancelRequestOnDealloc:task];
}


- (void)click:(UIButton *)button{
//    WMRequestAdapter *request = [WMRequestAdapter requestWithUrl:@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4" requestMethod:(WMRequestMethodDownload)];
//    [WMRequestManager requestWithSuccessHandler:^(WMRequestAdapter *request) {
//
//        NSLog(@"%@" , request.responseObject);
//
//    } ProgressHandler:^(WMRequestAdapter *request) {
//
//        NSLog(@"当前请求进度  %@   " , request.progress);
//
//    } failureHandler:^(WMRequestAdapter *request) {
//
//        NSLog(@"%@" , request.error);
//
//    } requestAdapter:request];
    

    NSMutableArray <id<WMRequestAdapterProtocol>> *requestsAdapter = [NSMutableArray array];
    for (int i = 0 ; i < 5 ; i++){
//        https://codeload.github.com/EricForGithub/SalesforceReactDemo/zip/master
//        http://v.juhe.cn/toutiao/index?type=&key=6759a6e8d853240c6aa92d8314f734f9
        WMRequestAdapter *request = [WMRequestAdapter requestWithUrl:@"https://codeload.github.com/EricForGithub/SalesforceReactDemo/zip/master" requestMethod:(WMRequestMethodDownload)];
        [requestsAdapter addObject:request];
    }

    __weak typeof(self) weakself = self;
    MKRequestTask *task = [WMRequestManager requestBatchWithSuccessHandler:^(NSArray<WMRequestAdapter *> *requests) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"显示哈哈哈" delegate:weakself cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [av show];
        NSLog(@"请求成功 回调  %@" ,requests);

    } failureHandler:^(NSArray<WMRequestAdapter *> *requests) {

        NSLog(@"%@" , requests);

    } requestAdapters:requestsAdapter];

    /// 界面销毁之后自动清理当前界面的请求
    [self autoCancelRequestOnDealloc:task];
    
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
