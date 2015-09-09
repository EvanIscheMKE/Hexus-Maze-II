//
//  HDCompletionView.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/15/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import UIKit;

#import "HDLayoverView.h"

@protocol HDCompletionViewDelegate;
@interface HDCompletionView : HDLayoverView
@property (nonatomic, weak) id <HDCompletionViewDelegate> delegate;
- (instancetype)initWithTitle:(NSString *)title;
@end

@protocol HDCompletionViewDelegate <NSObject>
@required
- (void)completionView:(HDCompletionView *)completionView selectedButtonWithTag:(NSInteger)tag;
@end
