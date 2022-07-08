#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DISPAIPUpdateLoop : NSObject
+ (void)start;
+ (void)stop;
+ (nullable NSArray<NSString*>*)getIPArray;
+ (NSDate*) lastUpdateTime;
@end

NS_ASSUME_NONNULL_END
