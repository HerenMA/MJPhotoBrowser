//
//  MJPhotoBrowser.m
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "MJPhotoView.h"
#import "MJPhotoToolbar.h"

/// iPhone X / iPhone XS / iPhone XR / iPhone 11 / iPhone 12
#define kiPhoneX (@available(iOS 11.0, *) ? [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.f ? YES : NO : NO)
/// Tabbar safe bottom margin.
#define kTabbarSafeBottomMargin (kiPhoneX ? 34.f : 0.f)

#define kPadding 10
#define kPhotoViewTagOffset 1000
#define kPhotoViewIndex(photoView) ([photoView tag] - kPhotoViewTagOffset)

#define ESPlayImageData @"iVBORw0KGgoAAAANSUhEUgAAADwAAAA8CAYAAAA6/NlyAAAAAXNSR0IArs4c6QAAAU9JREFUaEPtmUEOwzAIBOFnzcvavqzpy6g4WIpaKRK1DYuDL7lYkYdZhzhhutjgi/FSAa9uvAyX4cUqUJFeTOgPThkuw4tVoCJtFSoiDyK6E9FORE9m1ivs6DIsIi8iun3RQYP3AsuJSkjwmcCtFhpzjT3E8ABWUBjbXsDNbji4N3B4zKOAG/jm3caigd33NwKw6/5GAnbZ34jAU2OOCjwt5ujAw2OeBXhYG8sGrOBd7+YZgXdm3v49iRSwpXIicnYettzKMvdSke6C1apmiXQ3aIsQOvAw0AzAw2FRIz0FFNHwVFAkYP3O9fb6shn90HKxemzyUcDuoFGRDgONAA6H9WpLEKAehqFARwG3f8PHB6Frm7Ecs7ojrTc4/COGBh1i2FpdhPldfRgBwLqGArZWLNv8MpzNmHW9ZdhasWzzy3A2Y9b1lmFrxbLNv5zhD7Lttj1mSpwzAAAAAElFTkSuQmCC"
#define ESPauseImageData @"iVBORw0KGgoAAAANSUhEUgAAADwAAAA8CAYAAAA6/NlyAAAAAXNSR0IArs4c6QAAAWBJREFUaEPtWUESgzAIhJ/Vl7V9Wf0ZHRydqVaTVYyZiZtLD4UAu2SjonKzpTerV1hw64yTYTLcGAJs6cYI/SuHDJPhxhBgSzdG6DWiZWYvEek9mqoOv3tW1D8V69SWNrOHiHwWAd+q6gBk11jo86h/NoATgBihNmZma7aqCsWJ+iN5QokgG22wO7l2udaO+iM5DkcMNczZRROO+ufym/5nwShSS7soQ1F/NG8yjCJFhtfvYKr0VgfxDM+Ryd7j6FGkaKFIUbQoWrMeyJ5BihZFa/+HhNVX1aMiRdGiaFG0kh/zqNJUaar0oQuGLw+HYBORqOhE/dG8yTCKFJ+07vak5YybmQ/SfKD2u3pV7ZDOifojMU47w2PBXqxP/6ai4cnhGf6XFzwFdMXNDc9SyUX9U3ufyjCCcG0bFlybgdLxyXBphGvvT4ZrM1A6PhkujXDt/clwbQZKxyfDpRGuvf8XY4BGTMJu8jgAAAAASUVORK5CYII="
#define ESThumbImageData @"iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAAAXNSR0IArs4c6QAAAWlJREFUWEfVmG0OwiAMhunJdCfTncx5spomQPguMISyX4ss7NnbvpUWlPALhPOp24CI+HQ+0r2/AOC6K0AXoIZ66Ze7UCkegvwqpbqAmwAdMA4qJ9xJCwDwrlW2GhARP0qpXrCQ56yFZAEHqJYTi0JPoMU8LQJqOFLun9dRgswCToIzH56FLAGOzDkuAuTwI/VQEhARyWWmjHCbj1pPQkaAi+CyoZYGGKnoAU42Ri41PMOEgCtyLwT1VAwBZzo3W8BdR4eAOMqSN/exYbaAQvIvcrMLKCH/tgG0px2pCiYB6az375NLrXfEA8p2MQDY1NuuUEv4J/H6lb0OC2Sxwd1brWvNc1G3lzoPriw3POBCFZO98p5Nk1ZxZqjb286JkH2Nu7GV6NGHWyMGt6PZRj2sS+zwKAFJP/U29VUDI/edTYBB2MlEj4qRnJlesZOs6tFHa/nXeeqNf80e3HiNe1eXgtymI9fFA/4Akcu5KbFv6nkAAAAASUVORK5CYII="

@interface MJPhotoBrowser () <MJPhotoViewDelegate>
@property (strong, nonatomic) UIView *view;
@property (strong, nonatomic) UIScrollView *photoScrollView;
@property (strong, nonatomic) NSMutableSet *visiblePhotoViews, *reusablePhotoViews;
@property (strong, nonatomic) MJPhotoToolbar *toolbar;

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

@property (strong, nonatomic) UIView *playerView;
@property (strong, nonatomic) UISlider *progressSlider;
@property (strong, nonatomic) UILabel *currentTimeLabel;
@property (strong, nonatomic) UILabel *totalTimeLabel;
@property (strong, nonatomic) UIButton *playPauseButton;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation MJPhotoBrowser

#pragma mark - init M

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

#pragma mark - get M

- (UIView *)view{
    if (!_view) {
        _view = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
        _view.backgroundColor = [UIColor blackColor];
    }
    return _view;
}

- (UIScrollView *)photoScrollView{
    if (!_photoScrollView) {
        CGRect frame = self.view.bounds;
        frame.origin.x -= kPadding;
        frame.size.width += (2 * kPadding);
        _photoScrollView = [[UIScrollView alloc] initWithFrame:frame];
        _photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _photoScrollView.pagingEnabled = YES;
        _photoScrollView.delegate = self;
        _photoScrollView.showsHorizontalScrollIndicator = NO;
        _photoScrollView.showsVerticalScrollIndicator = NO;
        _photoScrollView.backgroundColor = [UIColor clearColor];
    }
    return _photoScrollView;
}

- (MJPhotoToolbar *)toolbar{
    if (!_toolbar) {
        CGFloat barHeight = 49;
        CGFloat barY = self.view.frame.size.height - (barHeight + kTabbarSafeBottomMargin);
        _toolbar = [[MJPhotoToolbar alloc] init];
        _toolbar.frame = CGRectMake(0, barY, self.view.frame.size.width, barHeight);
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    return _toolbar;
}

-(UIView *)playerView{
    if (!_playerView) {
        CGFloat barHeight = 49;
        CGFloat barY = self.view.frame.size.height - (barHeight * 2 + kTabbarSafeBottomMargin);
        _playerView = [[UIView alloc] init];
        _playerView.frame = CGRectMake(0, barY, self.view.frame.size.width, barHeight);
        _playerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        UIImage *playImage = [UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:ESPlayImageData options:NSDataBase64DecodingIgnoreUnknownCharacters] scale:2.0];
        UIImage *pauseImage = [UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:ESPauseImageData options:NSDataBase64DecodingIgnoreUnknownCharacters] scale:2.0];
        _playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playPauseButton.frame = CGRectMake(0.0, 0.0, _playerView.frame.size.height, _playerView.frame.size.height);
        [_playPauseButton setImage:playImage forState:UIControlStateNormal];
        [_playPauseButton setImage:pauseImage forState:UIControlStateSelected];
        [_playPauseButton addTarget:self action:@selector(playPauseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_playerView addSubview:_playPauseButton];
        
        CGFloat rectX = _playPauseButton.frame.origin.x + _playPauseButton.frame.size.width + 10.0;
        CGFloat rectY = 0.0;
        CGFloat rectW = 50.0;
        CGFloat rectH = _playerView.frame.size.height;
        _currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(rectX, rectY, rectW, rectH)];
        _currentTimeLabel.font = [UIFont systemFontOfSize:14.0];
        _currentTimeLabel.textColor = UIColor.whiteColor;
        _currentTimeLabel.textAlignment = NSTextAlignmentLeft;
        _currentTimeLabel.text = @"00:00";
        _currentTimeLabel.adjustsFontSizeToFitWidth = YES;
        [_playerView addSubview:_currentTimeLabel];
        
        rectX = _playerView.frame.size.width - (rectW + 10.0);
        _totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(rectX, rectY, rectW, rectH)];
        _totalTimeLabel.font = [UIFont systemFontOfSize:14.0];
        _totalTimeLabel.textColor = UIColor.whiteColor;
        _totalTimeLabel.textAlignment = NSTextAlignmentRight;
        _totalTimeLabel.text = @"00:00";
        _totalTimeLabel.adjustsFontSizeToFitWidth = YES;
        [_playerView addSubview:_totalTimeLabel];
        
        rectX = _currentTimeLabel.frame.origin.x + rectW;
        rectW = _totalTimeLabel.frame.origin.x - rectX;
        UIImage *thumbImage = [UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:ESThumbImageData options:NSDataBase64DecodingIgnoreUnknownCharacters] scale:2.0];
        _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(rectX, rectY, rectW, rectH)];
        [_progressSlider setTintColor:UIColor.whiteColor];
        [_progressSlider setThumbImage:thumbImage forState:UIControlStateNormal];
        [_progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_playerView addSubview:_progressSlider];
    }
    return _playerView;
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    //初始化数据
    {
        if (!_visiblePhotoViews) {
            _visiblePhotoViews = [NSMutableSet set];
        }
        if (!_reusablePhotoViews) {
            _reusablePhotoViews = [NSMutableSet set];
        }
        self.toolbar.photos = self.photos;
        
        
        CGRect frame = self.view.bounds;
        frame.origin.x -= kPadding;
        frame.size.width += (2 * kPadding);
        self.photoScrollView.contentSize = CGSizeMake(frame.size.width * self.photos.count, 0);
        self.photoScrollView.contentOffset = CGPointMake(self.currentPhotoIndex * frame.size.width, 0);
        
        [self.view addSubview:self.photoScrollView];
        [self.view addSubview:self.toolbar];
        [self updateTollbarState];
        [self showPhotos];
    }
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    [UIView animateWithDuration:0.3f
                     animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0.f;
        [self.view setFrame:frame];
    }
                     completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }];
}

#pragma mark - set M
- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    if (_photos.count <= 0) {
        return;
    }
    for (int i = 0; i<_photos.count; i++) {
        MJPhoto *photo = _photos[i];
        photo.index = i;
    }
}

- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;
    
    if (_photoScrollView) {
        _photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * _photoScrollView.frame.size.width, 0);
        
        // 显示所有的相片
        [self showPhotos];
    }
}

- (void)playVideo:(MJPhoto *)photo
{
    self.player = [AVPlayer playerWithURL:photo.videoUrl];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.view.frame;
    [self.view.layer addSublayer:self.playerLayer];
    [self.view addSubview:self.playerView];
    
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew) context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemFailedToPlayToEndTime:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:self.player.currentItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    __weak typeof(self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        CMTime currentTime = weakSelf.player.currentTime;
        CMTime videoDuration = weakSelf.player.currentItem.duration;
        float durationInSeconds = CMTimeGetSeconds(videoDuration);
        float currentTimeInSeconds = CMTimeGetSeconds(currentTime);
        weakSelf.progressSlider.value = currentTimeInSeconds / durationInSeconds;
        weakSelf.currentTimeLabel.text = [weakSelf formattedTime:currentTimeInSeconds];
        weakSelf.totalTimeLabel.text = [weakSelf formattedTime:durationInSeconds];
    }];
}

- (void)stopVideo
{
    [self.timer invalidate];
    self.timer = nil;
    [self.playerView removeFromSuperview];
    self.playerView = nil;
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    
    [self.player pause];
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.player = nil;
}

- (void)playPauseButtonTapped:(UIButton *)sender
{
    [self.timer invalidate];
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.player play];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
    } else {
        self.playerView.alpha = 1.0;
        [self.player pause];
    }
}

- (void)hideControls {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.30 animations:^{
        weakSelf.playerView.alpha = 0.00;
    }];
}

- (void)progressSliderValueChanged:(UISlider *)slider
{
    CMTime duration = self.player.currentItem.duration;
    CGFloat totalTime = CMTimeGetSeconds(duration);
    CGFloat currentTime = totalTime * self.progressSlider.value;
    [self.player seekToTime:CMTimeMakeWithSeconds(currentTime, 1)];
}

- (NSString *)formattedTime:(CGFloat)totalSeconds
{
    NSInteger seconds = (NSInteger)totalSeconds % 60;
    NSInteger minutes = (NSInteger)(totalSeconds / 60) % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}

#pragma mark - Notification
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            CMTime duration = self.player.currentItem.duration;
            CGFloat totalTime = CMTimeGetSeconds(duration);
            self.totalTimeLabel.text = [self formattedTime:totalTime];
            
            [self.playPauseButton setSelected:YES];
            [self.player play];
            
            [self.timer invalidate];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
        }
    }
}

- (void)payerItemDidPlayToEndTime:(NSNotification *)notification {
    [self.player seekToTime:kCMTimeZero];
    self.playPauseButton.selected = NO;
    self.playerView.alpha = 1.0;
    [self.timer invalidate];
}

- (void)playerItemFailedToPlayToEndTime:(NSNotification *)notification {
    [self.player seekToTime:kCMTimeZero];
    self.playPauseButton.selected = NO;
    self.playerView.alpha = 1.0;
    [self.timer invalidate];
}

- (void)applicationDidEnterBackground {
    if (self.player.rate != 0 && self.player.error == nil) {
        [self playPauseButtonTapped:self.playPauseButton];
    }
}

- (void)applicationWillEnterForeground {
    if (![self.currentTimeLabel.text isEqualToString:@"00:00"] && ![self.currentTimeLabel.text isEqualToString:self.totalTimeLabel.text]) {
        [self playPauseButtonTapped:self.playPauseButton];
    }
}

#pragma mark - Show Photos
- (void)showPhotos
{
    CGRect visibleBounds = _photoScrollView.bounds;
    int firstIndex = (int)floorf((CGRectGetMinX(visibleBounds)+kPadding*2) / CGRectGetWidth(visibleBounds));
    int lastIndex  = (int)floorf((CGRectGetMaxX(visibleBounds)-kPadding*2-1) / CGRectGetWidth(visibleBounds));
    if (firstIndex < 0) firstIndex = 0;
    if (firstIndex >= _photos.count) firstIndex = (int)_photos.count - 1;
    if (lastIndex < 0) lastIndex = 0;
    if (lastIndex >= _photos.count) lastIndex = (int)_photos.count - 1;
    
    // 回收不再显示的ImageView
    NSInteger photoViewIndex;
    for (MJPhotoView *photoView in _visiblePhotoViews) {
        photoViewIndex = kPhotoViewIndex(photoView);
        if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
            [_reusablePhotoViews addObject:photoView];
            [photoView removeFromSuperview];
        }
    }
    
    [_visiblePhotoViews minusSet:_reusablePhotoViews];
    while (_reusablePhotoViews.count > 2) {
        [_reusablePhotoViews removeObject:[_reusablePhotoViews anyObject]];
    }
    
    for (NSUInteger index = firstIndex; index <= lastIndex; index++) {
        if (![self isShowingPhotoViewAtIndex:index]) {
            [self showPhotoViewAtIndex:(int)index];
        }
    }
    
}

//  显示一个图片view
- (void)showPhotoViewAtIndex:(int)index
{
    MJPhotoView *photoView = [self dequeueReusablePhotoView];
    if (!photoView) { // 添加新的图片view
        photoView = [[MJPhotoView alloc] init];
        photoView.photoViewDelegate = self;
    }
    
    // 调整当前页的frame
    CGRect bounds = _photoScrollView.bounds;
    CGRect photoViewFrame = bounds;
    photoViewFrame.size.width -= (2 * kPadding);
    photoViewFrame.origin.x = (bounds.size.width * index) + kPadding;
    photoView.tag = kPhotoViewTagOffset + index;
    
    MJPhoto *photo = _photos[index];
    photoView.frame = photoViewFrame;
    photoView.photo = photo;
    
    [_visiblePhotoViews addObject:photoView];
    [_photoScrollView addSubview:photoView];
}

//  index这页是否正在显示
- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index {
    for (MJPhotoView *photoView in _visiblePhotoViews) {
        if (kPhotoViewIndex(photoView) == index) {
            return YES;
        }
    }
    return  NO;
}
// 重用页面
- (MJPhotoView *)dequeueReusablePhotoView
{
    MJPhotoView *photoView = [_reusablePhotoViews anyObject];
    if (photoView) {
        [_reusablePhotoViews removeObject:photoView];
    }
    return photoView;
}

#pragma mark - updateTollbarState
- (void)updateTollbarState
{
    _currentPhotoIndex = _photoScrollView.contentOffset.x / _photoScrollView.frame.size.width;
    _toolbar.currentPhotoIndex = _currentPhotoIndex;
}



#pragma mark - MJPhotoViewDelegate
- (void)photoViewSingleTap:(MJPhotoView *)photoView
{
    if (self.player && self.player.rate != 0 && self.player.error == nil) {
        self.playerView.alpha = 1.0;
        
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
        return;
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    // 移除工具条
    [self.toolbar removeFromSuperview];
    [self.playerView removeFromSuperview];
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         CGRect frame = self.view.frame;
                         frame.origin.y = self.view.frame.size.height;
                         [self.view setFrame:frame];
                     }
                     completion:^(BOOL finished) {
                         [self.view removeFromSuperview];
                         
                         if (self.toolbar.downloadTask && (self.toolbar.downloadTask.state == NSURLSessionTaskStateRunning ||
                                                           self.toolbar.downloadTask.state == NSURLSessionTaskStateSuspended)) {
                             [self.toolbar.downloadTask cancel];
                         }
        
                         if (self.dismiss) {
                             self.dismiss();
                         }
                     }];
}

- (void)photoViewImageFinishLoad:(MJPhotoView *)photoView
{
    [self updateTollbarState];
}

- (void)photoViewPlayVideo:(MJPhotoView *)photoView {
    if (self.player) {
        [self photoViewSingleTap:photoView];
    } else {
        [self playVideo:photoView.photo];
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.player) {
        [self stopVideo];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self showPhotos];
    [self updateTollbarState];
}

@end
