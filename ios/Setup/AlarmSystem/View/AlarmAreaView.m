//
//  AlarmAreaView.m
//  collectview
//
//  Created by 视宏 on 17/2/25.
//  Copyright © 2017年 视宏. All rights reserved.
//

#import "AlarmAreaView.h"
//UNSELECTCOLOR
@interface AlarmAreaView()<UICollectionViewDataSource,UICollectionViewDelegate>
@property(nonatomic,strong) UICollectionView *collectionview;
@property (strong , nonatomic) NSIndexPath * m_lastAccessed;
@property(nonatomic,assign) int row;
@property(nonatomic,assign) int column;
@property(nonatomic,strong) NSMutableArray *alarmAreaArray;



@end
@implementation AlarmAreaView
@synthesize alarmAreaArray = _alarmAreaArray;
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionview];
    }
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self addSubview:self.collectionview];
        

    }
    return self;
}

-(UICollectionView *)collectionview{

    if (!_collectionview) {
//        self.backgroundColor = [UIColor redColor];
//Create a pipeline layout
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
        // set the spacing
        NSInteger superWidth = self.frame.size.width;
        NSInteger superHeight = self.frame.size.height;
        
        int MaxCol =self.column;
        int MaxRow = self.row;
        NSInteger margin = 0.01;
        layout.minimumInteritemSpacing = margin;
        layout.minimumLineSpacing = margin;
        
//Set item size
        CGFloat itemW = (superWidth - (MaxCol + 1) * margin) / MaxCol;//
        CGFloat itemH = (superHeight - (MaxRow +1) * margin) / MaxRow;//;
        layout.itemSize = CGSizeMake(itemW, itemH);
        
        layout.sectionInset = UIEdgeInsetsMake(margin, margin, 0, margin);
        
        // Set the horizontal scroll direction
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        //Create collectionview
        _collectionview = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
        
        //set background color
        _collectionview.backgroundColor = [UIColor clearColor];

        //set center point
        _collectionview.center = self.center;
        
        // set the data source, display the data
        _collectionview.dataSource = self;
        //Set the proxy, listen
        _collectionview.delegate = self;
        
        // 注册cell
        NSString *ID = @"CELL";
        [_collectionview registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:ID];
        
        // set the scroll bar
        _collectionview.showsHorizontalScrollIndicator = NO;
        _collectionview.showsVerticalScrollIndicator = NO;
        _collectionview.allowsMultipleSelection=YES;
        
        //Set whether the spring effect is required
        _collectionview.bounces = NO;
        
        UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        [_collectionview addGestureRecognizer:panGesture];
       
    }
    
    
    return _collectionview;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.collectionview.frame = self.bounds;
    
    

}

-(void)setflowlayout{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    //set spacing
    NSInteger superWidth = self.frame.size.width;
    NSInteger superHeight = self.frame.size.height;
    
    int MaxCol =self.alarmModel.column;
    int MaxRow = self.alarmModel.row;
    NSInteger margin = 0.01;
    layout.minimumInteritemSpacing = margin;
    layout.minimumLineSpacing = margin;
    
    //Set item size
    CGFloat itemW = (superWidth - (MaxCol + 1) * margin) / MaxCol;//
    CGFloat itemH = (superHeight - (MaxRow + 1) * margin) / MaxRow;//;
    layout.itemSize = CGSizeMake(itemW, itemH);
    
    layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    
    // Set the horizontal scroll direction
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [self.collectionview setCollectionViewLayout:layout];
    
}
-(void)panGesture:(UIGestureRecognizer*)gestureRecognizer{
    float pointerX = [gestureRecognizer locationInView:self.collectionview].x;
//    NSLog(@"pointerX = %f",pointerX);
    float pointerY = [gestureRecognizer locationInView:self.collectionview].y;
    for(UICollectionViewCell* cell1 in self.collectionview.visibleCells) {
        float cellLeftTop = cell1.frame.origin.x;
//        NSLog(@"cellLeftTop = %f",cellLeftTop);
        float cellRightTop = cellLeftTop + cell1.frame.size.width;
        float cellLeftBottom = cell1.frame.origin.y;
        float cellRightBottom = cellLeftBottom + cell1.frame.size.height;
        
        if (pointerX >= cellLeftTop && pointerX <= cellRightTop && pointerY >= cellLeftBottom && pointerY <= cellRightBottom) {
            NSIndexPath* touchOver = [self.collectionview indexPathForCell:cell1];
            if (self.m_lastAccessed != touchOver) {
                cell1.backgroundColor =[UIColor redColor];
                
                if (cell1.selected) {
                    [self deselectCellForCollectionView:self.collectionview atIndexPath:touchOver];
                }
                else
                {
                    
                    [self selectCellForCollectionView:self.collectionview atIndexPath:touchOver];
                    
                }
            }
            
            self.m_lastAccessed = touchOver;
            
        }
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.m_lastAccessed = nil;
        self.collectionview.scrollEnabled = YES;
    }
    
}

/*Callback when Cell is not selected*/
-(void)selectCellForCollectionView:(UICollectionView*)collection atIndexPath:(NSIndexPath*)indexPath{
    [collection selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    [self collectionView:collection didSelectItemAtIndexPath:indexPath];
  
}

-(void)deselectCellForCollectionView:(UICollectionView*)collection atIndexPath:(NSIndexPath*)indexPath{
    [collection deselectItemAtIndexPath:indexPath animated:YES];
    [self collectionView:collection didDeselectItemAtIndexPath:indexPath];
    
   
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
   // selected callback
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
//    cell.backgroundColor = [UIColor redColor];
//    NSLog(@"didSelectItemAtIndexPath indexPath.item = %d",indexPath.item);
    cell.backgroundColor = SELECTCOLOR;

    [self.alarmAreaArray replaceObjectAtIndex:indexPath.item withObject:[NSString stringWithFormat:@"%d",cell.isSelected]];
//    NSLog(@"chooseitem %ld -- %d ",(long)indexPath.item,[self.alarmAreaArray[indexPath.item] boolValue]);
 
    if (self.updateAreaBlock) {
        self.updateAreaBlock(_alarmAreaArray);
    }
}


/*Callback when Cell has been selected*/

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    // cancel selection callback
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = UNSELECTCOLOR;
    // cell.backgroundColor = [UIColor grayColor];
    [_alarmAreaArray replaceObjectAtIndex:indexPath.item withObject:[NSString stringWithFormat:@"%d",cell.isSelected]];

// NSLog(@"Deselect %ld--- %d ",indexPath.item,[self.alarmAreaArray[indexPath.item] boolValue]);
    if (self.updateAreaBlock) {
        self.updateAreaBlock(_alarmAreaArray);
    }
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    return YES;
}
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;{

    return [self.alarmAreaArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    if ([(NSString*)self.alarmAreaArray[indexPath.row] boolValue]) {
        cell.backgroundColor = SELECTCOLOR;

        [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        [cell setSelected:YES];
    }else{
        
        cell.backgroundColor = UNSELECTCOLOR;
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        [cell setSelected:NO];
    }
    
    cell.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.layer.borderWidth = 0.5;

    return cell;
}
-(void)clearselect{
    
    for (int i = 0; i < self.alarmAreaArray.count; i++) {
        [self.alarmAreaArray replaceObjectAtIndex:i withObject:@"0"];
    }
    [_collectionview reloadData];
  
}
-(void)selectallArea{
    
    for (int i = 0; i < self.alarmAreaArray.count; i++) {
        [self.alarmAreaArray replaceObjectAtIndex:i withObject:@"1"];
    }
    [_collectionview reloadData];
   
}
-(NSMutableArray *)alarmAreaArray{
    if (!_alarmAreaArray) {
        _alarmAreaArray = [NSMutableArray array];
        
    }
  
    return _alarmAreaArray;
}

-(void)setAlarmAreaArray:(NSMutableArray *)alarmAreaArray{
    
    if (_alarmAreaArray != alarmAreaArray) {
        _alarmAreaArray = [alarmAreaArray mutableCopy];
        [self.collectionview reloadData];
    }
 
}


-(void)setAlarmModel:(AlarmAreaModel *)alarmModel{
    
    if(_alarmModel != alarmModel){
        _alarmModel = alarmModel;
        [self clearselect];
        
        self.alarmAreaArray = [_alarmModel.alarmAreaArr mutableCopy];
        self.row = _alarmModel.row;
        self.column = _alarmModel.column;
    }
    [self setflowlayout];
  
}

-(void)updateAlarmArea:(updateAlarmArea)AlarmArea{
    
    self.alarmModel.alarmAreaArr = [self.alarmAreaArray mutableCopy];
    if (AlarmArea) {
        AlarmArea(self.alarmModel);
    }
}


-(void)dealloc{

}
@end
