//
//  PlayerView.m
//  PlayerDemo
//
//  Created by luoluo on 14-5-27.
//  Copyright (c) 2014年 罗稳. All rights reserved.
//

#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>
@implementation PlayerView

+ (Class)layerClass
{
	return [AVPlayerLayer class];
}

- (AVPlayer*)player
{
	return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer*)player
{
	[(AVPlayerLayer*)[self layer] setPlayer:player];
}

/* Specifies how the video is displayed within a player layer’s bounds.
 (AVLayerVideoGravityResizeAspect is default) */
- (void)setVideoFillMode:(NSString *)fillMode
{
	AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
	playerLayer.videoGravity = fillMode;
}

@end
