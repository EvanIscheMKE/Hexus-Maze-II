//
//  HDIntroScene.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 3/13/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "HDDefaultScene.h"

@interface HDIntroScene : HDDefaultScene
- (void)performIntroAnimationsWithCompletion:(dispatch_block_t)completion;
@end
