//
//  WMNewsDetailViewController.m
//  Pleasure
//
//  Created by Sper on 2017/9/7.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMNewsDetailViewController.h"
#import <WebKit/WebKit.h>

@interface WMTouchsGesturesTableView : UITableView

@end

@implementation WMTouchsGesturesTableView

//允许同时识别多个手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end


@interface WMNewsDetailViewController ()<UITableViewDelegate ,UITableViewDataSource ,UIWebViewDelegate , UIScrollViewDelegate , WKUIDelegate,
WKNavigationDelegate >
@property (nonatomic , strong) WKWebView *webView;

@property (nonatomic , strong) WMTouchsGesturesTableView *tableView;

@property (nonatomic, assign) CGFloat     heightOfContent;

@property (nonatomic , assign) BOOL tableViewScrollEnable;

@property (nonatomic , assign) BOOL webViewScrollEnable;
@end

@implementation WMNewsDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupView];
}

- (void)setupView {
    [self.view addSubview:self.tableView];
    self.webViewScrollEnable = YES;
    self.tableViewScrollEnable = NO;
    [self loadHtml];
}

#pragma mark 记载html
- (void)loadHtml{
    NSURL *url = [NSURL URLWithString:@"http://www.cocoachina.com/bbs/read.php?tid-309899-page-4.html"];
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5.0f]];
    
    
//    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"details" ofType:@"html"];
//    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
//    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
//    [self.webView loadHTMLString:htmlString baseURL:baseURL];
}

//页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    __weak typeof(self) weakself = self;
    [webView evaluateJavaScript:@"document.body.offsetHeight;" completionHandler:^(id _Nullable any, NSError * _Nullable error) {
        
        NSString *heightStr = [NSString stringWithFormat:@"%@",any];
        
        weakself.heightOfContent = heightStr.floatValue;
//        weakself.tableView.tableHeaderView.height = heightStr.floatValue;
//        weakself.tableView.contentSize = CGSizeMake(self.view.frame.size.width, self.tableView.contentSize.height + heightStr.floatValue - kScreenHeight - 64);
    }];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat contentOffY = scrollView.contentOffset.y;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//    CGRect rect = [cell convertRect:self.tableView.frame toView:self.view];
    
    CGRect rect  = [cell convertRect:cell.frame toView:self.view];
    
    NSLog(@"%f    %f" , contentOffY  , rect.origin.y);
    
    
    if (scrollView == self.webView.scrollView){
        if ((contentOffY + self.webView.frame.size.height >= self.heightOfContent) && self.heightOfContent > 0){
            self.webViewScrollEnable = NO;
            self.tableViewScrollEnable = YES;
        }
        if (self.webViewScrollEnable == NO){
            self.webView.scrollView.contentOffset = CGPointMake(0, self.heightOfContent - self.webView.frame.size.height);
        }
    }
    
    if (self.tableViewScrollEnable){
        if (rect.origin.y > 64){
            self.tableViewScrollEnable = NO;
            self.webViewScrollEnable = YES;
        }
    }

    if (self.tableViewScrollEnable == NO){
        self.tableView.contentOffset = CGPointMake(0, -64);
    }
}


#pragma mark -- UITableViewDelegate and UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0 ? 1 : 20;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell;
    if (indexPath.section == 0){
    
        static NSString * cellId = @"webCellId";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            [cell.contentView addSubview:self.webView];
        }
        
    }else {
        static NSString * cellId = @"CellId";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        cell.textLabel.text = @"Hi";
        
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 0 ? self.webView.frame.size.height : 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 创建webView
- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
//        if(CNiOS_9_OR_LATER) {
            configuration.allowsInlineMediaPlayback = YES;
            configuration.requiresUserActionForMediaPlayback = YES;
            configuration.allowsPictureInPictureMediaPlayback = YES;
//        }
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64) configuration:configuration];
//        _webView.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
//        _webView.scrollView.scrollEnabled = NO;
        _webView.navigationDelegate = self;
        _webView.allowsBackForwardNavigationGestures = YES;
        _webView.scrollView.backgroundColor = [UIColor whiteColor];
        _webView.UIDelegate = self;
        _webView.scrollView.delegate = self;
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
//        [_webView.scrollView addSubview:self.tableView];
//        
//        
//        [_webView evaluateJavaScript:@"document.body.offsetHeight"completionHandler:^(id _Nullable result,NSError *_Nullable error) {
//
            
////            NSLog(@"%@" , result);
//            //获取页面高度，并重置webview的frame
////            NSString *javaScriptString = @"document.body.offsetHeight";
//            CGFloat heightContent = [result floatValue];
//            _heightOfContent = heightContent;
//            
//            self.webView.scrollView.contentSize = CGSizeMake(kScreenWidth, _heightOfContent + kScreenHeight + 1000);
//            self.tableView.frame = CGRectMake(0, _heightOfContent + 1000, kScreenWidth, kScreenHeight);
//        }];
        
    }
    return _webView;
}

- (UITableView *)tableView{
    if (_tableView == nil){
        _tableView = [[WMTouchsGesturesTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
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
