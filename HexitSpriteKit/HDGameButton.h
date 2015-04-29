//
//  HDGameButton.h
//  SixSquare
//
//  Created by Evan Ische on 4/24/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDButton.h"

@interface HDGameButton : HDButton
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, strong) UIColor *buttonColor;
@property (nonatomic, readonly) UIColor *buttonBaseColor;
@end
