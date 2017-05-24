//
//  MovieView.m
//  WeiXinFriendCircle
//
//  Created by sunyong on 16/12/31.
//  Copyright © 2016年 @八点钟学院. All rights reserved.
//

#import "MovieView.h"

static NSMutableDictionary *imageDict;

@implementation MovieView

- (void)layoutSubviews{

    if (!theImageV) {
        theImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:theImageV];
    }
    if (!playButton) {
        playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [playButton setFrame:theImageV.frame];
        playButton.backgroundColor = [UIColor clearColor];
        [playButton setTitle:@"播放" forState:UIControlStateNormal];
        [playButton addTarget:self action:@selector(playeMovie:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:playButton];
        
    }
    theImageV.image = nil;
    if (!imageDict) {
        imageDict = [NSMutableDictionary dictionary];
    }
        
    if ([imageDict objectForKey:self.movieURLStr]) {
        theImageV.image = [imageDict objectForKey:self.movieURLStr];
    }else{
        [NSThread detachNewThreadSelector:@selector(getImage:) toTarget:self withObject:self.movieURLStr];
    }
    
}

// 任务提取出来
- (void)asyLoad:(asyDrawEocBlock)asyDrawEocBlock{
    
    UIImageView *imageV = theImageV;
    [NSThread detachNewThreadWithBlock:^{
        UIImage *drawData = (UIImage*)asyDrawEocBlock();
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([drawData isKindOfClass:[UIImage class]]) {
                imageV.image = drawData;
            }else{
                
                //其他清苦处理
                
            }
            
        });
    }];
    
    
    
}


// 异步加载
- (void)getImage:(NSString *)videoURL
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    
    NSURL *url = [[NSURL alloc] initWithString:videoURL];
    
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
    
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(150, 150);
    
    NSError *error = nil;
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(10, 10) actualTime:NULL error:&error];
    UIImage *image = [UIImage imageWithCGImage:img];
    if (image) {
        [imageDict setObject:image forKey:videoURL];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        theImageV.image = image;
        [theImageV setNeedsLayout];
    });
   
}

- (void)playeMovie:(UIButton*)sender{
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"11" ofType:@"mp4"];
    if (!playerConttol) {
        playerConttol = [[PlayerController alloc] initWithScreen:NO];
        // playerConttol.URL = [NSURL URLWithString:self.movieURLStr];
        playerConttol.URL = [NSURL fileURLWithPath:filePath];
        
        
    }
    [[UIApplication sharedApplication].keyWindow addSubview:playerConttol.view];
}

- (void)tapGesture:(UITapGestureRecognizer*)tap{
    [playerConttol.view removeFromSuperview];
}

@end
