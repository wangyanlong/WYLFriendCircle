//
//  CellMessageCell.m
//  WYLFriendCircle
//
//  Created by wyl on 2017/5/25.
//  Copyright © 2017年 wyl. All rights reserved.
//

#import "CellMessageCell.h"

@implementation CellMessageCell

- (void)messagePro:(NSDictionary *)messageDict content:(NSString *)content{
    
    NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc] initWithString:content];
    [attribString setAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]} range:NSMakeRange(0, content.length)];
    
    int status = [[messageDict objectForKey:@"status"] intValue];
    NSString *name = [messageDict objectForKey:@"name"];
    
    if (status == 0) {// 楼主回复xx:
        
        NSMutableDictionary *attriDict = [NSMutableDictionary dictionary];
        [attriDict setObject:[UIColor blueColor] forKey:NSForegroundColorAttributeName];
        [attribString setAttributes:attriDict range:NSMakeRange(0, 2)];
        [attribString setAttributes:attriDict range:NSMakeRange(2 + 2, name.length)];//这里的+2是指回复两个字 楼主(蓝色)回复(xxx)(蓝色)
    
    }else if(status == 1){ // XX回复楼主:
        NSMutableDictionary *attriDict = [NSMutableDictionary dictionary];
        [attriDict setObject:[UIColor blueColor] forKey:NSForegroundColorAttributeName];
        [attribString setAttributes:attriDict range:NSMakeRange(0, name.length)];
        [attribString setAttributes:attriDict range:NSMakeRange(name.length + 2, 2)];
    }
    else if(status == 2){// 楼主回复:
        NSMutableDictionary *attriDict = [NSMutableDictionary dictionary];
        [attriDict setObject:[UIColor blueColor] forKey:NSForegroundColorAttributeName];
        [attribString setAttributes:attriDict range:NSMakeRange(0, 2)];
    }
    else if(status == 3){ // XX回复:
        NSMutableDictionary *attriDict = [NSMutableDictionary dictionary];
        [attriDict setObject:[UIColor blueColor] forKey:NSForegroundColorAttributeName];
        [attribString setAttributes:attriDict range:NSMakeRange(0, name.length)];
    }
    
    messageLb.attributedText = attribString;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
