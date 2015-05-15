//
//  HDTextureManager.h
//  FlatJump
//
//  Created by Evan Ische on 4/23/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import Foundation;
@import SpriteKit;

@interface HDTextureManager : NSObject
+ (HDTextureManager *)sharedManager;
- (SKTexture *)textureForKeyPath:(NSString *)keyPath;
- (void)preloadTexturesWithCompletion:(dispatch_block_t)completion;
@end
