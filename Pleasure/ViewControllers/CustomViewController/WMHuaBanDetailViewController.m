//
//  WMHuaBanDetailViewController.m
//  Pleasure
//
//  Created by Sper on 2017/12/22.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMHuaBanDetailViewController.h"
#import "WMTransitionProtocol.h"

@interface WMHuaBanDetailViewController ()<WMTransitionProtocol>
@property (nonatomic, strong) UIImageView *headerImageView;
@end

@implementation WMHuaBanDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"个人信息";
    self.fd_prefersNavigationBarHidden = YES;
    [self initUI];
}
#pragma mark -  初始化UI
- (void)initUI{
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    _headerImageView = [UIImageView new];
    _headerImageView.frame = CGRectMake(0, 0, self.view.width , kScreenWidth / _headerImage.size.width * _headerImage.size.height);
    [self.tableView addSubview:_headerImageView];
    [_headerImageView setImage:_headerImage];
}

#pragma mark -- WMTransitionProtocol
- (UIView *)targetTransitionView{
    return self.headerImageView;
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
