//
//  IMMJPhoto.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#import "UIImageView+YYWebImage.h"

@interface IMMJPhoto : NSObject

@property (strong, nonatomic) NSURL *url;
/// 完整的图片
@property (strong, nonatomic) UIImage *image;
/// 默认图片
@property (strong, readonly, nonatomic) UIImage *placeholder;
/// 索引
@property (assign, nonatomic) NSUInteger index;

@end