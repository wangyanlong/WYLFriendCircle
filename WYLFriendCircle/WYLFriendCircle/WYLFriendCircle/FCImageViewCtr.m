//
//  FCImageViewCtr.m
//  WeiXinFriendCircle
//
//  Created by sunyong on 17/1/2.
//  Copyright © 2017年 @八点钟学院. All rights reserved.
//
#import "UIView+FC.h"
#import "FCImageViewCtr.h"

@interface FCImageViewCtr ()<UIScrollViewDelegate>

@end

@implementation FCImageViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:tapGest];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    self.imagAry = _imagAry;
}

- (void)tapGesture:(UIGestureRecognizer*)gesture{
    [self.view removeFromSuperview];
}

- (void)setImagAry:(NSArray *)imagAry{
    _imagAry = imagAry;
    thePageContrl.numberOfPages = imagAry.count;
    thePageContrl.currentPage = self.startIndex;
    [theScorllView setContentSize:CGSizeMake(imagAry.count*theScorllView.frame.size.width, theScorllView.frame.size.height)];
    [theScorllView removeAllSubView];
    for (int i = 0; i < imagAry.count; i++) {
        
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(i*theScorllView.frame.size.width, 0, theScorllView.frame.size.width, 400)];
        [imageV setCenter:CGPointMake(imageV.center.x, theScorllView.frame.size.height/2)];
        NSURL *imageUrl = [NSURL URLWithString:[imagAry objectAtIndex:i]];
        imageV.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
        [theScorllView addSubview:imageV];
    }
    [theScorllView setContentOffset:CGPointMake(self.startIndex*theScorllView.frame.size.width, 0)];
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger indexPage = scrollView.contentOffset.x/scrollView.frame.size.width;
    thePageContrl.currentPage = indexPage;
}


@end
