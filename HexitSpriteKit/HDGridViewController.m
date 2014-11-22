//
//  HDGridViewController.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/21/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDLevelViewCell.h"
#import "UIColor+FlatColors.h"
#import "HDGridViewController.h"
#import "HDCollectionViewCell.h"

static NSString * const cellReuseIdentifer = @"identifier";

@interface HDGridViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation HDGridViewController

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
    [self.collectionView setBackgroundColor:[UIColor flatMidnightBlueColor]];
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
        
        [cell.indexLabel setText:[NSString stringWithFormat:@"%ld", (indexPath.item + 1) + (collectionView.tag * 15)]];
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
    NSInteger index = (indexPath.item + 1) + (collectionView.tag * 15);
    [ADelegate navigateToNewLevel:index];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
