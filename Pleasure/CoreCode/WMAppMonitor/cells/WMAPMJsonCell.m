//
//  WMAPMJsonCell.m
//  Pleasure
//
//  Created by Sper on 2018/4/19.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMAPMJsonCell.h"

@interface WMAPMJsonCell()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnLeftPadding;
@property (weak, nonatomic) IBOutlet UIButton *openCloseBtn;
@property (weak, nonatomic) IBOutlet UILabel *key;
@property (weak, nonatomic) IBOutlet UILabel *value;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *valueHeight;
@property (nonatomic , strong) WMJsonModel *jsonModel;
@property (nonatomic , copy  ) WMButtonClickHandle clickHandle;
@end

@implementation WMAPMJsonCell

- (void)setJsonModel:(WMJsonModel *)jsonModel clickHandle:(WMButtonClickHandle)clickHandle{
    _clickHandle = clickHandle;
    [self setJsonModel:jsonModel];
}
- (void)setJsonModel:(WMJsonModel *)jsonModel{
    _jsonModel = jsonModel;
    self.key.text = jsonModel.key;
    self.value.text = jsonModel.value;
    self.openCloseBtn.hidden = !_jsonModel.canOpen;
    self.btnLeftPadding.constant = _jsonModel.leftPadding;
    if (_jsonModel.isOpen){
        [self.openCloseBtn setTitle:@"－" forState:UIControlStateNormal];
    }else {
        [self.openCloseBtn setTitle:@"＋" forState:UIControlStateNormal];
    }
    self.valueHeight.constant = _jsonModel.valueHeight;
}
- (IBAction)openOrClose:(id)sender {
    if (_clickHandle){
        _clickHandle(_jsonModel);
    }
}
+ (CGFloat)cellHeightWithModel:(WMJsonModel *)jsonModel{
    return jsonModel.cellHeight;
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
