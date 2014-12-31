//
//  HDTableViewCell.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/27/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDTableViewCell.h"
#import "UIColor+FlatColors.h"

@implementation HDTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.font          = GILLSANS_LIGHT(12.0f);
        self.textLabel.font                = GILLSANS(20.0f);
        self.selectionStyle                = UITableViewCellSelectionStyleNone;
        self.backgroundColor               = [UIColor flatMidnightBlueColor];
        self.detailTextLabel.textColor     = [UIColor whiteColor];
        self.textLabel.textColor           = [UIColor whiteColor];
        
    }
    return self;
}


@end
