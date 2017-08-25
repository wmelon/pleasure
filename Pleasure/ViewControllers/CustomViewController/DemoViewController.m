//
//  DemoViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/4.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "DemoViewController.h"
#import "Demo2ViewController.h"
#import "DemoTableViewController.h"

@interface DemoViewController ()
@property (nonatomic , strong)CAShapeLayer *elasticShaperLayer;
@property (nonatomic , strong)UIImageView *imageView;
@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"这是demo一";
//    [self requestRefresh];
//    [self beginRefresh];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    UIImage *image = [UIImage imageNamed:@"pc_bg"];
    imageView.userInteractionEnabled = YES;
    imageView.image =image;
//    CGFloat width = kScreenWidth;
//    CGFloat height = kScreenWidth * image.size.height / image.size.width;
//    imageView.frame = CGRectMake(0, 0, width, height);
    [self.view addSubview:imageView];
    
    self.imageView = imageView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(present)];
    [imageView addGestureRecognizer:tap];
}

- (void)present{
    Demo2ViewController * vc = [Demo2ViewController new];
    vc.srcImageView = self.imageView;
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)requestRefresh{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
//        for (int i = 0 ; i < 0 ; i++){
//            [self.rows addObject:@""];
//        }
        [self.rows removeAllObjects];
        [self finishRequest];
        [self realodEmptyView];
        [self.tableView reloadData];
    });
}
- (void)requestGetMore{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
//        for (int i = 0 ; i < 20 ; i++){
//            [self.rows addObject:@""];
//        }
        [self finishRequest];
        [self realodEmptyView];
        [self.tableView reloadData];
    });
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
    cell.textLabel.text = @"Hi All";
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row % 2 == 0){
        [self nextClick:nil];
    }else {
        [self tabClick:nil];
    }
    
}

- (void)tabClick:(UIButton *)button{
    DemoTableViewController * vc = [DemoTableViewController new];
    [_svc.topNavigationController pushViewController:vc animated:YES];
}

- (void)nextClick:(UIButton *)button{
    
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
