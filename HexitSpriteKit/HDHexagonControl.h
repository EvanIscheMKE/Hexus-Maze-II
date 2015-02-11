//
//  HDHexagonControl.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDHexagonControl : UIView
@property (nonatomic, strong) UIColor *currentPageTintColor;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, assign) NSUInteger numberOfPages;
@property (nonatomic, assign) NSUInteger currentPage;
@end
