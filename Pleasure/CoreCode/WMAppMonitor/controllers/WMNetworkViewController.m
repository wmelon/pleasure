//
//  WMNetworkViewController.m
//  Pleasure
//
//  Created by Sper on 2018/3/13.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMNetworkViewController.h"
#import "WMHttpDatasource.h"
#import "WMHttpRequestCell.h"
#import "WMNetworkDetailViewController.h"

@interface WMNetworkViewController ()<UITableViewDataSource , UITableViewDelegate>
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) NSArray<WMAPMHttpModel *> *dataArray;
@end

@implementation WMNetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor yellowColor];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [button addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"清空" forState:UIControlStateNormal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WMHttpRequestCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WMHttpRequestCell class])];
    
    self.dataArray = [[WMHttpDatasource shareInstance] httpRequestArray];
    [self.tableView reloadData];
}
- (void)clear{
    [[WMHttpDatasource shareInstance] clearAllHttpRequest];
    self.dataArray = nil;
    [self.tableView reloadData];
}
#pragma mark -- UITableViewDelegate and UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WMHttpRequestCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WMHttpRequestCell class])];
    
    WMAPMHttpModel *httpModel = self.dataArray[indexPath.row];
    cell.httpMpdel = httpModel;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WMNetworkDetailViewController *detailVc = [[WMNetworkDetailViewController alloc] init];
    detailVc.httpModel = self.dataArray[indexPath.row];
    [self.navigationController pushViewController:detailVc animated:YES];
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
