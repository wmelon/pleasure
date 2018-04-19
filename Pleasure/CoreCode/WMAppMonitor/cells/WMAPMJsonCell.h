//
//  WMAPMJsonCell.h
//  Pleasure
//
//  Created by Sper on 2018/4/19.
//  Copyright © 2018年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMJsonParse.h"

typedef void(^WMButtonClickHandle)(WMJsonModel *jsonModel);

@interface WMAPMJsonCell : UITableViewCell
+ (CGFloat)cellHeightWithModel:(WMJsonModel *)jsonModel;
- (void)setJsonModel:(WMJsonModel *)jsonModel clickHandle:(WMButtonClickHandle)clickHandle;
@end
