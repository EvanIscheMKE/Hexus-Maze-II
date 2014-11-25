//
//  HDGridViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/21/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDLevel.h"
#import "HDMapManager.h"
#import "HDLevelViewCell.h"
#import "UIColor+FlatColors.h"
#import "HDGridViewController.h"
#import "HDCollectionViewCell.h"
#import "HDSpaceView.h"

#define singularMessage [NSString stringWithFormat:@"You must first complete level 1 to unlock the Level"]
#define pluralMessage(x)[NSString stringWithFormat:@"You must first complete levels 1 through %ld to unlock this Level",x]

static NSString * const title = @"Locked";
static NSString * const cellReuseIdentifer = @"identifier";

@interface HDGridViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation HDGridViewController

- (void)loadView
{
    CGRect spaceRect = [[UIScreen mainScreen] bounds];
    HDSpaceView *space = [[HDSpaceView alloc] initWithFrame:spaceRect];
    [self setView:space];
}

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor flatMidnightBlueColor]];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [layout setMinimumInteritemSpacing:0];
    [layout setMinimumLineSpacing:0];
    [layout setItemSize:CGSizeMake(CGRectGetWidth(self.view.bounds),
                                   CGRectGetHeight(self.view.bounds) - 60.0f)];
    
    CGRect collectionViewRect = CGRectMake(0.0, 60.0f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 60.0f);
     self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewRect collectionViewLayout:layout];
    [self.collectionView registerClass:[HDCollectionViewCell class] forCellWithReuseIdentifier:cellReuseIdentifer];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setTag:5];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.collectionView];

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView.tag == 5) {
        return 4;
    }
    return 15;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag == 5) {
      
        HDCollectionViewCell *cell = (HDCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifer
                                                                                                       forIndexPath:indexPath];
        
        [cell setTag:indexPath.item];
        [cell.collectionViewGrid setDelegate:self];
        [cell.collectionViewGrid setDataSource:self];
        [cell.collectionViewGrid reloadData];

        return cell;
        
    } else {
        
        HDLevelViewCell *cell = (HDLevelViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:levelCellReuseIdentifer
                                                                                             forIndexPath:indexPath];
        
        NSInteger levelIndex  = (indexPath.item) + (collectionView.tag * 15);
        NSInteger levelNumber = levelIndex + 1;
        
        HDLevel *level = [[HDMapManager sharedManager] levels][levelIndex];
        
        [cell setCompleted:level.isCompleted];
        
        [cell.indexLabel setText:[NSString stringWithFormat:@"%ld", levelNumber]];
        switch (collectionView.tag) {
            case 0:
                [cell setBackgroundColor:[[UIColor flatPeterRiverColor] colorWithAlphaComponent:.25f]];
                [cell.layer setBorderColor:[[UIColor flatPeterRiverColor] CGColor]];
                break;
            case 1:
                [cell setBackgroundColor:[[UIColor flatEmeraldColor] colorWithAlphaComponent:.25f]];
                [cell.layer setBorderColor:[[UIColor flatEmeraldColor] CGColor]];
                break;
            case 2:
                [cell setBackgroundColor:[[UIColor flatTurquoiseColor] colorWithAlphaComponent:.25f]];
                [cell.layer setBorderColor:[[UIColor flatTurquoiseColor] CGColor]];
                break;
            case 3:
                [cell setBackgroundColor:[[UIColor flatSilverColor] colorWithAlphaComponent:.25f]];
                [cell.layer setBorderColor:[[UIColor flatSilverColor] CGColor]];
                break;
        }
        return cell;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger levelIndex  = (indexPath.item) + (collectionView.tag * 15);
    NSInteger levelNumber = levelIndex + 1;
    
  //  HDLevel *level = [[HDMapManager sharedManager] levels][levelIndex];
    
  //  NSString *message = ((indexPath.row + 1) <= 2) ? singularMessage : pluralMessage(indexPath.row);
 
    
  //  if (level.isUnlocked) {
        [ADelegate navigateToNewLevel:levelNumber];
//    } else {
//        
//        if (NSClassFromString(@"UIAlertController")) {
//            
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
//                                                                           message:message
//                                                                    preferredStyle:UIAlertControllerStyleAlert];
//            
//            UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
//                [alert dismissViewControllerAnimated:YES completion:nil];
//            }];
//            
//            [alert addAction:okay];
//            [self.navigationController presentViewController:alert animated:NO completion:nil];
//            
//        } else {
//            
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
//                                                                message:message
//                                                               delegate:self
//                                                      cancelButtonTitle:@"Okay"
//                                                      otherButtonTitles:nil];
//            [alertView show];
//        }
//    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
