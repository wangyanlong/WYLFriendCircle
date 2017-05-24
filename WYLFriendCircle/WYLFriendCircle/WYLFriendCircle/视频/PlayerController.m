//
//  PlayerController.m
//  PlayerDemo
//
//  Create.
//  Copyright (c) . All rights reserved.
//

#import "PlayerController.h"
#import <MediaPlayer/MediaPlayer.h>
/* Asset keys */
NSString * const kTracksKey         = @"tracks";
NSString * const kPlayableKey		= @"playable";

/* PlayerItem keys */
NSString * const kStatusKey         = @"status";

/* AVPlayer keys */
NSString * const kRateKey			= @"rate";
NSString * const kCurrentItemKey	= @"currentItem";

static void *PlaybackViewControllerRateObservationContext = &PlaybackViewControllerRateObservationContext;
static void *PlaybackViewControllerStatusObservationContext = &PlaybackViewControllerStatusObservationContext;
static void *PlaybackViewControllerCurrentItemObservationContext = &PlaybackViewControllerCurrentItemObservationContext;
static void *PlaybackLikelyToKeepUp = &PlaybackLikelyToKeepUp;
static void *PlaybackBufferFull = &PlaybackBufferFull;

#define MiniPlayBtnTag 10080
#define MiniPauseBtnTag 10081
#define MaxPlayBtnTag 10082
#define MaxPauseBtnTag 10083

#define MiniToolBarTag 10010
#define MaxToolBarTag 10011
#define TopViewTag 10012
#define MidViewTag 10013
#define LoadingBufferTag 7890

@interface PlayerController ()
{
    UILabel *miniCurrentTime;
    UILabel *miniTotalTime;
    UIProgressView *miniScrubber;
    
    UILabel *maxCurrentTime;
    UILabel *maxTotalTime;
    UISlider *maxScrubber;
    
    UILabel *titleLabel;
    
    UIButton *miniPlayBtn;
    UIButton *miniPauseBtn;
    UIButton *maxPlayBtn;
    UIButton *maxPauseBtn;
    
    UIActivityIndicatorView *loadingBuffer;
    UISlider *volumeSlider;
    
    MPMusicPlayerController *mpc;
    
    float mRestoreAfterScrubbingRate;

}

@property (nonatomic,strong)NSString *nowTime;
@property (nonatomic,strong) NSString *totalTime;
@property (nonatomic) CGFloat currentProgress;
@property (nonatomic,strong) NSString *dCourseName;
@property (nonatomic) UIInterfaceOrientation orienttion;
@property (nonatomic) BOOL isFullScreen;
@end

@interface PlayerController (Player)

- (void)removePlayerTimeObserver;
- (CMTime)playerItemDuration;
- (BOOL)isPlaying;
- (void)playerItemDidReachEnd:(NSNotification *)notification ;
- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys;

@end

@implementation PlayerController
@synthesize mPlayer;

- (id)initWithScreen:(BOOL)isBig
{
    if (self = [super init]) {
        self.isFullScreen = isBig;
        [self initData];
        [self setUI];
        
    }
    return self;
}

- (void)initData
{
    self.currentProgress = 0.0f;
    self.nowTime = @"00:00";
    self.totalTime = @"00.00";

}

#pragma mark - Update Data and UI

- (void)updatePlayAndPauseBtn
{
    if ([self isPlaying]) {
        maxPlayBtn.hidden = NO;
        miniPlayBtn.hidden = NO;
        maxPauseBtn.hidden = YES;
        miniPauseBtn.hidden = YES;

    } else {
        maxPauseBtn.hidden = NO;
        miniPauseBtn.hidden = NO;
        maxPlayBtn.hidden = YES;
        miniPlayBtn.hidden = YES;

    }
}

- (void)updateCurrentTime:(NSString *)time
{
    miniCurrentTime.text = time;
    maxCurrentTime.text = time;
}

- (void)updateTotalTime:(NSString *)time
{
    miniTotalTime.text = time;
    maxTotalTime.text = time;
}

- (void)updateScrubber:(CGFloat)value
{
    miniScrubber.progress = value;
    maxScrubber.value = value;
}

- (void)updateTitleName:(NSString *)name
{
    titleLabel.text = name;
}

- (NSString *)convertTimeToString:(float)time
{
    
    int m = (int)(time/60);
    int s = (int) ((time/60 - m)*60);
    
    return [NSString stringWithFormat:@"%02d:%02d ",m,s];
    
}



#pragma mark - 定制UI

//- (void)setLoadingbuffer
//{
//    loadingbuffer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _mPlaybackView.frame.size.width, _mPlaybackView.frame.size.height)];
//    loadingbuffer.backgroundColor = [UIColor clearColor];
//    [_mPlaybackView addSubview:loadingbuffer];
//    UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    loading.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
//    loading.tag = LoadingBufferTag;
//    loading.frame = CGRectMake(120, 60, 37, 37);
//    [loadingbuffer addSubview:loading];
//    [loading startAnimating];
//    
//    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(157, 63, 80, 30)];
//    msgLabel.font = [UIFont systemFontOfSize:14.0f];
//    msgLabel.backgroundColor = [UIColor clearColor];
//    msgLabel.text = @"即将播放";
//    msgLabel.textColor = [UIColor whiteColor];
//    [loadingbuffer addSubview:msgLabel];
//
//}

- (void)setUI
{
    //16:9
    if (_isFullScreen && !IOS7) {
        self.mPlaybackView = [[PlayerView alloc] initWithFrame:CGRectMake(0, -20, DEVICE_WIDTH, DEVICE_HEIGHT)];
    } else
        self.mPlaybackView = [[PlayerView alloc] initWithFrame:self.view.bounds];

    _mPlaybackView.backgroundColor = [UIColor colorWithRed:37/255.0 green:37/255.0 blue:37/255.0 alpha:1];
    _mPlaybackView.userInteractionEnabled = YES;
    _mPlaybackView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideForScreen)];
    [_mPlaybackView addGestureRecognizer:tap];
    [self.view addSubview:_mPlaybackView];
    


    loadingBuffer = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    loadingBuffer.frame = CGRectMake(160, 50, 20, 20);
    [_mPlaybackView addSubview:loadingBuffer];
    [loadingBuffer startAnimating];
    
    
    if (self.isFullScreen) {
        [self maxPlayerToolbar];
    } else {
        [self miniPlayerToolBar];

    }
    
}

- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
    if (self.isFullScreen) {
        return;
    } else {
        if (self.orienttion == UIInterfaceOrientationPortrait ) {
            [self removeMaxPlayerToolBar];
            
            self.view.frame = CGRectMake(0, IOS7 ? 20 : 0, 320, 180);
            self.mPlaybackView.frame = self.view.bounds;
            
            [self miniPlayerToolBar];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Hide" object:[NSNumber numberWithBool:NO]];
            
        } else if (self.orienttion == UIInterfaceOrientationLandscapeLeft || self.orienttion == UIInterfaceOrientationLandscapeRight) {
            
            [self removeMiniPlayerToolBar];
            self.view.frame = CGRectMake(0,IOS7 ? 0 : -20, DEVICE_HEIGHT, 320);
            [self maxPlayerToolbar];

        }

    }
}

- (void)miniPlayerToolBar //小视频工具栏
{
    loadingBuffer.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    loadingBuffer.frame = CGRectMake(150, 70, 20, 20);
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

    
    UIView *miniTool = [[UIView alloc] initWithFrame:CGRectMake(0, 180-40, 320, 40)];
    miniTool.tag = MiniToolBarTag;
    miniTool.backgroundColor = [UIColor clearColor];
    [self.view addSubview:miniTool];
    UIImageView *bottomBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    bottomBg.image = [[UIImage imageNamed:@"video_Vertical-screen_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    [miniTool addSubview:bottomBg];
    
    UIButton *zoomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [zoomBtn setBackgroundImage:[UIImage imageNamed:@"video_amplify"] forState:UIControlStateNormal];
    zoomBtn.frame = CGRectMake(320 - 30, 8, 20, 23);
    zoomBtn.tag = 10002;
    [miniTool addSubview:zoomBtn];
    [zoomBtn addTarget:self action:@selector(zoomIn:) forControlEvents:UIControlEventTouchUpInside];
    
    miniPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    miniPlayBtn.frame = CGRectMake(0, 0, 40, 40);
    miniPlayBtn.tag = MiniPlayBtnTag;
    [miniPlayBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [miniPlayBtn setBackgroundImage:[UIImage imageNamed:@"video_mini_play"] forState:UIControlStateNormal];
    [miniTool addSubview:miniPlayBtn];
    
    miniPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    miniPauseBtn.frame = CGRectMake(0, 0, 40, 40);
    miniPauseBtn.tag = MiniPauseBtnTag;
    miniPauseBtn.hidden = YES;
    [miniPauseBtn addTarget:self action:@selector(pauseAction:) forControlEvents:UIControlEventTouchUpInside];
    [miniPauseBtn setBackgroundImage:[UIImage imageNamed:@"video_mini_pause"] forState:UIControlStateNormal];
    [miniTool addSubview:miniPauseBtn];
    
    miniCurrentTime = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 40, 40)];
    miniCurrentTime.backgroundColor = [UIColor clearColor];
    miniCurrentTime.font = [UIFont boldSystemFontOfSize:13];
    miniCurrentTime.text = _nowTime;
    miniCurrentTime.textColor = [UIColor whiteColor];
    [miniTool addSubview:miniCurrentTime];
    
    miniScrubber = [[UIProgressView alloc] initWithFrame:CGRectMake(85, IOS7 ? 19 : 15, 140, 9)];
    miniScrubber.progress = 0.0;
    miniScrubber.progressViewStyle = UIProgressViewStyleDefault;
    if (IOS7) {
        [miniScrubber setTrackTintColor:[UIColor grayColor]];
        [miniScrubber setProgressTintColor:[UIColor greenColor]];

    } else {
        [miniScrubber setTrackImage:[[UIImage imageNamed:@"video_tiao-9.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 6, 4, 6)]];
        [miniScrubber setProgressImage:[[UIImage imageNamed:@"video_tiao-9-pre.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 6, 4, 6)]];
 
    }
    [miniTool addSubview:miniScrubber];
    
    miniTotalTime = [[UILabel alloc] initWithFrame:CGRectMake(85+140+12, 0, 40, 40)];
    miniTotalTime.backgroundColor = [UIColor clearColor];
    miniTotalTime.font = [UIFont boldSystemFontOfSize:13];
    miniTotalTime.text = _totalTime;
    miniTotalTime.textColor = [UIColor whiteColor];
    [miniTool addSubview:miniTotalTime];
    
    [self updatePlayAndPauseBtn];

    
}

- (void)maxPlayerToolbar
{
    
    CGFloat yy = 320;
    if (_isFullScreen && !IOS7) {
        yy = 300 ;
    } else if (IOS7) {
        yy = 320 ;
    }
    loadingBuffer.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    loadingBuffer.frame = CGRectMake(DEVICE_HEIGHT/2.0-10, yy/2.02-10, 20, 20);

    
    UIView *maxTool = [[UIView alloc] initWithFrame:CGRectMake(0, yy - 70 , DEVICE_HEIGHT, 70)];
    maxTool.tag = MaxToolBarTag;
    maxTool.backgroundColor = [UIColor clearColor];
    [self.view addSubview:maxTool];
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_HEIGHT, 70)];
    bgImageView.image = [[UIImage imageNamed:@"Video-player_bottom_bg.png"] stretchableImageWithLeftCapWidth:74 topCapHeight:20];
    [maxTool addSubview:bgImageView];
    
    maxPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    maxPlayBtn.frame = CGRectMake(21, 16, 45, 45);
    maxPlayBtn.tag = MaxPlayBtnTag;
    [maxPlayBtn setBackgroundImage:[UIImage imageNamed:@"video_past"] forState:UIControlStateNormal ];
    [maxTool addSubview:maxPlayBtn];
    [maxPlayBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    
    maxPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    maxPauseBtn.frame = CGRectMake(21, 16, 45, 45);
    maxPauseBtn.tag = MaxPauseBtnTag;
    maxPauseBtn.hidden = YES;
    [maxPauseBtn setBackgroundImage:[UIImage imageNamed:@"video_on"] forState:UIControlStateNormal ];
    [maxTool addSubview:maxPauseBtn];
    [maxPauseBtn addTarget:self action:@selector(pauseAction:) forControlEvents:UIControlEventTouchUpInside];
    
    maxCurrentTime = [[UILabel alloc] initWithFrame:CGRectMake(78, 12, 50, 58)];
    maxCurrentTime.backgroundColor = [UIColor clearColor];
    maxCurrentTime.textColor = [UIColor whiteColor];
    maxCurrentTime.text = _nowTime;
    maxCurrentTime.font = [UIFont boldSystemFontOfSize:15.0f];
    [maxTool addSubview:maxCurrentTime];
    
    maxScrubber = [[UISlider alloc] initWithFrame:CGRectMake(78 + 50, 27, DEVICE_HEIGHT - 235, 30)];
    maxScrubber.maximumValue = 1.0f;
    maxScrubber.minimumValue = 0.0f;
    [maxScrubber setThumbImage:[UIImage imageNamed:@"Video_btn_control"] forState:UIControlStateNormal];
    [maxScrubber setMaximumTrackImage:[[UIImage imageNamed:@"Video-player_bar_black"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 2, 6)] forState:UIControlStateNormal];
    [maxScrubber setMinimumTrackImage:[[UIImage imageNamed:@"Video-player_bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 2, 6)] forState:UIControlStateNormal];
    [maxTool addSubview:maxScrubber];
    
    [maxScrubber addTarget:self action:@selector(scrubbingDidBegin) forControlEvents:UIControlEventTouchDown|UIControlEventTouchDownRepeat];
    
    [maxScrubber addTarget:self action:@selector(scrubberIsScrolling:) forControlEvents:(UIControlEventValueChanged|UIControlEventTouchDragInside)];
    
    [maxScrubber addTarget:self action:@selector(scrubbingDidEnd) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel)];

    
    maxTotalTime = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_HEIGHT - 54 - 42, 12, 50, 58)];
    maxTotalTime.backgroundColor = [UIColor clearColor];
    maxTotalTime.textColor = [UIColor whiteColor];
    maxTotalTime.text = _totalTime;
    maxTotalTime.font = [UIFont boldSystemFontOfSize:15.0f];
    [maxTool addSubview:maxTotalTime];
    

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"video_blow-up"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(DEVICE_HEIGHT - 54, 20, 44, 44);
    [maxTool addSubview:backBtn];
    [backBtn addTarget:self action:@selector(zoomOut:) forControlEvents:UIControlEventTouchUpInside];
    
    [self createTopView];
    [self updatePlayAndPauseBtn];
    
}

- (void)createTopView
{
    float topY = 0;
    if (!IOS7) {
        if (!_isFullScreen) {
            topY = 20;
        }
    }
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, topY, DEVICE_HEIGHT,IOS7 ? 64 : 44)];
    topView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topView];
    topView.tag = TopViewTag;
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_HEIGHT, IOS7 ? 64 : 44)];
    bgImageView.image = [[UIImage imageNamed:@"Video-player_top_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    [topView addSubview:bgImageView];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, IOS7 ? 20 : 0, DEVICE_HEIGHT,44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:15.0f];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, topView.frame.size.height - 44, 50, 44);
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back_normal.png"] forState:UIControlStateNormal];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back_press.png"] forState:UIControlStateHighlighted];
    [topView addSubview:backBtn];
    [backBtn addTarget:self action:@selector(zoomOut:) forControlEvents:UIControlEventTouchUpInside];

    //声音控制面板
    UIView *midView = [[UIView alloc] initWithFrame:CGRectMake(DEVICE_HEIGHT - 50, topView.frame.origin.y + topView.frame.size.height + 17, 37, 166)];
    midView.tag = MidViewTag;
    [self.view addSubview:midView];

   UIImageView *midbg = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"Video-player_sound_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 14, 10, 14)]];
    midbg.frame = CGRectMake(0, 0, 37, 166);
    [midView addSubview:midbg];

    volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(DEVICE_HEIGHT - 160, (DEVICE_WIDTH - 35)/2.0, 140, 27)];
    volumeSlider.maximumValue = 1.0f;
    volumeSlider.minimumValue = 0.0f;
    volumeSlider.value = mpc.volume;
    [volumeSlider setMinimumTrackImage:[[UIImage imageNamed:@"Video-player_bar_bot"]resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) ] forState:UIControlStateNormal];
    [volumeSlider setMaximumTrackImage:[[UIImage imageNamed:@"Video-player_bar_bot_gradd"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) ] forState:UIControlStateNormal];
    [volumeSlider setThumbImage:[UIImage imageNamed:@"Video_btn_control"] forState:UIControlStateNormal];
    [volumeSlider setThumbImage:[UIImage imageNamed:@"Video_btn_control"] forState:UIControlStateHighlighted];
    
	CGAffineTransform rotation = CGAffineTransformMakeRotation(-1.57079633);
	[volumeSlider setTransform:rotation];
    [volumeSlider addTarget:self action:@selector(volumeChangeAction:) forControlEvents:UIControlEventValueChanged];
	
	[volumeSlider setFrame:CGRectMake(5, 12, 27, 140)];
    [midView addSubview:volumeSlider];

    
    [self updateTitleName:self.dCourseName];

}

#pragma mark Movie scrubber control

-(void)initScrubberTimer
{
	double interval = .1f;
	
	CMTime playerDuration = [self playerItemDuration];
	if (CMTIME_IS_INVALID(playerDuration))
	{
		return;
	}

    __weak typeof(self) weakSelf = self;
	mTimeObserver = [self.mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                                queue:NULL
                                                           usingBlock:^(CMTime time)
                      {
                          [weakSelf syncScrubber];
                      }];
    
}

- (void)syncScrubber
{
	CMTime playerDuration = [self playerItemDuration];
	if (CMTIME_IS_INVALID(playerDuration))
	{
		miniScrubber.progress = 0.0;
		return;
	}
    
	double duration = CMTimeGetSeconds(playerDuration);
    
    CMTime currentTime = self.player.currentItem.currentTime;

    CGFloat currentPlayTime = (CGFloat)currentTime.value/currentTime.timescale;
    
    self.nowTime = [self convertTimeToString:currentPlayTime];
    [self updateCurrentTime:self.nowTime];
    
	if (isfinite(duration))
	{
		float minValue = [maxScrubber minimumValue];
		float maxValue = [maxScrubber maximumValue];
		double time = CMTimeGetSeconds([self.player currentTime]);
		
		[maxScrubber setValue:(maxValue - minValue) * time / duration + minValue];
        miniScrubber.progress = CMTimeGetSeconds(currentTime)/duration;

        
	}
}

//按动滑块
-(void)scrubbingDidBegin
{
    mRestoreAfterScrubbingRate = [self.player rate];
	[self.player setRate:0.f];
    [self removePlayerTimeObserver];
    
}

//快进
-(void)scrubberIsScrolling:(id)sender
{
	if ([sender isKindOfClass:[UISlider class]])
	{
		UISlider* slider = sender;
        
		CMTime playerDuration = [self playerItemDuration];
		if (CMTIME_IS_INVALID(playerDuration)) {
			return;
		}
		
		double duration = CMTimeGetSeconds(playerDuration);
		if (isfinite(duration))
		{
			float minValue = [slider minimumValue];
			float maxValue = [slider maximumValue];
			float value = [slider value];
			
			double time = duration * (value - minValue) / (maxValue - minValue);
			maxCurrentTime.text = [self convertTimeToString:time];
			[self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) completionHandler:^(BOOL finished)
             {
//                 self.Moviebuffer.hidden = YES;
//                 [_Moviebuffer stopAnimating];
             }];
            
		}
	}
    
}

-(void)scrubbingDidEnd
{
//    self.Moviebuffer.hidden = NO;
//    [_Moviebuffer startAnimating];
    
    
	if (!mTimeObserver)
	{
		CMTime playerDuration = [self playerItemDuration];
		if (CMTIME_IS_INVALID(playerDuration))
		{
			return;
		}
		
		double duration = CMTimeGetSeconds(playerDuration);
		if (isfinite(duration))
		{
            __weak typeof(self) weakSelf = self;
			mTimeObserver = [self.mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC) queue:NULL usingBlock:
                              ^(CMTime time)
                              {
                                  [weakSelf syncScrubber];
                              }];
		}
	}
    
	if (mRestoreAfterScrubbingRate)
	{
		[self.player setRate:mRestoreAfterScrubbingRate];
		mRestoreAfterScrubbingRate = 0.f;
	}
}


#pragma mark - Event

- (void)volumeChangeAction:(UISlider *)slider
{
    float minValue = [slider minimumValue];
    float maxValue = [slider maximumValue];
    float value = [slider value];
    
    float volume = 1.0 * (value - minValue) / (maxValue - minValue);
    
    
    mpc.volume = volume;
}



- (void)playAction:(UIButton *)btn
{
    if (btn.tag == MiniPlayBtnTag) {
        UIView *view = [self.view viewWithTag:MiniToolBarTag];
        UIButton *newBtn = (UIButton *)[view viewWithTag:MiniPauseBtnTag];
        newBtn.hidden = NO;
        btn.hidden = YES;
    } else if (btn.tag == MaxPlayBtnTag) {
        UIView *view = [self.view viewWithTag:MaxToolBarTag];
        UIButton *newBtn = (UIButton *)[view viewWithTag:MaxPauseBtnTag];
        newBtn.hidden = NO;
        btn.hidden = YES;

    }
    [self.player pause];

}

- (void)pauseAction:(UIButton *)btn
{
    if (btn.tag == MiniPauseBtnTag) {
        UIView *view = [self.view viewWithTag:MiniToolBarTag];
        UIButton *newBtn = (UIButton *)[view viewWithTag:MiniPlayBtnTag];
        newBtn.hidden = NO;
        btn.hidden = YES;
    } else if (btn.tag == MaxPauseBtnTag) {
        UIView *view = [self.view viewWithTag:MaxToolBarTag];
        UIButton *newBtn = (UIButton *)[view viewWithTag:MaxPlayBtnTag];
        newBtn.hidden = NO;
        btn.hidden = YES;

    }
    [self.player play];

}

- (void)hideForScreen
{
    [self.view removeFromSuperview];
    
}



- (void)backAction:(UIButton *)btn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)removeMaxPlayerToolBar
{
    UIView *view = [self.view viewWithTag:MaxToolBarTag];
    UIView *topView = [self.view viewWithTag:TopViewTag];
    UIView *midView = [self.view viewWithTag:MidViewTag];
    
    midView.hidden = YES;
    topView.hidden = YES;
    view.hidden = YES;
    [midView removeFromSuperview];
    [topView removeFromSuperview];
    [view removeFromSuperview];
}

- (void)removeMiniPlayerToolBar
{
    UIView *view = [self.view viewWithTag:MiniToolBarTag];
    view.hidden = YES;
    [view removeFromSuperview];
}

- (void)zoomOut:(UIButton *)btn
{
    if (self.isFullScreen) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val = UIInterfaceOrientationPortrait;
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }

    }




}


- (void)zoomIn:(UIButton *)btn
{

    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationLandscapeRight;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }


}

- (void)resetPayer
{
    if (self.mPlayerItem)
    {
        
        [self.mPlayerItem removeObserver:self forKeyPath:kStatusKey];
		
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.mPlayerItem];
        self.mPlayerItem = nil;
    }
    [loadingBuffer startAnimating];
    [self removePlayerTimeObserver];

    [self.mPlaybackView setPlayer:nil];
    [self initData];
    [self updateCurrentTime:_nowTime];
    [self updateTotalTime:_totalTime];
    [self updateScrubber:0.0];

}

#pragma mark - Asset URL

- (void)playCourseWithURL:(NSURL *)URL andCourseName:(NSString *)courseName
{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:URL options:nil];
    NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey, kPlayableKey, nil];
    self.dCourseName = courseName;
    self.totalTime = [self convertTimeToString:asset.duration.value / asset.duration.timescale];
    [self updateTotalTime:self.totalTime];
    [self updateTitleName:self.dCourseName];


    
    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
        dispatch_async( dispatch_get_main_queue(),
                       ^{
                           
                           [self prepareToPlayAsset:asset withKeys:requestedKeys];
                       });
    }];


}




- (void)playTheNextCourse:(id)sender
{

}

#pragma mark - 声音预设置

- (void)initVolumeSetting
{
    NSError *myErr = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&myErr];
    //声音监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    mpc = [MPMusicPlayerController applicationMusicPlayer];

    
}



#pragma mark - viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initVolumeSetting];
    
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)volumeChanged:(NSNotification *)notification
{
    volumeSlider.value = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.player pause];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.player play];

}

- (void)viewWillAppear:(BOOL)animated
{
//    [loadingBuffer startAnimating];
}

- (void)clearAllPlayerObserver
{
    [self removePlayerTimeObserver];
	
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[self.mPlayer removeObserver:self forKeyPath:@"rate"];
    [mPlayer.currentItem removeObserver:self forKeyPath:@"status"];

    [self.mPlayer removeObserver:self forKeyPath:@"currentItem"];
    
	[self.mPlayer pause];
	self.mPlayer = nil;
	

}

- (void)dealloc
{
    [self clearAllPlayerObserver];
	NSLog(@"player dealloc");
}


////视图旋转之前自动调用
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (!_isFullScreen) {
        self.orienttion = toInterfaceOrientation;
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            
            self.view.frame = CGRectMake(0, 0, DEVICE_HEIGHT, 320);
            [self removeMiniPlayerToolBar];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Hide" object:[NSNumber numberWithBool:YES]];
            
        } else if (toInterfaceOrientation == UIInterfaceOrientationPortrait ) {
            
            [self removeMaxPlayerToolBar];
            
            
        }

    }
}


#pragma mark – 屏幕旋转控制

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (self.isFullScreen) {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);

    } else {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    if (self.isFullScreen) {
        return UIInterfaceOrientationMaskLandscape;
        
    } else {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
}


@end


#pragma mark -

@implementation PlayerController (Player)

#pragma mark - Play Item

- (BOOL)isPlaying
{
    return [self.player rate] != 0.f;
}

- (CMTime)playerItemDuration
{
	AVPlayerItem *playerItem = [self.mPlayer currentItem];
	if (playerItem.status == AVPlayerItemStatusReadyToPlay)
	{
        
		return([playerItem duration]);
	}
	
	return(kCMTimeInvalid);
}


- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    
}

/* Cancels the previously registered time observer. */
-(void)removePlayerTimeObserver
{
	if (mTimeObserver)
	{
        [self.mPlayer pause];
		[self.mPlayer removeTimeObserver:mTimeObserver];
		mTimeObserver = nil;
	}
}

#pragma mark -
#pragma mark Error Handling - Preparing Assets for Playback Failed

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self removePlayerTimeObserver];
    NSLog(@"error %@",[error description]);
}

#pragma mark -
#pragma mark Prepare to play asset, URL

- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
	for (NSString *thisKey in requestedKeys)
	{
		NSError *error = nil;
		AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
		if (keyStatus == AVKeyValueStatusFailed)
		{
			[self assetFailedToPrepareForPlayback:error];
			return;
		}
        
		/* If you are also implementing -[AVAsset cancelLoading], add your code here to bail out properly in the case of cancellation. */
	}
    
    if (!asset.playable)
    {
        
//        [self assetFailedToPrepareForPlayback:nil];
        NSLog(@"error on playable");
//        return;
    }
	
    if (self.mPlayerItem)
    {
        
        [self.mPlayerItem removeObserver:self forKeyPath:kStatusKey];
		
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.mPlayerItem];
        self.mPlayerItem = nil;
    }

	
    self.mPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    
//    [self.mPlayerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:PlaybackLikelyToKeepUp];
//    [self.mPlayerItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew context:PlaybackBufferFull];


    [self.mPlayerItem addObserver:self
                       forKeyPath:kStatusKey
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:PlaybackViewControllerStatusObservationContext];
	
    /* When the player item has played to its end time we'll toggle
     the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.mPlayerItem];
	
	
    if (!self.mPlayer)
    {
        [self setPlayer:[AVPlayer playerWithPlayerItem:self.mPlayerItem]];
		
        [self.player addObserver:self
                      forKeyPath:kCurrentItemKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:PlaybackViewControllerCurrentItemObservationContext];
        
        [self.player addObserver:self
                      forKeyPath:kRateKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:PlaybackViewControllerRateObservationContext];
    }
    
    /* Make our new AVPlayerItem the AVPlayer's current item. */
    if (self.player.currentItem != self.mPlayerItem)
    {
        [self.mPlayer replaceCurrentItemWithPlayerItem:self.mPlayerItem];
        
    }
	
}

#pragma mark -
#pragma mark Asset Key Value Observing
#pragma mark Key Value Observer for player rate, currentItem, player item status
- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
	if (context == PlaybackViewControllerStatusObservationContext)
	{
        
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        
        [self updatePlayAndPauseBtn];
        switch (status)
        {
            case AVPlayerStatusUnknown:
            {
                [self removePlayerTimeObserver];
                NSLog(@"AVPlayerStatusUnknown");
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {

                [self initScrubberTimer];
                [self.player play];
            }
                break;
                
            case AVPlayerStatusFailed:
            {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error];
            }
                break;
        }
	}
	else if (context == PlaybackViewControllerRateObservationContext)
	{
        [self updatePlayAndPauseBtn];

	} else if (context == PlaybackViewControllerCurrentItemObservationContext)
	{
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        /* Is the new player item null? */
        if (newPlayerItem == (id)[NSNull null])
        {
        }
        else /* Replacement of player currentItem has occurred */
        {
            [self.mPlaybackView setPlayer:mPlayer];
            [self.mPlaybackView setVideoFillMode:AVLayerVideoGravityResizeAspect];
            
            [loadingBuffer stopAnimating];

            
        }
	}
	else
	{
		[super observeValueForKeyPath:path ofObject:object change:change context:context];
	}
}



@end
