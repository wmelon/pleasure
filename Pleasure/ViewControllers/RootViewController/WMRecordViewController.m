//
//  WMRecordViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/25.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMRecordViewController.h"
#import "WMInputInfoView.h"

@interface WMRecordViewController ()<WMInputInfoViewDelegate>
@property (nonatomic , strong) WMInputInfoView *inputInfoView;

@property (nonatomic , strong) NSArray * imageUrlArray;
@end

@implementation WMRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.tableView addSubview:self.inputInfoView];
    
    self.imageUrlArray = @[@"http://pic1.5442.com/2015/0908/06/02.jpg" , @"http://imgsrc.baidu.com/image/c0%3Dshijue1%2C0%2C0%2C294%2C40/sign=60aeee5da74bd11310c0bf7132c6ce7a/72f082025aafa40fe3c0c4f3a164034f78f0199d.jpg" , @"http://www.wallcoo.com/nature/amazing_color_landscape_2560x1600/wallpapers/1366x768/amazing_landscape_33_ii.jpg" , @"http://pic1.5442.com/2013/0801/07/05.jpg" ,@"http://www.wallcoo.com/nature/Amazing_Color_Landscape_2560x1600/wallpapers/1920x1080/Amazing_Landscape_36_II.jpg",@"https://hbimg.b0.upaiyun.com/453ab8bbea3bcf35b3ff7536bb9027ed4ead9108ca93-wjbGDX_fw658"];
    
    [self.inputInfoView reloadView];
    
    [self showRightItem:@"发布" image:nil];
}

- (void)rightAction:(UIButton *)button{
    /// 发布消息
}

#pragma mark -- WMInputInfoViewDataSource and WMInputInfoViewDelegate

- (NSInteger)maxPhotoCountAtInputInfoView:(WMInputInfoView *)inputInfoView{
    return 9;
}

- (NSInteger)selectedPhotoCountAtInputInfoView:(WMInputInfoView *)inputInfoView{
    return self.imageUrlArray.count;
}

- (NSString *)inputInfoView:(WMInputInfoView *)inputInfoView selectedPhotoUrlAtIndex:(NSInteger)index{

    return self.imageUrlArray[index];
}


- (WMInputInfoView *)inputInfoView{
    
    if (_inputInfoView == nil){
        
        _inputInfoView = [[WMInputInfoView alloc] init];
        _inputInfoView.delegate = self;
    }
    
    return _inputInfoView;
    
}

- (BOOL)shouldShowGetMore{
    return NO;
}

- (BOOL)shouldShowRefresh{
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
