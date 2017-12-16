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
    
    [self.view showLoadingType:(WMLoadingType_gifImage)];
    
//    [self click:nil];
//    [self canael:nil];
}


- (void)canael:(UIButton *)button{
//    [self.view showLoading];
//
//    WMRequestAdapter *requestAdapter = [WMRequestAdapter requestWithUrl:@"http://www.ecloudtm.com/cnnews/api/getStartAd.do" requestMethod:(WMRequestMethodGET)];
//
//    __weak typeof(self) weakself = self;
//    NSURLSessionTask *task = [WMRequestManager requestWithSuccessHandler:^(WMRequestAdapter *request) {
////        NSLog(@"请求成功返回数据 %@" , request.responseObject);
//
//        /// 这里如果不用weak 就会出现网络请求不回来就无法销毁控制器 这样就无法实现销毁控制器自动停止网络请求
////        [weakself.view hiddenLoading];
//        [weakself.view showLoadEmptyWithRetryBlcok:^{
//           /// 加载数据为空   可以实现空数据点击
//        }];
//
//    } cacheHandler:^(WMRequestAdapter *request) {
//
//    } failureHandler:^(WMRequestAdapter *request) {
//
//        [weakself.view showLoadFailedWithRetryBlcok:^{
//            /// 加载失败重新加载
//            [weakself canael:nil];
//        }];
//
//    } requestAdapter:requestAdapter];
//
//    /// 界面销毁自动释放网络请求
//    [self autoCancelRequestOnDealloc:task];
}


- (void)click:(UIButton *)button{

    NSMutableArray <id<WMRequestAdapterProtocol>> *requestsAdapter = [NSMutableArray array];
    for (int i = 0 ; i < 5 ; i++){
        WMRequestAdapter *request = [WMRequestAdapter requestWithUrl:@"http://v.juhe.cn/toutiao/index?type=&key=6759a6e8d853240c6aa92d8314f734f9" requestMethod:(WMRequestMethodGET)];
        [requestsAdapter addObject:request];
    }

    NSArray *tasks = [WMRequestManager requestBatchWithSuccessHandler:^(NSArray<WMRequestAdapter *> *requests) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"显示哈哈哈" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [av show];

//        NSLog(@"%@" , requests);
    } failureHandler:^(NSArray<WMRequestAdapter *> *requests) {
        
//        NSLog(@"%@" , requests);
    } requestAdapters:requestsAdapter];
    
    /// 界面销毁之后自动清理当前界面的请求
    [self autoCancelMoreRequestOnDealloc:tasks];
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
