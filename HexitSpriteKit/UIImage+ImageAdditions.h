//
//  UIImage+ImageAdditions.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 4/29/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageAdditions)
+ (UIImage *)tileFromSize:(CGSize)size
                    color:(UIColor *)color
                direction:(HDTileDirection)direction;
@end
