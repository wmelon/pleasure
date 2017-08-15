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

@interface WMAIListViewController ()

@end

@implementation WMAIListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"效果集";
    NSArray *array = @[[WMAIListModel initWithTitle:@"衰减动画" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"弹簧动画" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"跑马灯效果" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"Pop缩放动画" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"防百度加载提示" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"facebook辉光动画" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"Gradinent转场动画" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"scrollViews视差效果" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"wellCome加载动画" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"多个按钮按照微博九宫格排布" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"模仿qq图片浏览" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"researchKit的lineChart" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"自定义模态转场动画" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"心电图" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"Cell点击动画" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"设置页面" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"登录页面" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"天猫Loading" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"多人游戏" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"不规则按钮" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"自适应高度textView" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"模糊效果" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"音乐播放按钮" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"航班信息" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"包裹" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"gradientLayer动画" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"离散图" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"BeginnerCook" andTargetVC:[WMAIBeginnerCookViewController class]],
                       [WMAIListModel initWithTitle:@"本地闹钟" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"Twitter开场动画" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"画板" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"下载按钮" andTargetVC:[WMDownloadListViewController class]],
                       [WMAIListModel initWithTitle:@"officebuddy" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"折叠" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"类似Safari效果" andTargetVC:[UIViewController class]],
                       [WMAIListModel initWithTitle:@"播放按钮 + loading" andTargetVC:[UIViewController class]]
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
    [_svc wm_pushViewController:[model.targetVC new]];
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
