//
//  WMDebugViewController.m
//  Pleasure
//
//  Created by Sper on 2018/3/13.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMDebugViewController.h"
#import "WMNetworkViewController.h"
#import "WMCrashViewController.h"
#import "WMDebugManager.h"

@interface WMSourceEntity : NSObject
@property (nonatomic , strong) NSString *title;
@property (nonatomic , strong) Class targetClass;
@end
@implementation WMSourceEntity
+ (instancetype)initWithTitle:(NSString *)title andTargetVC:(Class)class{
    return [[self alloc] initWithTitle:title andTargetVC:class];
}
- (instancetype)initWithTitle:(NSString *)title andTargetVC:(Class)class{
    if (self = [super init]){
        self.title = title;
        self.targetClass = class;
    }
    return self;
}
@end

@interface WMDebugViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) NSArray *dataSource;
@end

@implementation WMDebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"欢迎来到APM世界";
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    self.dataSource = @[[WMSourceEntity initWithTitle:@"network监控" andTargetVC:[WMNetworkViewController class]],
                        [WMSourceEntity initWithTitle:@"crash监控" andTargetVC:[WMCrashViewController class]],
                         ];
    [self.tableView reloadData];
    
    [self showLeftCloseBtn];
}
- (void)showLeftCloseBtn{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    button.backgroundColor = [UIColor clearColor];
    [button setTitle:@"关闭" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem  alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = item;
}
- (void)closeClick:(UIButton *)button{
    [WMDebugManager hiddenDebugController];
}
#pragma mark -- UITableViewDelegate and UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellId = @"CellId";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    WMSourceEntity *source = self.dataSource[indexPath.row];
    cell.textLabel.text = source.title;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WMSourceEntity *source = self.dataSource[indexPath.row];
    UIViewController *targetVc = [source.targetClass new];
    targetVc.title = source.title;
    if ([targetVc isKindOfClass:[UIViewController class]]){
        [self.navigationController pushViewController:targetVc animated:YES];
    }
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
