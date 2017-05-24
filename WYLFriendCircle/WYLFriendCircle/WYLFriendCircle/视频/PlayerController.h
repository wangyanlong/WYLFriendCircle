//
//  PlayerController.h
//  PlayerDemo
//
//  Created by luoluo on 14-5-27.
//  Copyright (c) 2014年 罗稳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PlayerView.h"
#define DEVICE_WIDTH [UIScreen mainScreen].bounds.size.width
#define DEVICE_HEIGHT [UIScreen mainScreen].bounds.size.height
#define IOS7 YES
@class CourseDetailList;

@interface PlayerController : UIViewController
{
    @private
    id mTimeObserver;
    AVPlayer *mPlayer;
}

@property (nonatomic,strong) NSURL *URL;
@property (nonatomic,strong,setter = setPlayer:,getter = player) AVPlayer* mPlayer;

@property (nonatomic,strong) AVPlayerItem* mPlayerItem;
@property (nonatomic, strong)  PlayerView *mPlaybackView;
- (void)playCourseWithURL:(NSURL *)URL andCourseName:(NSString *)courseName;
- (void)playTheNextCourse:(CourseDetailList *)d;
- (id)initWithScreen:(BOOL)isBig;
@end
