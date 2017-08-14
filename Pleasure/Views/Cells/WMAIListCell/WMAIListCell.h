//
//  WMAIListCell.h
//  Pleasure
//
//  Created by Sper on 2017/8/14.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMAIListModel.h"

@interface WMAIListCell : UITableViewCell
@property (nonatomic , strong) WMAIListModel *aiModel;
@property (nonatomic , strong) NSIndexPath *indexPath;
@end
