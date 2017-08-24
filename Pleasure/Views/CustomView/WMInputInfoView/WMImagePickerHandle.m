//
//  WMImagePickerHandle.m
//  Pleasure
//
//  Created by Sper on 2017/8/9.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMImagePickerHandle.h"
#import <TZImagePickerController.h>
#import <AVFoundation/AVFoundation.h>
#import "WMPhotoBrowser.h"

@interface WMImagePickerHandle()<TZImagePickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate , WMPhotoBrowserDelegate>

/// 当前控制器
@property (nonatomic , weak) UIViewController *viewController;

/// 需要打开浏览的图片集合
@property (nonatomic , strong) NSArray<WMPhoto *> * showPhotos;

/// 选择图片回调
@property (nonatomic , copy) WMImageResultHandle imageResultHandle;

/// 删除图片回调
@property (nonatomic , copy) WMPhotoDeleteHandle deleteHandle;

@end

@implementation WMImagePickerHandle


- (instancetype)initWithController:(UIViewController *)viewController{

    if (self = [super init]){
        _viewController = viewController;
    }
    return self;
}

/// 打开相机拍照
- (void)openCameraWithImageResultHandle:(WMImageResultHandle)imageResultHandle{
    _imageResultHandle = imageResultHandle;
    
    /// 需要验证是否允许使用拍照 和 照相机是否可以使用
    if ([self takePhotoFromViewController:self.viewController]){
        
    
    }
}

/// 打开相册选择图片
- (void)openPhotoAlbumWithMaxImagesCount:(NSInteger)maxImagesCount imageResultHandle:(WMImageResultHandle)imageResultHandle{

    _imageResultHandle = imageResultHandle;
    
    /// 需要先允许访问用户相册
    [self wm_createSelectPhotosWithMaxCount:maxImagesCount viewController:self.viewController];
}

/// 浏览图片
- (void)photoBrowserWithCurrentIndex:(NSInteger)currentIndex imageView:(UIImageView *)imageView photosArray:(NSArray<WMPhoto *> *)photos deleteHandle:(WMPhotoDeleteHandle)deleteHandle{
    _showPhotos = photos;
    _deleteHandle = deleteHandle;
    
    WMPhotoBrowser *browser = [[WMPhotoBrowser alloc] initWithDelegate:self];
    [browser setCurrentPhotoIndex:currentIndex];
    [browser showRightItem:nil image:[UIImage imageNamed:@"navBar_search_grey"]];
    [browser setSrcImageView:imageView];
    [self.viewController presentViewController:browser animated:YES completion:nil];
//    [self.viewController.navigationController pushViewController:browser animated:YES];
}

#pragma mark -- WMPhotoBrowserDelegate

- (void)photoBrowser:(WMPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index{
    if (self.deleteHandle){
        self.deleteHandle(index);
    }
}
- (NSUInteger)numberOfPhotosInPhotoBrowser:(WMPhotoBrowser *)photoBrowser{
    return self.showPhotos.count;
}

- (WMPhotoModel *)photoBrowser:(WMPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    
    WMPhotoModel * photo;
    if (index < self.showPhotos.count){
        
        WMPhoto * wmPhoto = self.showPhotos[index];
        
        if (wmPhoto.photo){
            
            photo = [WMPhotoModel photoWithImage:wmPhoto.photo];
        }else if (wmPhoto.photoUrl){
        
            photo = [WMPhotoModel photoWithURL:[NSURL URLWithString:wmPhoto.photoUrl]];
        }
//        photo = [WMPhotoModel photoWithURL:[NSURL URLWithString:@"http://img.pconline.com.cn/images/upload/upc/tx/wallpaper/1212/27/c1/16933645_1356590157539.jpg"]];
    }
    
    return photo;
}



- (void)wm_createSelectPhotosWithMaxCount:(NSInteger)maxCount viewController:(UIViewController *)viewController{
    
    if (maxCount <= 0) {
        return;
    }
//    maxCount = maxCount + _selectedAssets.count;
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:maxCount delegate:self];
    // imagePickerVc.navigationBar.translucent = NO;
    
#pragma mark - 五类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = YES;

//    if (maxCount > 1) {
//        // 1.设置目前已经选中的图片数组
//        imagePickerVc.selectedAssets = _selectedAssets; // 目前已经选中的图片数组
//    }
    imagePickerVc.allowTakePicture = YES; // 在内部显示拍照按钮

//    // imagePickerVc.photoWidth = 1000;
//    
//    // 2. Set the appearance
//    // 2. 在这里设置imagePickerVc的外观
//    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
//    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
//    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
//    // imagePickerVc.navigationBar.translucent = NO;
//    
//    // 3. Set allow picking video & photo & originalPhoto or not
//    // 3. 设置是否可以选择视频/图片/原图
//    imagePickerVc.allowPickingVideo = self.allowPickingVideoSwitch.isOn;
//    imagePickerVc.allowPickingImage = self.allowPickingImageSwitch.isOn;
//    imagePickerVc.allowPickingOriginalPhoto = self.allowPickingOriginalPhotoSwitch.isOn;
//    imagePickerVc.allowPickingGif = self.allowPickingGifSwitch.isOn;
//    imagePickerVc.allowPickingMultipleVideo = self.allowPickingMuitlpleVideoSwitch.isOn; // 是否可以多选视频
//    
//    // 4. 照片排列按修改时间升序
//    imagePickerVc.sortAscendingByModificationDate = self.sortAscendingSwitch.isOn;
//    
//    // imagePickerVc.minImagesCount = 3;
//    // imagePickerVc.alwaysEnableDoneBtn = YES;
//    
//    // imagePickerVc.minPhotoWidthSelectable = 3000;
//    // imagePickerVc.minPhotoHeightSelectable = 2000;
//    
//    /// 5. Single selection mode, valid when maxImagesCount = 1
//    /// 5. 单选模式,maxImagesCount为1时才生效
    imagePickerVc.showSelectBtn = YES;
//    imagePickerVc.allowCrop = self.allowCropSwitch.isOn;
//    imagePickerVc.needCircleCrop = self.needCircleCropSwitch.isOn;
//    // 设置竖屏下的裁剪尺寸
//    NSInteger left = 30;
//    NSInteger widthHeight = self.view.tz_width - 2 * left;
//    NSInteger top = (self.view.tz_height - widthHeight) / 2;
//    imagePickerVc.cropRect = CGRectMake(left, top, widthHeight, widthHeight);
//    // 设置横屏下的裁剪尺寸
//    // imagePickerVc.cropRectLandscape = CGRectMake((self.view.tz_height - widthHeight) / 2, left, widthHeight, widthHeight);
//    /*
//     [imagePickerVc setCropViewSettingBlock:^(UIView *cropView) {
//     cropView.layer.borderColor = [UIColor redColor].CGColor;
//     cropView.layer.borderWidth = 2.0;
//     }];*/
//    
//    //imagePickerVc.allowPreview = NO;
//    
//    imagePickerVc.isStatusBarDefault = NO;
#pragma mark - 到这里为止
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
    }];
    
    [viewController presentViewController:imagePickerVc animated:YES completion:nil];
}



#pragma mark - TZImagePickerControllerDelegate

/// User click cancel button
/// 用户点击了取消
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    // NSLog(@"cancel");
}

// The picker should dismiss itself; when it dismissed these handle will be called.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[TZImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    
    if (self.imageResultHandle){
        self.imageResultHandle(photos);
    }
    
//    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
//    _selectedAssets = [NSMutableArray arrayWithArray:assets];
//    _isSelectOriginalPhoto = isSelectOriginalPhoto;
//    [_collectionView reloadData];
//    // _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
//    
//    // 1.打印图片名字
//    [self printAssetsName:assets];
//    // 2.图片位置信息
//    if (iOS8Later) {
//        for (PHAsset *phAsset in assets) {
//            NSLog(@"location:%@",phAsset.location);
//        }
//    }
    
    
}

// If user picking a video, this callback will be called.
// If system version > iOS8,asset is kind of PHAsset class, else is ALAsset class.
// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
//    _selectedPhotos = [NSMutableArray arrayWithArray:@[coverImage]];
//    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
//    // open this code to send video / 打开这段代码发送视频
//    // [[TZImageManager manager] getVideoOutputPathWithAsset:asset completion:^(NSString *outputPath) {
//    // NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
//    // Export completed, send video here, send by outputPath or NSData
//    // 导出完成，在这里写上传代码，通过路径或者通过NSData上传
//    
//    // }];
//    [_collectionView reloadData];
    // _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
}

// If user picking a gif image, this callback will be called.
// 如果用户选择了一个gif图片，下面的handle会被执行
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset {
//    _selectedPhotos = [NSMutableArray arrayWithArray:@[animatedImage]];
//    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
//    [_collectionView reloadData];
}

// Decide album show or not't
// 决定相册显示与否
- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(id)result {
    /*
     if ([albumName isEqualToString:@"个人收藏"]) {
     return NO;
     }
     if ([albumName isEqualToString:@"视频"]) {
     return NO;
     }*/
    return YES;
}

// Decide asset show or not't
// 决定asset显示与否
- (BOOL)isAssetCanSelect:(id)asset {
    /*
     if (iOS8Later) {
     PHAsset *phAsset = asset;
     switch (phAsset.mediaType) {
     case PHAssetMediaTypeVideo: {
     // 视频时长
     // NSTimeInterval duration = phAsset.duration;
     return NO;
     } break;
     case PHAssetMediaTypeImage: {
     // 图片尺寸
     if (phAsset.pixelWidth > 3000 || phAsset.pixelHeight > 3000) {
     // return NO;
     }
     return YES;
     } break;
     case PHAssetMediaTypeAudio:
     return NO;
     break;
     case PHAssetMediaTypeUnknown:
     return NO;
     break;
     default: break;
     }
     } else {
     ALAsset *alAsset = asset;
     NSString *alAssetType = [[alAsset valueForProperty:ALAssetPropertyType] stringValue];
     if ([alAssetType isEqualToString:ALAssetTypeVideo]) {
     // 视频时长
     // NSTimeInterval duration = [[alAsset valueForProperty:ALAssetPropertyDuration] doubleValue];
     return NO;
     } else if ([alAssetType isEqualToString:ALAssetTypePhoto]) {
     // 图片尺寸
     CGSize imageSize = alAsset.defaultRepresentation.dimensions;
     if (imageSize.width > 3000) {
     // return NO;
     }
     return YES;
     } else if ([alAssetType isEqualToString:ALAssetTypeUnknown]) {
     return NO;
     }
     }*/
    return YES;
}

- (BOOL)takePhotoFromViewController:(UIViewController*)controller
{
    if ([[AVCaptureDevice class] respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
        AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authorizationStatus == AVAuthorizationStatusRestricted
            || authorizationStatus == AVAuthorizationStatusDenied) {
            
            // 没有权限
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"请授予拍照权限在设置隐私选项中"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            return NO;
        }
    }
    return YES;
}


@end
