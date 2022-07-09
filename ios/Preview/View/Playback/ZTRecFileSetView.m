//
//  ZTRecFileSetView.m
//  iCamSee
//
//  Created by hs_mac on 2018/3/8.
//  Copyright © 2018年 Macrovideo. All rights reserved.
//

#import "ZTRecFileSetView.h"
#import "ZTRecFileCollectionViewCell.h"

@interface ZTRecFileSetView()<UICollectionViewDataSource,UICollectionViewDelegate>

@property(strong, nonatomic) UICollectionView *collectionView;
@property(assign, nonatomic) NSInteger currentIndex;
@property(nonatomic,strong) UIView *noFileBgView;
@property(nonatomic,strong) UIView *noCloudBgView;
@property (nonatomic, strong) UILabel *tipsLable;
@property (nonatomic, strong) UILabel *openSDRecordTipsLabel;

@end

static NSString *cellID = @"FileSetcell";

@implementation ZTRecFileSetView

-(instancetype)initWithFrame:(CGRect)frame{
    
    if(self = [super initWithFrame:frame]){
    
     
       // set the pipeline layout
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        // Set UICollectionView to scroll horizontally
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        // spacing between cells in each row
       // flowLayout.minimumLineSpacing = 50;
        // spacing between cells in each column
         flowLayout.minimumInteritemSpacing = 0;
        // Set the spacing between the first cell and the last cell and the parent control
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView = collectionView;
        [self addSubview:collectionView];
        [self.collectionView registerClass:[ZTRecFileCollectionViewCell class] forCellWithReuseIdentifier:cellID];
        [self addNoFileListView];
        [self addNoCloudFileView];//add by qin 20190221
    }
    return self;
    
}


-(void)addNoFileListView{
    self.noFileBgView = [[UIView alloc]init];
    self.noFileBgView.backgroundColor = [UIColor whiteColor];
    self.noFileBgView.frame = self.bounds;
    [self addSubview:self.noFileBgView];
    
    self.tipsLable = [[UILabel alloc]init];
    self.tipsLable.frame = CGRectMake(0, 8, self.frame.size.width, 30);
    self.tipsLable.text = NSLocalizedString(@"TFCardCheckFail", @"TF card not detected");
    self.tipsLable.textAlignment = NSTextAlignmentCenter;
    [self.noFileBgView addSubview:self.tipsLable];
    
    self.openSDRecordTipsLabel = [[UILabel alloc]init];
    self.openSDRecordTipsLabel.frame = CGRectMake(0, CGRectGetMaxY(self.tipsLable.frame), self.frame.size.width, 30);
    self.openSDRecordTipsLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Please make sure the recording is turned on", @"Please make sure the recording is turned on")];
    self.openSDRecordTipsLabel.textAlignment = NSTextAlignmentCenter;
    self.openSDRecordTipsLabel.font = [UIFont systemFontOfSize:13];
    self.openSDRecordTipsLabel.textColor = [UIColor grayColor];
    [self.noFileBgView addSubview:self.openSDRecordTipsLabel];
    
    
//    UILabel *tipLable2 =[[UILabel alloc]init];
//    tipLable2.frame = CGRectMake(0,CGRectGetMaxY(tipLable1.frame), self.frame.size.width, 40);
//    tipLable2.text = NSLocalizedString(@"lblSearchRecFilesFailDes", nil);
//    tipLable2.textAlignment = NSTextAlignmentCenter;
//    tipLable2.numberOfLines = 2;
//    tipLable2.textColor = [HSColorScheme colorWithDarkMode:[UIColor colorWithHex:0x999999] lightColor:[UIColor lightGrayColor]];
//    tipLable2.font = [UIFont systemFontOfSize:15];
//    [self.noFileBgView addSubview:tipLable2];
    
}

//-(void)setNoFileListTipsView:(BOOL)hide{
//    self.noFileBgView.hidden = hide;
//}

-(void)showNoSdCardTips{
    self.noFileBgView.hidden = NO;
    self.openSDRecordTipsLabel.hidden = YES;
   self.tipsLable.text = NSLocalizedString(@"TFCardCheckFail", @"TF card not detected");
}

-(void)showNoFileTips{
    self.noFileBgView.hidden = NO;
    self.openSDRecordTipsLabel.hidden = NO;
    self.tipsLable.text = NSLocalizedString(@"There is no video file on the search date", "There is no video file on the search date");
}

-(void)dismissTipsView{
    self.openSDRecordTipsLabel.hidden = YES;
    self.noFileBgView.hidden = YES;
}

//add by qin 20190221
-(void)addNoCloudFileView{
    self.noCloudBgView =  [[UIView alloc]init];
    self.noCloudBgView.backgroundColor = [UIColor whiteColor];
    self.noCloudBgView.frame = self.bounds;
    [self addSubview:self.noCloudBgView];
    
    UILabel *cloudTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.frame.size.width, 30)];
    cloudTipsLabel.textAlignment = NSTextAlignmentCenter;
    UIFont *labelTextFont = [UIFont systemFontOfSize:15];
    cloudTipsLabel.font = labelTextFont;
//    UIColor *textColer = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
//    cloudTipsLabel.textColor = textColer;
    cloudTipsLabel.text = NSLocalizedString(@"There is no recording file on the search date (please make sure the recording is turned on)", @"There is no recording file on the search date (please make sure the recording is turned on)");
    [self.noCloudBgView addSubview:cloudTipsLabel];
    
    UILabel *openRecordTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(cloudTipsLabel.frame), self.frame.size.width, 30)];
    openRecordTipsLabel.textAlignment = NSTextAlignmentCenter;
    openRecordTipsLabel.font = [UIFont systemFontOfSize:13];
    openRecordTipsLabel.textColor = [UIColor grayColor];
    openRecordTipsLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Please make sure the recording is turned on", @"Please make sure the recording is turned on")];
    [self.noCloudBgView addSubview:openRecordTipsLabel];
}

-(void)setNoCloudFileTipsView:(BOOL)hide{
    self.noCloudBgView.hidden = hide;
}
//end by qin 20190221


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _fileSetList.count;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZTRecFileCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    if (!cell ) {
        cell = [[ZTRecFileCollectionViewCell alloc] init];
    }
    NSInteger index = self.isReverse ? self.fileSetList.count - 1 - indexPath.row : indexPath.row;
    cell.fileModel = _fileSetList[index]; //Video playback weibin 20180913
    
    cell.layer.borderColor = [UIColor orangeColor].CGColor;
    if(indexPath.row == _currentIndex && _currentIndex >= 0){
        cell.layer.borderWidth = 1.8;
        
    }else{
        cell.layer.borderWidth = 0;
  
    }
    return cell;
}


//Set the width and height of each Cell
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    return CGSizeMake(140 , self.frame.size.height);
    
}
//Set the spacing between sections (top, left, bottom, right)
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(0, 5, 0, 5);
    
}


-(void)setFileSetList:(NSArray *)fileSetList{
    
    _fileSetList = [fileSetList copy];
    _currentIndex = -1;
    [_collectionView reloadData];
    
}


// click
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

// if(indexPath.row != _currentIndex){
    NSIndexPath *totalIndexpath = nil;
    if (self.isReverse) {
        totalIndexpath = [NSIndexPath indexPathForRow:self.fileSetList.count - 1 - indexPath.row inSection:indexPath.section];
    }else{
        totalIndexpath = indexPath;
    }
        self.selectItemAction(totalIndexpath);
// }
    // select box
    ZTRecFileCollectionViewCell *cell = (ZTRecFileCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    cell.layer.borderWidth = 1.8;
    if(indexPath.row != _currentIndex && _currentIndex >= 0){
        ZTRecFileCollectionViewCell *lastcell = (ZTRecFileCollectionViewCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0]];
        lastcell.layer.borderWidth = 0;
        
    }
    _currentIndex = indexPath.row;
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ZTRecFileCollectionViewCell *cell = (ZTRecFileCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    cell.layer.borderWidth = 0;
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];//add by weibin 20180930
}

-(void)updateItemWithIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row >= 0 && indexPath.row <= _fileSetList.count && indexPath.section == 0){
        NSIndexPath *totalIndexPath = [NSIndexPath indexPathForRow:self.isReverse ? self.fileSetList.count - 1 - indexPath.row : indexPath.row inSection:indexPath.section];
        [self.collectionView reloadItemsAtIndexPaths:@[totalIndexPath]];
        
    }
    
}

//Refresh the entire view data add by weibin 20181009
-(void) reloadDataForCollectionView{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.currentIndex = -1;
        [self.collectionView reloadData];
        
        //Jump to the first cell
        CGPoint offset = self.collectionView.contentOffset;
        offset.x = 0;
        self.collectionView.contentOffset = offset;
        [self setNeedsLayout];
        
        if (self.fileSetList.count > 0) {
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        }
    });
   
}

// Scroll to a row
-(void)scrollToItemAtIndexPath:(NSIndexPath*)indexPath{
    
    if(self.fileSetList && self.fileSetList.count >=0 && indexPath.row < self.fileSetList.count ){
        NSIndexPath *totalIndexPath = [NSIndexPath indexPathForRow:self.isReverse ? self.fileSetList.count - 1 - indexPath.row : indexPath.row inSection:indexPath.section];
        self.currentIndex = totalIndexPath.row;
        [self.collectionView scrollToItemAtIndexPath:totalIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        [self.collectionView reloadItemsAtIndexPaths:@[totalIndexPath]];
    }
}

//select a row
-(void)selectCellAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row >= self.fileSetList.count) {
        return;
    }
// self.currentIndex = indexPath.row;
// [self.collectionView reloadData];
    NSIndexPath *totalIndexPath = [NSIndexPath indexPathForRow:self.isReverse ? self.fileSetList.count - 1 - indexPath.row : indexPath.row inSection:indexPath.section];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:totalIndexPath];
}

//refresh
-(void)reloadView{
    NSLog(@"reloadView,filecount = %lu",self.fileSetList.count);
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

@end
