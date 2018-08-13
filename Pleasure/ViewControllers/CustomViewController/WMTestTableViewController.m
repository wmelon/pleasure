//
//  WMTestTableViewController.m
//  Pleasure
//
//  Created by Sper on 2018/5/24.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMTestTableViewController.h"
#import "WMCNNewsModel.h"

@interface WMTestTableViewController ()

@end

@implementation WMTestTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self beginRefresh];
    /// 这个界面有三四个接口    只有一部分需要下拉刷新   ，只有列表接口是要求上拉加载的。。。。
    [self requestDataWithLoading];
}
#pragma mark -- 网络请求
/// 下拉刷新
- (void)requestNewData{
    [super requestNewData];
}
/// 翻页加载更多
- (void)requestMoreData{
    [super requestMoreData];
    
}
/// 带大loading的请求数据
- (void)requestDataWithLoading{
    [self.tableView showLoading];
    [self requestProductList];
}
/// 筛选请求数据
- (void)FilteringRequest{
    
}
/// 请求作品列表
- (void)requestProductList{
    /// 加载   空态   错误态    是否应该显示在一个视图上面？？？ 什么时候显示什么时候隐藏  ？？？？？
    WMWeakself
    WMRequestAdapter *adapter = [WMRequestAdapter requestWithUrl:@"http://shcnapp.changning.sh.cn:8090/cnnews/api/getNewsList.do?id=4028cb815e0d5e96015e0d74b7380003" requestMethod:(WMRequestMethodGET)];
    [WMRequestManager requestWithSuccessHandler:^(WMRequestAdapter *request) {
        NSArray *array = [WMCNNewsModel pc_modelListWithArray:request.responseDictionary[@"data"]];
        if (weakself.isRefresh){
            [weakself.rows setArray:array];
        }else {
            [weakself.rows addObjectsFromArray:array];
        }
//        [weakself.tableView showLoadEmptyMessage:<#(NSString *)#> image:<#(UIImage *)#>]
        [weakself.tableView reloadData];
    } failureHandler:^(WMRequestAdapter *request) {
        [weakself.tableView showLoadFailedWithRetryBlcok:^{
            [weakself requestDataWithLoading];
        }];
    } requestAdapter:adapter];
}
#pragma mark -- UITableViewDelegate and UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.rows.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellId = @"CellId";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    WMCNNewsModel *newsModel = self.rows[indexPath.row];
    cell.textLabel.text = newsModel.title;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
