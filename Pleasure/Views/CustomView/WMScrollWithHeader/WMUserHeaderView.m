//
//  WMUserHeaderView.m
//  AllDemo
//
//  Created by Sper on 2017/7/26.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMUserHeaderView.h"

@interface WMUserHeaderView()
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *compayLabel;
@property (weak, nonatomic) IBOutlet UILabel *roleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@end

@implementation WMUserHeaderView

+(WMUserHeaderView *)userHeaderView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"WMUserHeaderView" owner:nil options:nil] firstObject];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.userAvatarImageView.layer.cornerRadius = 80 / 2.0;
    self.userAvatarImageView.layer.borderWidth = 1;
    self.userAvatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.userAvatarImageView.layer.masksToBounds = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
