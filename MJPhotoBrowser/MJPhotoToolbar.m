//
//  MJPhotoToolbar.m
//  FingerNews
//
//  Created by mj on 13-9-24.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <Photos/Photos.h>
#if __has_include(<Toast/Toast.h>)
    #import <Toast/Toast.h>
#else
    #import "Toast.h"
#endif

#import "MJPhotoToolbar.h"
#import "MJPhoto.h"

#define ESWeak(var, weakVar)                  __weak __typeof(&*var) weakVar = var
#define ESStrong_DoNotCheckNil(weakVar, _var) __typeof(&*weakVar) _var = weakVar
#define ESStrong(weakVar, _var)               ESStrong_DoNotCheckNil(weakVar, _var); if (!_var) return;

#define ESWeak_(var)                          ESWeak(var, weak_ ## var);
#define ESStrong_(var)                        ESStrong(weak_ ## var, _ ## var);

/** defines a weak `self` named `__weakSelf` */
#define ESWeakSelf   ESWeak(self, __weakSelf);
/** defines a strong `self` named `_self` from `__weakSelf` */
#define ESStrongSelf ESStrong(__weakSelf, _self);

@interface MJPhotoToolbar () {
    // 显示页码
    UILabel *_indexLabel;
    // 保存
    UIButton *_saveButton;
}
@end

/// <#Description#>
@implementation MJPhotoToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;

    _indexLabel = [[UILabel alloc] init];
    _indexLabel.font = [UIFont boldSystemFontOfSize:20];
    _indexLabel.frame = self.bounds;
    _indexLabel.backgroundColor = [UIColor clearColor];
    _indexLabel.textColor = [UIColor whiteColor];
    _indexLabel.textAlignment = NSTextAlignmentCenter;
    _indexLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:_indexLabel];

    // 保存
    _saveButton = [[UIButton alloc] init];
    _saveButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    _saveButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_saveButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_saveButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateDisabled];
    [_saveButton setTitle:@"   保存   " forState:UIControlStateNormal];
    [_saveButton setTitle:@"保存中..." forState:UIControlStateDisabled];
    [_saveButton addTarget:self action:@selector(saveClick:) forControlEvents:UIControlEventTouchUpInside];
    [_saveButton sizeToFit];
    _saveButton.frame = CGRectMake(CGRectGetWidth(self.frame) - (CGRectGetWidth(_saveButton.frame) + 5), (CGRectGetHeight(self.frame) - CGRectGetHeight(_saveButton.frame)) / 2, CGRectGetWidth(_saveButton.frame), CGRectGetHeight(_saveButton.frame));
    [self addSubview:_saveButton];
}

- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex {
    _currentPhotoIndex = currentPhotoIndex;

    // 更新页码
    _indexLabel.text = [NSString stringWithFormat:@"%d / %d", (int)_currentPhotoIndex + 1, (int)_photos.count];
}

- (void)saveClick:(UIButton *)sender {
    MJPhoto *photo = _photos[_currentPhotoIndex];

    if (photo.videoUrl.absoluteString.length > 0) {
        // 视频
        [self downloadTask:photo.videoUrl isVideo:YES];
    } else {
        // 图片
        if (photo.image) {
            [self saveImageFromImage:photo.image];
        } else {
            [self downloadTask:photo.url isVideo:NO];
        }
    }
}

/// <#Description#>
- (NSString *)generateFileName {
    NSString *timestamp = [NSString stringWithFormat:@"%lld", (long long)([[NSDate date] timeIntervalSince1970] * 1000)];
    NSString *randomString = [NSString stringWithFormat:@"%u", arc4random()];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", timestamp, randomString];

    return fileName;
}

/// <#Description#>
/// - Parameters:
///   - url: <#url description#>
///   - isVideo: <#isVideo description#>
- (void)downloadTask:(NSURL *)url isVideo:(BOOL)isVideo {
    ESWeakSelf;
    ESWeak_(_saveButton);
    _saveButton.enabled = NO;

    _downloadTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                         ESStrongSelf;
                         ESStrong_(_saveButton);

                         dispatch_async(dispatch_get_main_queue(), ^{
                                            _saveButton.enabled = YES;

                                            if (error) {
                                                [_self.superview makeToast:error.localizedDescription];
                                            } else {
                                                if (isVideo) {
                                                    NSString *fileName = [NSString stringWithFormat:@"%@.mp4", self.generateFileName];
                                                    NSString *videoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
                                                    [data writeToFile:videoPath atomically:YES];
                                                    [_self saveVideoFromPath:videoPath];
                                                } else {
                                                    UIImage *image = [UIImage imageWithData:data];
                                                    [_self saveImageFromImage:image];
                                                }
                                            }
                                        });
                     }];

    [_downloadTask resume];
}

/// <#Description#>
/// - Parameter image: <#image description#>
- (void)saveImageFromImage:(UIImage *)image {
    ESWeakSelf;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
         [PHAssetChangeRequest creationRequestForAssetFromImage:image];
     } completionHandler:^(BOOL success, NSError *_Nullable error) {
         ESStrongSelf;
         NSString *message;

         if (success) {
             message = @"保存成功";
         } else {
             message = error.localizedDescription;
         }

         dispatch_async(dispatch_get_main_queue(), ^{
                            [_self.superview makeToast:message];
                        });
     }];
}

/// <#Description#>
/// - Parameter videoPath: <#videoPath description#>
- (void)saveVideoFromPath:(NSString *)videoPath {
    ESWeakSelf;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
         NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
         [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoURL];
     } completionHandler:^(BOOL success, NSError *_Nullable error) {
         ESStrongSelf;
         NSString *message;

         if (success) {
             message = @"保存成功";
         } else {
             message = error.localizedDescription;
         }

         NSError *removeError = nil;
         [[NSFileManager defaultManager] removeItemAtPath:videoPath error:&removeError];
         if (removeError) {
             message = error.localizedDescription;
         }

         dispatch_async(dispatch_get_main_queue(), ^{
                            [_self.superview makeToast:message];
                        });
     }];
}

@end
