//
//  HDGameCenterManager.h
//  SixTilesSquare
//
//  Created by Evan William Ische on 6/20/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol HDGameCenterManagerDelegate;
@interface HDGameCenterManager : NSObject
@property (nonatomic, weak) id<HDGameCenterManagerDelegate> delegate;
+ (HDGameCenterManager *)sharedManager;
- (void)authenticateForGameCenter;
@end

@protocol HDGameCenterManagerDelegate <NSObject>
@optional
- (void)openViewControllerOnMainThread:(UIViewController *)controller;
@end
