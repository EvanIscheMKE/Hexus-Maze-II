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
#import "HDGridMenu.h"
#import "HDPageControl.h"
#import "HDSpaceView.h"

#define singularMessage [NSString stringWithFormat:@"You must first complete level 1 to unlock the Level"]
#define pluralMessage(x)[NSString stringWithFormat:@"You must first complete levels 1 through %ld to unlock this Level",x ]

static NSString * const title = @"Locked";
static NSString * const cellReuseIdentifer = @"identifier";

@interface HDGridViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) HDPageControl *pageControl;

@end

@implementation HDGridViewController {
    NSInteger _previousPage;
    NSInteger _selectedLevelIndex;
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
    
//    UIButton *toNonJSONLevel = [UIButton buttonWithType:UIButtonTypeCustom];
//    [toNonJSONLevel setBackgroundColor:[UIColor redColor]];
//    [toNonJSONLevel setTitle:@"Random" forState:UIControlStateNormal];
//    [toNonJSONLevel sizeToFit];
//    [toNonJSONLevel setCenter:CGPointMake(CGRectGetMidX(self.view.bounds), 30.0f)];
//    [toNonJSONLevel addTarget:ADelegate action:@selector(navigateToRandomlyGeneratedLevel) forControlEvents:UIControlEventTouchDown];
//    [self.view addSubview:toNonJSONLevel];
    
     self.pageControl = [[HDPageControl alloc] init];
    [self.pageControl setBackgroundColor:[UIColor flatMidnightBlueColor]];
    [self.pageControl setNumberOfPages:[[HDMapManager sharedManager] numberOfSections]];
    [self.pageControl sizeToFit];
    [self.pageControl setCenter:CGPointMake(CGRectGetMidX(self.view.bounds), 35.0f)];
    [self.pageControl setCurrentPageIndicatorTintColor:[UIColor flatPeterRiverColor]];
    [self.pageControl setCurrentPage:0];
    [self.view addSubview:self.pageControl];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [layout setMinimumInteritemSpacing:0];
    [layout setMinimumLineSpacing:0];
    [layout setItemSize:CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 60.0f)];
    
    CGRect collectionViewRect = CGRectMake(0.0, 60.0f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 60.0f);
     self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewRect collectionViewLayout:layout];
    [self.collectionView registerClass:[HDCollectionViewCell class] forCellWithReuseIdentifier:cellReuseIdentifer];
    [self.collectionView setShowsHorizontalScrollIndicator:NO];
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
        return [[HDMapManager sharedManager] numberOfSections];
    }
    return [[HDMapManager sharedManager] numberOfLevelsInSection];
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
        
        NSInteger levelIndex  = (indexPath.item) + (collectionView.tag * [[HDMapManager sharedManager] numberOfLevelsInSection]);
        
        HDLevel *level = [[HDMapManager sharedManager] levels][levelIndex];
        
        
        [cell setCompleted:level.isCompleted];
        [cell setAnimate:(!level.completed && level.unlocked)];
        [cell.indexLabel setText:[NSString stringWithFormat:@"%ld", levelIndex + 1]];
        
        switch (collectionView.tag) {
            case 0:
                [cell.hexagonLayer setFillColor:[[UIColor flatPeterRiverColor] CGColor]];
                break;
            case 1:
                [cell.hexagonLayer setFillColor:[[UIColor flatEmeraldColor] CGColor]];
                break;
            case 2:
                [cell.hexagonLayer setFillColor:[[UIColor flatTurquoiseColor] CGColor]];
                break;
            case 3:
                [cell.hexagonLayer setFillColor:[[UIColor flatSilverColor] CGColor]];
                break;
            case 4:
                [cell.hexagonLayer setFillColor:[[UIColor flatSilverColor] CGColor]];
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
    
    HDLevel *level = [[HDMapManager sharedManager] levels][levelIndex];
    
    NSString *message = ((indexPath.row + 1) <= 2) ? singularMessage : pluralMessage(indexPath.row);
    
    _selectedLevelIndex = levelNumber;
    
    if (level.isUnlocked) {
        
        [[HDSoundManager sharedManager] playSound:@"menuClicked.wav"];
        [ADelegate navigateToNewLevel:_selectedLevelIndex];
        
    }
    //else {
        
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
}

#pragma mark -
#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger currentPage = ceilf(scrollView.contentOffset.x / CGRectGetWidth(self.collectionView.bounds));
    
    if (_previousPage == currentPage) {
        return;
    }
    
    [[HDSoundManager sharedManager] playSound:@"Swooshed.mp3"];
    [self.pageControl setCurrentPage:currentPage];
    
    switch (currentPage) {
        case 0:
            [self.pageControl setCurrentPageIndicatorTintColor:[UIColor flatPeterRiverColor]];
            break;
        case 1:
            [self.pageControl setCurrentPageIndicatorTintColor:[UIColor flatEmeraldColor]];
            break;
        case 2:
            [self.pageControl setCurrentPageIndicatorTintColor:[UIColor flatTurquoiseColor]];
            break;
        case 3:
            [self.pageControl setCurrentPageIndicatorTintColor:[UIColor flatSilverColor]];
            break;
        case 4:
            [self.pageControl setCurrentPageIndicatorTintColor:[UIColor flatSilverColor]];
            break;
    }
    
    _previousPage = currentPage;
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
