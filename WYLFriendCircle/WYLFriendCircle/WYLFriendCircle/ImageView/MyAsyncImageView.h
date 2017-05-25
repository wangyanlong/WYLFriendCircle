//
//  MyAsyncImageView.h
//  MyFirendImageView
//
//  Created by 王老师 on 2017/5/19.
//  Copyright © 2017年 wyl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <stdatomic.h>

typedef void(^ImageFinishBlock)(UIImage *image);

@interface MyAsyncImageView : UIView

@property (nonatomic, readonly)atomic_size_t monitorValue;
@property (nonatomic, strong)NSString *urlStr;

- (void)loadImageWithURL:(NSString *)urlStr block:(ImageFinishBlock)imageBlock;

@end
