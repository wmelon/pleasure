//
//  UIScrollView+AppScrollView.h
//  Pleasure
//
//  Created by Sper on 2017/7/11.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MJRefresh/MJRefreshGifHeader.h>

typedef void(^WMRefreshBlock) (void);

@class WM_RefreshGifHeader;

@interface UIScrollView (AppScrollView)

@property (nonatomic , copy , readonly)WMRefreshBlock refreshHeaderBlock;
@property (nonatomic , copy , readonly)WMRefreshBlock refreshFooterBlock;

- (void)wm_RefreshHeaderWithBlock:(WMRefreshBlock)refreshBlock;
- (void)wm_RefreshFooterWithBlock:(WMRefreshBlock)refreshBlock;
- (void)wm_endRefreshing;
- (void)wm_beginRefreshing;

@end


@interface WM_RefreshGifHeader : MJRefreshGifHeader

@end





