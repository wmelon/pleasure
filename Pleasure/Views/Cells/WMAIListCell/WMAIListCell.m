//
//  WMAIListCell.m
//  Pleasure
//
//  Created by Sper on 2017/8/14.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMAIListCell.h"
#import <POP.h>

@interface WMAIListCell()
@property (nonatomic, strong) UILabel  *titlelabel;
@property (nonatomic, strong) UILabel  *subTitleLabel;
@end

@implementation WMAIListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        
        self.titlelabel      = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 290, 25)];
        [self.contentView addSubview:self.titlelabel];
        
        self.subTitleLabel           = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, 290, 10)];
        self.subTitleLabel.font      = [UIFont systemFontOfSize:8];
        self.subTitleLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.subTitleLabel];
        
    }
    return self;
}

- (void)setAiModel:(WMAIListModel *)aiModel{
    _aiModel = aiModel;
    
    self.titlelabel.attributedText = aiModel.titleString;
    self.subTitleLabel.text = [NSString stringWithFormat:@"%@",[aiModel.targetVC class]];
    if (self.indexPath.row % 2) {
        
        self.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.05f];
        
    } else {
        
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    [super setHighlighted:highlighted animated:animated];
    
    if (self.highlighted) {
        
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.duration           = 0.1f;
        scaleAnimation.toValue            = [NSValue valueWithCGPoint:CGPointMake(0.95, 0.95)];
        [self.titlelabel pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
        
    } else {
        POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.toValue             = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        scaleAnimation.velocity            = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
        scaleAnimation.springBounciness    = 20.f;
        [self.titlelabel pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
