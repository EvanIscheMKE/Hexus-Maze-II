//
//  HDAlertView.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/27/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HDInfoView;
@interface HDAlertView : UIView
@property (nonatomic, copy) dispatch_block_t completion;
@property (nonatomic, readonly) HDInfoView *infoView;
- (void)show;
@end
