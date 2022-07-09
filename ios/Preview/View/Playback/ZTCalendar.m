//
//  ZTCalendar.m
//  iCamSee
//
//  Created by hs_mac on 2018/3/19.
//  Copyright © 2018年 Macrovideo. All rights reserved.
//

#import "ZTCalendar.h"
#import "ZTCalendarCell.h"
#import "ZTCalendarModel.h"
#import "ZTPointInsideButton.h"
@interface ZTCalendar () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    
    
}

@property (nonatomic, strong) UICollectionView *calendarCollectView;
@property (nonatomic, strong) ZTCalendarModel *calendarModel;
@property (nonatomic, strong) NSArray *weekArray;
@property (nonatomic, strong) NSArray *dayArray;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) UILabel *titlelabel;
@property (nonatomic, strong) ZTPointInsideButton *backBtn;
@property (nonatomic, strong) NSMutableDictionary *mutDict;
@property (nonatomic, assign) NSInteger nLastMonthDays; // The number of days left in the previous month
@property (nonatomic, assign) NSInteger nNextMonthDays; // number of extra days in next month
@property (nonatomic, assign) NSInteger nMonthDays; // days of the month
@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger month;
@end

@implementation ZTCalendar

// 重写Init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
self.backgroundColor = [UIColor whiteColor]; // default color
        [self setupData]; // initialize data
        [self setupUI]; // initialize the interface
    }
    
    return self;
}

-(void) setupData{
    __weak typeof(self) weakSelf = self;
_weekArray = @[NSLocalizedString(@"Day", nil),NSLocalizedString(@"One", nil),NSLocalizedString(@"Two", nil),NSLocalizedString(@"Three", nil),NSLocalizedString(@"Four" , nil),NSLocalizedString(@"five", nil),NSLocalizedString(@"six", nil)];
    _calendarModel = [[ZTCalendarModel alloc] init];
    self.calendarModel.block = ^(NSUInteger year, NSUInteger month) {
        X_StrongSelf;
        strongSelf.titlelabel.text = [NSString stringWithFormat:@"%ld-%ld",(long)year,(long)month];
        strongSelf.year = year;
        strongSelf.month = month;
    };
    self.dayArray = [_calendarModel setDayArr];
    self.index = _calendarModel.index;
    self.selectedIndex = self.index;
    _mutDict = [NSMutableDictionary new];
}

-(void) setupUI{
    
    // record date
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = NSLocalizedString(@"Recording date", nil);
    textLabel.textColor = [UIColor grayColor];
    textLabel.font = [UIFont systemFontOfSize:16.0];
    textLabel.frame = CGRectMake(10, 0, 100, 40);
    [self addSubview:textLabel];
    
    _titlelabel.font = [UIFont systemFontOfSize:16.0];
    _titlelabel.frame = CGRectMake((self.bounds.size.width - 100)/2.0, 0, 100, 40);
    _titlelabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.titlelabel];
    
    CGFloat width = self.bounds.size.width/7.0;
    UIButton *lastBtn = [[UIButton alloc] initWithFrame:CGRectMake(_titlelabel.frame.origin.x - 15, (40 - 15)/2.0, 15, 15)];
    [lastBtn setImage:[UIImage imageNamed:@"previw_btn_nextmonth"] forState:UIControlStateNormal];
    [lastBtn addTarget:self action:@selector(lastMonthClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:lastBtn];
    
    UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_titlelabel.frame), (40 - 15)/2.0, 15, 15)];
    [nextBtn setImage:[UIImage imageNamed:@"previw_btn_premonth"] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextMonthClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextBtn];
    
    ZTPointInsideButton *backButton = [ZTPointInsideButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"btn_videodateback"] forState:UIControlStateNormal];
    backButton.frame = CGRectMake(self.frame.size.width - 20 - 10, (40 - 20)/2.0, 20, 20);
    [backButton addTarget:self action:@selector(btnBackClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backButton];
    self.backBtn = backButton;
    
    UIView *weekBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, self.frame.size.width, 30)];
    weekBgView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
    [self addSubview:weekBgView];
                                  
    
    for (int i = 0; i < [_weekArray count]; i ++) {
        UIButton *weekBtn = [[UIButton alloc] initWithFrame:CGRectMake(i * width, (30 - 20)/2.0, width, 20)];
        [weekBtn setTitle:_weekArray[i] forState:UIControlStateNormal];
        weekBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [weekBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [weekBgView addSubview:weekBtn];
    }
    
    UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
    flowlayout.minimumLineSpacing = 0;
    flowlayout.minimumInteritemSpacing = 0;
    _calendarCollectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(weekBgView.frame), self.bounds.size.width, self.bounds.size.height - CGRectGetMaxY(weekBgView.frame)) collectionViewLayout:flowlayout];
    _calendarCollectView.delegate = self;
    _calendarCollectView.dataSource = self;
    [_calendarCollectView registerClass:[ZTCalendarCell class] forCellWithReuseIdentifier:@"cell"];
    _calendarCollectView.backgroundColor = [UIColor colorWithRed:236/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
    self.calendarCollectView.alwaysBounceVertical = YES;
    [self addSubview:_calendarCollectView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_dayArray count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.bounds.size.width/7.0, self.bounds.size.width/7.0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ZTCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.dayArray[indexPath.row];
    if(indexPath.row >= _nLastMonthDays && indexPath.row < self.dayArray.count - _nNextMonthDays){
        cell.textLabel.textColor = [UIColor blackColor];
        cell.userInteractionEnabled = YES;
    }else{
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.userInteractionEnabled = NO;
    }
    
    
    if (self.index == indexPath.row && [self isCurrentMonth]) {
        
        cell.textLabel.layer.cornerRadius = cell.textLabel.frame.size.height/2.0;
        cell.textLabel.clipsToBounds = YES;
        cell.textLabel.layer.borderWidth = 0;
        if (self.index == self.selectedIndex) {
            cell.textLabel.backgroundColor = [UIColor orangeColor];
            cell.textLabel.textColor = [UIColor whiteColor];
        }else{
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.backgroundColor = [UIColor lightGrayColor];
            if (@available(iOS 12.0, *)) {
                if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    cell.textLabel.layer.borderWidth = 1;
                    cell.textLabel.layer.borderColor = [UIColor orangeColor].CGColor;
                    cell.textLabel.backgroundColor = [UIColor lightGrayColor];
                }else {
                    cell.textLabel.layer.borderWidth = 0;
                    cell.textLabel.backgroundColor = [UIColor lightGrayColor];
                }
            }
        }
        
    }else {
        
        cell.textLabel.layer.cornerRadius = cell.textLabel.frame.size.height/2.0;
        cell.textLabel.layer.borderWidth = 0.5;
        cell.textLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        cell.textLabel.clipsToBounds = YES;
        if ([self.mutDict valueForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
            
            cell.textLabel.backgroundColor = [UIColor orangeColor];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.layer.borderWidth = 0;
            cell.textLabel.layer.cornerRadius = cell.textLabel.frame.size.height/2.0;
            cell.textLabel.clipsToBounds = YES;
            
        }else {
            cell.textLabel.backgroundColor = [UIColor whiteColor];
            if (@available(iOS 12.0, *)) {
                if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    if(!(indexPath.row >= _nLastMonthDays && indexPath.row < self.dayArray.count - _nNextMonthDays)){
                        cell.textLabel.layer.borderWidth = 0;
                        cell.textLabel.backgroundColor = [UIColor clearColor];
                    }
                }else {
                    cell.textLabel.layer.borderWidth = 0.5;
                    cell.textLabel.backgroundColor = [UIColor whiteColor];
                }
            }
        }
        
    }
    
    return cell;
}

// 判断当前月份是否为最新月份
-(BOOL) isCurrentMonth{
    
    // 获取最新的月份
    NSDate *date        = [NSDate date];
    NSTimeZone *zone    = [NSTimeZone timeZoneWithName:@"UTC"];
    NSInteger interval  = [zone secondsFromGMTForDate:date];
    NSDate *localDate   = [date dateByAddingTimeInterval:interval];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:localDate];
    
    NSInteger currentMonth = [dateComponent month];
    if(currentMonth == _month){
        return YES;
    }
    
    return NO;
}



- (void)lastMonthClick {
    [self.mutDict removeAllObjects];
    self.dayArray = [self.calendarModel lastMonthDataArr];
    [self.calendarCollectView reloadData];
}

- (void)nextMonthClick {
    [self.mutDict removeAllObjects];
    self.dayArray = [self.calendarModel nextMonthDataArr];
    [self.calendarCollectView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.row;
    [self.mutDict removeAllObjects];
    [self.mutDict setValue:@"value" forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%ld-%ld-%@",(long)_year,(long)_month,self.dayArray[indexPath.row]]];
    self.itemClickAction(date);
    [self.calendarCollectView reloadData];
    [self removeFromSuperview];

}

- (UILabel *)titlelabel {
    if (!_titlelabel) {
        _titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - 60, 20, 120, 20)];
        _titlelabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titlelabel;
}

-(void)btnBackClick:(id)sender{
    
    [self removeFromSuperview];
    
}

-(void)setDayArray:(NSArray *)dayArray{
    
    _dayArray = dayArray;
    self.nLastMonthDays = [_calendarModel lastMonthLestDays];
    self.nNextMonthDays = [_calendarModel nextMonthLestDays];
    self.nMonthDays = [_calendarModel monthDays];
    
}

@end
