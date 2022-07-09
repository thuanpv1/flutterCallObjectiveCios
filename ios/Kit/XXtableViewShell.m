#import "XXtableViewShell.h"

#define kReuseRowDefault @"ReuseRowDefault"
#define kReuseHeaderDefault @"ReuseHeaderDefault"
#define kReuseFooterDefault @"ReuseFooterDefault"

#define kHeader @"Header"
#define kRow @"Row"
#define kFooter @"Footer"

#define kTitle @"Title"
#define kDetail @"Detail"
#define kImage @"Image"
#define kAccessoryType @"AccessoryType"
#define kCellDisable @"CellDisable"

@interface XXtableViewShell()
@property (nonatomic,strong) UIView *emptyView;
@property (nonatomic ,strong) UILabel *redDot;
@end

@implementation XXtableViewShell
#pragma mark - <Init>
- (instancetype)init{
    self = [super init];
    if (self) {
        _sectionDatas   = [NSMutableArray new];
        _rowSystemStyle = UITableViewCellStyleDefault;
        _rowType        = nil;
        //_rowHeight = -1;
    }
    return self;
}

#pragma mark - <Config>
- (void)shell:(UITableView*)tableView{
    if(nil != _tableView) return;
    _tableView = tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 30;//_rowHeight;
}
- (void)configEmptyView:(NSString*)cls loadType:(XXtableViewShellRowLoadType)loadType{
    _emptyType = [cls copy];
    _emptyLoadType = loadType;
    
    if(self.emptyLoadType == XXtableViewShellRowLoadTypeNib){
        self.emptyView = [[NSBundle mainBundle] loadNibNamed:self.emptyType owner:nil options:nil].firstObject;
    }
    else{
        self.emptyView = [NSClassFromString(self.emptyType) new];
    }
    
    if(nil!=self.emptyView && nil!=self.tableView){
        self.emptyView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.tableView addSubview:self.emptyView];
        [self.emptyView.centerXAnchor constraintEqualToAnchor:self.tableView.centerXAnchor].active = YES;
        [self.emptyView.centerYAnchor constraintEqualToAnchor:self.tableView.centerYAnchor].active = YES;
    }
}
- (void)configEmptyViewInstance:(UIView*)view{
    self.emptyView = view;
    if(self.emptyView){
        self.emptyView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.tableView addSubview:self.emptyView];
        [self.emptyView.centerXAnchor constraintEqualToAnchor:self.tableView.centerXAnchor].active = YES;
        [self.emptyView.centerYAnchor constraintEqualToAnchor:self.tableView.centerYAnchor].active = YES;
    }
}
- (void)configRowType:(nullable NSString*)type loadType:(XXtableViewShellRowLoadType)loadType systemStyle:(UITableViewCellStyle)systemStyle height:(CGFloat)height{
    _rowType = type;
    _rowLoadType = loadType;
    _rowSystemStyle = systemStyle;
    
    if(nil != type){
        if(XXtableViewShellRowLoadTypeNib == loadType){
            [_tableView registerNib:[UINib nibWithNibName:_rowType bundle:nil] forCellReuseIdentifier:_rowType];
        }
        else if(XXtableViewShellRowLoadTypeCode == loadType){
            [_tableView registerClass:NSClassFromString(_rowType) forCellReuseIdentifier:_rowType];
        }
        else{
            
        }
    }
    
    if(height <= 0){
        _tableView.estimatedRowHeight = 30;
    }
    else{
        _tableView.rowHeight = height;
    }
//    _tableView.sectionHeaderHeight = 30;
    _tableView.sectionFooterHeight = 0;
}

- (void)configSectionWithHeaders:(nullable NSArray*)headers rows:(NSArray*)rows footers:(nullable NSArray*)footers{
    
    int sectionCount = (int)rows.count;
    for (int index = 0; index < sectionCount; index++) {
        NSMutableDictionary *section = [NSMutableDictionary new];
        if(nil != headers) [section setObject:headers[index] forKey:kHeader];
        if(nil != footers) [section setObject:footers[index] forKey:kFooter];
        
        NSMutableArray *rowsDataOfOneSection = [[NSMutableArray alloc] initWithArray:rows[index]];
        [section setObject:rowsDataOfOneSection forKey:kRow];
        [_sectionDatas addObject:section];
    }
        
    [_tableView reloadData];
}
- (void)configSectionWithHeader:(nullable id)header row:(nullable NSArray*)row footer:(nullable id)footer{
    NSMutableDictionary *section = [NSMutableDictionary new];
    if(nil != header) [section setObject:header forKey:kHeader];
    if(nil != footer) [section setObject:footer forKey:kFooter];
    if(nil != row) {
        NSMutableArray *rowsDataOfOneSection = [[NSMutableArray alloc] initWithArray:row];
        [section setObject:rowsDataOfOneSection forKey:kRow];
    }
    [_sectionDatas addObject:section];
}
- (void)configFinished{
    [_tableView reloadData];
}


#pragma mark - <Section>
- (void)addSectionWithHeader:(nullable id)header row:(nullable NSArray*)row footer:(nullable id)footer{
    NSMutableDictionary *section = [NSMutableDictionary new];
    if(nil != header) [section setObject:header forKey:kHeader];
    if(nil != footer) [section setObject:footer forKey:kFooter];
    if(nil != row) [section setObject:row forKey:kRow];
    [_sectionDatas addObject:section];
    [_tableView reloadData];
}
- (void)insertSectionWithHeader:(nullable id)header row:(nullable NSArray*)row footer:(id)footer atIndex:(int)index{
    NSMutableDictionary *section = [NSMutableDictionary new];
    if(nil != header) [section setObject:header forKey:kHeader];
    if(nil != footer) [section setObject:footer forKey:kFooter];
    if(nil != row) [section setObject:row forKey:kRow];
    [_sectionDatas insertObject:section atIndex:index];
    [_tableView reloadData];
}
- (void)removeSectionAtIndex:(int)index{
    [_sectionDatas removeObjectAtIndex:index];
    [_tableView reloadData];
}

#pragma mark - <Row>
- (void)resetRow:(nullable NSArray*)row atSection:(int)section{
    NSMutableDictionary *sectionData = section < _sectionDatas.count?_sectionDatas[section]:nil;
    if(nil == sectionData && row && row.count>0){
        if(section == _sectionDatas.count){
            /// If the specified section is the current maximum section number + 1, a new section will be created directly (sections are ordered)
            sectionData = [NSMutableDictionary new];
            _sectionDatas[section] = sectionData;
        }
        else{
            /// The specified section is not the maximum section number + 1, and the creation of multiple intermediate sections is temporarily not supported.
            return;
        }
    }
    if(nil == sectionData){
        return;
    }
    
    if(nil == row || 0 == row.count){
        [sectionData removeObjectForKey:kRow];
        if(0 == sectionData.count){
            [self.sectionDatas removeObject:sectionData];
        }
    }
    else{
        [sectionData setObject:row forKey:kRow];
    }
    [_tableView reloadData];
}
- (void)addRow:(NSArray*)row atSection:(int)section{
    NSMutableDictionary *sectionData = section < _sectionDatas.count?_sectionDatas[section]:nil;
    if(nil == sectionData){
        if(section == _sectionDatas.count){
            /// If the specified section is the current maximum section number + 1, a new section will be created directly (sections are ordered)
            sectionData = [NSMutableDictionary new];
            _sectionDatas[section] = sectionData;
        }
        else{
            /// The specified section is not the maximum section number + 1, and the creation of multiple intermediate sections is not supported for the time being
            return;
        }
    }
    
    NSMutableArray *localRow = sectionData[kRow];
    if(nil == localRow){
        sectionData[kRow] = [[NSMutableArray alloc] initWithArray:row];
    }
    else{
        [localRow addObjectsFromArray:row];
    }
    [_tableView reloadData];
}
- (void)removeRowAtIndexPath:(NSIndexPath*)indexPath{
    NSMutableArray *rows = [self getRowWithSection:(int)indexPath.section];
    if(nil == rows){
        return;
    }
    if(indexPath.row>=0 && indexPath.row<rows.count){
        [rows removeObjectAtIndex:indexPath.row];
        [_tableView reloadData];
    }
}
- (void)resetData:(id)data atIndexPath:(NSIndexPath*)indexPath{
    NSMutableArray *rows = [self getRowWithSection:(int)indexPath.section];
    if(nil == rows){
        return;
    }
    [rows replaceObjectAtIndex:indexPath.row withObject:data];
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
- (id)getDataAtIndexPath:(NSIndexPath*)indexPath{
    NSMutableArray *rows = [self getRowWithSection:(int)indexPath.section];
    if(nil == rows){
        return nil;
    }
    return [rows objectAtIndex:indexPath.row];
}

- (void)rowDoSomething:(NSString*)event info:(nullable id)info atIndex:(NSIndexPath*)indexPath{
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    if(nil == cell){
        NSLog(@"[XXtableViewShell] [rowDoSomething] indexPath（%@）The corresponding cell is nil。", indexPath);
        return;
    }
    
    if(![cell conformsToProtocol:@protocol(XXtableViewCellDelegate)]){
        NSLog(@"[XXtableViewShell] [rowDoSomething] cell doesn't follow protocol‘XXtableViewCellDelegate’。");
        return;
    }
    
    id<XXtableViewCellDelegate> xxcell = (id<XXtableViewCellDelegate>)cell;
    [xxcell doSomething:event info:info];
}

#pragma mark - <Private>
- (nullable NSMutableArray*)getRowWithSection:(int)section{
    return [[_sectionDatas objectAtIndex:section] objectForKey:kRow];
}
- (id)getRowDataWithSection:(int)section row:(int)row{
    NSMutableArray *rows = [self getRowWithSection:section];
    return [rows objectAtIndex:row];
}

#pragma mark - <UITableViewDataSource>
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell       = nil;
    BOOL isSystem               = nil == _rowType;
    
    /// Get the reused cell
    if (isSystem) {
        cell = [tableView dequeueReusableCellWithIdentifier:kReuseRowDefault];
    }
    else{
        id<XXtableViewCellDelegate> xxcell  = [tableView dequeueReusableCellWithIdentifier:_rowType forIndexPath:indexPath];
        xxcell.tableViewShell       = self;
        xxcell.indexPath            = indexPath;
        cell                        = (UITableViewCell*)xxcell;
    }
    
   /// No reusable cells
    if (nil == cell) {
        if(isSystem){
            cell = [[UITableViewCell alloc] initWithStyle:_rowSystemStyle reuseIdentifier:kReuseRowDefault];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else{
            id<XXtableViewCellDelegate> xxcell  = [[NSClassFromString(_rowType) alloc] initWithReuseIdentifier:_rowType];
            xxcell.tableViewShell       = self;
            xxcell.indexPath            = indexPath;
            cell                        = (UITableViewCell*)xxcell;
        }
    }
    if(nil == cell){
        NSLog(@"[XXtableViewShell] Failure to create cell.");
        return cell;
    }
    
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    cell.imageView.image = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    for (UIView *view in cell.contentView.subviews) {
        if (view.tag == 998) {
            [view removeFromSuperview];
        }
    }
    
    /// Get the data of the corresponding row (cell)
    NSMutableArray *rowsData = [[_sectionDatas objectAtIndex:indexPath.section] objectForKey:kRow];
    id rowData = [rowsData objectAtIndex:indexPath.row];
    if(nil == rowData){
        return cell;
    }
    /// Set data
    if(isSystem){
        if([rowData isKindOfClass:[NSString class]]){
            cell.textLabel.text = rowData;
        }
        else if([rowData isKindOfClass:[NSDictionary class]]){
            NSDictionary *dict = rowData;
            if(nil != [dict objectForKey:kTitle]){
                cell.textLabel.text = dict[kTitle];
                //add by qin 20200921
                if ([[NSString stringWithString:[dict objectForKey:kTitle]] isEqualToString:NSLocalizedString(@"lblDeviceVersion", @"固件版本检测")] && self.haveRedDot) {
                    [_redDot removeFromSuperview];
                    [cell.contentView addSubview:self.redDot];
                }
                //end by qin 20200921
            }
            if(nil != [dict objectForKey:kDetail]){
                cell.detailTextLabel.text = dict[kDetail];
            }
            if(nil != [dict objectForKey:kImage]){
                cell.imageView.image = dict[kImage];
            }
            if(nil != [dict objectForKey:kAccessoryType]){
                cell.accessoryType = [dict[kAccessoryType] intValue];
            }
            if(nil != [dict objectForKey:kCellDisable]){
                BOOL disable = [dict[kCellDisable] boolValue];
                if (disable) {
                    [self addMask:cell];
                }else{
                    [self removeMask:cell];
                }
            }else{
                [self removeMask:cell];
            }
        }
        else{
            NSLog(@"[XXtableViewShell] Unknown type(%@) of row data(%@).", NSStringFromClass([rowData class]), rowData);
        }
    }
    else{
        id<XXtableViewCellDelegate> xxcell = (id<XXtableViewCellDelegate>)cell;
        [xxcell resetData:rowData];
    }
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSDictionary *sectionData = _sectionDatas[section];
    id headerData = [sectionData objectForKey:kHeader];
    if(nil == headerData){
        return nil;
    }
    else if([headerData isKindOfClass:[NSString class]]){
        return headerData;
    }
    else if([headerData isKindOfClass:[NSDictionary class]]){
        return [headerData objectForKey:kTitle];
    }
    else{
        return nil;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    NSDictionary *sectionData = _sectionDatas[section];
    id headerData = [sectionData objectForKey:kFooter];
    if(nil == headerData){
        return nil;
    }
    else if([headerData isKindOfClass:[NSString class]]){
        return headerData;
    }
    else if([headerData isKindOfClass:[NSDictionary class]]){
        return [headerData objectForKey:kTitle];
    }
    else{
        return nil;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableDictionary *sectionData = [_sectionDatas objectAtIndex:section];
    if(nil == sectionData){
        return 0;
    }
    NSArray *rowsData = [sectionData objectForKey:kRow];
    if(nil == rowsData){
        return 0;
    }
    return rowsData.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger count = self.sectionDatas ? self.sectionDatas.count : 0;
    if(self.emptyView){
        self.emptyView.hidden = 0!=count;
    }
    return count;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return _canSlideDelete || tableView.isEditing;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        BOOL toDelete = YES;
        if(_onRowEditingDelete){
            id data = [self getRowDataWithSection:(int)indexPath.section row:(int)indexPath.row];
            toDelete = _onRowEditingDelete(self,indexPath,data);
        }
        
        if(toDelete){
            [self removeRowAtIndexPath:indexPath];
        }
    }
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([[_sectionDatas objectAtIndex:section] objectForKey:kHeader]) {
        return tableView.sectionHeaderHeight==0 ? 30 : tableView.sectionHeaderHeight;
    }
    return 0;
}

#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_onRowClicked){
        NSMutableArray *rowsData    = [[_sectionDatas objectAtIndex:indexPath.section] objectForKey:kRow];
        id rowData                  = [rowsData objectAtIndex:indexPath.row];
        _onRowClicked(self, indexPath, rowData);
    }
}

#pragma mark - 其他

-(UILabel *)redDot{
    if (!_redDot) {
        _redDot = [[UILabel alloc]init];
        _redDot.frame = CGRectMake(kWidth - 45, 20, 10, 10);
        if ([NSLocalizedString(@"lanName", nil) isEqualToString:@"fa"] || [NSLocalizedString(@"lanName", nil) isEqualToString:@"ar"]) {
            _redDot.frame = CGRectMake(30, 20, 10, 10);
        }
        _redDot.text = @"●";
        _redDot.tag = 998;
        _redDot.font = [UIFont systemFontOfSize:10];
        _redDot.textColor = [UIColor redColor];

    }
    return _redDot;
}

-(void)addMask:(UITableViewCell *)cell{

    
    cell.contentView.alpha = 0.5;
    cell.userInteractionEnabled = NO;
}

-(void)removeMask:(UITableViewCell *)cell{
//    for (UIView *view in cell.contentView.subviews) {
//        if (view.tag == 998) {
//            [view removeFromSuperview];
//        }
//    }
    cell.contentView.alpha = 1;
    cell.userInteractionEnabled = YES;
}
@end

