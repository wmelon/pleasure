//
//  WMSettingViewController.m
//  Pleasure
//
//  Created by Sper on 2017/8/25.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMSettingViewController.h"
//#import "module_face.h"

@interface WMSettingViewController ()
/// 人脸识别模块
//@property (nonatomic , strong) module_face *moduleFace;
@end

@implementation WMSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"设置";
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"module_face_sa" ofType:@".dat"];
//    NSLog(@"%@" , path);
//    self.moduleFace = [module_face sharedFaceModule];
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        UIImage *image = [UIImage imageNamed:@"case_big"];
//        [self.moduleFace get_landmark:image orientation:(UIImageOrientationUp) callback:^(int err_code, NSMutableArray *landmarks) {
//            NSLog(@"%@  %d" ,landmarks , err_code);
//        }];
//    });
}
//- (void)dealloc{
//    self.moduleFace = nil;
//}
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
