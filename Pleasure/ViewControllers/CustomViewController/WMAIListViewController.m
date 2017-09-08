//
//  WMAIListViewController.m
//  Pleasure
//
//  Created by Sper on 2017/8/14.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMAIListViewController.h"
#import "WMAIListModel.h"
#import "WMAIListCell.h"
#import "WMAIBeginnerCookViewController.h"
#import "WMDownloadListViewController.h"
#import "WMPhotoSelectViewController.h"
#import "WMPhotoBrowserViewController.h"
#import "WMPhotoCaptionViewController.h"
#import "WMNewsDetailViewController.h"

@interface WMAIListViewController ()

@end

@implementation WMAIListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"效果集";
    NSArray *array = @[[WMAIListModel initWithTitle:@"选择图片样式" andTargetVC:[WMPhotoSelectViewController class]],
                       [WMAIListModel initWithTitle:@"放大效果浏览图片样式" andTargetVC:[WMPhotoBrowserViewController class]],
                       [WMAIListModel initWithTitle:@"带图片描述图片浏览" andTargetVC:[WMPhotoCaptionViewController class]],
                       [WMAIListModel initWithTitle:@"BeginnerCook" andTargetVC:[WMAIBeginnerCookViewController class]],
                       [WMAIListModel initWithTitle:@"下载按钮" andTargetVC:[WMDownloadListViewController class]],
                       [WMAIListModel initWithTitle:@"新闻详情" andTargetVC:[WMNewsDetailViewController class]]
                       ];
    

    for (int i = 0; i < array.count; i++) {
        WMAIListModel *model = array[i];
        model.index        = i+1;
        [model createAttributedString];
        [self.rows addObject:model];
    }
    [self.tableView reloadData];
}

#pragma mark -- UITableViewDelegate and UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.rows.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellId = @"CellId";
    WMAIListCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[WMAIListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    [cell setIndexPath:indexPath];
    [cell setAiModel:self.rows[indexPath.row]];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WMAIListModel *model = self.rows[indexPath.row];
    UIViewController * vc = [model.targetVC new];
    vc.title = model.title;
    [_svc wm_pushViewController:vc];
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
