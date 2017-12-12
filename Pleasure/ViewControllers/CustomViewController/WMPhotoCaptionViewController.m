//
//  WMPhotoCaptionViewController.m
//  Pleasure
//
//  Created by Sper on 2017/9/4.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMPhotoCaptionViewController.h"
#import "WMPhotoBrowser.h"
#import "WMPhotoItemCell.h"

@interface WMPhotoCaptionViewController ()<WMPhotoBrowserDelegate>
@property (nonatomic , strong)NSArray *imageUrlArray;
@property (nonatomic , strong)NSArray *captionArray;

@end

@implementation WMPhotoCaptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.collectionView registerClass:[WMPhotoItemCell class] forCellWithReuseIdentifier:NSStringFromClass([WMPhotoItemCell class])];
    
    self.imageUrlArray = @[@"http://pic1.5442.com/2015/0908/06/02.jpg" ,
                           @"http://imgsrc.baidu.com/image/c0%3Dshijue1%2C0%2C0%2C294%2C40/sign=60aeee5da74bd11310c0bf7132c6ce7a/72f082025aafa40fe3c0c4f3a164034f78f0199d.jpg" ,
                           @"http://www.wallcoo.com/nature/amazing_color_landscape_2560x1600/wallpapers/1366x768/amazing_landscape_33_ii.jpg" ,
                           @"http://pic1.5442.com/2013/0801/07/05.jpg" ,
                           @"http://www.wallcoo.com/nature/Amazing_Color_Landscape_2560x1600/wallpapers/1920x1080/Amazing_Landscape_36_II.jpg",
                           @"https://hbimg.b0.upaiyun.com/453ab8bbea3bcf35b3ff7536bb9027ed4ead9108ca93-wjbGDX_fw658"];
    
    self.captionArray = @[@"碧波荡漾,水天一色,在那一瞬间,画面仿佛都静止了,留下的,只是老人那一个孤独的背影和轻微的呼吸声。",
                          @"真相，是你眼睛无法企及的光，那不是雪中红，那是血在流。" ,
                          @"耍猴的时代即将结束，被猴耍的时代即将开始",
                          @"一个油画般的造型，穿着有七八个破洞的T恤，蹲在夕阳下，深深吸一口烟，缓缓吐出来，淡淡地说：“我也想成为伟大的人，可是妈妈喊我回家种田。“",
                          @"有思念你的人在的地方,就是你的归处。",
                          @"他永远活在他自己的世界中，她在自己的世界里杜撰他们的故事。"
                          ];
    
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
//    [browser setCurrentPhotoIndex:index];
    browser.shouldShowTopToolBar = YES;
    browser.fd_prefersNavigationBarHidden = YES;
    [self.navigationController pushViewController:browser animated:NO];
}

#pragma mark -- WMPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(WMPhotoBrowser *)photoBrowser{
    return self.imageUrlArray.count;
}

- (WMPhotoModel *)photoBrowser:(WMPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    WMPhotoModel * photo;
    if (index < self.imageUrlArray.count){
        
        NSString *url = self.imageUrlArray[index];
        photo = [WMPhotoModel photoWithURL:[NSURL URLWithString:url]];
        photo.caption = self.captionArray[index];
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
