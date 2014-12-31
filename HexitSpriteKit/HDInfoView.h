//
//  HDInfoView.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/27/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const tableViewIdentifier;
@interface HDInfoView : UIView
- (void)setDelegate:(id<UITableViewDelegate>)delegate dataSource:(id<UITableViewDataSource>)datasource;
@end
