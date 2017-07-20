//
//  ViewController.m
//  PositiveGridDemo
//
//  Created by Rick on 2017/2/15.
//  Copyright © 2017年 Rick. All rights reserved.
//

#import "ViewController.h"

#define cellSpace   (10)
#define Insert      (20)
#define cellWidth   (60)
@interface ViewController () {
    NSInteger cellCount;
    NSMutableArray *path0, *path1, *path2, *path3;
    UICollectionView *SrcColView, *DstColView;
    CGPoint movementTargetPosition;
    NSIndexPath *SrcIndexPath;
}

@end

@implementation ViewController
@synthesize draggingView, draggingIndexPath, draggingViewPreviousRect, draggingCell;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    path0 = [[NSMutableArray alloc] initWithObjects:@"EQ", @"Reverb", @"Preamp", nil];
    path1 = [[NSMutableArray alloc] initWithObjects:@"Delay", @"Mixer", nil];
    path2 = [[NSMutableArray alloc] initWithObjects:@"Volume", nil];
    path3 = [[NSMutableArray alloc] initWithObjects:@"Blender", @"DI",  nil];
    cellCount = path0.count + path1.count + path2.count + path3.count;
    
    [self initCollectionViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateSignalPathLayout];
}

- (void)initCollectionViews {
    UILongPressGestureRecognizer *longGR0 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longGR0.minimumPressDuration = 0.2;
    [self.collectionView0 addGestureRecognizer:longGR0];
    self.collectionView0.delegate = self;
    self.collectionView0.dataSource = self;
    UILongPressGestureRecognizer *longGR1 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longGR1.minimumPressDuration = 0.2;
    [self.collectionView1 addGestureRecognizer:longGR1];
    self.collectionView1.delegate = self;
    self.collectionView1.dataSource = self;
    UILongPressGestureRecognizer *longGR2 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longGR2.minimumPressDuration = 0.2;
    [self.collectionView2 addGestureRecognizer:longGR2];
    self.collectionView2.delegate = self;
    self.collectionView2.dataSource = self;
    UILongPressGestureRecognizer *longGR3 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longGR3.minimumPressDuration = 0.2;
    [self.collectionView3 addGestureRecognizer:longGR3];
    self.collectionView3.delegate = self;
    self.collectionView3.dataSource = self;
}

#pragma mark - Drag Handle
- (void)handleLongPress:(UILongPressGestureRecognizer *)gr{
    movementTargetPosition = [gr locationInView:self.view];
    switch(gr.state){
        case UIGestureRecognizerStateBegan:
        {
            SrcColView = (UICollectionView*)gr.view;
            NSIndexPath *srcIndexPath = [SrcColView indexPathForItemAtPoint:[gr locationInView:SrcColView]];
            if(srcIndexPath == nil) break;
            [SrcColView beginInteractiveMovementForItemAtIndexPath:srcIndexPath];
            if ([self startDragFromView:SrcColView atPoint:[gr locationInView:SrcColView]]) {
                NSLog(@"Sucess copy cell:%@", self.draggingView);
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            [SrcColView updateInteractiveMovementTargetPosition:[gr locationInView:gr.view]];
            
            if (self.draggingView !=nil) {
                [self handleDrag:gr];
            }
            break;
        }
        
        case UIGestureRecognizerStateEnded:
        {
            UIView *dstView = [self.view hitTest:movementTargetPosition withEvent:nil];
            DstColView = nil;
            
            if (movementTargetPosition.x > 0 && movementTargetPosition.y > 0) {
                if ([dstView isKindOfClass:[UICollectionView class]]) {
                    DstColView = (UICollectionView*)dstView;
                }
                else if ([dstView.superview isKindOfClass:[UICollectionView class]]){
                    DstColView = (UICollectionView*)dstView.superview;
                }
                else if ([dstView.superview.superview isKindOfClass:[UICollectionView class]]){
                    DstColView = (UICollectionView*)dstView.superview.superview;
                }
                else {
                    [self snapDraggingViewBack];
                }
                [SrcColView endInteractiveMovement];
                if (DstColView != nil) {
                    CGPoint dstPosition = [self.view convertPoint:movementTargetPosition toView:DstColView];
                    NSLog(@"CollectionView(%3.0f,%3.0f)", dstPosition.x, dstPosition.y);
                    [self stopDragFromView:DstColView atPoint:dstPosition];
                }
            }
            [self updateSignalPathLayout];
            break;
        }
        default:
        {
            [SrcColView cancelInteractiveMovement];
            break;
        }
    }
}

- (void)stopDragFromView:(UIView*) container atPoint:(CGPoint) point{
    UICollectionViewCell *cell;
    NSIndexPath *indexPath = [self determineIndexForContainer:DstColView atPoint:point forCell:&cell];
    NSLog(@"New IndexPath%@", indexPath);
    if (draggingView != nil) {
        NSInteger targetIndex = -1;
        if (DstColView != SrcColView) { //
            if (indexPath && cell) {    // on pedal
                CGPoint cellPosition = [self.view convertPoint:movementTargetPosition toView:cell];
                if (cellPosition.x>cell.frame.size.width/2) {
                    targetIndex = indexPath.item + 1;   // Right Side
                }
                else {
                    targetIndex = indexPath.item;       // Left Side
                }
            }
            else {
                // in gap or last
                targetIndex = roundf((point.x-(Insert/2))/(cellWidth+cellSpace));
                if (targetIndex > [DstColView numberOfItemsInSection:0]) {
                    targetIndex = [DstColView numberOfItemsInSection:0];
                }
            }
            NSLog(@"Target Index = %ld", (long)targetIndex);
            // Move target from Src to Dst
            [self dropItemTo:targetIndex];
        
        }
        else if (DstColView == SrcColView) {
            NSLog(@"Local Drap (stopDragFromView)");
            NSIndexPath *nSrcIndexPath = [SrcColView indexPathForCell:self.draggingCell];
            [SrcColView cellForItemAtIndexPath:nSrcIndexPath].alpha = 1;
        }
        else {
            [self snapDraggingViewBack];
        }
    }
    else {
        [self snapDraggingViewBack];
    }
    [self.draggingView removeFromSuperview];
    self.draggingView = nil;
    self.draggingIndexPath = nil;
    DstColView = nil;
}

- (void)dropItemTo:(NSInteger)dstIndex {
    NSMutableArray *srcArray, *dstArray;
    if (SrcColView == self.collectionView0) {
        srcArray = path0;
    }
    else if (SrcColView == self.collectionView1) {
        srcArray = path1;
    }
    else if (SrcColView == self.collectionView2) {
        srcArray = path2;
    }
    else if (SrcColView == self.collectionView3) {
        srcArray = path3;
    }
    else {
        return;
    }
    if (DstColView == self.collectionView0) {
        dstArray = path0;
    }
    else if (DstColView == self.collectionView1) {
        dstArray = path1;
    }
    else if (DstColView == self.collectionView2) {
        dstArray = path2;
    }
    else if (DstColView == self.collectionView3) {
        dstArray = path3;
    }
    else {
        return;
    }
    
    if (SrcIndexPath == nil) {
        return;
    }
    NSInteger srcIndex = SrcIndexPath.item;
    NSString *itemObject = [srcArray objectAtIndex:srcIndex];
    NSLog(@"itemObject: %@", itemObject);
    
    [dstArray insertObject:itemObject atIndex:dstIndex];
    [srcArray removeObjectAtIndex:srcIndex];
    
    NSLog(@"%@", srcArray);
    NSLog(@"%@", dstArray);
    
    NSIndexPath *dstIndexPath = [NSIndexPath indexPathForItem:dstIndex inSection:0];
    [DstColView insertItemsAtIndexPaths:@[dstIndexPath]];
    NSIndexPath *nSrcIndexPath = [SrcColView indexPathForCell:self.draggingCell];
    [SrcColView deleteItemsAtIndexPaths:@[nSrcIndexPath]];

    
//    [DstColView reloadData];
//    [SrcColView reloadData];
    [self.draggingView removeFromSuperview];
    self.draggingView = nil;
    self.draggingCell = nil;
    self.isDragging = NO;
}

-(void) snapDraggingViewBack{
    UIView* dragginView = self.draggingView;
    NSIndexPath* dragginIndex = self.draggingIndexPath;
    CGRect previousGlobalRect = [self.view convertRect:self.draggingViewPreviousRect fromView:SrcColView];
 
    void (^completion)(BOOL finished) = ^(BOOL finished){
        NSLog(@"Animation complete!");
        /* Reshow the actual cell if it was set to hide */
        if(SrcColView){
            [SrcColView cellForItemAtIndexPath:dragginIndex].alpha = 1;
        }
        [dragginView removeFromSuperview];
    };
    
    [UIView animateWithDuration:0.15 animations:
     ^{
        dragginView.frame = previousGlobalRect;
    } completion:completion];

    
    self.draggingView = nil;
}


- (BOOL)startDragFromView:(UIView*) container atPoint:(CGPoint) point{
    
    
    UIView* cell;
    
    NSIndexPath* index = [self determineIndexForContainer:container
                                                  atPoint:point
                                                  forCell:&cell];
    
    if(index == nil){
        NSLog(@"Invalid Cell.");
        return NO;
    }
    else {
        SrcIndexPath = index;
    }
    
    NSLog(@"Dragging at item:%ld section:%ld", (long)[index item], (long)[index section]);

    /* Find the origin inside the window */
    
    CGPoint cellPoint = cell.frame.origin;
    CGRect containerFrame = container.frame;
    CGRect cellFrame = cell.frame;
    
    cellPoint.x += containerFrame.origin.x;
    cellPoint.y += containerFrame.origin.x;
    
    UIView* cellCopy;
    
    if([container isKindOfClass:[UICollectionView class]]){
        UICollectionViewCell* cell = [(UICollectionView*)container cellForItemAtIndexPath:index];
        self.draggingCell = cell;
        cellCopy = [self copyOfView:cell];
    }
    else {
        return NO;
    }
    
    /* Hide the original cell if specified */
    if((container == SrcColView)&&(cell)){
        cell.alpha = 0.01;
    }
    
    self.draggingView = cellCopy;
    self.draggingViewPreviousRect = cellFrame;
    self.draggingIndexPath = index;
    self.isDragging = YES;
    
    /* Translate the cell's coords to global coords */
    self.draggingView.frame = [self.view convertRect:cellFrame fromView:container];
    self.draggingView.userInteractionEnabled = NO;
    [self.view addSubview:self.draggingView];
    [self.draggingView setHidden:NO];
    
    NSLog(@"Adding dragging data: %ld, draggingView %@", (long)[index row], self.draggingView);
    
    return YES;
    
}

-(void) handleDrag:(UILongPressGestureRecognizer*) gestureRecognizer{
    
    if(!self.isDragging){
        /* Catch erronious dragging gestures */
        NSLog(@"Handle drag but we're not dragging.");
        return;
    }
    
    /* Translate */
    [self.draggingView setCenter:movementTargetPosition];
//    NSLog(@"Translate:(%3.0f,%3.0f)", self.draggingView.center);
    
}

- (NSIndexPath*)determineIndexForContainer:(UIView*) container
                                   atPoint:(CGPoint) point
                                   forCell:(UIView**) cell{
    
    NSIndexPath* index;
    
    if([container isKindOfClass:[UICollectionView class]]){
        
        index = [(UICollectionView*)container indexPathForItemAtPoint:point];
        if(cell){
            *cell = [(UICollectionView*)container cellForItemAtIndexPath:index];
        }
    }
    
    
    return index;
}

-(UIView*) copyOfView:(UIView*) viewToCopy{
    
    [viewToCopy setHidden:NO];
    
    if([viewToCopy isKindOfClass:[UICollectionViewCell class]]){
        
        [(UICollectionViewCell*)viewToCopy setHighlighted:NO];
        
        NSData* viewCopyData = [NSKeyedArchiver archivedDataWithRootObject:viewToCopy];
        return [NSKeyedUnarchiver unarchiveObjectWithData:viewCopyData];
        
    }
    
    /* If its not a UITableView or UICollectionView cell then return nil */
    
    return nil;
    
}

#pragma mark - Collection View Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return cellSpace;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return cellSpace;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _collectionView0) {
        return path0.count;
    }
    else if (collectionView == _collectionView1) {
        return path1.count;
    }
    else if (collectionView == _collectionView2) {
        return path2.count;
    }
    else if (collectionView == _collectionView3) {
        return path3.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    if(cell == nil){
        cell = [UICollectionViewCell new];
    }
    UILabel *cellLabel = (UILabel*)[cell viewWithTag:101];
    NSString *pedalString;
    if (collectionView == _collectionView0) {
        pedalString = [NSString stringWithFormat:@"%@", path0[indexPath.row]];
    }
    else if (collectionView == _collectionView1) {
        pedalString = [NSString stringWithFormat:@"%@", path1[indexPath.row]];
    }
    else if (collectionView == _collectionView2) {
        pedalString = [NSString stringWithFormat:@"%@", path2[indexPath.row]];
    }
    else if (collectionView == _collectionView3) {
        pedalString = [NSString stringWithFormat:@"%@", path3[indexPath.row]];
    }
    [cellLabel setText:pedalString];
    
    UIButton *btn = (UIButton*)[cell viewWithTag:102];
    btn.userInteractionEnabled = NO;
    btn.selected = NO;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", indexPath);
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIButton *btn = (UIButton*)[cell viewWithTag:102];
    btn.selected = !btn.selected;

}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (collectionView == DstColView) {
        [self moveCellItem:sourceIndexPath :destinationIndexPath];
    }
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

- (void)moveCellItem2:(NSInteger)dIdx {
    NSMutableArray *pathArray;
    
    if (SrcColView == self.collectionView0) {
        pathArray = path0;
    }
    else if (SrcColView == self.collectionView1) {
        pathArray = path1;
    }
    else if (SrcColView == self.collectionView2) {
        pathArray = path2;
    }
    else if (SrcColView == self.collectionView3) {
        pathArray = path3;
    }
    else {
        return;
    }
    NSInteger sIdx = SrcIndexPath.item;
    NSString *cellItem = [pathArray objectAtIndex:sIdx];
    [pathArray removeObjectAtIndex:sIdx];
    dIdx -= 1;
    [pathArray insertObject:cellItem atIndex:dIdx];
    
    [SrcColView reloadData];
}

- (void)moveCellItem:(NSIndexPath*)sIdx :(NSIndexPath*)dIdx {
    NSMutableArray *pathArray;
    
    NSLog(@"Local Drap (moveCellItem)");
    
    if (SrcColView == self.collectionView0) {
        pathArray = path0;
    }
    else if (SrcColView == self.collectionView1) {
        pathArray = path1;
    }
    else if (SrcColView == self.collectionView2) {
        pathArray = path2;
    }
    else if (SrcColView == self.collectionView3) {
        pathArray = path3;
    }
    else {
        return;
    }
    
    NSString *cellItem = [pathArray objectAtIndex:sIdx.item];
    [pathArray removeObjectAtIndex:sIdx.item];
    [pathArray insertObject:cellItem atIndex:dIdx.item];
    
    NSLog(@"%@", pathArray);
    [SrcColView reloadData];
}

- (void) updateSignalPathLayout {
    // Path 0 Frame
    CGFloat viewWidth = Insert + (cellWidth + cellSpace)*path0.count;
    CGRect newFrame = CGRectMake(self.collectionView0.frame.origin.x, self.collectionView0.frame.origin.y, viewWidth, self.collectionView0.frame.size.height);
    self.collectionView0.frame = newFrame;
    // frontImgView
    newFrame = CGRectMake(self.collectionView0.frame.origin.x, self.frontImgView.frame.origin.y, viewWidth, self.frontImgView.frame.size.height);
    self.frontImgView.frame = newFrame;
    // Path 1 Frame
    viewWidth = Insert + (cellWidth + cellSpace)*[self max:path1.count :path2.count];
    CGFloat viewOriginX = self.collectionView0.frame.origin.x + self.collectionView0.frame.size.width;
    newFrame = CGRectMake(viewOriginX, self.collectionView1.frame.origin.y, viewWidth, self.collectionView1.frame.size.height);
    self.collectionView1.frame = newFrame;
    // Path 2 Frame
    newFrame = CGRectMake(viewOriginX, self.collectionView2.frame.origin.y, viewWidth, self.collectionView2.frame.size.height);
    self.collectionView2.frame = newFrame;
    // MidImgView
    newFrame = CGRectMake(viewOriginX, self.midImgView.frame.origin.y, viewWidth, self.midImgView.frame.size.height);
    self.midImgView.frame = newFrame;
    // Path 3 Frame
    viewWidth = Insert + (cellWidth + cellSpace)*path3.count;
    viewOriginX = self.collectionView2.frame.origin.x + self.collectionView2.frame.size.width;
    newFrame = CGRectMake(viewOriginX, self.collectionView3.frame.origin.y, viewWidth, self.collectionView3.frame.size.height);
    self.collectionView3.frame = newFrame;
    // backImgView
    newFrame = CGRectMake(viewOriginX, self.backImgView.frame.origin.y, viewWidth, self.backImgView.frame.size.height);
    self.backImgView.frame = newFrame;
}

- (NSInteger)max:(NSInteger)x :(NSInteger)y {
    if (x>=y) {
        return x;
    }
    else {
        return y;
    }
}

#pragma mark - Button Callback
- (IBAction)addBtnPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add a pedal"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // optionally configure the text field
        textField.keyboardType = UIKeyboardTypeDefault;
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         UITextField *textField = [alert.textFields firstObject];
                                                         NSLog(@"UIAlertAction:[%@]", textField.text);
                                                         
                                                         NSString *newPedal = textField.text;
                                                         [path3 addObject:newPedal];
                                                         [self.collectionView3 reloadData];
                                                         [self updateSignalPathLayout];
                                                     }];
    [alert addAction:okAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)removeBtnPressed:(id)sender {
    for (NSInteger i = path0.count-1; i >= 0; i--) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewCell *cell = [self.collectionView0 cellForItemAtIndexPath:indexPath];
        UIButton *btn = (UIButton*)[cell viewWithTag:102];
        if (btn.selected == YES) {
            [path0 removeObjectAtIndex:i];
        }
    }
    for (NSInteger i = path1.count-1; i >= 0; i--) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewCell *cell = [self.collectionView1 cellForItemAtIndexPath:indexPath];
        UIButton *btn = (UIButton*)[cell viewWithTag:102];
        if (btn.selected == YES) {
            [path1 removeObjectAtIndex:i];
        }
    }
    for (NSInteger i = path2.count-1; i >= 0; i--) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewCell *cell = [self.collectionView2 cellForItemAtIndexPath:indexPath];
        UIButton *btn = (UIButton*)[cell viewWithTag:102];
        if (btn.selected == YES) {
            [path2 removeObjectAtIndex:i];
        }
    }
    for (NSInteger i = path3.count-1; i >= 0; i--) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewCell *cell = [self.collectionView3 cellForItemAtIndexPath:indexPath];
        UIButton *btn = (UIButton*)[cell viewWithTag:102];
        if (btn.selected == YES) {
            [path3 removeObjectAtIndex:i];
        }
    }
    [self.collectionView0 reloadData];
    [self.collectionView1 reloadData];
    [self.collectionView2 reloadData];
    [self.collectionView3 reloadData];
    [self updateSignalPathLayout];
}
@end
