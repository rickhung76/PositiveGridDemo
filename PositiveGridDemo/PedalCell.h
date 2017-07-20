//
//  PedalCell.h
//  PositiveGridDemo
//
//  Created by Rick on 2017/2/17.
//  Copyright © 2017年 Rick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PedalCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (nonatomic, assign) NSString *state;
@end
