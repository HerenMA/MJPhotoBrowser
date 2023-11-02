//
//  CollectionViewController.m
//  MJPhotoBrowser
//
//  Created by Sunnyyoung on 15/5/22.
//  Copyright (c) 2015年 Sunnyyoung. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionViewCell.h"
#import "MJPhotoBrowser.h"

static NSString * const reuseIdentifier = @"Cell";

@interface CollectionViewController ()

@property (nonatomic, strong) NSArray *imageURLArray;

@end

@implementation CollectionViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _imageURLArray = @[@"https://alifei05.cfp.cn/creative/vcg/veer/612/veer-147473424.jpg",
                           @"https://tenfei01.cfp.cn/creative/vcg/veer/612/veer-152656515.jpg",
                           @"https://alifei02.cfp.cn/creative/vcg/veer/612/veer-149626661.jpg",
                           @"https://nim-nosdn.netease.im/MTY3NzYzMjU=/bmltYV82MzU0MTIxNjU4M18xNjkzNTU0Mjk1NDUzXzlkZTYyOTU5LTg5YWYtNDAxOS05MzM0LTIyNzFmYjg0Y2Y2MQ==?vframe=1",
                           @"https://alifei02.cfp.cn/creative/vcg/veer/612/veer-153686131.jpg",
                           @"https://alifei05.cfp.cn/creative/vcg/veer/612/veer-147500854.jpg",
                           @"https://alifei01.cfp.cn/creative/vcg/veer/612/veer-152216760.jpg",
                           @"https://alifei02.cfp.cn/creative/vcg/veer/612/veer-151524091.jpg",
                           @"https://nim-nosdn.netease.im/MTY3NzYzMjU=/bmltYV82MzU0MTIxNjU4M18xNjkzNTU0Mjk1NDUzXzFjMWMzOTAzLWJkOWQtNDYyYi05OWJmLTU1ZTY5ZTg5ZTVhMw==?vframe=1",
                           @"https://tenfei03.cfp.cn/creative/vcg/veer/612/veer-149494937.jpg",
                           @"https://tenfei02.cfp.cn/creative/vcg/veer/612/veer-152352866.jpg"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imageURLArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.imageView.yy_imageURL= [NSURL URLWithString:_imageURLArray[indexPath.row]];
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = 0;
    NSMutableArray *photoArray = [NSMutableArray array];
    MJPhotoBrowser *photoBrowser = [[MJPhotoBrowser alloc] init];
    for (NSString *imageURL in _imageURLArray) {
        MJPhoto *photo = ({
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.url = [NSURL URLWithString:imageURL];
            photo.image = ((CollectionViewCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]]).imageView.image;
            if (row == 3) {
                photo.videoUrl = [NSURL URLWithString:@"https://nim-nosdn.netease.im/MTY3NzYzMjU=/bmltYV82MzU0MTIxNjU4M18xNjkzNTU0Mjk1NDUzXzlkZTYyOTU5LTg5YWYtNDAxOS05MzM0LTIyNzFmYjg0Y2Y2MQ=="];
            } else if (row == 8) {
                photo.videoUrl = [NSURL URLWithString:@"https://nim-nosdn.netease.im/MTY3NzYzMjU=/bmltYV82MzU0MTIxNjU4M18xNjkzNTU0Mjk1NDUzXzFjMWMzOTAzLWJkOWQtNDYyYi05OWJmLTU1ZTY5ZTg5ZTVhMw=="];
            }
            photo;
        });
        row++;
        [photoArray addObject:photo];
    }
    photoBrowser.photos = photoArray;
    photoBrowser.currentPhotoIndex = indexPath.row;
    [photoBrowser show];
}

@end
