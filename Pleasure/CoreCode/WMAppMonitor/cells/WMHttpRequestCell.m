//
//  WMHttpRequestCell.m
//  Pleasure
//
//  Created by Sper on 2018/4/16.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMHttpRequestCell.h"

@interface WMHttpRequestCell()
@property (weak, nonatomic) IBOutlet UILabel *url;
@property (weak, nonatomic) IBOutlet UILabel *duration;
@property (weak, nonatomic) IBOutlet UILabel *dataLength;
@property (weak, nonatomic) IBOutlet UILabel *requestTime;
@end

@implementation WMHttpRequestCell

- (void)setHttpMpdel:(WMAPMHttpModel *)httpMpdel{
    _httpMpdel = httpMpdel;
    self.url.text = [NSString stringWithFormat:@"%@",_httpMpdel.url];
    self.duration.text = _httpMpdel.totalDuration;
    self.dataLength.text = _httpMpdel.totalLength;
    self.requestTime.text = _httpMpdel.startTime;
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
