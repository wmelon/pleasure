//
//  CLLocation+WMTransform.m
//  Pleasure
//
//  Created by Sper on 2018/4/18.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "CLLocation+WMTransform.h"

const double pi = 3.14159265358979324;
const double a = 6378245.0;
const double ee = 0.00669342162296594323;

@implementation CLLocation (WMTransform)
- (CLLocation *)transformMarsLocations{
    double wgLat = self.coordinate.latitude;
    double wgLon = self.coordinate.longitude;
    if ([self outOfChinaWithLat:wgLat Lon:wgLon])
    {
        return self;
    }
    double dLat = [self transformLatWithX:wgLon - 105 Y:wgLat - 35];
    double dLon = [self transformLonWithX:wgLon - 105 Y:wgLat - 35];
    double radLat = wgLat / 180.0 * pi;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi);
    return [[CLLocation alloc] initWithLatitude:wgLat + dLat longitude:wgLon + dLon];
}
- (BOOL)outOfChinaWithLat:(double)lat Lon:(double) lon
{
    if (lon < 72.004 || lon > 137.8347)
        return true;
    if (lat < 0.8293 || lat > 55.8271)
        return true;
    return false;
}

- (double)transformLatWithX:(double)x Y:(double)y
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
    return ret;
}

- (double)transformLonWithX:(double)x Y:(double)y
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0;
    return ret;
}
@end
