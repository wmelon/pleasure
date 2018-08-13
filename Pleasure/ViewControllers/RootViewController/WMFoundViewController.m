//
//  WMFoundViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/25.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMFoundViewController.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "HuabanModel.h"
#import "XHWaterCollectionCell.h"
#import "WMTransitionProtocol.h"

@interface WMFoundViewController ()<CHTCollectionViewDelegateWaterfallLayout , WMTransitionProtocol>
@property (nonatomic , strong) NSIndexPath *selectIndexPath;
@end

@implementation WMFoundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configCollectionView];
    /// 开始加载数据
    [self beginRefresh];
}

- (void)configCollectionView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenHeight, 100)];
    view.backgroundColor = [UIColor redColor];
    [self.view addSubview:view];
    
    CHTCollectionViewWaterfallLayout * layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.columnCount = 2;
    // Change individual layout attributes for the spacing between cells
    layout.minimumColumnSpacing = 10.0;
    layout.minimumInteritemSpacing = 10.0;
    //  设置collectionView的 四周的内边距
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.collectionView.frame = CGRectMake(0, CGRectGetMaxY(view.frame), kScreenWidth, kScreenHeight - kTabBarHeight - CGRectGetMaxY(view.frame));
    self.collectionView.collectionViewLayout = layout;
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([XHWaterCollectionCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([XHWaterCollectionCell class])];
}

- (void)requestDataWithTurnPage:(NSDictionary *)turnPage{
    WMWeakself
    WMRequestAdapter *adapter = [WMRequestAdapter requestWithUrl:@"https://test.api.nanguache.com/salon/api/productv2/mainList?ver=2.22.0&platform=iPhone7,2&cityid=1&apptype=pumpkin_iOS&sysVersion=iOS9.3&nid=68f36e3227efbd21dee2ac09bb1864a2&channel=AppStore&secureKey=b7e633738061d1394d6ea02ae139c75f&token=266acc3656ac700ca8f5b8b6ee833a76&signature=e9a95c04a23edbf9a9212606c47aa79d&customerLng=121.417&customerLat=31.2044&nextIndex=0&prevEndIndex=" requestMethod:(WMRequestMethodGET)];
    [adapter requestParameters:turnPage];
    [WMRequestManager requestWithSuccessHandler:^(WMRequestAdapter *request) {
        [weakself parseDataWithRequest:request];
    } cacheHandler:^(WMRequestAdapter *request) {
        [weakself parseDataWithRequest:request];
    } failureHandler:^(WMRequestAdapter *request) {
        [weakself finishRequest];
    } requestAdapter:adapter];
}
- (void)parseDataWithRequest:(WMRequestAdapter *)request{
    NSDictionary *responseObject = request.responseDictionary;
    NSArray *array = [HuabanModel pc_modelListWithArray:responseObject[@"pins"]];
    if (self.isRefresh) {
        [self.rows setArray:array];
    }else {
        [self.rows addObjectsFromArray:array];
    }
    [self.collectionView reloadData];
    [self finishRequest];
}
#pragma mark -- UICollectionViewDelegate and UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.rows.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    XHWaterCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([XHWaterCollectionCell class]) forIndexPath:indexPath];
    HuabanModel *model = [self.rows objectAtIndex:indexPath.row];
    [cell setModel:model];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    HuabanModel *model = [self.rows objectAtIndex:indexPath.row];
    return [XHWaterCollectionCell getSize:model];
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.selectIndexPath = indexPath;
    XHWaterCollectionCell * cell =(XHWaterCollectionCell *)[self.collectionView cellForItemAtIndexPath:self.selectIndexPath];
    
    /**这段代码是控制上下移动位置*/
    CGRect frrr = [self.view convertRect:cell.frame fromView:collectionView];
    CGPoint point = self.collectionView.contentOffset;
    point.y -= (self.collectionView.frame.size.height*0.5 - ((frrr.origin.y - CGRectGetMinY(collectionView.frame)) + frrr.size.height*0.5));
    if (point.y < -35) {
        point.y = -kNavBarHeight;
    }
    [self.collectionView setContentOffset:point animated:YES];
    
    
    WMHuaBanDetailViewController *detailVc = [WMHuaBanDetailViewController new];
    detailVc.headerImage = cell.photoImageView.image;
    [_svc wm_pushViewController:detailVc];
}
#pragma mark -- WMTransitionProtocol
- (UIView *)targetTransitionView{
    XHWaterCollectionCell * cell =(XHWaterCollectionCell *)[self.collectionView cellForItemAtIndexPath:self.selectIndexPath];
    return cell.photoImageView;
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
