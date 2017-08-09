//
//  WMInputInfoView.m
//  Pleasure
//
//  Created by Sper on 2017/8/8.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMInputInfoView.h"
#import <UIButton+WebCache.h>
#import "WMImagePickerHandle.h"
//#import <MWPhotoBrowser.h>

@interface WMPhoto : NSObject

@property (nonatomic , copy) NSString * photoUrl;
@property (nonatomic , strong) UIImage * photo;

/// 是否是添加视图 默认是 NO
@property (nonatomic , assign) BOOL isAddPhoto;
/// 为显示图片分配一个顺序
@property (nonatomic , assign) NSInteger index;
@end

@implementation WMPhoto

- (instancetype)initWithIndex:(NSInteger)index{
    if (self = [super init]){
    
        _index = index;
        
    }
    return self;

}
@end


@class WMPhotoCell;

@protocol WMPhotoCellDelegate <NSObject>

- (void)addPhotoClickAtPhotoCell:(WMPhotoCell *)photoCell;

- (void)photoCell:(WMPhotoCell *)photoCell showPhotoClickAtIndex:(NSInteger)index;

@end

@interface WMPhotoCell : UICollectionViewCell

@property (nonatomic , strong) UIButton *photoButton;
@property (nonatomic , strong) WMPhoto *photo;
@property (nonatomic , weak) id<WMPhotoCellDelegate> delegate;

@end

@implementation WMPhotoCell

- (instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]){
        
        UIButton * button = [[UIButton alloc] initWithFrame:self.bounds];
        [button addTarget:self action:@selector(photoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [button.imageView setClipsToBounds:YES];
        button.contentEdgeInsets = UIEdgeInsetsZero;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        [self.contentView addSubview:button];
        
        self.photoButton = button;
    }
    
    return self;
}

- (void)photoButtonClick:(UIButton *)button{

    if (_photo.isAddPhoto){
        
        if ([self.delegate respondsToSelector:@selector(addPhotoClickAtPhotoCell:)]){
        
            [self.delegate addPhotoClickAtPhotoCell:self];
        }
    }else {
    
        if ([self.delegate respondsToSelector:@selector(photoCell:showPhotoClickAtIndex:)]){
        
            [self.delegate photoCell:self showPhotoClickAtIndex:_photo.index];
        }
    }
}

- (void)setPhoto:(WMPhoto *)photo{

    _photo = photo;
    
    if (photo.photo){
        
        [self.photoButton setImage:photo.photo forState:UIControlStateNormal];
        
    }else if (photo.photoUrl){
        [self.photoButton sd_setImageWithURL:[NSURL URLWithString:photo.photoUrl] forState:UIControlStateNormal completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (image){
                photo.photo = image;
            }
        }];
    }
    
}
- (void)layoutSubviews{

    [super layoutSubviews];
    self.photoButton.frame = self.bounds;
}

@end

/// 屏幕宽度
#define k_wm_screen_width [UIScreen mainScreen].bounds.size.width

@interface WMInputInfoView()<UITextViewDelegate , UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout , WMPhotoCellDelegate >
//MWPhotoBrowserDelegate
/// 文本编辑视图
@property (nonatomic , strong) UITextView * textView;

/// 视图显示视图
@property (nonatomic , strong) UICollectionView *collectionView;

/// 最多选择图片数量
@property (nonatomic , assign) NSInteger maxPhotoCount;

/// 图片显示的宽度和高度
@property (nonatomic , assign) CGFloat photoShowWidth;

/// 展示图片数据源
@property (nonatomic , strong) NSMutableArray<WMPhoto *> *showPhotos;

@property (nonatomic , strong) WMImagePickerHandle *ImagePickerHandle;

@end


@implementation WMInputInfoView


- (void)setDataSource:(id<WMInputInfoViewDataSource>)dataSource{
    
    _dataSource = dataSource;
    
    /// 默认最多是3张图片
    NSInteger photoCount = 3;
    if ([self.dataSource respondsToSelector:@selector(maxPhotoCountAtInputInfoView:)]){
    
        photoCount = [self.dataSource maxPhotoCountAtInputInfoView:self];
    }
    self.maxPhotoCount = photoCount;
    

    /// 加载和显示已经选择的图片
    [self wm_loadAndShowSelectedPhotosWithMaxCount:self.maxPhotoCount];
 
}

- (void)wm_loadAndShowSelectedPhotosWithMaxCount:(NSInteger)maxCount{

    NSInteger selectedPhotoCount = 0;
    if ([self.dataSource respondsToSelector:@selector(selectedPhotoCountAtInputInfoView:)]){
        
        selectedPhotoCount = [self.dataSource selectedPhotoCountAtInputInfoView:self];
    }
    
    if (selectedPhotoCount >= maxCount){ /// 已经选择的图片个数不能大于最大图片个数
        selectedPhotoCount = maxCount;
        
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:selectedPhotoCount];
    for (int i = 0 ; i < selectedPhotoCount ; i ++){
        WMPhoto * photo = [[WMPhoto alloc] initWithIndex:i];
        
        NSString * photoUrl;
        if ([self.dataSource respondsToSelector:@selector(inputInfoView:selectedPhotoUrlAtIndex:)]){
        
            photoUrl = [self.dataSource inputInfoView:self selectedPhotoUrlAtIndex:i];
        }
        photo.photoUrl = photoUrl;
        
        UIImage * image;
        if ([self.dataSource respondsToSelector:@selector(inputInfoView:selectedPhotoAtIndex:)]){
            image = [self.dataSource inputInfoView:self selectedPhotoAtIndex:i];
            
        }
        photo.photo = image;
        
        
        [array addObject:photo];
    }
    
    [self.showPhotos removeAllObjects];
    [self.showPhotos addObjectsFromArray:array];
    
    /// 初始化图片显示视图
    [self wm_configCollectionViewWithShowCount:self.showPhotos.count];
}

- (void)wm_configCollectionViewWithShowCount:(NSInteger)showCount{

    /// 每一行显示的图片
    NSInteger rowPhotoCount = 3;
    if ([self.dataSource respondsToSelector:@selector(eachRowShowPhotoCountAtInputInfoView:)]){
    
        rowPhotoCount = [self.dataSource eachRowShowPhotoCountAtInputInfoView:self];
    }
    
    if (showCount < self.maxPhotoCount){   /// 显示的图片数量小于最大图片数量 就需要添加一个添加图片的按钮
        
        showCount ++;
    
    }else {
    
        showCount = self.maxPhotoCount;
    }

    UICollectionViewFlowLayout * layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat topPadding = layout.sectionInset.top;
    CGFloat bottomPadding = layout.sectionInset.bottom;
    CGFloat leftPadding = layout.sectionInset.left;
    CGFloat rightPadding = layout.sectionInset.right;
    
    CGFloat minimumLineSpacing = layout.minimumLineSpacing;
    CGFloat minimumInteritemSpacing = layout.minimumInteritemSpacing;
    
    
    self.photoShowWidth = floorf((k_wm_screen_width - (rowPhotoCount - 1) * minimumLineSpacing - leftPadding - rightPadding) / rowPhotoCount);   /// 宽度向下取整
    /// 一共有多少列图片
    NSInteger column = showCount / rowPhotoCount + (showCount % rowPhotoCount == 0 ? 0 : 1);
    
    CGFloat collectionViewHeight = ceilf(topPadding + bottomPadding + (column - 1) * minimumInteritemSpacing + column * self.photoShowWidth);
    
    self.collectionView.frame = CGRectMake(0, CGRectGetMaxY(self.textView.frame), k_wm_screen_width, collectionViewHeight);
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, k_wm_screen_width, CGRectGetMaxY(self.collectionView.frame));
    
    /// 视图的高度
    _viewHeight = self.frame.size.height;
    
    [self.collectionView reloadData];
}


/** 获取当前View的控制器对象  如果当前控制器是作为一个自控制器存在的话就需要获取这个控制器的父控制器（用来作为界面跳转）*/
- (UIViewController *)getCurrentViewController{
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}


#pragma mark -- UICollectionViewDelegate and UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.showPhotos.count >= self.maxPhotoCount ? self.maxPhotoCount : (self.showPhotos.count + 1);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WMPhotoCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([WMPhotoCell class]) forIndexPath:indexPath];
    WMPhoto *photo;
    if (indexPath.row < self.showPhotos.count){
    
        photo = self.showPhotos[indexPath.row];
        
    }else {
    
        photo = [self wm_getDefaultAddPhoto];
        
    }
    [cell setPhoto:photo];
    cell.delegate = self;
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.photoShowWidth , self.photoShowWidth);
}

- (WMPhoto *)wm_getDefaultAddPhoto{

    WMPhoto * photo = [WMPhoto new];
    photo.isAddPhoto = YES;
    
    UIImage * image;
    if ([self.dataSource respondsToSelector:@selector(addIconAtAtInputInfoView:)]){
        
        image = [self.dataSource addIconAtAtInputInfoView:self];
        
    }else {
        
        /// 默认的添加图片icon
        image = [UIImage imageNamed:@"addphoto"];
    }
    photo.photo = image;
    
    return photo;
}

#pragma mark -- WMPhotoCellDelegate

/// 添加图片
- (void)addPhotoClickAtPhotoCell:(WMPhotoCell *)photoCell{

    /// 打开相册列表选择图片
    [self.ImagePickerHandle openPhotoAlbumWithMaxImagesCount:self.maxPhotoCount - self.showPhotos.count imageResultHandle:^(NSArray *images) {
        
        /// 处理返回的图片数组
        for (UIImage *image in images) {
            NSInteger index = self.showPhotos.count;
            if (index < self.maxPhotoCount){
                
                WMPhoto *photo = [[WMPhoto alloc] initWithIndex:index];
                photo.photo = image;
                
                [self.showPhotos addObject:photo];
            }
        }
        
        [self wm_configCollectionViewWithShowCount:self.showPhotos.count];
        
    }];
    
    
//    /// 拍照
//    [self.ImagePickerHandle openCameraWithImageResultHandle:^(NSArray *images) {
//        
//    }];

}

/// 展示图片
- (void)photoCell:(WMPhotoCell *)photoCell showPhotoClickAtIndex:(NSInteger)index{

    /// 打开已经选择图片视图查看
    
//    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
//    [browser setInitialPageIndex:index];
}


//#pragma mark -- MWPhotoBrowserDelegate
//
//- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
//    return self.showPhotos.count;
//}
//
//- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
//
//    MWPhoto * photo;
//    if (index < self.showPhotos.count){
//    
//        WMPhoto * wmPhoto = self.showPhotos[index];
//        if (wmPhoto.photo){
//        
//            photo = [MWPhoto photoWithImage:wmPhoto.photo];
//        }else if (wmPhoto.photoUrl){
//        
//            photo = [MWPhoto photoWithURL:[NSURL URLWithString:wmPhoto.photoUrl]];
//        }
//    }
//
//    return photo;
//}



- (void)reloadView{
    [self setDataSource:_dataSource];
}


#pragma mark -- getter and setter 

- (UICollectionView *)collectionView{

    if (_collectionView == nil){

        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[WMPhotoCell class] forCellWithReuseIdentifier:NSStringFromClass([WMPhotoCell class])];
        [self addSubview:_collectionView];
    }
    
    return _collectionView;
}
- (UITextView *)textView{
    
    if (_textView == nil){
    
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, k_wm_screen_width, 100)];
        _textView.delegate = self;
        [self addSubview:_textView];

    }
    return _textView;
}
- (NSMutableArray<WMPhoto *> *)showPhotos{

    if (_showPhotos == nil){
    
        _showPhotos = [NSMutableArray array];
        
    }
    
    return _showPhotos;
}

- (WMImagePickerHandle *)ImagePickerHandle{

    if (_ImagePickerHandle == nil){
    
        _ImagePickerHandle = [[WMImagePickerHandle alloc] initWithController:[self getCurrentViewController]];
    }
    return _ImagePickerHandle;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
