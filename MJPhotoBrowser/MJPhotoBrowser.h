//
//  MJPhotoBrowser.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import "MJPhoto.h"

@protocol MJPhotoBrowserDelegate;

typedef void (^MJPhotoBrowserDismiss)();

@interface MJPhotoBrowser : NSObject <UIScrollViewDelegate>

/// 所有的图片对象
@property (assign, nonatomic) NSArray *photos;
/// 当前展示的图片索引
@property (assign, nonatomic) NSUInteger currentPhotoIndex;
/// Block
@property (copy, nonatomic) MJPhotoBrowserDismiss dismiss;

/**
 显示
 */
- (void)show;

@end
