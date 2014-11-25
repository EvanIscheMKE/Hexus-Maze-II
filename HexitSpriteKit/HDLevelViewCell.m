//
//  HDLevelViewCell.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/21/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDLevelViewCell.h"
#import "UIColor+FlatColors.h"

NSString * const levelCellReuseIdentifer = @"levelReuseIdentifier";


static const CGFloat kPadding = 15.0f;
@implementation HDLevelViewCell {
    UIImageView *_lockedImageView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self.layer setBorderWidth:4.0f];
        [self.layer setCornerRadius:CGRectGetMidX(self.bounds)];
        [self.layer setMasksToBounds:YES];
        
        CGRect indexRect = CGRectMake(0.0f, 0.0f, CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds));
        self.indexLabel = [[UILabel alloc] initWithFrame:indexRect];
        [self.indexLabel setFont:GILLSANS_LIGHT(CGRectGetMidY(self.contentView.bounds) / 1.5)];
        [self.indexLabel setNumberOfLines:1];
        [self.indexLabel setTextAlignment:NSTextAlignmentCenter];
        [self.indexLabel setTextColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.indexLabel];
        
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"STAR_NOT_COMPLETED.png"]];
        [self.contentView addSubview:self.imageView];
        
        _lockedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LOCKEDLEVEL.png"]];
     //   [self.contentView addSubview:_lockedImageView];
        
    }
    return self;
}

- (void)setCompleted:(BOOL)completed
{
    if (_completed == completed) {
        return;
    }
    
    _completed = completed;
    
    if (_completed) {
        [self.imageView setImage:[UIImage imageNamed:@"STAR_COMPLETED.png"]];
    } else {
        [self.imageView setImage:[UIImage imageNamed:@"STAR_NOT_COMPLETED.png"]];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.imageView   setCenter:CGPointMake(CGRectGetMidX(self.contentView.bounds), kPadding * 1.5)];
    [self.indexLabel  setCenter:CGPointMake(CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds) + kPadding)];
   // [_lockedImageView setCenter:CGPointMake(CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds))];
}

@end
