//
//  UIScrollView+AppScrollView.m
//  Pleasure
//
//  Created by Sper on 2017/7/11.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "UIScrollView+AppScrollView.h"
#import <MJRefreshBackNormalFooter.h>
#import <objc/runtime.h>

@implementation UIScrollView (AppScrollView)
- (void)wm_RefreshHeaderWithBlock:(WMRefreshBlock)refreshBlock{
    self.refreshHeaderBlock = refreshBlock;
    
    // 下拉刷新
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    WM_RefreshGifHeader *header = [WM_RefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestRefresh)];
    
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    
    // 隐藏状态
    header.stateLabel.hidden = YES;
    
    // 设置header
    self.mj_header = header;
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    self.mj_header.automaticallyChangeAlpha = YES;
}

- (void)requestRefresh{
    if (self.refreshHeaderBlock){
        self.refreshHeaderBlock();
    }
}
- (void)requestMore{
    if (self.refreshFooterBlock){
        self.refreshFooterBlock();
    }
}
- (void)wm_beginRefreshing{
    [self.mj_header beginRefreshing];
}

- (void)wm_RefreshFooterWithBlock:(WMRefreshBlock)refreshBlock{
    self.refreshFooterBlock = refreshBlock;
    
    __weak typeof(self) weakself = self;
    // 上拉刷新
    self.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakself requestMore];
    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    self.mj_footer.automaticallyChangeAlpha = YES;
}
- (void)wm_endRefreshing{
    [self.mj_header endRefreshing];
    [self.mj_footer endRefreshing];
}

- (void)setRefreshHeaderBlock:(WMRefreshBlock)refreshHeaderBlock{
    objc_setAssociatedObject(self, @selector(refreshHeaderBlock), refreshHeaderBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (WMRefreshBlock)refreshHeaderBlock{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setRefreshFooterBlock:(WMRefreshBlock)refreshFooterBlock{
    objc_setAssociatedObject(self, @selector(refreshFooterBlock), refreshFooterBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (WMRefreshBlock)refreshFooterBlock{
    return objc_getAssociatedObject(self, _cmd);
}
@end



#define MJRefreshStateIdleImagesCount 14
#define MJRefreshStateRefreshingImagesCount 13

@implementation WM_RefreshGifHeader

- (void)prepare {
    [super prepare];
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    for (NSInteger idx = 1; idx <= MJRefreshStateIdleImagesCount*3; idx++) {
        UIImage *image = [UIImage imageNamed:@"pull_pulling_1"];
        [idleImages addObject:image];
    }
    for (NSInteger idx = 1; idx <= MJRefreshStateIdleImagesCount; idx++ ) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"pull_pulling_%zd", idx]];
        [idleImages addObject:image];
    }
    [self setImages:idleImages forState:MJRefreshStateIdle];
    
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger idx = 1; idx <= MJRefreshStateRefreshingImagesCount; idx++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"pull_refreshing_%zd", idx]];
        [refreshingImages addObject:image];
    }
    
    // 设置正在刷新状态的动画图片
    [self setImages:refreshingImages duration:0.5 forState:MJRefreshStateRefreshing];
    
}
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    [super setState:state];
    if (state == MJRefreshStateIdle) {
        [self.gifView startAnimating];
    }
}


@end






