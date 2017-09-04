//
//  WMPhotoSelectViewController.m
//  Pleasure
//
//  Created by Sper on 2017/9/4.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMPhotoSelectViewController.h"
#import "WMPhotoBrowser.h"
#import "WMPhotoItemCell.h"

@interface WMPhotoSelectViewController ()<WMPhotoBrowserDelegate>
@property (nonatomic , strong)NSArray *imageUrlArray;
@end

@implementation WMPhotoSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.collectionView registerClass:[WMPhotoItemCell class] forCellWithReuseIdentifier:NSStringFromClass([WMPhotoItemCell class])];
    
    self.imageUrlArray = @[@"http://pic1.5442.com/2015/0908/06/02.jpg" , @"http://imgsrc.baidu.com/image/c0%3Dshijue1%2C0%2C0%2C294%2C40/sign=60aeee5da74bd11310c0bf7132c6ce7a/72f082025aafa40fe3c0c4f3a164034f78f0199d.jpg" , @"http://www.wallcoo.com/nature/amazing_color_landscape_2560x1600/wallpapers/1366x768/amazing_landscape_33_ii.jpg" , @"http://pic1.5442.com/2013/0801/07/05.jpg" ,@"http://www.wallcoo.com/nature/Amazing_Color_Landscape_2560x1600/wallpapers/1920x1080/Amazing_Landscape_36_II.jpg",@"https://hbimg.b0.upaiyun.com/453ab8bbea3bcf35b3ff7536bb9027ed4ead9108ca93-wjbGDX_fw658"];
    
    [self.collectionView reloadData];
}
#pragma mark -- UICollectionViewDelegate and UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imageUrlArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WMPhotoItemCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([WMPhotoItemCell class]) forIndexPath:indexPath];
    [cell setPhotoUrl:self.imageUrlArray[indexPath.row]];
    __weak typeof(self) weakself = self;
    [cell setIndex:indexPath.row clickHandle:^(UIImageView *imageView) {
        [weakself pushPhotoBrowserAtIndex:indexPath.row];
    }];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(100, 100);
}

- (void)pushPhotoBrowserAtIndex:(NSInteger)index{
    WMPhotoBrowser *browser = [[WMPhotoBrowser alloc] initWithDelegate:self];
    [browser setCurrentPhotoIndex:index];
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark -- WMPhotoBrowserDelegate
- (void)photoBrowser:(WMPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index{
    NSLog(@"点击删除图片  %ld" , index);
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(WMPhotoBrowser *)photoBrowser{
    return self.imageUrlArray.count;
}

- (WMPhotoModel *)photoBrowser:(WMPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    WMPhotoModel * photo;
    if (index < self.imageUrlArray.count){
        NSString *url = self.imageUrlArray[index];
        photo = [WMPhotoModel photoWithURL:[NSURL URLWithString:url]];
    }
    return photo;
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
