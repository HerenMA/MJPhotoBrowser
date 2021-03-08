//
//  MJPhoto.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import <YYWebImage/YYWebImage.h>

@interface MJPhoto : NSObject

/// 图片URL
@property (strong, nonatomic) NSURL *url;
/// 完整的图片
@property (strong, nonatomic) UIImage *image;
/// 默认图片
@property (strong, readonly, nonatomic) UIImage *placeholder;
/// 索引
@property (assign, nonatomic) NSUInteger index;

@end
