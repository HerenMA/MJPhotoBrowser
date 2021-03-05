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
                           @"https://alifei02.cfp.cn/creative/vcg/veer/612/veer-153686131.jpg",
                           @"https://alifei05.cfp.cn/creative/vcg/veer/612/veer-147500854.jpg",
                           @"https://alifei01.cfp.cn/creative/vcg/veer/612/veer-152216760.jpg",
                           @"https://alifei02.cfp.cn/creative/vcg/veer/612/veer-151524091.jpg",
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
