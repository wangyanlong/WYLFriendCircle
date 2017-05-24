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
        [infoDict setObject:@"八点钟学院" forKey:@"text"];
        [infoDict setObject:@"http://www.baidu.com" forKey:@"url"];
        [infoDict setObject:@"logo.png" forKey:@"img"];
        fcModel.linkInfoDict = infoDict;
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

@end
