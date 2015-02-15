//
//  HDCompletionView.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/15/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HDCompletionViewDelegate;
@interface HDCompletionView : UIView
@property (nonatomic, weak) id<HDCompletionViewDelegate> delegate;
@end

@protocol HDCompletionViewDelegate <NSObject>
@required
- (void)completionView:(HDCompletionView *)completionView selectedButtonWithTitle:(NSString *)title;
@end
