//
//  XHWaterCollectionCell.h
//  仿花瓣
//
//  Created by Sper on 16/8/12.
//  Copyright © 2016年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HuabanModel.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define itemWaterWidth ((kScreenWidth - 30) / 2.0)

@interface XHWaterCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (nonatomic , strong)HuabanModel *model;
+ (CGSize)getSize:(HuabanModel *)model;
@end
