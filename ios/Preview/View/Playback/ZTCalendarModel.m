//
//  ZTCalendarModel.m
//  iCamSee
//
//  Created by hs_mac on 2018/3/19.
//  Copyright © 2018年 Macrovideo. All rights reserved.
//

#import "ZTCalendarModel.h"

@interface ZTCalendarModel ()

@property (nonatomic, strong) NSCalendar *calendar;

@property (nonatomic, assign) NSInteger year; // year
@property (nonatomic, assign) NSInteger month; // month
@property (nonatomic, assign) NSInteger day; // day

@property (nonatomic, strong) NSMutableArray *dayArray;
@property (nonatomic, assign) NSInteger nLastMonthDays; // The number of days left in the previous month
@property (nonatomic, assign) NSInteger nNextMonthDays; // number of extra days in next month
@property (nonatomic, assign) NSInteger nMonthDays; // days of the month

@end

@implementation ZTCalendarModel

- (instancetype)init {
    if (self = [super init]) {
        // get the current time
        NSDate *currentDate = [NSDate date];
        self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *nowCompoents =[self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
        self.year = nowCompoents.year;
        self.month = nowCompoents.month;
        self.day = nowCompoents.day;
        self.dayArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithDate:(NSDate *)date{
    if (self = [super init]) {
        
        NSDate *currentDate= date;
        self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *nowCompoents =[self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
        self.year = nowCompoents.year;
        self.month = nowCompoents.month;
        self.day = nowCompoents.day;
        self.dayArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray *)setDayArr {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //current date
    NSDate *nowDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%ld-%ld-%ld",(long)_year,(long)_month,(long)_day]];
    // range of days in this month
    NSRange dayRange = [_calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:nowDate];
    // range of days in the previous month
    NSRange lastdayRange = [_calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[self setLastMonthWithDay]];
    // NSDate object for the first day of the month
    NSDate *nowMonthfirst = [dateFormatter dateFromString:[NSString stringWithFormat:@"%ld-%ld-%d",(long)_year,(long)_month,1]];
    // The first day of the month is the day of the week
    NSDateComponents *components = [_calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:nowMonthfirst];
    // NSDate object for the last day of the month
    NSDate *nextDay = [dateFormatter dateFromString:[NSString stringWithFormat:@"%ld-%ld-%ld",(long)_year,(long)_month,(long)dayRange.length]];
    NSDateComponents *lastDay = [_calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:nextDay];
    //The number of days left in the previous month
    for (NSInteger i = lastdayRange.length - components.weekday + 2; i <= lastdayRange.length; i++) {
        NSString * string = [NSString stringWithFormat:@"%ld",(long)i];
        [self.dayArray addObject:string];
    }
    self.nLastMonthDays = self.dayArray.count;
    //Total days of the month
    for (NSInteger i = 1; i <= dayRange.length ; i++) {
        NSString * string = [NSString stringWithFormat:@"%ld",(long)i];
        [self.dayArray addObject:string];
    }
    self.nMonthDays = self.dayArray.count - _nLastMonthDays;
    NSInteger temp = self.dayArray.count;
    //The number of days left in the next month
    for (NSInteger i = 1; i <= (7 - lastDay.weekday); i++) {
        NSString * string = [NSString stringWithFormat:@"%ld",(long)i];
        [self.dayArray addObject:string];
    }
    self.nNextMonthDays = self.dayArray.count - temp ; // final result
    
    self.index = components.weekday - 2 + self.day;
    self.block(_year, _month);
    return self.dayArray;
}

//Return the NSDate object of the first day of the month
- (NSDate *)firstDayDate {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = self.year;
    components.month = self.month;
    components.day = 1;
    return [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] dateFromComponents:components];
}

//Return the NSDate object of the first day of the previous month
- (NSDate *)setLastMonthWithDay {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * date = nil;
    
    if (self.month != 1) {
        date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%ld-%ld-%d",(long)self.year,(long)self.month-1,01]];
    }else{
        // The previous month of January is December of the previous year
        date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%ld-%d-%d",(long)self.year - 1,12,01]];
    }
    
    return date;
}

// data for the next month
- (NSArray *)nextMonthDataArr {
    [self.dayArray removeAllObjects];
    if (_month == 12) {
        _month = 1;
        _year ++;
    }else {
        _month ++;
    }
    if (_month < 8) {
        if (_month % 2 == 0 && _day > 30) {
            _day = 30;
        }
    }else {
        if (_month % 2 != 0 && _day > 30) {
            _day = 30;
        }
    }
    if (_month == 2) {
        if (_year % 4 == 0 && _day > 29) {
            _day = 29;
        }else if (_day > 28) {
            _day = 28;
        }
    }
    return [self setDayArr];
}

// last month's data
- (NSArray *)lastMonthDataArr {
    [self.dayArray removeAllObjects];
    if (_month == 1) {
        _month = 12;
        _year --;
    }else {
        _month --;
    }
    if (_month < 8) {
        if (_month % 2 == 0 && _day > 30) {
            _day = 30;
        }
    }else {
        if (_month % 2 != 0 && _day > 30) {
            _day = 30;
        }
    }
    if (_month == 2) {
        if (_year % 4 == 0 && _day > 29) {
            _day = 29;
        }else if (_day > 28) {
            _day = 28;
        }
    }
    return [self setDayArr];
}

//The number of days left in the previous month
- (NSInteger) lastMonthLestDays{
    
    return self.nLastMonthDays;
    
}
// number of days in the next month
- (NSInteger) nextMonthLestDays{
    
    return self.nNextMonthDays;
}
//days of the month
-(NSInteger)monthDays{
    
    return self.nMonthDays;
    
}

@end
