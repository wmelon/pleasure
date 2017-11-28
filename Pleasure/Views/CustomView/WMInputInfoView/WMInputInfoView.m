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
#import "WMTextView.h"
#import <LCActionSheet.h>

@class WMPhotoCell;

@protocol WMPhotoCellDelegate <NSObject>

- (void)addPhotoClickAtPhotoCell:(WMPhotoCell *)photoCell;

- (void)photoCell:(WMPhotoCell *)photoCell showPhotoClickAtPhoto:(WMPhoto *)clickPhoto;

@end

@interface WMPhotoCell : UICollectionViewCell
/// 是否正在移动
@property (nonatomic , assign) BOOL isMoving;

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
- (void)setIsMoving:(BOOL)isMoving{
    _isMoving = isMoving;
    if (_isMoving) {
        self.backgroundColor = [UIColor clearColor];
        self.photoButton.hidden = YES;
    }else{
        self.backgroundColor = [self backgroundColor];
        self.photoButton.hidden = NO;
    }
}
/// 点击事件
- (void)photoButtonClick:(UIButton *)button{
    if (_photo.isAddPhoto){
        if ([self.delegate respondsToSelector:@selector(addPhotoClickAtPhotoCell:)]){
        
            [self.delegate addPhotoClickAtPhotoCell:self];
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(photoCell:showPhotoClickAtPhoto:)]){
        
            [self.delegate photoCell:self showPhotoClickAtPhoto:_photo];
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

@interface WMInputInfoView()<UITextViewDelegate , UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout , WMPhotoCellDelegate>{
    //被拖拽的item
    WMPhotoCell *_dragingItem;
    //正在拖拽的indexpath
    NSIndexPath *_dragingIndexPath;
    //目标位置
    NSIndexPath *_targetIndexPath;
}

/// 文本编辑视图
@property (nonatomic , strong) WMTextView * textView;

/// 视图显示视图
@property (nonatomic , strong) UICollectionView *collectionView;

/// 最多选择图片数量
@property (nonatomic , assign) NSInteger maxPhotoCount;

/// 图片显示的宽度和高度
@property (nonatomic , assign) CGFloat photoShowWidth;

/// 展示图片数据源
@property (nonatomic , strong) NSMutableArray<WMPhoto *> *showPhotos;

/// 添加图片  可以拍照和相册选择
@property (nonatomic , strong) WMImagePickerHandle *ImagePickerHandle;

/// 上传图片回调
@property (nonatomic , copy)  WMUploadImageHandle uploadImageHandle;
@end


@implementation WMInputInfoView

#pragma mark -- 刷新数据源
- (void)reloadView{
    [self setDelegate:_delegate];
}

/// 上传图片
- (void)uploadSelectedImage:(WMUploadImageHandle)handle{
    _uploadImageHandle = handle;
    
    /// 上传选中的图片
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.showPhotos.count];
    [self.showPhotos enumerateObjectsUsingBlock:^(WMPhoto * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.photoUrl && obj.photo){
            [array addObject:obj.photo];
        }
    }];
    __weak typeof(self) weakself = self;
    [WMUtility Base64ImageStrWithImages:array complete:^(NSArray *imageIds) {
        if (weakself.uploadImageHandle){
            weakself.uploadImageHandle(imageIds);
        }
    }];
}

- (void)setDelegate:(id<WMInputInfoViewDelegate>)delegate{
    _delegate = delegate;
    
    /// 默认最多是3张图片
    NSInteger photoCount = 3;
    if ([self.delegate respondsToSelector:@selector(maxPhotoCountAtInputInfoView:)]){
        
        photoCount = [self.delegate maxPhotoCountAtInputInfoView:self];
    }
    self.maxPhotoCount = photoCount;
    
    
    /// 加载和显示已经选择的图片
    [self wm_loadAndShowSelectedPhotosWithMaxCount:self.maxPhotoCount];
}

- (void)wm_loadAndShowSelectedPhotosWithMaxCount:(NSInteger)maxCount{
    NSInteger selectedPhotoCount = 0;
    if ([self.delegate respondsToSelector:@selector(selectedPhotoCountAtInputInfoView:)]){
        
        selectedPhotoCount = [self.delegate selectedPhotoCountAtInputInfoView:self];
    }
    
    if (selectedPhotoCount >= maxCount){ /// 已经选择的图片个数不能大于最大图片个数
        selectedPhotoCount = maxCount;
        
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:selectedPhotoCount];
    for (int i = 0 ; i < selectedPhotoCount ; i ++){
        WMPhoto * photo = [[WMPhoto alloc] init];
        
        NSString * photoUrl;
        if ([self.delegate respondsToSelector:@selector(inputInfoView:selectedPhotoUrlAtIndex:)]){
        
            photoUrl = [self.delegate inputInfoView:self selectedPhotoUrlAtIndex:i];
        }
        photo.photoUrl = photoUrl;
        
        UIImage * image;
        if ([self.delegate respondsToSelector:@selector(inputInfoView:selectedPhotoAtIndex:)]){
            image = [self.delegate inputInfoView:self selectedPhotoAtIndex:i];
            
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
    if ([self.delegate respondsToSelector:@selector(eachRowShowPhotoCountAtInputInfoView:)]){
        
        rowPhotoCount = [self.delegate eachRowShowPhotoCountAtInputInfoView:self];
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
    
    /// 代理方式返回视图的高度
    if([self.delegate respondsToSelector:@selector(inputInfoViewHeight:)]){
        [self.delegate inputInfoViewHeight:CGRectGetHeight(self.frame)];
    }
    
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
    if ([self.delegate respondsToSelector:@selector(addIconAtAtInputInfoView:)]){
        image = [self.delegate addIconAtAtInputInfoView:self];
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
    LCActionSheet *as = [[LCActionSheet alloc] initWithTitle:@"选择图片" cancelButtonTitle:@"取消" clicked:^(LCActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 1){
            [self wm_takePhoto];
        }else if (buttonIndex == 2){
            [self wm_selectPhoto];
        }
    } otherButtonTitles:@"拍照" ,@"图库", nil];
    [as show];
}

/// 拍照
- (void)wm_takePhoto{
    /// 拍照
    __weak typeof(self) weakself = self;
    [self.ImagePickerHandle openCameraWithImageResultHandle:^(NSArray *images) {
        /// 处理返回的图片数组
        [weakself wm_dealWithPhotos:images];
    }];
}

/// 选择图片
- (void)wm_selectPhoto{
    /// 打开相册列表选择图片
    __weak typeof(self) weakself = self;
    [self.ImagePickerHandle openPhotoAlbumWithMaxImagesCount:self.maxPhotoCount - self.showPhotos.count imageResultHandle:^(NSArray *images) {
        /// 处理返回的图片数组
        [weakself wm_dealWithPhotos:images];
    }];
}

- (void)wm_dealWithPhotos:(NSArray *)images{
    /// 处理返回的图片数组
    for (UIImage *image in images) {
        NSInteger index = self.showPhotos.count;
        if (index < self.maxPhotoCount){
            WMPhoto *photo = [[WMPhoto alloc] init];
            photo.photo = image;
            
            [self.showPhotos addObject:photo];
        }
    }
    [self wm_configCollectionViewWithShowCount:self.showPhotos.count];
}

/// 展示图片
- (void)photoCell:(WMPhotoCell *)photoCell showPhotoClickAtPhoto:(WMPhoto *)clickPhoto{
    NSInteger index = [self.showPhotos indexOfObject:clickPhoto];
    __weak typeof(self) weakself = self;
    /// 打开已经选择图片视图查看
    [self.ImagePickerHandle photoBrowserWithCurrentIndex:index photosArray:self.showPhotos deleteHandle:^(NSInteger deleteIndex) {
        [weakself.showPhotos removeObjectAtIndex:deleteIndex];
        [weakself wm_configCollectionViewWithShowCount:weakself.showPhotos.count];
    }];
}

#pragma mark -- 长按拖拽图片

- (void)longPressAction:(UILongPressGestureRecognizer *)gesture {
    /// 没有实现代理或者是代理返回不允许拖拽  都不能取实现拖拽
    if ([self.delegate respondsToSelector:@selector(allowDragItemAtInputInfoView:)]){
        if ([self.delegate allowDragItemAtInputInfoView:self] == NO) return;
    } else {
        return;
    }
    CGPoint point = [gesture locationInView:_collectionView];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self dragBegin:point];
            break;
        case UIGestureRecognizerStateChanged:
            [self dragChanged:point];
            break;
        case UIGestureRecognizerStateEnded:
            [self dragEnd];
            break;
        default:
            break;
    }
}
//拖拽开始 找到被拖拽的item
- (void)dragBegin:(CGPoint)point{
    _dragingIndexPath = [self getDragingIndexPathWithPoint:point];
    if (!_dragingIndexPath) {return;}
    [_collectionView bringSubviewToFront:_dragingItem];
    WMPhotoCell *item = (WMPhotoCell*)[_collectionView cellForItemAtIndexPath:_dragingIndexPath];
    item.isMoving = true;
    //更新被拖拽的item
    _dragingItem.hidden = false;
    _dragingItem.frame = item.frame;
    [_dragingItem setPhoto:item.photo];
    [_dragingItem setTransform:CGAffineTransformMakeScale(1.1, 1.1)];
}

//正在被拖拽、、、
- (void)dragChanged:(CGPoint)point{
    if (!_dragingIndexPath) {return;}
    _dragingItem.center = point;
    _targetIndexPath = [self getTargetIndexPathWithPoint:point];
    //交换位置 如果没有找到_targetIndexPath则不交换位置
    if (_dragingIndexPath && _targetIndexPath) {
        //更新数据源
        [self rearrangeInItem];
        //更新item位置
        [_collectionView moveItemAtIndexPath:_dragingIndexPath toIndexPath:_targetIndexPath];
        _dragingIndexPath = _targetIndexPath;
    }
}

//拖拽结束
- (void)dragEnd{
    if (!_dragingIndexPath) {return;}
    CGRect endFrame = [_collectionView cellForItemAtIndexPath:_dragingIndexPath].frame;
    [_dragingItem setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    [UIView animateWithDuration:0.3 animations:^{
        _dragingItem.frame = endFrame;
    }completion:^(BOOL finished) {
        _dragingItem.hidden = true;
        WMPhotoCell *item = (WMPhotoCell*)[_collectionView cellForItemAtIndexPath:_dragingIndexPath];
        item.isMoving = false;
    }];
}
//获取被拖动IndexPath的方法
- (NSIndexPath*)getDragingIndexPathWithPoint:(CGPoint)point{
    NSIndexPath* dragIndexPath = nil;
    //最后剩一个怎不可以排序
    if ([_collectionView numberOfItemsInSection:0] == 1) {return dragIndexPath;}
    for (NSIndexPath *indexPath in _collectionView.indexPathsForVisibleItems) {
        //下半部分不需要排序
        if (indexPath.section > 0) {continue;}
        dragIndexPath = [self notAllowDragWithIndexPath:indexPath point:point];
        if (dragIndexPath) break;
    }
    return dragIndexPath;
}
//获取目标IndexPath的方法
- (NSIndexPath*)getTargetIndexPathWithPoint:(CGPoint)point{
    NSIndexPath *targetIndexPath = nil;
    for (NSIndexPath *indexPath in _collectionView.indexPathsForVisibleItems) {
        //如果是自己不需要排序
        if ([indexPath isEqual:_dragingIndexPath]) {continue;}
        //第二组不需要排序
        if (indexPath.section > 0) {continue;}
        targetIndexPath = [self notAllowDragWithIndexPath:indexPath point:point];
        if (targetIndexPath) break;
    }
    return targetIndexPath;
}

/// 最后一张添加按钮的图片不允许进行排序
- (NSIndexPath *)notAllowDragWithIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point{
    NSIndexPath *targetIndexPath = nil;
    //在上半部分中找出相对应的Item
    if (CGRectContainsPoint([_collectionView cellForItemAtIndexPath:indexPath].frame, point)) {
        /// 如果当前选中的是添加图片不做任何处理
        if (indexPath.row < self.showPhotos.count) {
            targetIndexPath = indexPath;
        }
    }
    return targetIndexPath;
}
//拖拽排序后需要重新排序数据源
- (void)rearrangeInItem{
    id obj = [self.showPhotos objectAtIndex:_dragingIndexPath.row];
    if (obj && _targetIndexPath.row < self.showPhotos.count){
        [self.showPhotos removeObject:obj];
        [self.showPhotos insertObject:obj atIndex:_targetIndexPath.row];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _dragingItem.frame = CGRectMake(0, 0, self.photoShowWidth, self.photoShowWidth);
    self.textView.frame = CGRectMake(0, 0, k_wm_screen_width, 100);
    [self wm_configCollectionViewWithShowCount:self.showPhotos.count];
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
        
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        longPressGesture.minimumPressDuration = 0.3f;
        [_collectionView addGestureRecognizer:longPressGesture];
        
        /// 用于拖拽的视图
        _dragingItem = [[WMPhotoCell alloc] init];
        _dragingItem.hidden = true;
        [_collectionView addSubview:_dragingItem];
    }
    return _collectionView;
}

- (UITextView *)textView{
    if (_textView == nil){
        _textView = [[WMTextView alloc] init];
        _textView.delegate = self;
        [_textView setFont:[UIFont systemFontOfSize:15]];
        _textView.myPlaceHolder = @"这一刻的想法...";
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
