//
//  WMDownloadListViewController.m
//  Pleasure
//
//  Created by Sper on 2017/8/15.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMDownloadListViewController.h"
#import "WMDownloadButton.h"
#import <AFNetworking.h>

@interface WMDownloadListViewController ()

@property (nonatomic , strong) WMDownloadButton *downloadButton;

/** 进程*/
@property(nonatomic,strong)NSURLSessionDataTask *task;

@end

@implementation WMDownloadListViewController


- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_task cancel];  /// 停止下载
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView addSubview:[self createDownloadButton]];
}

- (void)wm_download{
    
    __weak typeof(self) weakSelf = self;
    _task = [[AFHTTPSessionManager manager] GET:@"http://wvideo.spriteapp.cn/video/2016/0116/569a048739c11_wpc.mp4" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
        dispatch_async(dispatch_get_main_queue(), ^{  /// 更新UI必须放在主线程里面
            weakSelf.downloadButton.progress    = downloadProgress.fractionCompleted;
            
            weakSelf.downloadButton.text        = [self transitionUnit:downloadProgress.completedUnitCount];
            
            NSLog(@"%@" , weakSelf.downloadButton.text);
        });
        
        //如果要计算下载速度xxkb/s 这种可以打开注释
        //           //一秒中内的数据
        //           downTask.readData                   += (downTask.completedUnitCount - progress.completedUnitCount);
        //           downTask.completedUnitCount          = progress.completedUnitCount;
        //           //获得当前时间
        //           NSDate *nowdate                      = [NSDate date];
        //           if ([nowdate timeIntervalSinceDate:downTask.lastDate] >= 1) {
        //               //时间差
        //               double time = [nowdate timeIntervalSinceDate:downTask.lastDate];
        //               //计算速度
        //               long long speed = downTask.readData/time;
        //               downTask.speed  = speed;
        //               //维护变量，将计算过的清零
        //               downTask.readData = 0.0;
        //               //维护变量，记录这次计算的时间
        //               downTask.lastDate = nowdate;
        //               AILog(@"下载速度:%@",[self transitionUnit:speed]);
        //           }

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{  /// 更新UI必须放在主线程里面
            weakSelf.downloadButton.progress    = 1.0;
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (WMDownloadButton *)createDownloadButton{
    
    __weak typeof(self) weakself = self;
    _downloadButton = [[WMDownloadButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 100) / 2, 100, 100, 100)];
    [_downloadButton setBlock:^(WMDownloadButton *button){
        switch (button.state) {
                case WMDownloadButtonLoading:
                [weakself wm_download];
                break;
                case WMDownloadButtonResume:
//                [weakself.task resume];
                break;
                case WMDownloadButtonSuspend:
//                [weakself.task suspend];
                break;
                
            default:
                break;
        }
    }];
    return _downloadButton;
}
/**
 转换单位
 
 @param size 文件大小
 @return 返回单位
 */
- (NSString *)transitionUnit:(int64_t)size {
    
    return [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}

- (BOOL)shouldShowRefresh{
    return NO;
}
- (BOOL)shouldShowGetMore{
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
