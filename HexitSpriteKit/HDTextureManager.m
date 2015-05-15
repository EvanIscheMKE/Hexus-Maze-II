//
//  HDTextureManager.m
//  FlatJump
//
//  Created by Evan Ische on 4/23/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"
#import "HDHexaObject.h"
#import "HDTextureManager.h"
#import "UIImage+ImageAdditions.h"

@interface HDTextureManager ()
@property (nonatomic, strong) NSDictionary *textures;
@end

@implementation HDTextureManager

- (instancetype)init {
    if (self = [super init]) {
        _textures = [NSDictionary dictionary];
    }
    return self;
}

+ (HDTextureManager *)sharedManager {
    static HDTextureManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HDTextureManager alloc] init];
    });
    return manager;
}

- (void)preloadTexturesWithCompletion:(dispatch_block_t)completion {
    
    if ([_textures allKeys].count) {
        return;
    }
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[@"ExplosionTexture"] = [SKTexture textureWithImageNamed:@"ExplosionTexture"];
    dictionary[@"Default-Double"]   = [SKTexture textureWithImageNamed:@"Default-Double"];
    dictionary[@"Default-OneTap"]   = [SKTexture textureWithImageNamed:@"Default-OneTap"];
    dictionary[@"Default-Start"]    = [SKTexture textureWithImageNamed:@"Default-Start"];
    dictionary[@"Default-Triple"]   = [SKTexture textureWithImageNamed:@"Default-Triple"];
    dictionary[@"Default-End"]      = [SKTexture textureWithImageNamed:@"Default-End"];
    dictionary[@"Default-Mine"]     = [SKTexture textureWithImageNamed:@"Default-Mine"];
    dictionary[@"Default-Count"]    = [SKTexture textureWithImageNamed:@"Default-Count"];
    dictionary[@"Selected-Tile"]    = [SKTexture textureWithImageNamed:@"Selected-Tile"];
    
     _textures = dictionary;
    
    [SKTexture preloadTextures:[dictionary allValues] withCompletionHandler:^{
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }];
}

- (SKTexture *)textureForKeyPath:(NSString *)keyPath {
    if (self.textures[keyPath]) {
       return self.textures[keyPath];
    }
    return nil;
}

@end
