//
//  MJPhotoToolbar.m
//  FingerNews
//
//  Created by mj on 13-9-24.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <Photos/Photos.h>
#if __has_include(<SVProgressHUD/SVProgressHUD.h>)
    #import <SVProgressHUD/SVProgressHUD.h>
#else
    #import "SVProgressHUD.h"
#endif

#import "MJPhotoToolbar.h"
#import "MJPhoto.h"

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
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
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
    [_saveButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_saveButton setTitle:@" 保存 " forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(saveClick:) forControlEvents:UIControlEventTouchUpInside];
    [_saveButton sizeToFit];
    _saveButton.frame = CGRectMake(CGRectGetWidth(self.frame) - (CGRectGetWidth(_saveButton.frame) + 10), (CGRectGetHeight(self.frame) - CGRectGetHeight(_saveButton.frame)) / 2, CGRectGetWidth(_saveButton.frame), CGRectGetHeight(_saveButton.frame));
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

    [SVProgressHUD showWithStatus:@"请稍候..."];
    _downloadTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                         ESStrongSelf;

                         if (error) {
                             [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                         } else {
                             [SVProgressHUD dismiss];

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
                     }];

    [_downloadTask resume];
}

/// <#Description#>
/// - Parameter image: <#image description#>
- (void)saveImageFromImage:(UIImage *)image {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
         [PHAssetChangeRequest creationRequestForAssetFromImage:image];
     } completionHandler:^(BOOL success, NSError *_Nullable error) {
         if (success) {
             [SVProgressHUD showSuccessWithStatus:@"保存成功"];
         } else {
             [SVProgressHUD showErrorWithStatus:error.localizedDescription];
         }
     }];
}

/// <#Description#>
/// - Parameter videoPath: <#videoPath description#>
- (void)saveVideoFromPath:(NSString *)videoPath {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
         NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
         [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoURL];
     } completionHandler:^(BOOL success, NSError *_Nullable error) {
         if (success) {
             [SVProgressHUD showSuccessWithStatus:@"保存成功"];
         } else {
             [SVProgressHUD showErrorWithStatus:error.localizedDescription];
         }

         NSError *removeError = nil;
         [[NSFileManager defaultManager] removeItemAtPath:videoPath error:&removeError];
         if (removeError) {
             [SVProgressHUD showErrorWithStatus:error.localizedDescription];
         }
     }];
}

@end
