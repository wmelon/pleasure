//
//  Demo2ViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/4.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "Demo2ViewController.h"
#import "DemoViewController.h"

#import "WMInteractiveTransition.h"
#import "WMBaseTransitionAnimator.h"

@interface Demo2ViewController ()<UIViewControllerTransitioningDelegate>
@property (nonatomic , strong) WMInteractiveTransition *interactive;
@property (nonatomic , strong) UIImageView *MyImageView;
@end

@implementation Demo2ViewController

- (instancetype)init{
    if (self = [super init]){
        self.transitioningDelegate = self;
        _MyImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        UIImage *image = [UIImage imageNamed:@"pc_bg"];
        _MyImageView.userInteractionEnabled = YES;
        _MyImageView.image =image;
        CGFloat width = kScreenWidth;
        CGFloat height = kScreenWidth * image.size.height / image.size.width;
        _MyImageView.frame = CGRectMake(0, 0, width, height);
        [self.view addSubview:_MyImageView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.title = @"Demo2";
    self.navigationItem.title = @"Demo2";
    
    self.interactive = [WMInteractiveTransition interactiveTransitionWithTransitionType:(WMInteractiveTransitionTypeDismiss) gestureDirection:(WMInteractiveTransitionGestureDirectionDown)];
    __weak typeof(self) weakself = self;
    [self.interactive addPanGestureForViewController:self gestureConifg:^{
        [weakself wm_dismiss];
    }];
}

- (void)wm_dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    WMBaseTransitionAnimator *animator = [WMBaseTransitionAnimator transitionAnimatorWithTransitionType:(WMTransitionAnimatorTypePresent)];
    [animator setSrcView:self.srcImageView];
    [animator setDestView:self.MyImageView];
//    [animator setDestFrame:self.MyImageView.frame];
    return animator;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    WMBaseTransitionAnimator *animator = [WMBaseTransitionAnimator transitionAnimatorWithTransitionType:(WMTransitionAnimatorTypeDismiss)];
    [animator setSrcView:self.srcImageView];
    [animator setDestView:self.MyImageView];
    return animator;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator{
    return _interactive.interation ? _interactive : nil;
}




//#pragma mark -- UICollectionViewDelegate and UICollectionViewDataSource
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
//    return 1;
//}
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//    return 20;
//}
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
//    cell.backgroundColor = [UIColor redColor];
//    return cell;
//}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    return CGSizeMake(100, 100);
//}
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    [self nextClick:nil];
//}
//
//- (UIView *)loadNavigationHeaderView{
//    UIView * headerView = [UIView new];
//    headerView.backgroundColor = [UIColor greenColor];
//    
//    return headerView;
//}
//
//- (void)nextClick:(UIButton *)button{
//    DemoViewController * vc = [DemoViewController new];
//    [self.navigationController pushViewController:vc animated:YES];
//}

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
