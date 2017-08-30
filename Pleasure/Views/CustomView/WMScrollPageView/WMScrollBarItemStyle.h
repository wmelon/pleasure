//
//  WMScrollBarItemStyle.h
//  Pleasure
//
//  Created by Sper on 2017/8/4.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger , wm_itemSizeStyle){
    wm_itemSizeStyle_equal_width,   /// 默认是切换项等宽
    wm_itemSizeStyle_equal_textSize   /// 根据文本计算宽度
};

@interface WMScrollBarItemStyle : NSObject

#pragma mark -- 显示标题的样式

/** 是否显示滚动条 默认为NO*/
@property (assign, nonatomic, getter=isShowLine) BOOL showLine;
/** 是否缩放标题 默认为NO*/
@property (assign, nonatomic, getter=isScaleTitle) BOOL scaleTitle;
/** 是否滚动标题 默认为YES 设置为NO的时候所有的标题将不会滚动, 和系统的segment效果相似 */
@property (assign, nonatomic, getter=isScrollTitle) BOOL scrollTitle;
/** 是否颜色渐变 默认为NO*/
@property (assign, nonatomic, getter=isGradualChangeTitleColor) BOOL gradualChangeTitleColor;
/** 是否显示附加的按钮 默认为NO*/
@property (assign, nonatomic, getter=isShowExtraButton) BOOL showExtraButton;
/// 默认是 yes
@property (assign, nonatomic, getter=isAllowShowBottomLine) BOOL allowShowBottomLine;
/** 滚动条的高度 默认为2 */
@property (assign, nonatomic) CGFloat scrollLineHeight;
/// 滚动条的宽度 默认是 和文字宽度一样
@property (assign, nonatomic) CGFloat scrollLineWidth;
/** 滚动条的颜色 */
@property (strong, nonatomic) UIColor *scrollLineColor;
/** 标题之间的间隙 默认为10.0 */
@property (assign, nonatomic) CGFloat titleMargin;
/** 标题的字体 默认为17 */
@property (strong, nonatomic) UIFont *titleFont;
/** 标题缩放倍数, 默认1.2 */
@property (assign, nonatomic) CGFloat titleBigScale;
/** 标题一般状态的颜色 */
@property (strong, nonatomic) UIColor *normalTitleColor;
/** 标题选中状态的颜色 */
@property (strong, nonatomic) UIColor *selectedTitleColor;
/** segmentVIew的高度, 这个属性只在使用ZJScrollPageVIew的时候设置生效 */
@property (assign, nonatomic) CGFloat segmentHeight;
/// segmentVIew的背景颜色默认是白色
@property (strong, nonatomic) UIColor *segmentBgColor;
/// 底部分割线高度 默认是0.5
@property (assign, nonatomic) CGFloat bottomLineHeight;
/// 底部分割线颜色 默认是灰色
@property (strong, nonatomic) UIColor *bottomLineColor;
/// 选择项宽度样式 默认是屏幕宽度平分
@property (assign, nonatomic) wm_itemSizeStyle itemSizeStyle;

#pragma mark -- 显示内容的样式
/// 外面是否显示导航栏 默认是 YES
@property (assign, nonatomic , getter=isShowNavigationBar) BOOL showNavigationBar;
/// 头部是否可以下拉放大 默认是 YES
@property (assign, nonatomic) BOOL allowStretchableHeader;

@end
