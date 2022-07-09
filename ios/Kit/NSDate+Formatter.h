/**
 
 date to string
 
 */

#import <Foundation/Foundation.h>

@interface NSDate (Formatter)

/** Date string format: 1970-01-01 */
- (NSString *)dateString;

/** Time string format: 08:08:08 */
- (NSString *)timeString;

/** Time string format: 08:08 */
- (NSString *)timeStringNoSecond;

/** Date and time string format: 1970-01-01 08:08:08 */
- (NSString *)dateAndTimeString;

/** Set to 0:00:00 of the current date */
- (NSDate *)beginOfTheDay;

/** Set to the last second of the current date */
- (NSDate *)endOfTheDay;

/** Set to the last minute and 0 seconds of the current date*/
- (NSDate *)endOfTheDayZeroSecond;

/** Create a time in the specified time zone from a string Format: 1970-01-01 08:08:08 */
+ (instancetype)dateFromTimeString:(NSString *)string timeZone:(NSTimeZone *)zone;

/** Create time in local time zone from string Format: 1970-01-01 08:08:08 */
+ (instancetype)dateFromLocalTimeString:(NSString *)string;

/** Create Beijing time from string format: 1970-01-01 08:08:08 */
+ (instancetype)dateFromBeijingTimeString:(NSString *)string;



@end