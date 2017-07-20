//
//  OneCollectionViewController.h
//  PositiveGridDemo
//
//  Created by Rick on 2017/2/16.
//  Copyright © 2017年 Rick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OneCollectionViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource> {
    
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end
