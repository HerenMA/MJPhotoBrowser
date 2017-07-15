//
//  IMMJPhotoView.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMMJPhotoBrowser, IMMJPhoto, IMMJPhotoView;

@protocol IMMJPhotoViewDelegate <NSObject>
- (void)photoViewImageFinishLoad:(IMMJPhotoView *)photoView;
- (void)photoViewSingleTap:(IMMJPhotoView *)photoView;
@end

@interface IMMJPhotoView : UIScrollView <UIScrollViewDelegate>
/// 图片
@property (nonatomic, strong) IMMJPhoto *photo;
/// 代理
@property (nonatomic, strong) id<IMMJPhotoViewDelegate> photoViewDelegate;

@end