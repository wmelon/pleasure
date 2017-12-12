//
//  WMAIListViewController.h
//  Pleasure
//
//  Created by Sper on 2017/8/14.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMBaseTableViewController.h"

@interface WMAIListViewController : WMBaseTableViewController
- (void)routerTarget:(nullable id)target action:(nonnull SEL)action params:(nonnull id)param,... NS_REQUIRES_NIL_TERMINATION;


@end
