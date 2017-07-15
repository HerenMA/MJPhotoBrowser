//
//  IMMJPhotoLoadingView.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMinProgress 0.0001

@class IMMJPhotoBrowser;
@class IMMJPhoto;

@interface IMMJPhotoLoadingView : UIView

- (void)showLoading;
- (void)showFailure;

@end