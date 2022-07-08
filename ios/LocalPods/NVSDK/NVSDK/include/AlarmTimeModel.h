//
//  AlarmTimeModel.h
//  datepicker
//
//  Created by 视宏 on 17/2/22.
//  Copyright © 2017年 视宏. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlarmTimeModel : NSObject

@property(nonatomic,strong) NSDate *beginTime;
@property(nonatomic,strong) NSDate *endTime;
@property(nonatomic,assign) BOOL isSelect;

@end
