//
//  WMAPMContentViewController.m
//  Pleasure
//
//  Created by Sper on 2018/4/18.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMAPMContentViewController.h"
#import "WMAPMJsonCell.h"

@interface WMAPMContentViewController ()<UITableViewDataSource ,UITableViewDelegate>
@property (nonatomic , copy  ) NSString *content;
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) NSMutableArray *dataArray;
@end

@implementation WMAPMContentViewController

- (void)setIntentDic:(NSDictionary *)dic{
    _content = [dic objectForKey:@"content"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"显示内容";
    UIButton *btnCopy = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    btnCopy.titleLabel.font = [UIFont systemFontOfSize:13];
    [btnCopy setTitle:@"Copy" forState:UIControlStateNormal];
    [btnCopy addTarget:self action:@selector(copyAction) forControlEvents:UIControlEventTouchUpInside];
    [btnCopy setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIBarButtonItem *btnright = [[UIBarButtonItem alloc] initWithCustomView:btnCopy];
    self.navigationItem.rightBarButtonItem = btnright;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView = tableView;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WMAPMJsonCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WMAPMJsonCell class])];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSData *data = [_content dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *tempDictQueryDiamond = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    self.dataArray = [NSMutableArray arrayWithArray:[WMJsonParse parseJsonWithData:tempDictQueryDiamond]];
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
    WMAPMJsonCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WMAPMJsonCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    WMJsonModel *jsonModel = self.dataArray[indexPath.row];
    __weak typeof(self) weakself = self;
    [cell setJsonModel:jsonModel clickHandle:^(WMJsonModel *jsonModel) {
        [weakself clickJsonModel:jsonModel];
    }];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [WMAPMJsonCell cellHeightWithModel:self.dataArray[indexPath.row]];
}
- (void)clickJsonModel:(WMJsonModel *)jsonModel{
    if (!jsonModel.canOpen) return;
    if (jsonModel.isOpen){
        /// 处理关闭
        if (jsonModel.subList.count){
            [self closeNodeWithJsonModel:jsonModel];
            /// 所有子集打开的都需要关闭掉
            [self.tableView reloadData];
        }
    }else {
        /// 处理展开
        if (jsonModel.subList.count){
            NSInteger index = [self.dataArray indexOfObject:jsonModel];
            NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index + 1, jsonModel.subList.count)];
            [self.dataArray insertObjects:jsonModel.subList atIndexes:set];
            [self.tableView reloadData];
        }
    }
    jsonModel.open = !jsonModel.open;
}
/// 递归关闭之前打开的，（从里向外关闭）
- (void)closeNodeWithJsonModel:(WMJsonModel *)jsonModel{
    [jsonModel.subList enumerateObjectsUsingBlock:^(WMJsonModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self closeNodeWithJsonModel:obj];
        obj.open = NO;
        [self.dataArray removeObject:obj];
    }];
}

- (void)copyAction {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = _content;
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"复制成功" delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [av show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [av dismissWithClickedButtonIndex:av.cancelButtonIndex animated:YES];
    });
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
