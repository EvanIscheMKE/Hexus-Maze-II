//
//  HDHexagonControl.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HDHexaControlDelegate;
@interface HDHexaControl : UIView
@property (nonatomic, weak) id <HDHexaControlDelegate> delegate;
@property (nonatomic, strong) UIImage *currentPageImage;
@property (nonatomic, strong) UIImage *pageImage;
@property (nonatomic, assign) NSUInteger numberOfPages;
@property (nonatomic, assign) NSUInteger currentPage;
@end

@protocol HDHexaControlDelegate <NSObject>
@optional
- (void)hexaControl:(HDHexaControl *)hexaControl pageIndexWasSelected:(NSUInteger)pageIndex;
@end
