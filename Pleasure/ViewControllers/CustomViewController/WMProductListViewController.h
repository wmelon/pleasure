//
//  WMProductListViewController.h
//  Pleasure
//
//  Created by Sper on 2017/7/27.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMBaseTableViewController.h"


@class WMProductListViewController;

@protocol WMProductListViewControllerDelegate <NSObject>

- (void)productListViewController:(WMProductListViewController *)productListViewController didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface WMProductListViewController : UITableViewController
@property (nonatomic , weak) id<WMProductListViewControllerDelegate> delegate;

@property (nonatomic , copy) NSString * titleString;
@end
