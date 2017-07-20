//
//  ViewController.h
//  PositiveGridDemo
//
//  Created by Rick on 2017/2/15.
//  Copyright © 2017年 Rick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource> {
    
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView0;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView1;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView2;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView3;
- (IBAction)addBtnPressed:(id)sender;
- (IBAction)removeBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *frontImgView;
@property (weak, nonatomic) IBOutlet UIImageView *midImgView;
@property (weak, nonatomic) IBOutlet UIImageView *backImgView;

@property (atomic, readwrite) BOOL isDragging;
@property (nonatomic, readwrite, retain) NSIndexPath* draggingIndexPath;
@property (nonatomic, retain) UIView* draggingView;
@property (nonatomic, retain) UICollectionViewCell* draggingCell;
@property (nonatomic, readwrite) CGRect draggingViewPreviousRect;
@end

