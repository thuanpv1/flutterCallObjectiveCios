//
//  PresetViewPortrait.m
//  iCamSee
//
//  Created by VINSON on 2019/12/6.
//  Copyright © 2019 Macrovideo. All rights reserved.
//

#import "PresetViewPortrait.h"
#import "PresetCell.h"

#define kImage @"image"
#define kTitle @"title"
#define kSelected @"selected"

@interface PresetViewPortrait() <UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectiontView;

@property (nonatomic,assign) BOOL isEditing;
@property (nonatomic,strong) NSMutableArray *infos;
@property (nonatomic,assign) int deviceID;
@property (nonatomic,assign) int panoIndex;
@end

@implementation PresetViewPortrait
- (void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
    _titleLabel.text =@"Preset";
    _titleLabel.textColor = [UIColor blackColor];
    [_deleteButton setTitle:@"delete" forState:UIControlStateNormal];
    [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    _collectiontView.delegate = self;
    _collectiontView.dataSource = self;
    //_collectiontView.allowsMultipleSelection = YES;
    [_collectiontView registerNib:[UINib nibWithNibName:@"PresetCell" bundle:nil] forCellWithReuseIdentifier:@"PresetCell"];
    _collectiontView.backgroundColor = [UIColor whiteColor];
    
    _isEditing = YES;
    self.isEditing = NO;
}

-(void)reset:(int)panoIndex deviceID:(int)deviceID ptzxCount:(int)ptzxCount ptzxs:(NSArray<PTZXPicture*>*)ptzxs{
    NSMutableArray *infos = [[NSMutableArray alloc] initWithCapacity:ptzxCount];
    for (int index = 0; index<ptzxCount; index++) {
        NSMutableDictionary * info = [NSMutableDictionary new];
        info[kTitle] = [NSString stringWithFormat:@"Preset%d",index+1];
        [infos addObject:info];
    }
    
    PTZXPicture *ptzx = nil;
    NSEnumerator *enumer = ptzxs.objectEnumerator;
    while (nil != (ptzx = enumer.nextObject)) {
        infos[ptzx.nPTZXID][kImage] = ptzx.imageData;        
    }
    self.infos = infos;
    self.panoIndex = panoIndex;
    self.deviceID = deviceID;
}
-(void)reset:(UIImage*)image atIndex:(int)index{
    _infos[index][kImage] = image;
    [_collectiontView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
}

- (void)setInfos:(NSMutableArray *)infos{
    _infos = infos;
    [_collectiontView reloadData];
}
- (void)setIsEditing:(BOOL)isEditing{
    _closeButton.hidden = isEditing;
    _editButton.hidden = isEditing;
    
    _deleteButton.hidden = !isEditing;
    _cancelButton.hidden = !isEditing;
    
    //_collectiontView.allowsSelection = isEditing;
    _isEditing = isEditing;
}
- (void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    if(_hiddenLayouts && _showingLayouts){
        NSArray *active = hidden ? _hiddenLayouts : _showingLayouts;
        NSArray *deactive = hidden ? _showingLayouts : _hiddenLayouts;
        
        [NSLayoutConstraint deactivateConstraints:deactive];
        [NSLayoutConstraint activateConstraints:active];
        [self updateConstraints];
    }
}

- (IBAction)onButtonTouchupInside:(id)sender {
    if(sender == _closeButton){
        /// TODO: page exit
        self.hidden = YES;
    }
    else if(sender == _editButton){
        /// TODO: enter the editing state
        self.isEditing = YES;
    }
    else if(sender == _deleteButton){
        /// TODO: delete checked
        BOOL isEmpty = YES;
        int count = (int)_infos.count;
        for (int index = 0; index < count; index++) {
            NSMutableDictionary *info = _infos[index];
            if(info[kSelected]){
                isEmpty = NO;
                break;
            }
        }
        if(isEmpty) return; // If it is not selected, return directly without any prompt, nor exit the page
        
        __weak typeof(self) weakSelf = self;
        NSString *messgae = @"Are you sure you want to delete this preset?";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:messgae preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: @"Cancel" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            for (int index = 0; index < count; index++) {
                NSMutableDictionary *info = strongSelf.infos[index];
                if(info[kSelected]){
                    [info removeObjectForKey:kSelected];
                    [info removeObjectForKey:kImage];

                    if(strongSelf.onChanged) strongSelf.onChanged(strongSelf.panoIndex, strongSelf.deviceID, index, PresetActionDelete);
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.isEditing = NO;
                [strongSelf.collectiontView reloadData];
            });
        }];
        
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        [_viewController presentViewController:alert animated:YES completion:nil];
    }
    else if(sender == _cancelButton){
        /// TODO: Exit the editing state
        self.isEditing = NO;
        NSEnumerator *enumer = _infos.objectEnumerator;
        NSMutableDictionary *info = nil;
        while (nil != (info = enumer.nextObject)) {
            [info removeObjectForKey:kSelected];
        }
        [self.collectiontView reloadData];
    }
    else{
    }
}

#pragma mark - Protocol function: <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *info = self.infos[indexPath.row];
    if(_isEditing){
        if(nil == info[kSelected] && nil != info[kImage]){
            info[kSelected] = @(YES);
        }
        else{
            [info removeObjectForKey:kSelected];
        }
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
    else{
        if(_onChanged){
            _onChanged(_panoIndex, _deviceID, (int)indexPath.row, nil != info[kImage] ? PresetActionCall : PresetActionReset);
        }
    }
}

#pragma mark - Protocol function: <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return nil == _infos ? 0 : _infos.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PresetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PresetCell" forIndexPath:indexPath];
    if(nil == cell){
        cell = [[NSBundle mainBundle] loadNibNamed:@"PresetCell" owner:nil options:nil].lastObject;
    }
    
    NSDictionary *info = self.infos[indexPath.row];
    cell.title.text = info[kTitle];
    cell.image.image = nil == info[kImage] ? [UIImage imageNamed:@"crusing_btn_addpostion"] : info[kImage];
    cell.edit = nil == info[kSelected] ? NO : YES;
    return cell;
}
@end
