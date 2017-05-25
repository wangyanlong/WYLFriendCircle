//
//  MyAsyncImageView.m
//  MyFirendImageView
//
//  Created by 王老师 on 2017/5/19.
//  Copyright © 2017年 wyl. All rights reserved.
//

#import "MyAsyncImageView.h"
#import "MyImageOperationQueue.h"
#import "MyImageOperation.h"

static MyImageOperationQueue *myOperationQueue;

@implementation MyAsyncImageView

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myOperationQueue = [MyImageOperationQueue new];
        myOperationQueue.maxConcurrentOperationCount = 2;
    });
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _monitorValue = 0;
    }
    return self;
}

- (void)loadImageWithURL:(NSString *)urlStr block:(ImageFinishBlock)imageBlock{
    
    if (!urlStr) {
        return;
    }
    
    _urlStr = urlStr;
    atomic_fetch_add(&_monitorValue, 1);
    
    MyImageOperation *loadImageOp = [[MyImageOperation alloc] init];
    
    loadImageOp.imageV = self;
    loadImageOp.urlStr = urlStr;
    loadImageOp.finishBlock = imageBlock;
    
    [myOperationQueue addOperation:loadImageOp];
    
}

@end
