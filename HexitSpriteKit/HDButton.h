//
//  UIButton+SoundAdditions.h
//  FlatJump
//
//  Created by Evan Ische on 4/15/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDButton : UIButton
@property (nonatomic, assign) NSUInteger index;
- (void)addSoundNamed:(NSString *)name forControlEvent:(UIControlEvents)controlEvent;
@end
