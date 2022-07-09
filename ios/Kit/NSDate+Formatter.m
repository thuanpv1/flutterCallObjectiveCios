

/**
 
date to string
 
 */

#import "NSDate+Formatter.h"

@implementation NSDate (Formatter)

// date string
- (NSString *)dateString {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    formatter.timeZone = [NSTimeZone localTimeZone];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    return [formatter stringFromDate:self];
}

// time string
- (NSString *)timeString {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    formatter.timeZone = [NSTimeZone localTimeZone];
    formatter.dateFormat = @"HH:mm:ss";
    
    return [formatter stringFromDate:self];
}

- (NSString *)timeStringNoSecond {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    formatter.timeZone = [NSTimeZone localTimeZone];
    formatter.dateFormat = @"HH:mm";
    
    return [formatter stringFromDate:self];
}

// date and time string
- (NSString *)dateAndTimeString {
    
    return [NSString stringWithFormat:@"%@ %@", [self dateString], [self timeString]];
}

// set to zero hour zero minute zero second of current date
- (NSDate *)beginOfTheDay {

    if (self == nil) {

        return nil;
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateString = [formatter stringFromDate:self];
    NSString *string = [dateString stringByAppendingString:@" 00:00:00"];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";

    return [formatter dateFromString:string];
}

// set to the last second of the current date
- (NSDate *)endOfTheDay {

    if (self == nil) {

        return nil;
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateString = [formatter stringFromDate:self];
    NSString *string = [dateString stringByAppendingString:@" 23:59:59"];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";

    return [formatter dateFromString:string];
}

// set to the last minute and 0 seconds of the current date
- (NSDate *)endOfTheDayZeroSecond{
    
    if (self == nil) {
        
        return nil;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateString = [formatter stringFromDate:self];
    NSString *string = [dateString stringByAppendingString:@" 23:59:00"];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    return [formatter dateFromString:string];
}

// Create the time in the specified time zone from a string
+ (instancetype)dateFromTimeString:(NSString *)string timeZone:(NSTimeZone *)zone {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    formatter.timeZone = zone;
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    return [formatter dateFromString:string];
}

// create the time in the local time zone from the string
+ (instancetype)dateFromLocalTimeString:(NSString *)string {
    
    return [self dateFromTimeString:string timeZone:[NSTimeZone localTimeZone]];
}

// Create Beijing time from string
+ (instancetype)dateFromBeijingTimeString:(NSString *)string {
    
    return [self dateFromTimeString:string timeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
}



@end
