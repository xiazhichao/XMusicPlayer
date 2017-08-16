//
//  XPlayMusicViewController.m
//  XMusicPlayerDemo
//
//  Created by xzc on 2017/8/16.
//  Copyright © 2017年 xzc. All rights reserved.
//

#import "XPlayMusicViewController.h"
#import "XMusicSlider.h"

#import "XMusicHandler.h"
#import "XTrack.h"
#import "XMusicListViewController.h"
#import "XMusicModel.h"
#import "UIImageView+WebCache.h"
#import "UIView+Animations.h"
#define kScreenW  [UIScreen mainScreen].bounds.size.width
#define kScreenH  [UIScreen mainScreen].bounds.size.height
static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;
@interface XPlayMusicViewController ()<XMusicListViewControllerDelegate>
{
    BOOL isAllowTouch; //防止歌曲状态之间毫秒级的切换（播放，暂停，下一首，上一首）
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *albumImageLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *albumImageRightConstraint;
@property (weak, nonatomic) IBOutlet XMusicSlider *musicSlider;
@property (weak, nonatomic) IBOutlet UIImageView *backgroudImageView;
@property (weak, nonatomic) IBOutlet UIView *albumBgView;
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
@property (weak, nonatomic) IBOutlet UILabel *musicNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;
@property (weak, nonatomic) IBOutlet UILabel *musicTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *beginTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *previousMusicButton;
@property (weak, nonatomic) IBOutlet UIButton *nextMusicButton;
@property (weak, nonatomic) IBOutlet UIButton *musicToggleButton;
@property (weak, nonatomic) IBOutlet UIButton *musicCycleButton;

@property (strong, nonatomic) UIVisualEffectView *visualEffectView;
@property(nonatomic,strong) XMusicModel *musicModel;
@property (strong, nonatomic) NSMutableString *lastMusicUrl;

@property (nonatomic) NSTimer *musicDurationTimer;

@property (nonatomic) NSInteger currentIndex;
@end

@implementation XPlayMusicViewController
static XPlayMusicViewController *playMusicVC = nil;
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    [self reConfigMudicPlayer];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];

    
}

//单例类
+(instancetype)shareSingleObj
{
    static dispatch_once_t once;
    
    dispatch_once(&once, ^
                  {
                      if (playMusicVC == nil)
                      {
                          playMusicVC = [[XPlayMusicViewController alloc] initWithNibName:@"XPlayMusicViewController" bundle:nil];
                      }
                  });
    return playMusicVC;
}

+(id)alloc
{
    
    static dispatch_once_t once ;
    
    dispatch_once(&once, ^
                  {
                      if (playMusicVC == nil)
                      {
                          playMusicVC = [super alloc];
                      }
                  });
    return playMusicVC;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self adapterIphone4];
    _musicDurationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSliderValue:) userInfo:nil repeats:YES];
    
    self.currentIndex = 0;
    isAllowTouch = YES;
    [self configUI];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}


-(void)configUI
{
    self.albumImageView.layer.masksToBounds = YES;
    self.albumBgView.layer.masksToBounds = YES;
    self.albumBgView.layer.cornerRadius = (kScreenW - 60)/2;
    self.albumImageView.layer.cornerRadius = (kScreenW - 70)/2;
    [self addPanRecognizer];
    
}

-(void)reConfigMudicPlayer
{
    if (_streamer) return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self createStreamer];
    });
}

# pragma mark - Basic setup

//- (void)adapterIphone4 {
//    if (iPhone4) {
//        CGFloat margin = 65;
//        _albumImageLeftConstraint.constant = margin;
//        _albumImageRightConstraint.constant = margin;
//    }
//}

//设置要播放的新歌曲的信息
- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    if (!_musicModels.count) return;
    [self setupMusicViewWithMusicEntity:_musicModels[currentIndex]];
}

- (void)setupMusicViewWithMusicEntity:(XMusicModel *)entity {
    _musicModel.isPlaying = NO;
    _musicModel = entity;
    _musicModel.isPlaying = YES;
    _musicNameLabel.text = _musicModel.audioName;
    _singerLabel.text = _musicModel.audioArtistName;
    _musicTitleLabel.text = _musicModel.audioName;
    [_musicSlider setValue:0.0f animated:NO];
    //    [_backgroudImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?x-oss-process=image/blur,r_50,s_6",_musicModel.audioImageUrlStr]] placeholderImage:placeHolderStr];
    [_albumImageView sd_setImageWithURL:[NSURL URLWithString:_musicModel.audioImageUrlStr] placeholderImage:nil];
    
}


//添加手势判断
- (void)addPanRecognizer {
    UISwipeGestureRecognizer *swipeRecognizer = nil;
    swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRecognizer];
    
    swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeRecognizer];
}

//手势判断上一首或者下一首
-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if(recognizer.direction==UISwipeGestureRecognizerDirectionLeft) {
        [self playNextMusic:nil];
    }else if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        [self playPreviousMusic:nil];
    }
}

//切换音乐循环模式
- (IBAction)didTouchMusicCycleButton:(id)sender {
    switch (_musicCycleType) {
        case DD_MusicCycleTypeLoopAll: {
            self.musicCycleType = DD_MusicCycleTypeShuffle;
            NSLog(@"随机播放");
        } break;
        case DD_MusicCycleTypeShuffle: {
            self.musicCycleType = DD_MusicCycleTypeLoopSingle;
            NSLog(@"单曲循环");
        } break;
        case DD_MusicCycleTypeLoopSingle: {
            self.musicCycleType = DD_MusicCycleTypeLoopAll;
            NSLog(@"列表循环");
        } break;
            
        default:
            break;
    }
}

//设置音乐环播播放模式
- (void)setMusicCycleType:(DDMusicCycleType)musicCycleType {
    _musicCycleType = musicCycleType;
    [self updateMusicCycleButton];
}

//更新循环播放模式
- (void)updateMusicCycleButton {
    switch (_musicCycleType) {
        case DD_MusicCycleTypeLoopAll:
            [_musicCycleButton setImage:[UIImage imageNamed:@"loop_all_icon"] forState:UIControlStateNormal];
            break;
        case DD_MusicCycleTypeShuffle:
            [_musicCycleButton setImage:[UIImage imageNamed:@"shuffle_icon"] forState:UIControlStateNormal];
            break;
        case DD_MusicCycleTypeLoopSingle:
            [_musicCycleButton setImage:[UIImage imageNamed:@"loop_single_icon"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    
}

//更新播放按钮
- (void)setMusicIsPlaying:(BOOL)musicIsPlaying {
    _musicIsPlaying = musicIsPlaying;
    
    if (_musicIsPlaying) {
        
        [_musicToggleButton setImage:[UIImage imageNamed:@"big_pause_button"] forState:UIControlStateNormal];
    } else {
        [self.albumImageView pauseRotationAnimation];
        [_musicToggleButton setImage:[UIImage imageNamed:@"big_play_button"] forState:UIControlStateNormal];
    }
    _musicModel.isPlaying = musicIsPlaying;
}

# pragma mark - Music Controls
//播放或者暂停
- (IBAction)didTouchMusicToggleButton:(id)sender {
    if (!isAllowTouch) return;
    isAllowTouch = NO;
    if (_musicModel.isPlaying) {
        
        [_streamer pause];
    } else {
        [self.albumImageView resumeRotationAnimation:20.0];
        [_streamer play];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        isAllowTouch = YES;
    });
}

//拖动进度条
- (IBAction)didChangeMusicSliderValue:(id)sender {
    if (_streamer.status == DOUAudioStreamerFinished) {
        _streamer = nil;
        [self createStreamer];
    }
    
    [_streamer setCurrentTime:[_streamer duration] * _musicSlider.value];
    [self updateProgressLabelValue];
}


# pragma mark - Audio Handle
//创建音频流，播放音乐
- (void)createStreamer {
    
    //    [self setupMusicViewWithMusicEntity:_musicModels[_currentIndex]];
    
    if (!_musicModel.audioURLStr || _musicModel.audioURLStr.length<=0) {
        NSLog(@"发现一首假的音乐");
        if (self.musicModels.count==1)return;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self playNextMusic:nil];
        });
        return;
    }
    [XMusicHandler configNowPlayingInfoCenter];
    
    XTrack *track = [[XTrack alloc] init];
    track.audioFileURL = [NSURL URLWithString:_musicModel.audioURLStr];
    
    @try {
        [self removeStreamerObserver];
    } @catch(id anException){
    }
    [self.streamer stop];
    self.streamer = nil;
    self.streamer = [DOUAudioStreamer streamerWithAudioFile:track];
    
    [self addStreamerObserver];
    
    if (self.albumImageView.layer.animationKeys.count && !_musicIsPlaying) {

        [self.albumImageView resumeRotationAnimation:20.0];
    }else
    {
        [self.albumImageView configMakeRotation:20.0];
    }
    
    [self.streamer play];
    
    //缓存下一张图片
    if (_currentIndex<_musicModels.count-1) {
        XMusicModel *nextModel = _musicModels[_currentIndex+1];
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:nextModel.audioImageUrlStr];
        if (!image) {
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:nextModel.audioImageUrlStr] options:SDWebImageDownloaderUseNSURLCache progress:nil completed:nil];
        }
    }
    
    if (self.presentedViewController && [self.presentedViewController isKindOfClass:[XMusicListViewController class]]) {
        XMusicListViewController *listVc = (XMusicListViewController *)self.presentedViewController;
        [listVc updateCells:_currentIndex];
    }
    
    
}

//选上一首歌
- (IBAction)playPreviousMusic:(id)sender {
    
    if (!isAllowTouch) return;
    isAllowTouch = NO;
    if (_musicCycleType == DD_MusicCycleTypeShuffle && _musicModels.count > 2) {
        [self setupRandomMusicIfNeed];
    } else {
        NSInteger firstIndex = 0;
        if (_currentIndex == firstIndex || [self currentIndexIsInvalid]) {
            self.currentIndex = _musicModels.count - 1;
        } else {
            self.currentIndex--;
        }
    }
    [self.albumImageView startTransitionAnimation];
    //    [self.backgroudImageView startTransitionAnimation];
    [self createStreamer];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        isAllowTouch = YES;
    });
}

//选下一首歌
- (IBAction)playNextMusic:(id)sender {
    
    if (!isAllowTouch) return;
    isAllowTouch = NO;
    if (_musicCycleType == DD_MusicCycleTypeShuffle && _musicModels.count > 2) {
        [self setupRandomMusicIfNeed];
    } else {
        [self checkNextIndexValue];
    }
    [self.albumImageView startTransitionAnimation];
    //    [self.backgroudImageView startTransitionAnimation];
    [self createStreamer];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        isAllowTouch = YES;
    });
}

//检查是否有下一首歌
- (void)checkNextIndexValue {
    NSInteger lastIndex = _musicModels.count - 1;
    if (_currentIndex == lastIndex || [self currentIndexIsInvalid]) {
        self.currentIndex = 0;
    } else {
        self.currentIndex++;
    }
}

# pragma mark - Setup streamer
//随机歌曲
- (void)setupRandomMusicIfNeed {
    NSInteger index = arc4random()%self.musicModels.count;
    self.currentIndex = index>=self.musicModels.count?index-1:index;
}

# pragma mark - Check Current Index
//检查当前歌曲的位置是否超过数组
- (BOOL)currentIndexIsInvalid {
    return _currentIndex >= _musicModels.count;
}


# pragma mark - Handle Music Slider
//更新歌曲进度条
- (void)updateSliderValue:(id)timer {
    if (!_streamer) {
        return;
    }
    if (_streamer.status == DOUAudioStreamerFinished) {
        [_streamer play];
    }
    
    if ([_streamer duration] == 0.0) {
        [_musicSlider setValue:0.0f animated:NO];
    } else {
        if (_streamer.currentTime >= _streamer.duration) {
            _streamer.currentTime -= _streamer.duration;
        }
        
        [_musicSlider setValue:[_streamer currentTime] / [_streamer duration] animated:YES];
        [self updateProgressLabelValue];
    }
    
}

//更新进度显示
- (void)updateProgressLabelValue {
    _beginTimeLabel.text = [XPlayMusicViewController timeIntervalToMMSSFormat:_streamer.currentTime];
    _endTimeLabel.text = [XPlayMusicViewController timeIntervalToMMSSFormat:_streamer.duration];
}

//缓冲的时候调用
- (void)updateBufferingStatus {
    
}


//删除通知
- (void)removeStreamerObserver {
    [_streamer removeObserver:self forKeyPath:@"status"];
    [_streamer removeObserver:self forKeyPath:@"duration"];
    [_streamer removeObserver:self forKeyPath:@"bufferingRatio"];
}

//创建监听音乐状态，时间，缓冲的通知
- (void)addStreamerObserver {
    [_streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
    [_streamer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kDurationKVOKey];
    [_streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
}

//监听回掉
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == kStatusKVOKey) {
        [self performSelector:@selector(updateStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    } else if (context == kDurationKVOKey) {
        [self performSelector:@selector(updateSliderValue:)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    } else if (context == kBufferingRatioKVOKey) {
        [self performSelector:@selector(updateBufferingStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

//更新音乐状态
- (void)updateStatus {
    
    switch ([_streamer status]) {
        case DOUAudioStreamerPlaying:
            
            self.musicIsPlaying = YES;

            NSLog(@"Playing");
            break;
            
        case DOUAudioStreamerPaused:
            self.musicIsPlaying = NO;
            
            break;
            
        case DOUAudioStreamerIdle:
            
            break;
            
        case DOUAudioStreamerFinished:
            if (_musicCycleType == DD_MusicCycleTypeLoopSingle) {
                [_streamer play];
            } else {
                [self playNextMusic:nil];
            }
            break;
            
        case DOUAudioStreamerBuffering:
            
            NSLog(@"Buffering");
            break;
            
        case DOUAudioStreamerError:
            
            break;
    }
}

//刷新正在播放的音乐（列表中选择了新的回来刷新）
-(void)updatePlayMusic:(NSInteger)index
{
    if (_currentIndex == index && _musicModel.isPlaying) return;
    if (_currentIndex == index && !_musicModel.isPlaying)
    {
        [_streamer play];
        return;
    }
    self.currentIndex = index;
    [self createStreamer];
    
}

# pragma mark - Public Method
//获取当前正在播放的音乐模型
- (XMusicModel *)currentPlayingMusic {
    if (_musicModels.count == 0 || _currentIndex>=_musicModels.count) {
        return nil;
    }
    
    return _musicModels[_currentIndex];
}

//显示音乐列表
- (IBAction)musicListAction:(id)sender {
    XMusicListViewController *musicListVc = [[XMusicListViewController alloc] initWithNibName:@"XMusicListViewController" bundle:nil];
    musicListVc.delegate = self;
    musicListVc.musicModels = self.musicModels;
    musicListVc.currentIndex = _currentIndex;
    musicListVc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    musicListVc.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self presentViewController:musicListVc animated:YES completion:^{
        musicListVc.view.superview.backgroundColor = [UIColor clearColor];
        
    }];
    
}

//返回
- (IBAction)goBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

+ (NSString *)timeIntervalToMMSSFormat:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
