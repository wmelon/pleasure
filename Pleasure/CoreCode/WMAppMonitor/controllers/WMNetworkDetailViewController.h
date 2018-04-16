//
//  WMNetworkDetailViewController.h
//  Pleasure
//
//  Created by Sper on 2018/4/16.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMBaseMonitorViewController.h"
#import "WMAPMHttpModel.h"

@interface WMNetworkDetailViewController : WMBaseMonitorViewController
@property (nonatomic , strong) WMAPMHttpModel *httpModel;
@end
