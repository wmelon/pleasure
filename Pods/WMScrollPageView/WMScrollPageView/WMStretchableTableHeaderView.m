//
//  WMStretchableTableHeaderView.m
//  AllDemo
//
//  Created by Sper on 2017/7/31.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMStretchableTableHeaderView.h"
@interface WMStretchableTableHeaderView()
{
    CGRect initialFrame;
    CGFloat defaultViewHeight;
}
@property (nonatomic,retain) UITableView* tableView;
@property (nonatomic,retain) UIView* view;
@end


@implementation WMStretchableTableHeaderView
@synthesize tableView = _tableView;
@synthesize view = _view;

- (void)stretchHeaderForTableView:(UITableView*)tableView withView:(UIView*)view
{
    _tableView = tableView;
    _view = view;
    
    initialFrame       = _view.frame;
    defaultViewHeight  = initialFrame.size.height;
    
    UIView* emptyTableHeaderView = [[UIView alloc] initWithFrame:initialFrame];
    _tableView.tableHeaderView = emptyTableHeaderView;
    
    [_tableView addSubview:_view];
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    CGRect f = _view.frame;
    f.size.width = _tableView.frame.size.width;
    _view.frame = f;
    
    if(scrollView.contentOffset.y < 0) {
        CGFloat offsetY = (scrollView.contentOffset.y + scrollView.contentInset.top) * -1;
        initialFrame.origin.y = offsetY * -1;
        initialFrame.size.height = defaultViewHeight + offsetY;
        _view.frame = initialFrame;
    }
}

- (void)resizeView
{
    initialFrame.size.width = _tableView.frame.size.width;
    _view.frame = initialFrame;
}


@end
