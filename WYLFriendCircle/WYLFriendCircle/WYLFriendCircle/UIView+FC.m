//
//  UIView+FC.m
//  WYLFriendCircle
//
//  Created by wyl on 2017/5/25.
//  Copyright © 2017年 wyl. All rights reserved.
//

#import "UIView+FC.h"
#import <CoreText/CoreText.h>

@implementation UIView (FC)

- (void)removeAllSubView{
    
    NSArray *viewAry = [self subviews];
    
    for (int i = 0; i < viewAry.count; i++) {
        [[viewAry objectAtIndex:i] removeFromSuperview];
    }
    
}

+ (float)backLinesInView:(CGFloat)viewWidth string:(NSString *)contentS font:(UIFont*)font
{
    if (!contentS || contentS.length == 0)
        return 0;
    
    NSMutableAttributedString *textS = [[NSMutableAttributedString alloc] initWithString:contentS];
    CTFontRef helveticaBold = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, nil);
    [textS addAttribute:(id)kCTFontAttributeName value:(__bridge id)helveticaBold range:NSMakeRange(0, contentS.length)];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)textS);
    
    CGMutablePathRef leftColumnPath = CGPathCreateMutable();
    int drawHigh = 500;
    CGPathAddRect(leftColumnPath, NULL ,CGRectMake(0 , 0 ,viewWidth , drawHigh));
    
    CTFrameRef leftFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, 0), leftColumnPath , NULL);
    
    CFArrayRef arrayRef = CTFrameGetLines(leftFrame);
    CFIndex lineCounts  = CFArrayGetCount(arrayRef);
    CGPoint lineOrigins[lineCounts];// 每个行的起点
    CTFrameGetLineOrigins(leftFrame, CFRangeMake(0, 0), lineOrigins);
    
    double lastLineY = drawHigh - lineOrigins[lineCounts-1].y; // 最后一行的位置
    CGFloat ascent;
    CGFloat descent;
    CGFloat leading;
    CTLineRef lineRef = CFArrayGetValueAtIndex(arrayRef, lineCounts-1);
    CTLineGetTypographicBounds(lineRef, &ascent, &descent, &leading);
    lastLineY += (ascent + descent + leading);
    
    CFRelease(leftFrame);
    CFRelease(framesetter);
    CFRelease(helveticaBold);
    
    return lastLineY;
}



@end
