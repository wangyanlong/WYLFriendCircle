//
//  PlayerView.h
//  PlayerDemo
//
//  Created by luoluo on 14-5-27.
//  Copyright (c) 2014年 罗稳. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVPlayer;
@interface PlayerView : UIView
@property (nonatomic, retain) AVPlayer* player;

- (void)setPlayer:(AVPlayer*)player;
- (void)setVideoFillMode:(NSString *)fillMode;

@end
