//
//  CellMessageCell.h
//  WYLFriendCircle
//
//  Created by wyl on 2017/5/25.
//  Copyright © 2017年 wyl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellMessageCell : UITableViewCell
{
    IBOutlet UILabel *messageLb;
}

- (void)messagePro:(NSDictionary*)messageDict content:(NSString*)content;

@end
