//
//  WMNewsDetailViewController.m
//  Pleasure
//
//  Created by Sper on 2017/9/7.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMNewsDetailViewController.h"
#import <WebKit/WebKit.h>

@interface WMNewsDetailViewController ()<UITableViewDelegate ,UITableViewDataSource ,UIWebViewDelegate , UIScrollViewDelegate , WKUIDelegate,
WKNavigationDelegate ,UIWebViewDelegate>
//@property (nonatomic , strong) UIWebView *webView;
@property (nonatomic , strong) WKWebView *webView;
@property (nonatomic , strong) UITableView *tableView;

@end

@implementation WMNewsDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupView];
}

- (void)setupView {
    [self.view addSubview:self.tableView];
    [self loadHtml];
}

#pragma mark 记载html
- (void)loadHtml{
    NSURL *url = [NSURL URLWithString:@"http://www.toutiao.com/a6463320476507701773/"];
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5.0f]];
}

//页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    __weak typeof(self) weakself = self;
    [webView evaluateJavaScript:@"document.body.offsetHeight;" completionHandler:^(id _Nullable any, NSError * _Nullable error) {
        
        NSString *heightStr = [NSString stringWithFormat:@"%@",any];
        
        weakself.webView.height = heightStr.floatValue;
        
        [weakself.tableView reloadData];
    }];
}

//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    self.webView.height = self.webView.scrollView.contentSize.height;
//    [self.tableView reloadData];
//}


#pragma mark -- UITableViewDelegate and UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0 ? 1 : 20;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell;
    static NSString * cellId = @"CellId";
    cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    if (indexPath.section == 0){
        cell.textLabel.text = @"这是第一组的 Hi";
    }else {
        
        cell.textLabel.text = @"Hi";
        
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return section == 0 ? self.webView : [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0 ? self.webView.height : CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
#pragma mark - 创建webView
- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
//        if(CNiOS_9_OR_LATER) {
//            configuration.allowsInlineMediaPlayback = YES;
//            configuration.requiresUserActionForMediaPlayback = YES;
//            configuration.allowsPictureInPictureMediaPlayback = YES;
//        }
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64) configuration:configuration];
        _webView.navigationDelegate = self;
        _webView.allowsBackForwardNavigationGestures = YES;
        _webView.scrollView.backgroundColor = [UIColor whiteColor];
        _webView.scrollView.scrollEnabled = NO;
        _webView.UIDelegate = self;
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
        
    }
    return _webView;
}
//- (UIWebView *)webView
//{
//    if (!_webView) {
//        UIWebView *web = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 700)];
//        _webView = web;
//        _webView.delegate = self;
//    }
//    return _webView;
//}

- (UITableView *)tableView{
    if (_tableView == nil){
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.dataSource =  self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
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
