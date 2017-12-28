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
#import "WMNewGuideViewController.h"
#import "WMDemoViewController.h"

@interface WMAIListViewController ()

@end

@implementation WMAIListViewController
- (void)testA:(NSString *)a b:(NSString *)b c:(NSString *)c{
    NSLog(@"%@   %@   %@" , a , b , c);
}
- (void)routerTarget:(nullable id)target action:(nonnull SEL)action params:(nonnull id)param,... NS_REQUIRES_NIL_TERMINATION{
    
    NSMethodSignature *signature = [target methodSignatureForSelector:action];

    if (signature.numberOfArguments == 0) {
        return; //@selector未找到
    }
    NSMutableArray *arguments = [NSMutableArray arrayWithObjects:param, nil];
    // 定义一个指向个数可变的参数列表指针；
    va_list args;
    // 用于存放取出的参数
    id arg;
    // 初始化变量刚定义的va_list变量，这个宏的第二个参数是第一个可变参数的前一个参数，是一个固定的参数
    va_start(args, param);

    // 遍历全部参数 va_arg返回可变的参数(a_arg的第二个参数是你要返回的参数的类型)
    while ((arg = va_arg(args, NSString *))) {
        [arguments addObject:arg];
    }
    // 清空参数列表，并置参数指针args无效
    va_end(args);

    if (signature.numberOfArguments > [arguments count]+2) {
        return; //传入arguments参数不足。signature至少有两个参数，self和_cmd
    }

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:action];

    for(int i = 2; i < signature.numberOfArguments; i++)
    {
        id arg = [arguments objectAtIndex:i - 2];
        [invocation setArgument:&arg atIndex:i]; // The first two arguments are the hidden arguments self and _cmd
    }

    [invocation invoke]; // Invoke the selector
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"效果集";
    NSArray *array = @[[WMAIListModel initWithTitle:@"选择图片样式" andTargetVC:[WMPhotoSelectViewController class]],
                       [WMAIListModel initWithTitle:@"放大效果浏览图片样式" andTargetVC:[WMPhotoBrowserViewController class]],
                       [WMAIListModel initWithTitle:@"带图片描述图片浏览" andTargetVC:[WMPhotoCaptionViewController class]],
                       [WMAIListModel initWithTitle:@"BeginnerCook" andTargetVC:[WMAIBeginnerCookViewController class]],
                       [WMAIListModel initWithTitle:@"下载按钮" andTargetVC:[WMDownloadListViewController class]],
                       [WMAIListModel initWithTitle:@"新闻详情" andTargetVC:[WMNewsDetailViewController class]],
                       [WMAIListModel initWithTitle:@"新手引导页" andTargetVC:[WMNewGuideViewController class]],
                       [WMAIListModel initWithTitle:@"测试界面" andTargetVC:[WMDemoViewController class]]
                       ];
    

    for (int i = 0; i < array.count; i++) {
        WMAIListModel *model = array[i];
        model.index        = i+1;
        [model createAttributedString];
        [self.rows addObject:model];
    }
    [self.tableView reloadData];
}
- (UIColor *)naviBarBackgroundColor{
    return [UIColor whiteColor];
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
