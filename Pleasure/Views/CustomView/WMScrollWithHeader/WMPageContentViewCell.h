//
//  WMPageContentViewCell.h
//  Pleasure
//
//  Created by Sper on 2017/7/27.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMBaseContentController.h"

@class WMPageContentViewCell;

@protocol WMPageContentViewCellDataSource <NSObject>

/// 默认是1
- (NSInteger)numberOfCountInContentCell:(WMPageContentViewCell *)contentCell;

- (WMBaseContentController *)contentCell:(WMPageContentViewCell *)contentCell contentControllerAtIndex:(NSInteger)index;

@end

@interface WMPageContentViewCell : UITableViewCell

@property (nonatomic , assign)NSInteger selectIndex;
@property (nonatomic , assign)BOOL canScroll;

@property (nonatomic , weak) id<WMPageContentViewCellDataSource> dataSource;

+ (instancetype)cellForTableView:(UITableView *)tableView;
@end
