//
//  OneCollectionViewController.m
//  PositiveGridDemo
//
//  Created by Rick on 2017/2/16.
//  Copyright © 2017年 Rick. All rights reserved.
//

#import "OneCollectionViewController.h"

@interface OneCollectionViewController (){
    NSInteger cellCount;
    NSMutableArray *path0, *path1, *path2, *path3;
}


@end

@implementation OneCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    path0 = [[NSMutableArray alloc] initWithObjects:@"EQ", @"Reverd", @"Preamp", nil];
    path1 = [[NSMutableArray alloc] initWithObjects:@"Delay", @"Mixer", nil];
    path2 = [[NSMutableArray alloc] initWithObjects:@"Volume", nil];
    path3 = [[NSMutableArray alloc] initWithObjects:@"Blender", @"DI",  nil];
    cellCount = path0.count + path1.count + path2.count + path3.count;
    
    UILongPressGestureRecognizer *longGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.collectionView addGestureRecognizer:longGR];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Handle Gesture
- (void)handleLongPress:(UILongPressGestureRecognizer *)gr{
    switch(gr.state){
        case UIGestureRecognizerStateBegan:
        {
            NSIndexPath *selectedIndexPath = [self.collectionView indexPathForItemAtPoint:[gr locationInView:self.collectionView]];
            if(selectedIndexPath == nil) break;
            [self.collectionView beginInteractiveMovementForItemAtIndexPath:selectedIndexPath];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            [self.collectionView updateInteractiveMovementTargetPosition:[gr locationInView:gr.view]];
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [self.collectionView endInteractiveMovement];
            break;
        }
        default:
        {
            [self.collectionView cancelInteractiveMovement];
            break;
        }
    }
}

#pragma mark - Collection View Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 4;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return path0.count;
            break;
        case 1:
            return path1.count;
            break;
        case 2:
            return path2.count;
            break;
        case 3:
            return path3.count;
            break;
            
        default:
            break;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    if(cell == nil){
        cell = [UICollectionViewCell new];
    }
    
    cell = [self configureCell:cell :indexPath];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self moveCellItem:sourceIndexPath :destinationIndexPath];
}

- (UICollectionViewCell*)configureCell:(UICollectionViewCell*)cell :(NSIndexPath *)indexPath {
    UILabel *cellLabel = (UILabel*)[cell viewWithTag:101];
    NSString *pedalString;
    switch (indexPath.section) {
        case 0:
            pedalString = [NSString stringWithFormat:@"%@", path0[indexPath.row]];
            break;
        case 1:
            pedalString = [NSString stringWithFormat:@"%@", path1[indexPath.row]];
            break;
        case 2:
            pedalString = [NSString stringWithFormat:@"%@", path2[indexPath.row]];
            break;
        case 3:
            pedalString = [NSString stringWithFormat:@"%@", path3[indexPath.row]];
            break;
            
        default:
            break;
    }
    [cellLabel setText:pedalString];
    return cell;
}

- (void)moveCellItem:(NSIndexPath*)sIdx :(NSIndexPath*)dIdx {
    NSString *cellItem;
    
    switch (sIdx.section) {
        case 0:
            cellItem = [path0 objectAtIndex:sIdx.row];
            [path0 removeObjectAtIndex:sIdx.row];
            break;
        case 1:
            cellItem = [path1 objectAtIndex:sIdx.row];
            [path1 removeObjectAtIndex:sIdx.row];
            break;
        case 2:
            cellItem = [path2 objectAtIndex:sIdx.row];
            [path2 removeObjectAtIndex:sIdx.row];
            break;
        case 3:
            cellItem = [path3 objectAtIndex:sIdx.row];
            [path3 removeObjectAtIndex:sIdx.row];
            break;
        default:
            break;
    }
    if (cellItem == nil) {
        return;
    }
    
    switch (dIdx.section) {
        case 0:
            [path0 insertObject:cellItem atIndex:dIdx.row];
            break;
        case 1:
            [path1 insertObject:cellItem atIndex:dIdx.row];
            break;
        case 2:
            [path2 insertObject:cellItem atIndex:dIdx.row];
            break;
        case 3:
            [path3 insertObject:cellItem atIndex:dIdx.row];
            break;
        default:
            break;
    }
}


@end
