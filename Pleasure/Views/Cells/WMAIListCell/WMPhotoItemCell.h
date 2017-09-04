//
//  WMPhotoItemCell.h
//  Pleasure
//
//  Created by Sper on 2017/9/4.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^ClickHandle)(UIImageView *imageView);

@interface WMPhotoItemCell : UICollectionViewCell
@property (nonatomic , strong) UIButton *photoButton;
@property (nonatomic , strong) NSString *photoUrl;
@property (nonatomic , assign) NSInteger index;
@property (nonatomic , copy) ClickHandle handle;
- (void)setIndex:(NSInteger)index clickHandle:(ClickHandle)handle;
@end
