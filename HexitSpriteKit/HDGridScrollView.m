//
//  HDGridScrollView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/19/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDLevel.h"
#import "HDHexagonButton.h"
#import "HDGridScrollView.h"
#import "NSMutableArray+UniqueAdditions.h"
#import "UIColor+ColorAdditions.h"

@interface HDGridScrollView ()
@property (nonatomic, assign) NSUInteger numberOfPages;
@property (nonatomic, strong) HDMapManager *manager;
@end

@implementation HDGridScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.showsHorizontalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.manager = [HDMapManager sharedManager];
    }
    return self;
}

- (void)performIntroAnimationWithCompletion:(dispatch_block_t)completion {
    
    NSArray *viewsCorrespondingToProtocol = [[self subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject conformsToProtocol:@protocol(HDGridScrollViewChild)];
    }]];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    [CATransaction setAnimationDuration:0.03f];
    
    for (UIView <HDGridScrollViewChild> *child in viewsCorrespondingToProtocol) {
        [child performIntroAnimationWithCompletion:nil];
    }
    
    [CATransaction commit];
}

- (void)performOutroAnimationWithCompletion:(dispatch_block_t)completion {
    
    NSArray *viewsCorrespondingToProtocol = [[self subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject conformsToProtocol:@protocol(HDGridScrollViewChild)];
    }]];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    [CATransaction setAnimationDuration:0.03f];
    
    for (UIView <HDGridScrollViewChild> *child in viewsCorrespondingToProtocol) {
        [child performOutroAnimationWithCompletion:nil];
    }
    
    [CATransaction commit];
}

#pragma mark - Private

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        [self _setup];
    } 
}

- (void)_setup {
    
    NSArray *pages = [self.datasource pageViewsForGridScrollView:self];
    if (pages.count < 1) {
        return;
    }
    NSUInteger numberOfPages = pages.count;
    self.numberOfPages = numberOfPages;
    [self setContentSize:CGSizeMake(CGRectGetWidth(self.bounds)*numberOfPages, CGRectGetHeight(self.bounds))];
        
    NSUInteger pageIndex = 0;
    for (UIView *page in pages) {
        CGRect containerFrame = CGRectMake(pageIndex * self.bounds.size.width,
                                           0.0f,
                                           self.bounds.size.width,
                                           self.bounds.size.height);
        page.frame = containerFrame;
        [self addSubview:page];

        pageIndex++;
    }
}


@end
