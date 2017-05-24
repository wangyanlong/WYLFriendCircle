//
//  MovieView.h
//  WeiXinFriendCircle
//
//  Created by sunyong on 16/12/31.
//  Copyright © 2016年 @八点钟学院. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PlayerController.h"

typedef id(^asyDrawEocBlock)();

@interface MovieView : UIView{
    UIImageView *theImageV;
    UIButton *playButton;
    AVPlayer *mPlayer;
    PlayerController *playerConttol;
    
    // 视频图片第一帧加载  图片下载下来了，但加载不出来（多个线程处理问题）
}

@property (nonatomic, strong)NSString *movieURLStr;



- (void)asyLoad:(asyDrawEocBlock)asyDrawEocBlock;

@end
