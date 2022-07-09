//
//  ZTPlayerVarDefine.h
//  demo
//
//  Created by hs_mac on 2018/3/16.
//  Copyright © 2018年 Macrovideo. All rights reserved.
//

#ifndef ZTPlayerVarDefine_h
#define ZTPlayerVarDefine_h

typedef NS_ENUM(NSInteger, PlayerMode) {
    
PlayerModeRealTime = 0, // real-time preview
    PlayerModePlayBack // Video playback
    
};

typedef NS_ENUM(NSInteger, RecordType) {
    
    RecordTypeSD = 1, // SD card
    RecordTypeOSS = 2, // cloud storage
};

typedef NS_ENUM(NSInteger,recShowType) {
    
    recShowTypeFileset = 1, // event set
    recShowTypeRuler // Timeline
    
};


#define RELOADALBUM      @"reloadAlbum"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)



#endif /* ZTPlayerVarDefine_h */
