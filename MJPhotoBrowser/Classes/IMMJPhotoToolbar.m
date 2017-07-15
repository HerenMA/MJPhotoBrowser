//
//  IMMJPhotoToolbar.m
//  FingerNews
//
//  Created by mj on 13-9-24.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "IMMJPhoto.h"
#import "IMMJPhotoToolbar.h"

@interface IMMJPhotoToolbar () {
    /// 显示页码
    UILabel *_indexLabel;
}
@end

@implementation IMMJPhotoToolbar

- (id)initWithFrame:(CGRect)frame {
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
}

- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex {
    _currentPhotoIndex = currentPhotoIndex;

    // 更新页码
    _indexLabel.text = [NSString stringWithFormat:@"%d / %d", (int)_currentPhotoIndex + 1, (int)_photos.count];
}

@end
