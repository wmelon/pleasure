//
//  WMNewGuideViewController.m
//  Pleasure
//
//  Created by Sper on 2017/12/28.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMNewGuideViewController.h"
#import "ZWMGuideView.h"

@protocol WMTestViewProtocol <NSObject>
- (void)again;
@end

@interface WMTestView : UIView
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *viewsArray;
@property (nonatomic , weak) id <WMTestViewProtocol> delegate;
@end

@implementation WMTestView
- (IBAction)again:(id)sender {
    if ([self.delegate respondsToSelector:@selector(again)]){
        [self.delegate again];
    }
}
@end

@interface WMNewGuideViewController ()<ZWMGuideViewDataSource,ZWMGuideViewLayoutDelegate , WMTestViewProtocol>
@property (strong, nonatomic) NSArray<UIView *> *viewsArray;
@property (strong, nonatomic) ZWMGuideView *guideView;
@property (strong, nonatomic) NSArray *descriptionArrar;
@property (strong, nonatomic) WMTestView *testView;
@end

@implementation WMNewGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.testView];
    self.viewsArray = self.testView.viewsArray;
    
    self.descriptionArrar = @[@"^^提莫队长正在送命^^！",
                              @"^^这是另一条消息^^！",
                              @"^^人人都会打王者农药^^！",
                              @"^^我好想说点儿什么^^！",
                              @"^^你的剑就是我的剑^^！",
                              @"^^见识下真正的坑货吧^^！",
                              @"欢迎来到小学生联盟! 小学生还有30秒到达战场！碾碎他们！全军出鸡！"];
    [self.guideView show];
}

#pragma mark -- WMTestViewProtocol
- (void)again{
    [self.guideView show];
}
#pragma mark -- ZWMGuideViewDataSource（必须实现的数据源方法）
- (NSInteger)numberOfItemsInGuideMaskView:(ZWMGuideView *)guideMaskView{
    return self.viewsArray.count;
    
}
- (UIView *)guideMaskView:(ZWMGuideView *)guideMaskView viewForItemAtIndex:(NSInteger)index{
    UIView *view = self.viewsArray[index];
    return view;
    
}
- (NSString *)guideMaskView:(ZWMGuideView *)guideMaskView descriptionLabelForItemAtIndex:(NSInteger)index{
    return self.descriptionArrar[index];
}

#pragma mark -- ZWMGuideViewLayoutDelegate
- (CGFloat)guideMaskView:(ZWMGuideView *)guideMaskView cornerRadiusForItemAtIndex:(NSInteger)index
{
    if (index == self.viewsArray.count-1)
    {
        return 30;
    }
    
    return 5;
}
- (WMTestView *)testView{
    if (_testView == nil){
        _testView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([WMTestView class]) owner:nil options:0].lastObject;
        _testView.delegate = self;
        _testView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight - kNavBarHeight);
    }
    return _testView;
}
- (ZWMGuideView *)guideView
{
    if (_guideView == nil) {
        _guideView = [[ZWMGuideView alloc] initWithFrame:self.view.bounds];
        _guideView.dataSource = self;
        _guideView.delegate = self;
    }
    return _guideView;
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
