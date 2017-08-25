//
//  HomeViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/3.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "HomeViewController.h"
#import "DemoViewController.h"

#define kCityButtonHeight 24
#define kalpha 0.45
#define kButtonHeight 26

@interface HomeViewController (){
    UIButton * leftButton;
    UIButton * searchButton;
    UIButton * rightButton;
    UILabel * tipLabel;
    UIImageView * searchImageView;
}

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configNavigationBar];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 49);
    
    UIImageView * headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    headerView.image = [UIImage imageNamed:@"01.jpeg"];
    headerView.contentMode = UIViewContentModeScaleAspectFill;
    headerView.clipsToBounds = YES;
    self.tableView.tableHeaderView = headerView;
    
    self.navigationBarBackgroundView.backgroundColor = [UIColor orangeColor];
    
    
    [self requestRefresh];
}

- (void)configNavigationBar{
    leftButton = [[UIButton alloc] initWithFrame:CGRectMake(16, 20 + (44 - kCityButtonHeight) / 2, 65, kCityButtonHeight)];
    [leftButton setTitle:@"上海" forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(changeAddressAction:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    leftButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [leftButton setBackgroundColor:UIColorFromARGB(0x000000,kalpha)];
    [leftButton setBackgroundImage:[UIImage imageWithColor:[UIColor grayColor]] forState:UIControlStateHighlighted];
    leftButton.layer.cornerRadius = kCityButtonHeight / 2;
    leftButton.layer.masksToBounds = YES;
    
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = barButton;
    
#pragma mark -- 搜索按钮
    searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20 + (44 - kCityButtonHeight) / 2 , kScreenWidth, kCityButtonHeight)];
    [searchButton addTarget:self action:@selector(didClickSearchBar:) forControlEvents:UIControlEventTouchUpInside];
    [searchButton setBackgroundColor:[UIColor whiteColor]];
    searchButton.layer.cornerRadius = kButtonHeight / 2;
    searchButton.layer.masksToBounds = YES;
    [searchButton setBackgroundImage:[UIImage imageWithColor:[UIColor grayColor]] forState:UIControlStateHighlighted];
    
    searchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 5, 15, 15)];
    searchImageView.image = [UIImage imageNamed:@"navBar_search_grey"];
    [searchButton addSubview:searchImageView];
    
    tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, searchButton.frame.size.width - CGRectGetMaxX(searchImageView.frame) - 10, kButtonHeight)];
    tipLabel.text = @"请输入美发师姓名／门店名";
    tipLabel.textColor = [UIColor textColor];
    tipLabel.font = [UIFont systemFontOfSize:12];
    tipLabel.textAlignment = NSTextAlignmentLeft;
    [searchButton addSubview:tipLabel];
    
    self.navigationItem.titleView = searchButton;
    
    
    
    rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, (44 - kCityButtonHeight) / 2, 80, kButtonHeight)];
    [rightButton setBackgroundColor:UIColorFromARGB(0x000000,kalpha)];
    [rightButton setTitle:@"扫一扫" forState:UIControlStateNormal];
    rightButton.layer.cornerRadius = kButtonHeight / 2;
    rightButton.layer.masksToBounds = YES;
    [rightButton setBackgroundImage:[UIImage imageWithColor:[UIColor grayColor]] forState:UIControlStateHighlighted];
    
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
}
- (void)changeAddressAction:(UIButton *)button{
    
}

- (void)didClickSearchBar:(UIButton *)didClickSearchBar{
    
}
- (void)requestRefresh{
    for (int i = 0 ; i < 120 ; i++){
        [self.rows addObject:@""];
    }
    [self finishRequest];
    [self realodEmptyView];
    [self.tableView reloadData];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        
//        
//    });
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
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = @"Hi";
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    [_svc wm_pushViewController:[DemoViewController new]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset_Y = scrollView.contentOffset.y;
    CGFloat alpha = (offset_Y)/100.0f;
    self.navigationBarBackgroundView.alpha = alpha;
    
    if (offset_Y < 0){
        self.navigationController.navigationBar.alpha = 1 + alpha * 5;
    }else {
        self.navigationController.navigationBar.alpha = 1.0;
    }
}


- (BOOL)shouldShowBackItem{
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
