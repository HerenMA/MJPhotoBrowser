//
//  IMMJPhotoToolbar.h
//  FingerNews
//
//  Created by mj on 13-9-24.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMMJPhotoToolbar : UIView

/// 所有的图片对象
@property (strong, nonatomic) NSArray *photos;
/// 当前展示的图片索引
@property (assign, nonatomic) NSUInteger currentPhotoIndex;

@end
