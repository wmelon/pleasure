//
//  WMNetworkDetailViewController.m
//  Pleasure
//
//  Created by Sper on 2018/4/16.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMNetworkDetailViewController.h"
#import "WMAPMContentViewController.h"

@interface WMCellItem : NSObject
@property (nonatomic , copy  ) NSString *title;
@property (nonatomic , copy  ) NSString *subTitle;
@property (nonatomic , strong) Class targetClass;
@end

@implementation WMCellItem
+ (instancetype)cellItemWithTitle:(NSString *)title subTitle:(NSString *)subTitle{
    return [WMCellItem cellItemWithTitle:title subTitle:subTitle targetClass:nil];
}
+ (instancetype)cellItemWithTitle:(NSString *)title subTitle:(NSString *)subTitle targetClass:(Class)targetClass{
    return [[WMCellItem alloc] initWithTitle:title subTitle:subTitle targetClass:targetClass];
}
- (instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle targetClass:(Class)targetClass{
    if (self = [super init]){
        _title = title;
        _subTitle = subTitle;
        if (_subTitle){
            _targetClass = targetClass;
        }
    }
    return self;
}
@end

@interface WMNetworkDetailViewController ()<UITableViewDataSource ,UITableViewDelegate>
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) NSArray<WMCellItem *> *dataArray;
@end

@implementation WMNetworkDetailViewController

- (void)setHttpModel:(WMAPMHttpModel *)httpModel{
    _httpModel = httpModel;
    NSString *response = [[NSString alloc] initWithData:self.httpModel.responseData encoding:NSUTF8StringEncoding];
    
    self.dataArray = @[[WMCellItem cellItemWithTitle:@"Request URL" subTitle:self.httpModel.url.absoluteString targetClass:[WMAPMContentViewController class]],
                       [WMCellItem cellItemWithTitle:@"Method" subTitle:self.httpModel.method],
                       [WMCellItem cellItemWithTitle:@"Status Code" subTitle:[NSString stringWithFormat:@"%ld",self.httpModel.statusCode]],
                       [WMCellItem cellItemWithTitle:@"Mine Type" subTitle:self.httpModel.mineType],
                       [WMCellItem cellItemWithTitle:@"Start Time" subTitle:self.httpModel.startTime],
                       [WMCellItem cellItemWithTitle:@"Total Duration" subTitle:self.httpModel.totalDuration],
                       [WMCellItem cellItemWithTitle:@"Request Body" subTitle:self.httpModel.requestBody targetClass:[WMAPMContentViewController class]],
                       [WMCellItem cellItemWithTitle:@"Response Body" subTitle:response targetClass:[WMAPMContentViewController class]]
                       ];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"请求详情";
    [self.view addSubview:self.tableView];
}

#pragma mark -- UITableViewDelegate and UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellId = @"CellId";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    WMCellItem *item = self.dataArray[indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.subTitle;
    if (item.targetClass){
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WMCellItem *item = self.dataArray[indexPath.row];
    if (item.targetClass){
        WMBaseMonitorViewController *vc = [item.targetClass new];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:item.subTitle forKey:@"content"];
        [vc setIntentDic:dict];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (UITableView *)tableView{
    if (_tableView == nil){
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
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
