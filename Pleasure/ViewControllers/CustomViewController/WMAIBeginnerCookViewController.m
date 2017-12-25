//
//  WMAIBeginnerCookViewController.m
//  Pleasure
//
//  Created by Sper on 2017/8/14.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMAIBeginnerCookViewController.h"
#import "WMAIHerbDetailViewController.h"
#import "WMPresentAIAnimator.h"

@implementation WMAIHerbModel
- (instancetype)initWithName:(NSString*)name image:(NSString*)image license:(NSString*)license credit:(NSString*)credit descriptionString:(NSString*)descriptionString{
    self = [super init];
    if (self) {
        _name       = name;
        _image      = image;
        _credit     = credit;
        _license    = license;
        _descriptionString  = descriptionString;
    }
    return self;
}
+ (NSArray*)all {
    
    return @[
             [[WMAIHerbModel alloc]initWithName:@"Basil" image:@"basil.jpg" license:@"" credit:@"http://commons.wikimedia.org/wiki/User:Castielli" descriptionString:@"Basil is commonly used fresh in cooked recipes. In general, it is added at the last moment, as cooking quickly destroys the flavor. The fresh herb can be kept for a short time in plastic bags in the refrigerator, or for a longer period in the freezer, after being blanched quickly in boiling water. The dried herb also loses most of its flavor, and what little flavor remains tastes very different."],
             [[WMAIHerbModel alloc]initWithName:@"Saffron" image:@"saffron.jpg" license:@"http://creativecommons.org/licenses/by-sa/3.0" credit:@"http://commons.wikimedia.org/wiki/User:Lin%C3%A91" descriptionString:@"Saffron's aroma is often described by connoisseurs as reminiscent of metallic honey with grassy or hay-like notes, while its taste has also been noted as hay-like and sweet. Saffron also contributes a luminous yellow-orange colouring to foods. Saffron is widely used in Indian, Persian, European, Arab, and Turkish cuisines. Confectioneries and liquors also often include saffron."],
             [[WMAIHerbModel alloc]initWithName:@"Marjoram" image:@"marjorana.jpg" license:@"http://creativecommons.org/licenses/by-sa/3.0" credit:@"http://commons.wikimedia.org/wiki/User:Raul654" descriptionString:@"Marjoram is used for seasoning soups, stews, dressings and sauce. Majorana has been scientifically proved to be beneficial in the treatment of gastric ulcer, hyperlipidemia and diabetes. Majorana hortensis herb has been used in the traditional Austrian medicine for treatment of disorders of the gastrointestinal tract and infections."],
             [[WMAIHerbModel alloc]initWithName:@"Rosemary" image:@"rosemary.jpg" license:@"http://www.gnu.org/licenses/old-licenses/fdl-1.2.html" credit:@"" descriptionString:@"The leaves, both fresh and dried, are used in traditional Italian cuisine. They have a bitter, astringent taste and are highly aromatic, which complements a wide variety of foods. Herbal tea can be made from the leaves. When burnt, they give off a mustard-like smell and a smell similar to burning wood, which can be used to flavor foods while barbecuing. Rosemary is high in iron, calcium and vitamin B6."],
             [[WMAIHerbModel alloc]initWithName:@"Anise" image:@"anise.jpg" license:@"http://commons.wikimedia.org/wiki/File:AniseSeeds.jpg" credit:@"http://commons.wikimedia.org/wiki/User:Ben_pcc" descriptionString:@"Anise is sweet and very aromatic, distinguished by its characteristic flavor. The seeds, whole or ground, are used in a wide variety of regional and ethnic confectioneries, including black jelly beans, British aniseed balls, Australian humbugs, and others. The Ancient Romans often served spiced cakes with aniseseed, called mustaceoe at the end of feasts as a digestive. "]
             ];
}
@end

@interface WMAIBeginnerCookViewController ()<UIViewControllerTransitioningDelegate>
@property (strong, nonatomic) UIScrollView *listView;
@property (strong, nonatomic) UIImageView *bgImageView;
/** 列表数据*/
@property(nonatomic,strong)NSMutableArray<WMAIHerbModel *> *herbs;
/** 被选中的图片*/
@property(nonatomic,weak)UIImageView *selectedImageView;
/** 转场动画*/
@property(nonatomic,strong)WMPresentAIAnimator *transition;
@end

@implementation WMAIBeginnerCookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.bgImageView];
    [self.view addSubview:self.listView];
    
    [self setUpList];
    
    __weak typeof(self) weakSelf = self;
    self.transition.dismissComletion = ^{
        weakSelf.selectedImageView.hidden = NO;
    };
}
- (void)setUpList {

    for (int i = 0; i < self.herbs.count; i++) {
        WMAIHerbModel *model      = self.herbs[i];
        UIImageView *imageView  = [[UIImageView alloc]initWithImage:[UIImage imageNamed:model.image]];
        imageView.tag           = i+123456;
        imageView.contentMode   = UIViewContentModeScaleAspectFill;
        imageView.userInteractionEnabled    = YES;
        imageView.layer.cornerRadius        = 20.;
        imageView.layer.masksToBounds       = YES;
        [self.listView addSubview:imageView];
        
        UITapGestureRecognizer *tap         = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapImageView:)];
        [imageView addGestureRecognizer:tap];
    }
}

- (void)positionListItem {
    CGFloat listHeight      = CGRectGetHeight(self.listView.frame);
    CGFloat itemHeight      = listHeight *1.33;
    CGFloat aspectRatio     = kScreenHeight/kScreenWidth;
    CGFloat itemWith        = itemHeight / aspectRatio;
    
    CGFloat horizontalPadding   = 10.0;
    
    for (int i = 0; i < self.herbs.count; i++) {
        UIImageView *imageView  = [self.listView viewWithTag:i+123456];
        imageView.frame         = CGRectMake(i* itemWith+(1+i)*horizontalPadding, 0, itemWith, itemHeight);
    }
    self.listView.contentSize   = CGSizeMake(self.herbs.count * (itemWith+horizontalPadding)+horizontalPadding, 0);
}

#pragma mark -Action
-(void)didTapImageView:(UITapGestureRecognizer*)tap {
    self.selectedImageView      = (UIImageView*)tap.view;
    NSInteger index             = tap.view.tag - 123456;
    WMAIHerbModel *selectedHerbModel              = self.herbs[index];

    WMAIHerbDetailViewController   *herbDetailVC  = [[WMAIHerbDetailViewController alloc] init];
    herbDetailVC.herbModel                      = selectedHerbModel;
    herbDetailVC.transitioningDelegate          = self;
    [self presentViewController:herbDetailVC animated:YES completion:nil];
}

#pragma mark -UIViewControllerTransitioningDelegate

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    //坐标转换
    self.transition.originFrame = [self.selectedImageView.superview convertRect:_selectedImageView.frame toView:self.view];
    self.transition.presenting    = YES;
    self.selectedImageView.hidden = YES;
    return self.transition;
}
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.transition.presenting    = NO;
    return self.transition;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.listView.frame = CGRectMake(0, CGRectGetMaxY(self.view.frame) - 220, self.view.frame.size.width, 220);
    [self positionListItem];
}
- (NSMutableArray *)herbs {
    if (!_herbs) {
        _herbs   = [NSMutableArray arrayWithArray:[WMAIHerbModel all]];
    }
    return _herbs;
}
- (UIImageView *)bgImageView{
    if (_bgImageView == nil){
        _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
        _bgImageView.frame = self.view.bounds;
    }
    return _bgImageView;
}

- (UIScrollView *)listView{
    if (_listView == nil){
        _listView = [[UIScrollView alloc] init];
    }
    return _listView;
}
- (WMPresentAIAnimator *)transition {
    if (!_transition) {
        _transition = [[WMPresentAIAnimator alloc] init];
    }
    return _transition;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
