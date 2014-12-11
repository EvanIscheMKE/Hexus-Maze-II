//
//  HDGridViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/21/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//



#import "HDLevel.h"
#import "HDMapManager.h"
#import "HDSoundManager.h"
#import "HDLevelViewCell.h"
#import "UIColor+FlatColors.h"
#import "HDGridViewController.h"
#import "HDCollectionViewCell.h"

static NSString * const title = @"Locked";
static NSString * const cellReuseIdentifer = @"identifier";

static const NSUInteger COLLECTION_VIEW_TAG = 100;
static const CGFloat CV_OFFSET = 60.0f;

@interface HDGridViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation HDGridViewController {
    NSInteger _previousPage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor flatMidnightBlueColor]];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [layout setMinimumInteritemSpacing:0];
    [layout setMinimumLineSpacing:0];
    [layout setItemSize:CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CV_OFFSET)];
    
    CGRect collectionViewRect = CGRectMake(0.0, CV_OFFSET, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CV_OFFSET);
     self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewRect collectionViewLayout:layout];
    [self.collectionView registerClass:[HDCollectionViewCell class] forCellWithReuseIdentifier:cellReuseIdentifer];
    [self.collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.collectionView setShowsHorizontalScrollIndicator:NO];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setTag:COLLECTION_VIEW_TAG];  // Set it high enough that it will never collide with grid tag
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView.tag == COLLECTION_VIEW_TAG) {
        return [[HDMapManager sharedManager] numberOfSections];
    }
    return [[HDMapManager sharedManager] numberOfLevelsInSection];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag == COLLECTION_VIEW_TAG) {
      // Container CollectionView
        HDCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifer forIndexPath:indexPath];
        
        [cell setTag:indexPath.item];
        [cell.gridCollectionView setDelegate:self];
        [cell.gridCollectionView setDataSource:self];
        [cell.gridCollectionView reloadData];

        return cell;
        
    } else {
        // Grid CollectionView
        HDLevelViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:levelCellReuseIdentifer forIndexPath:indexPath];
        
        NSInteger levelIndex  = (indexPath.item) + (collectionView.tag * LEVELS_PER_PAGE);
        
        HDLevel *level = [[HDMapManager sharedManager] levelAtIndex:levelIndex];
        
        [cell setCompleted:level.isCompleted];
        [cell setAnimate:(!level.completed && level.unlocked)];
        [cell.indexLabel setText:[NSString stringWithFormat:@"%ld", levelIndex + 1]];
        
        return cell;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger levelIndex  = (indexPath.item) + (collectionView.tag * LEVELS_PER_PAGE);
    NSInteger levelNumber = levelIndex + 1;
    
    HDLevel *level = [[HDMapManager sharedManager] levelAtIndex:levelIndex];
    
  //  if (level.isUnlocked) {
        [[HDSoundManager sharedManager] playSound:@"menuClicked.wav"];
        [ADelegate navigateToNewLevel:levelNumber];
  //  } else {
        HDLevelViewCell *cell = (HDLevelViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [UIView animateWithDuration:.3f delay:0.0f
                            options:UIViewAnimationOptionAutoreverse
                         animations:^{
                             [cell setTransform:CGAffineTransformScale(cell.transform, .9f, .9f)];
                         } completion:^(BOOL finished) {
                             if (finished) {
                                 [cell setTransform:CGAffineTransformIdentity];
                                 [cell.layer removeAllAnimations];
                             }
                         }];
   // }
}

#pragma mark -
#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[HDSoundManager sharedManager] playSound:@"Swooshed.mp3"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
