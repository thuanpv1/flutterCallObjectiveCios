//
//  AlarmMessageManager.m
//  iCamSee
//
//  Created by macro on 2021/3/9.
//  Copyright © 2021 Macrovideo. All rights reserved.
//

#import "AlarmMessageManager.h"
#import "AlarmMessage.h"
#import "PushMessageUtils.h"
#import "DataBaseManager.h"
#import "NVCryptor.h"

@interface AlarmMessageManager (){
    
    BOOL isHasMoreInService;
}

@end

@implementation AlarmMessageManager

-(instancetype)init{
    
    self = [super init];
    if(self){

    }
    return self;
}

#pragma mark --------------------- 报警图片加载 -----------------------
//Get the latest news after a certain point in time
-(void)loadLatestAlarmMessageWithCurrentTime:(long long)lastTime device:(NVDevice *)device filterType:(AlarmMessageFilterType)filterType{
    
    self.currentLoadThreadID++;
    __block long long lLastGetTime_back;
    __block long long lBackFreshTime_back;
    
    long long m_lLastGetTime = lastTime;
        
    __block NSInteger threadID = self.currentLoadThreadID;   //Note the currently loaded ID
    
    [PushMessageUtils getLatestAlarmMessage:device lastGetTime:m_lLastGetTime resultBlock:^(long long lLastGetTime, long long lBackFreshTime, NSMutableArray *messageArray, NSError *error) {
    // return data
        if(threadID != self.currentLoadThreadID){
            return ;
        }
        
        if(!error){
            //return result
            if(messageArray != nil && messageArray.count > 0){
                if(messageArray.count == 5){
                    //There are more than 5 images
                    [self.alarmPicArray removeAllObjects];
                    self->isHasMoreInService = YES;
                }
                lLastGetTime_back = lLastGetTime;
                lBackFreshTime_back = lBackFreshTime;

                
                NSMutableArray *filterArray = [NSMutableArray arrayWithArray:messageArray];
                for (int i = 0; i < filterArray.count; i++) {
                    AlarmMessage *msg = filterArray[i];
                    if (![self checkMessage:msg filter:filterType]) {
                        [filterArray removeObject:msg];
                        i--;
                    }
                }
                
                [self pureArray:self.alarmPicArray new:filterArray];

                if(self.loadLatestPicCallback != nil){
                    self.loadLatestPicCallback([NSMutableArray arrayWithArray:self.alarmPicArray]);
                }
            }
            
            //(Refresh successfully), save the latest refresh time
            device.lLastGetTime = lLastGetTime;
            
        }else{
            // get failed
//            iToast *toast ;
            NSString *strtoast = nil;
            switch (error.code) {
                    
                case RESULT_CODE_FAIL_USERNAME_NOEXIST:
                {
                    strtoast = NSLocalizedString(@"User does not exist", "username error");
                }
                    break;
                case RESULT_CODE_FAIL_PASSWORD_ERROR:{
                    
                    strtoast = NSLocalizedString(@"Username or password error", "password error");
                    
                    
                }break;
                case RESULT_CODE_SUCCESS_NOTNEWMESSAGE:case RESULT_CODE_SUCCESS_NEWMESSAGE:{
                    
                    strtoast =NSLocalizedString(@"No new message", "no new message");
                    
                    
                }break;
                case RESULT_CODE_FAIL_CONNECT_SERVER_FAIL:{
                    strtoast = NSLocalizedString(@"connect fail", "connect fail");
                    
                }break;
                default:strtoast = NSLocalizedString(@"connect fail", "connect fail");
                    
                    break;
            }
//            toast = [iToast makeToast:strtoast];
//            [toast setToastPosition:kToastPositionCenter];
//            [toast setToastDuration:kToastDurationShort];
//            [toast performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
            
            if(self.loadLatestPicCallback != nil){
                
                self.loadLatestPicCallback([NSMutableArray array]);
            }
        }
    }];

}

//获取某个时间段的报警消息
-(void)loadAlarmMessageWithFromTime:(long long)fromTime toTime:(long long)toTime device:(NVDevice *)device filterType:(AlarmMessageFilterType)filterType{
    self.currentLoadThreadID++;
    long long lFromTime = fromTime;
    long long lToTime = toTime;
    int random = arc4random() % 10000;
    __block NSInteger threadID = self.currentLoadThreadID; //Note the currently loaded ID
    
    [PushMessageUtils getAlarmMessage:device fromTime:lFromTime toTime:lToTime resultBlock:^(long long lastFreshTime, NSMutableArray *messageArray, NSError *error) {
        if(threadID != self.currentLoadThreadID){
            return ;
        }
        if(!error){
                       
            // filter and sort
            NSMutableArray *filterArray = [NSMutableArray arrayWithArray:messageArray];
            for (int i = 0; i < filterArray.count; i++) {
                AlarmMessage *msg = filterArray[i];
                if (![self checkMessage:msg filter:filterType]) {
                    [filterArray removeObject:msg];
                    i--;
                }
            }
            
            [self pureArray:self.alarmPicArray new:filterArray];
            if(self.loadMorePicCallback != nil){
                self.loadMorePicCallback([NSMutableArray arrayWithArray:self.alarmPicArray]);
            }

        }else{
//            iToast *toast ;
            NSString *strtoast = nil;
            if (/*messageArray.count == 0 &&*/ error.code == -1004) {
                strtoast =NSLocalizedString(@"no more news", "no new message");
//                toast = [iToast makeToast:strtoast];
//                [toast setToastPosition:kToastPositionCenter];
//                [toast setToastDuration:kToastDurationShort];
//                [toast performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
            }
            
            
            if(self.loadMorePicCallback != nil){
                self.loadMorePicCallback(nil);
            }
        }
    }];
}


-(AlarmImageResult *)getLargeAlarmImage:(NVDevice *)device alarmMessage:(AlarmMessage *)alarmMessageInfo thumbnail:(int)thumbnail {
    
    AlarmImageResult *result = [PushMessageUtils getAlarmImage:device alarmMessage:alarmMessageInfo thumbnail:thumbnail];
    return result;
}


#pragma mark ------------ Array filtering and sorting ------------
- (void)reloadAlarmPicArray{
    [self.alarmPicArray removeAllObjects];
}

- (void)pureArray:(NSMutableArray *)old new:(NSArray *)new{
    
    NSMutableArray *noSameMsgArray = [NSMutableArray array];
    NSMutableArray *IDArray = [NSMutableArray array];
    // get all IDs of the old array
    for (AlarmMessage *msg in old) {
        [IDArray addObject:@(msg.nSaveID)];
    }
    // Traverse the data taken out, compare the ID, and add the ones that are not repeated to the array NO_SAME_MSG
    [noSameMsgArray removeAllObjects];
    for (AlarmMessage *newMsg in new) {
        if (![IDArray containsObject:@(newMsg.nSaveID)]) {
            // new image
            [noSameMsgArray addObject:newMsg];
        }
    }
    
    if(noSameMsgArray.count <= 0){
        NSSet *oldArraySet = [NSSet setWithArray:old];
        old = [NSMutableArray arrayWithArray:[[oldArraySet allObjects] mutableCopy]];
    }else{
        NSSet *arraySet = [NSSet setWithArray:noSameMsgArray];
        noSameMsgArray = [NSMutableArray arrayWithArray:[arraySet allObjects]];
        //Add to
        [old addObjectsFromArray:[noSameMsgArray mutableCopy]];
        //sort
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"llAlarmTime" ascending:NO];
        NSArray *sortArray = [old sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        //3. Re-copy the sorted array
        [old removeAllObjects];
        [old addObjectsFromArray:[sortArray mutableCopy]];
    }
    
    //Get the maximum and minimum time in the list
    if(old.count > 0){
        AlarmMessage *ms = old[0];
        self.MINTime = ms.llAlarmTime;
        self.MAXTime = ms.llAlarmTime;
        for (AlarmMessage *msg in old) {
            if(msg.llAlarmTime > self.MAXTime){
                self.MAXTime = msg.llAlarmTime;
            }
            if(msg.llAlarmTime < self.MINTime){
                self.MINTime = msg.llAlarmTime;
            }
            
        }
    }
}

//If the filter type is not all and does not match the alarm message type, return yes;
-(BOOL)checkMessage:(AlarmMessage *)msg filter:(AlarmMessageFilterType)filterType{
    switch ([msg nAlarmType]) {
        case ALARM_TYPE_MOTION:
            //Motion Detection
            if (filterType != AlarmMessageFilterTypeAll && filterType != AlarmMessageFilterTypeMove) {
                return NO;
            }
            break;
            
        case ALARM_TYPE_PIR:
            //PIR
            if (filterType != AlarmMessageFilterTypeAll && filterType != AlarmMessageFilterTypePIR) {
                return NO;
            }
            break;
        case ALARM_TYPE_HUMAN:
            // humanoid detection
            if (filterType != AlarmMessageFilterTypeAll && filterType != AlarmMessageFilterTypeHuman) {
                return NO;
            }
            break;
        case ALARM_TYPE_TEMPERATURE_HIGH:
            // High temperature abnormal alarm
            if (filterType != AlarmMessageFilterTypeAll && filterType != AlarmMessageFilterTypeHighTemp) {
                return NO;
            }
            break;
        case ALARM_TYPE_TEMPERATURE_LOW:
            // low temperature abnormal alarm
            if (filterType != AlarmMessageFilterTypeAll && filterType != AlarmMessageFilterTypeLowTemp) {
                return NO;
            }
            break;
        case ALARM_TYPE_CRY:
            //Cry detection alarm
            if (filterType != AlarmMessageFilterTypeAll && filterType != AlarmMessageFilterTypeCry) {
                return NO;
            }
            break;
        case ALARM_TYPE_SMOG:
            //Smoke detection alarm
            if (filterType != AlarmMessageFilterTypeAll && filterType != AlarmMessageFilterTypeSmoke) {
                return NO;
            }
            break;
        default:
            if (filterType != AlarmMessageFilterTypeAll) {
                return NO;
            }
            break;
    }
    return YES;
}

-(NSMutableArray *)alarmPicArray{
    if(_alarmPicArray == nil){
        _alarmPicArray = [NSMutableArray array];
    }
    return _alarmPicArray;
}


@end
