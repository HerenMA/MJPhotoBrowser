//
//  MJZoomingScrollView.m
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MJPhotoView.h"
#import "MJPhoto.h"
#import "MJPhotoLoadingView.h"
#import <QuartzCore/QuartzCore.h>

#define ESWeak(var, weakVar) __weak __typeof(&*var) weakVar = var
#define ESStrong_DoNotCheckNil(weakVar, _var) __typeof(&*weakVar) _var = weakVar
#define ESStrong(weakVar, _var) ESStrong_DoNotCheckNil(weakVar, _var); if (!_var) return;

#define ESWeak_(var) ESWeak(var, weak_##var);
#define ESStrong_(var) ESStrong(weak_##var, _##var);

/** defines a weak `self` named `__weakSelf` */
#define ESWeakSelf      ESWeak(self, __weakSelf);
/** defines a strong `self` named `_self` from `__weakSelf` */
#define ESStrongSelf    ESStrong(__weakSelf, _self);

#define ESPlayImageData        @"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"

@interface MJPhotoView ()
{
    BOOL _zoomByDoubleTap;
    UIImageView *_imageView;
    UIButton *_playButton;
    MJPhotoLoadingView *_photoLoadingView;
}
@end

@implementation MJPhotoView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.clipsToBounds = YES;
        // 图片
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        
        // 播放
        UIImage *playImage = [UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:ESPlayImageData options:NSDataBase64DecodingIgnoreUnknownCharacters] scale:2.0];
        _playButton = [[UIButton alloc] init];
        _playButton.hidden = YES;
        _playButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [_playButton setImage:playImage forState:UIControlStateNormal];
        [self addSubview:_playButton];
        
        // 进度条
        _photoLoadingView = [[MJPhotoLoadingView alloc] init];
        [self addSubview:_photoLoadingView];
        
        // 属性
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // 监听点击
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.delaysTouchesBegan = YES;
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    return self;
}

//设置imageView的图片
- (void)configImageViewWithImage:(UIImage *)image {
    _imageView.image = image;
}


#pragma mark - photoSetter
- (void)setPhoto:(MJPhoto *)photo {
    _photo = photo;
    
    [self showImage];
}

#pragma mark 显示图片
- (void)showImage {
    _playButton.frame = CGRectMake((CGRectGetWidth(self.frame) - 120) / 2, (CGRectGetHeight(self.frame) - 120) / 2, 120, 120);
    _playButton.hidden = _photo.videoUrl.absoluteString.length > 0 ? NO : YES;
    
    [self photoStartLoad];
    
    [self adjustFrame];
}

#pragma mark 开始加载图片
- (void)photoStartLoad {
    if (_photo.image) {
        [_photoLoadingView showFailure];
        
        _imageView.image = _photo.image;
        self.scrollEnabled = YES;
    } else {
        if (_photo.videoUrl.absoluteString.length > 0) {
            [_photoLoadingView showFailure];
        } else {
            [_photoLoadingView showLoading];
        }
        _imageView.image = _photo.placeholder;
        self.scrollEnabled = NO;
        
        ESWeakSelf;
        ESWeak_(_imageView);
        NSString *scheme = [_photo.url scheme];
        if ([scheme.lowercaseString isEqualToString:@"http"] || [scheme.lowercaseString isEqualToString:@"https"]) {
            [_imageView yy_setImageWithURL:_photo.url
                               placeholder:_photo.placeholder
                                   options:kNilOptions
                                completion:^(UIImage *_Nullable image, NSURL *_Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError *_Nullable error) {
                                    ESStrongSelf;
                                    ESStrong_(_imageView);
                                    _imageView.image = image;
                                    [_self photoDidFinishLoadWithImage:image];
                                }];
        } else {
            UIImage *image = [UIImage imageWithContentsOfFile:_photo.url.absoluteString];
            _imageView.image = image;
            [self photoDidFinishLoadWithImage:image];
        }
    }
}

#pragma mark 加载完毕
- (void)photoDidFinishLoadWithImage:(UIImage *)image {
    if (image) {
        self.scrollEnabled = YES;
        _photo.image = image;
        [_photoLoadingView showFailure];
        
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewImageFinishLoad:)]) {
            [self.photoViewDelegate photoViewImageFinishLoad:self];
        }
    }
    
    // 设置缩放比例
    [self adjustFrame];
}


#pragma mark 调整frame
- (void)adjustFrame {
    if (_imageView.image == nil) return;
    
    // 基本尺寸参数
    CGFloat boundsWidth = self.bounds.size.width;
    CGFloat boundsHeight = self.bounds.size.height;
    CGFloat imageWidth = _imageView.image.size.width;
    CGFloat imageHeight = _imageView.image.size.height;
    
    // 设置伸缩比例
    CGFloat imageScale = boundsWidth / imageWidth;
    CGFloat minScale = MIN(1.0, imageScale);
    
    CGFloat maxScale = 5.0;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxScale = maxScale / [[UIScreen mainScreen] scale];
    }
    if (_photo.videoUrl.absoluteString.length > 0) {
        maxScale = 1.0;
    }
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;
    
    CGRect imageFrame = CGRectMake(0, MAX(0, (boundsHeight - imageHeight * imageScale) / 2), boundsWidth, imageHeight * imageScale);
    
    self.contentSize = CGSizeMake(CGRectGetWidth(imageFrame), CGRectGetHeight(imageFrame));
    _imageView.frame = imageFrame;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (_zoomByDoubleTap) {
        CGFloat insetY = (CGRectGetHeight(self.bounds) - CGRectGetHeight(_imageView.frame)) / 2;
        insetY = MAX(insetY, 0.0);
        if (ABS(_imageView.frame.origin.y - insetY) > 0.5) {
            CGRect imageViewFrame = _imageView.frame;
            imageViewFrame = CGRectMake(imageViewFrame.origin.x, insetY, imageViewFrame.size.width, imageViewFrame.size.height);
            _imageView.frame = imageViewFrame;
        }
    }
    return _imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (_photo.videoUrl.absoluteString.length > 0) {
        return;
    }
    _zoomByDoubleTap = NO;
    CGFloat insetY = (CGRectGetHeight(self.bounds) - CGRectGetHeight(_imageView.frame)) / 2;
    insetY = MAX(insetY, 0.0);
    if (ABS(_imageView.frame.origin.y - insetY) > 0.5) {
        [UIView animateWithDuration:0.2
                         animations:^{
                             CGRect imageViewFrame = _imageView.frame;
                             imageViewFrame = CGRectMake(imageViewFrame.origin.x, insetY, imageViewFrame.size.width, imageViewFrame.size.height);
                             _imageView.frame = imageViewFrame;
                         }];
    }
}

#pragma mark - 手势处理
/**
 *  单击隐藏
 *
 *  @param tap <#tap description#>
 */
- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    if (CGRectContainsPoint(_playButton.frame, point) && !_playButton.isHidden) {
        // 通知代理
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewPlayVideo:)]) {
            [self.photoViewDelegate photoViewPlayVideo:self];
        }
        return;
    }
    
    // 移除进度条
    [_photoLoadingView removeFromSuperview];
    
    // 通知代理
    if ([self.photoViewDelegate respondsToSelector:@selector(photoViewSingleTap:)]) {
        [self.photoViewDelegate photoViewSingleTap:self];
    }
}

/**
 *  双击放大
 *
 *  @param tap <#tap description#>
 */
- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    if (_photo.videoUrl.absoluteString.length > 0) {
        return;
    }
    _zoomByDoubleTap = YES;
    
    if (self.zoomScale == self.maximumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self];
        CGFloat scale = self.maximumZoomScale / self.zoomScale;
        CGRect rectTozoom = CGRectMake(touchPoint.x * scale, touchPoint.y * scale, 1, 1);
        [self zoomToRect:rectTozoom animated:YES];
    }
}

- (void)dealloc {
    // 取消请求
    [_imageView yy_setImageWithURL:[NSURL URLWithString:@"file:///abc"] options:kNilOptions];
}

@end
