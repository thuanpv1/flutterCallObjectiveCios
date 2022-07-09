//
//  ZTRecFileSetView.h
//  iCamSee
//
//  Created by hs_mac on 2018/3/8.
//  Copyright © 2018年 Macrovideo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZTRecFileSetView : UIView

// event set
@property(copy, nonatomic) NSArray *fileSetList;

// callback for click
@property(copy, nonatomic) void (^selectItemAction)(NSIndexPath *indexPath);

//Whether to display in reverse order
@property (nonatomic, assign) BOOL isReverse;


// update the cell of a row
-(void) updateItemWithIndexPath:(NSIndexPath *)indexPath;

//Show hidden no video file view
//-(void)setNoFileListTipsView:(BOOL)hide;


-(void)showNoSdCardTips; //Show no card tips
-(void)showNoFileTips; //Show no video file prompt
-(void)dismissTipsView; //Hide the above two tips

//Refresh the entire view data add by weibin 20181009
-(void) reloadDataForCollectionView;

//Show hidden cloud storage without video files trying to add by qin 20190221
-(void)setNoCloudFileTipsView:(BOOL)hide;

// Scroll to a row
-(void)scrollToItemAtIndexPath:(NSIndexPath*)indexPath;

//select a row
-(void)selectCellAtIndexPath:(NSIndexPath *)indexPath;

//refresh
-(void)reloadView;
@end
