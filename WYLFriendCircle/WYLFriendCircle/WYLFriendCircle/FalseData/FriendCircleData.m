//
//  FriendCircleData.m
//  WYLFriendCircle
//
//  Created by wyl on 2017/5/22.
//  Copyright © 2017年 wyl. All rights reserved.
//
#import "WYLFCModel.h"
#import "FriendCircleData.h"

static NSInteger kAllPage = 0;
static NSMutableArray *imageContentAry;
static NSMutableArray *textContentAry;
static NSArray *AllNameAry;
static NSArray *AllMessageAry;

@implementation FriendCircleData

+(NSDictionary *)backFriendCircleData:(NSInteger)currentPage{
 
    if (currentPage == 0) {
        kAllPage = 0;
    }
    
    NSMutableDictionary *backDict = [NSMutableDictionary dictionary];
    
    NSMutableArray *dataAry = [NSMutableArray array];
    
    for (int i = 0; i < 15; i++) {
        WYLFCModel *fcModel = [FriendCircleData backRandomModel];
        [dataAry addObject:fcModel];
    }
    
    return nil;

}

+ (WYLFCModel *)backRandomModel{
    
    FCCellContentType modelType = random()%7;
    
    WYLFCModel *fcModel = [[WYLFCModel alloc] init];
    fcModel.name = [NSString stringWithFormat:@"WYL朋友圈%d号",(int)modelType];
    
    fcModel.protraitPath = [[FriendCircleData imageUrlFromFile] objectAtIndex:(int)modelType];
    fcModel.contentType = modelType;
    
    if (modelType == FC_OnlyTextContent || modelType == FC_TextAndPictureContent|| modelType == FC_TextAndLinkContent|| modelType == FC_TextAndMovieContent) {
        
        NSInteger textContextIndex = random()%[self textDesFromFile].count;
        fcModel.contentTextStr = [[self textDesFromFile] objectAtIndex:textContextIndex];
        
    }
    
    // 图片
    if (modelType == FC_OnlyPictureContent || modelType == FC_TextAndPictureContent) {
        NSInteger imageCount = random()%6;
        imageCount = (imageCount == 0)?1:imageCount;
        NSMutableArray *imageAr = [NSMutableArray array];
        for (int i = 0; i < imageCount; i++) {
            NSArray *allImageAry = [FriendCircleData imageUrlFromFile];
            NSInteger pictureIndex = random()%allImageAry.count;
            [imageAr addObject:[allImageAry objectAtIndex:pictureIndex]];
        }
        fcModel.imageAry = imageAr;
    }

    // 视频
    if (modelType == FC_OnlyMovieContent || modelType == FC_TextAndMovieContent) {
        fcModel.moviePath = @"http://www.8pmedu.com/appimage/8pm.mp4";
    }
    
    // 链接
    if (modelType == FC_OnlyLinkContent || modelType == FC_TextAndLinkContent) {
        NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
        [infoDict setObject:@"U17" forKey:@"text"];
        [infoDict setObject:@"http://www.u17.com" forKey:@"url"];
        [infoDict setObject:@"logo.png" forKey:@"img"];
        fcModel.linkInfoDict = infoDict;
    }
    
    //时间
    static int __timeStp = 10;
    fcModel.timeStp = [@(__timeStp++) description];
    
    // 留言
    NSArray *nameAry    = [self backName];
    NSArray *messageAry = [self backMessageContent];
    NSInteger messageCount = random()%6;
    fcModel.messageAry = [NSMutableArray array];
    //0(楼主回复XX:) 1(XX回复楼主:) 2(楼主回复:) 3(XX回复:)
    for (int i = 0; i < messageCount; i++) {
        NSInteger nameIndex = random()%nameAry.count;
        NSInteger messageIndex = random()%messageAry.count;
        int status = random()%4;
        NSMutableDictionary *messDict = [NSMutableDictionary dictionary];
        [messDict setObject:[nameAry objectAtIndex:nameIndex] forKey:@"name"];
        [messDict setObject:[messageAry objectAtIndex:messageIndex] forKey:@"msg"];
        [messDict setObject:[NSString stringWithFormat:@"%d", status] forKey:@"status"];
        [fcModel.messageAry addObject:messDict];
    }
    
    // 点赞
    NSInteger approveCount = random()%6;
    fcModel.approveAry = [NSMutableArray array];
    for (int i = 0; i < approveCount; i++) {
        NSInteger nameIndex = random()%nameAry.count;
        [fcModel.approveAry addObject:[nameAry objectAtIndex:nameIndex]];
    }

    
    return fcModel;
    
}

+ (NSArray *)imageUrlFromFile{
    
    if (imageContentAry) {
        return imageContentAry;
    }
    
    NSString *pathStr = [[NSBundle mainBundle] pathForResource:@"pictureURL" ofType:@"txt"];
    NSError *error = nil;
    
    NSString *allUrlStr = [NSString stringWithContentsOfFile:pathStr encoding:NSUTF8StringEncoding error:&error];
    
    NSArray *tmpAry = [allUrlStr componentsSeparatedByString:@"\n"];
    NSMutableArray *backAry = [NSMutableArray arrayWithArray:tmpAry];
    [backAry removeObject:@""];
    [backAry removeObject:@" "];
    
    imageContentAry = backAry;
    
    return imageContentAry;
    
}

+ (NSArray*)textDesFromFile{
    
    if (textContentAry) {
        return textContentAry;
    }
    
    NSString *pathStr = [[NSBundle mainBundle] pathForResource:@"contentDes" ofType:@"txt"];
    
    NSError *error = nil;
    NSString *allUrlStr = [NSString stringWithContentsOfFile:pathStr encoding:NSUTF8StringEncoding error:&error];
    NSArray *tmpAry = [allUrlStr componentsSeparatedByString:@"\n"];
    NSMutableArray *backAry = [NSMutableArray arrayWithArray:tmpAry];
    [backAry removeObject:@""];
    [backAry removeObject:@" "];
    textContentAry = backAry;
    
    return backAry;
    
}

+ (NSArray*)backName{
    if (AllNameAry) {
        return AllNameAry;
    }
    
    NSString *pathStr = [[NSBundle mainBundle] pathForResource:@"name" ofType:@"txt"];
    NSError *error = nil;
    NSString *allUrlStr = [NSString stringWithContentsOfFile:pathStr encoding:NSUTF8StringEncoding error:&error];
    NSArray *tmpAry = [allUrlStr componentsSeparatedByString:@"\n"];
    NSMutableArray *backAry = [NSMutableArray arrayWithArray:tmpAry];
    [backAry removeObject:@""];
    [backAry removeObject:@" "];
    AllNameAry = backAry;
    return backAry;
}

+ (NSArray*)backMessageContent{
    
    if (AllMessageAry) {
        return AllMessageAry;
    }
    
    NSString *pathStr = [[NSBundle mainBundle] pathForResource:@"message" ofType:@"txt"];
    NSError *error = nil;
    NSString *allUrlStr = [NSString stringWithContentsOfFile:pathStr encoding:NSUTF8StringEncoding error:&error];
    NSArray *tmpAry = [allUrlStr componentsSeparatedByString:@"\n"];
    NSMutableArray *backAry = [NSMutableArray arrayWithArray:tmpAry];
    [backAry removeObject:@""];
    [backAry removeObject:@" "];
    AllMessageAry = backAry;
    return backAry;
}

@end
