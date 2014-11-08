//
//  UIImage+HDImage.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/7/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDHexagon.h"

@interface UIImage (HDImage)

+ (UIImage *)textureImageWithType:(HDHexagonType)type;

@end
