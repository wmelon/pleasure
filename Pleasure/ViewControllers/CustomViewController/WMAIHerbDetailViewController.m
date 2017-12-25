//
//  WMAIHerbDetailViewController.m
//  Pleasure
//
//  Created by Sper on 2017/8/14.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMAIHerbDetailViewController.h"
#import "WMTransitionProtocol.h"

@interface WMAIHerbDetailViewController ()<WMTransitionProtocol>
@property (strong, nonatomic) UIImageView *bgImageView;
@end

@implementation WMAIHerbDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.bgImageView = imageView;
    [self.view addSubview:self.bgImageView];
    
    self.fd_prefersNavigationBarHidden = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(actionClLose:)];
    [self.view addGestureRecognizer:tap];
}
- (UIView *)targetTransitionView{
    return self.bgImageView;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.bgImageView.image = [UIImage imageNamed:self.herbModel.image];
}

#pragma mark -action
- (void)actionClLose:(UITapGestureRecognizer*)tap {
    [self dismissViewControllerAnimated:YES completion:nil];
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
