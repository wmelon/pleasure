//
//  XHWaterCollectionCell.m
//  仿花瓣
//
//  Created by Sper on 16/8/12.
//  Copyright © 2016年 WM. All rights reserved.
//

#import "XHWaterCollectionCell.h"
#import "UIImageView+WebCache.h"

@interface XHWaterCollectionCell()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoHeightConstraint;
//@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
//@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
//@property (weak, nonatomic) IBOutlet UILabel *boardNameLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
//@property (weak, nonatomic) IBOutlet UILabel *repinCountLabel;
//@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
//@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *repinImageView;
//@property (weak, nonatomic) IBOutlet UIImageView *likeImageView;
//@property (weak, nonatomic) IBOutlet UIImageView *commentImageView;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagViewBottomConstraint;
//@property (weak, nonatomic) IBOutlet UIView *userView;
@property (nonatomic, strong) UIColor *randColor;
@end

@implementation XHWaterCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.randColor = PCRandomColor;
//    UITapGestureRecognizer* tap = UITapGestureRecognizer(target: self, action:#selector(XHWaterCollectionCell.tapUserView))
//    self.userView.addGestureRecognizer(tap)
}
- (void)setModel:(HuabanModel *)model{
    _model = model;
    
//    self.userView.hidden = !_model.needUser;
//    self.tagViewBottomConstraint.constant = self.userView.hidden ? 0 : 40;
    if (_model.fileHeight == 0){
        CGFloat width = [_model.file.width floatValue];
        CGFloat height = [_model.file.height floatValue];
        CGFloat curentHeight = itemWaterWidth / width * height;
        _model.fileHeight = curentHeight;
    }
    self.photoHeightConstraint.constant = _model.fileHeight;

    
    [self.photoImageView pc_setImageWithURL:[NSURL URLWithString:_model.file.realImageKey] placeholderImage:[UIImage imageWithColor:self.randColor]];
//    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:_model.user.avatar]];
//    self.nameLabel.text = _model.user.username;
    
    
//    self.photoImageView.downloadImage(Url: NSURL(string: Safe.safeString(model.file?.realKey(ImageType.middle))), placeholder: nil, success: {[weak self] (imageURL, image) -> () in
//        self?.photoImageView.backgroundColor = UIColor.clearColor()
//    }, failure: nil)
//
//    self.iconImageView.downloadImage(Url: NSURL(string: Safe.safeString(model.user?.avatar as? String)))

//    self.boardNameLabel.text = _model.board.title;
//    self.repinCountLabel.text = @"\(_model.repin_count)";
//    self.likeCountLabel.text = @"\(_model.like_count)";
//    self.commentCountLabel.text = @"\(_model.comment_count)";
//    self.infoLabel.text = _model.raw_text;
}
+ (CGSize)getSize:(HuabanModel *)model{
    if (!model.cellSize.width) {

        if (model.file != nil) {

            if (model.fileHeight == 0) {
                CGFloat width = [model.file.width floatValue];
                CGFloat height = [model.file.height floatValue];
                CGFloat curentHeight = itemWaterWidth / width * height;
                model.fileHeight = curentHeight;
            }
//            CGFloat textHeight = 0;
//            if (model.raw_text.length > 0) {
//                textHeight = [model.raw_text boundingRectWithSize:CGSizeMake(itemWaterWidth - 16, MAXFLOAT) options:(NSStringDrawingUsesFontLeading) attributes:@{@"NSFontAttributeName":[UIFont systemFontOfSize:11]} context:nil].size.height;
//                if (textHeight >= 2 * 20 ){
//                    textHeight = 2 * 20;
//                }
//                textHeight += 16;
//            }
            model.cellSize = CGSizeMake(itemWaterWidth, model.fileHeight);
        } else {
            model.cellSize = CGSizeMake(itemWaterWidth, 150 + 5 * (arc4random() % 10) * 5);
        }
    }
    return model.cellSize;
}
@end
