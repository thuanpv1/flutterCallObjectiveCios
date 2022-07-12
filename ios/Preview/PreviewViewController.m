//
//  PreviewViewController.m
//  demo
//
//  Created by admin on 2022/3/31.
//  Copyright © 2022 Macrovideo. All rights reserved.
//
#import "PreviewViewController.h"
#import "MultiPreviewPlayer.h"
#import "PreviewComponentManager.h"
#import "GlobleVar.h"
#import "PermissionManager.h"
#import "PresetViewPortrait.h"
#import "DataBaseManager.h"
#import "HVPTZView.h"
#import "PTZViewForMulti.h"
#import "NVPanoPlayerNormalViewController.h"
#import "AlbumListManager.h"
#define ShowingLayouts(target)  \
    NSArray *showingLayouts = @[    \
        [target.topAnchor constraintEqualToAnchor:self.player.view.bottomAnchor], \
        [target.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],\
        [target.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],\
        [target.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]\
    ];\

#define HiddenLayouts(target) \
    NSArray *hiddenLayouts = @[ \
        [target.topAnchor constraintEqualToAnchor:self.view.bottomAnchor],\
        [target.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],\
        [target.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],\
        [target.heightAnchor constraintEqualToConstant:400]\
    ];\


#define WeakSelf        __weak typeof(self) weakSelf = self;
#define StrongSelf      __strong typeof(weakSelf) strongSelf = weakSelf;
#define Strong(s,src)   __strong typeof(src) s = src;

typedef enum : NSUInteger {
    PTZTypeNone,
    PTZTypeFull,
    PTZTypeHorizontal,
    PTZTypeVertical,
} PTZType;

// MARK:channel info keyword
const static NSString * const kNVDevice = @"nvdevice";
const static NSString * const kMute = @"mute";
const static NSString * const kHD = @"hd";
const static NSString * const kLogining = @"logining";
const static NSString * const kPlaying = @"playing";
const static NSString * const kRecording = @"recording";
const static NSString * const kGroup = @"group"; // the group it is in
const static NSString * const kIndexOfGroup = @"indexOfGroup"; // number in the group
const static NSString * const kLoginHandle = @"loginHandle";

const static NSString * const kIsEmptyPassword = @"isEmptyPassword";
const static NSString * const kIsErrorPassword = @"isErrorPassword";
const static NSString * const kIsWaitFirstFrame = @"isWaitFirstFrame";

@interface PreviewViewController ()<MultiPreviewEvents,PreviewEvents>

//@property (nonatomic,strong) MultiPreviewPlayer *player;
@property (nonatomic,strong) NSMutableArray *deviceInfos;
@property (nonatomic,assign) int indexOfArray;
@property (nonatomic,assign) int groupIndex;
@property (nonatomic,assign) int indexOfGroup;

@property (nonatomic,assign) BOOL isOffline; // offline

@property (nonatomic,assign) BOOL isOnPano; // Panoramic device preview
@property (nonatomic, assign) BOOL isMultiPreview; //Whether it is in four pictures

@property (nonatomic,strong) NSMutableArray<PreviewComponentManager*> *componentManagers;

// MARK: state attribute
@property (nonatomic,assign) BOOL isPlaying; // playing
@property (nonatomic,assign) BOOL isMuted; // mute
@property (nonatomic,assign) BOOL isRecording; // recording
@property (nonatomic,assign) BOOL isHD; //

// MARK: page related
@property (nonatomic, assign) int currentPage; // current page, starting from 1
@property (nonatomic,assign) int pageCount; // current page count
// intercom
@property (nonatomic,strong) UIButton * talkSmallButtonPortrait;
@property (nonatomic,assign) BOOL isPushToTalk; // Whether the talkback is being held
// preset
@property (nonatomic,strong) PresetViewPortrait *presetViewPortrait;
// MARK: account related
@property(nonatomic,strong) DataBaseManager *databaseManager;
// PTZ
@property(nonatomic,strong) HVPTZView *axisPtzViewPortrait;
@property(nonatomic,strong) PTZViewForMulti *ptzViewPortrait;


@property (nonatomic,assign) BOOL isFromReplay; // whether to return from playback
@property (nonatomic,assign) BOOL isFromPhoto; // whether to return from photo album

@end

@implementation PreviewViewController

- (instancetype)initViewAllCamera:(NSArray<NVDevice*>*)devices isShowToolBtns: (BOOL) isShowToolBtns{
    self = [super init];
    if(self){
        int deviceIndex = 0;
        _isOnPano = NO;
        
        [self initPlayer];
        [self initChannelUI];
        if (isShowToolBtns) [self initToolButton];
        //[self initPtz];
        //[self initBottomButton];
        //[self initPresetPortrait];
       // Refresh the device information list
        NSMutableArray *deviceIDs = [NSMutableArray new];
        NSEnumerator *enumer = devices.objectEnumerator;
        NVDevice *device;
        NSMutableArray *deviceFull = [NSMutableArray new];
        int group = 0;
        int indexOfGroup = 0;
        while (nil != (device = enumer.nextObject)) {
            NSMutableDictionary *infoFull = [NSMutableDictionary new];
            infoFull[kNVDevice] = device;
            infoFull[kGroup] = @(group);
            infoFull[kIndexOfGroup] = @(indexOfGroup);
            infoFull[kMute] = @(YES);
            ++indexOfGroup;
            if(indexOfGroup >= 4){
                indexOfGroup = 0;
                ++group;
            }
            [deviceFull addObject:infoFull];
            [deviceIDs addObject:@(device.NDevID)];
        }
        _deviceInfos = deviceFull;
        _indexOfArray = deviceIndex; // the position of the device in the device list
        _groupIndex = deviceIndex / 4; // Which group the device is in
        _indexOfGroup = deviceIndex % 4; // The position of the device in the group
        
        int groupCount = (int)_deviceInfos.count / 4;
        if(_deviceInfos.count % 4){
            groupCount++;
        }
        int deviceCountInGrounp = _groupIndex+1 >= groupCount ? _deviceInfos.count % 4 : 4;
        if(0 == deviceCountInGrounp){
            deviceCountInGrounp = 4;
        }
        
       
       // device navigation bar title
        device = devices[deviceIndex];
        NSString *deviceName = nil == device.strName || 0 == device.strName.length ? [NSString stringWithFormat:@"%d", device.NDevID] : device.strName;
        self.title = deviceName;
       
        
        // update pagination
        [self updatePageWithDeviceIndex:deviceIndex onPano:NO];
        self.player.currentSelected = _indexOfGroup;
        [self.player pano:YES]; // view all cameras
        // update the channel control
        for (int i = 0; i < 4; i++) {
            if(i >= deviceCountInGrounp){
                break;
            }
            
            PreviewComponentManager *componentManager = (PreviewComponentManager*)self.componentManagers[i];
            int di = _groupIndex * 4 + i;
            device = devices[di];
            if(ONLINE_STAT_OFF == device.nOnlineStatus){
                if(i == _indexOfGroup) self.isOffline = YES;
                
                [componentManager hidden:NO control:PreviewComponentOffline];
                
                continue;
            }
            else if(i == _indexOfGroup){
                [componentManager updateConstraints:YES];
                [self startWithDeviceIndex:deviceIndex mute:YES hd:NO];
            }
            else{
                [componentManager hidden:NO control:PreviewComponentPlay];
            }
        }
        [_player pano:NO];
        
    }
    return self;
}

- (instancetype)initWithDevices:(NSArray<NVDevice*>*)devices atDeviceIndex:(int)deviceIndex{
    self = [super init];
    if(self){
        _isOnPano = NO;
        
        [self initPlayer];
        [self initChannelUI];
        [self initToolButton];
        [self initPtz];
        [self initBottomButton];
        [self initPresetPortrait];
       // Refresh the device information list
        NSMutableArray *deviceIDs = [NSMutableArray new];
        NSEnumerator *enumer = devices.objectEnumerator;
        NVDevice *device;
        NSMutableArray *deviceFull = [NSMutableArray new];
        int group = 0;
        int indexOfGroup = 0;
        while (nil != (device = enumer.nextObject)) {
            NSMutableDictionary *infoFull = [NSMutableDictionary new];
            infoFull[kNVDevice] = device;
            infoFull[kGroup] = @(group);
            infoFull[kIndexOfGroup] = @(indexOfGroup);
            infoFull[kMute] = @(YES);
            ++indexOfGroup;
            if(indexOfGroup >= 4){
                indexOfGroup = 0;
                ++group;
            }
            [deviceFull addObject:infoFull];
            [deviceIDs addObject:@(device.NDevID)];
        }
        _deviceInfos = deviceFull;
        _indexOfArray = deviceIndex; // the position of the device in the device list
        _groupIndex = deviceIndex / 4; // Which group the device is in
        _indexOfGroup = deviceIndex % 4; // The position of the device in the group
        
        int groupCount = (int)_deviceInfos.count / 4;
        if(_deviceInfos.count % 4){
            groupCount++;
        }
        int deviceCountInGrounp = _groupIndex+1 >= groupCount ? _deviceInfos.count % 4 : 4;
        if(0 == deviceCountInGrounp){
            deviceCountInGrounp = 4;
        }
        
       
       // device navigation bar title
        device = devices[deviceIndex];
        NSString *deviceName = nil == device.strName || 0 == device.strName.length ? [NSString stringWithFormat:@"%d", device.NDevID] : device.strName;
        self.title = deviceName;
       
        
        // update pagination
        [self updatePageWithDeviceIndex:deviceIndex onPano:NO];
        self.player.currentSelected = _indexOfGroup;
        [self.player pano:YES];

        // update the channel control
        for (int i = 0; i < 4; i++) {
            if(i >= deviceCountInGrounp){
                break;
            }
            
            PreviewComponentManager *componentManager = (PreviewComponentManager*)self.componentManagers[i];
            int di = _groupIndex * 4 + i;
            device = devices[di];
            if(ONLINE_STAT_OFF == device.nOnlineStatus){
                if(i == _indexOfGroup) self.isOffline = YES;
                
                [componentManager hidden:NO control:PreviewComponentOffline];
                
                continue;
            }
            else if(i == _indexOfGroup){
                [componentManager updateConstraints:YES];
                [self startWithDeviceIndex:deviceIndex mute:YES hd:NO];
            }
            else{
                [componentManager hidden:NO control:PreviewComponentPlay];
            }
        }
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];


}
- (void)viewWillAppear:(BOOL)animated{

    

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [self.player active:NO];
    [self returnAndreleaseAll];
    
}
- (void)returnAndreleaseAll{
 
    self.player.multiPreviewEvents = nil;
    self.player.previewEvents = nil;
    [self stopAll];
    [self.player resetDataAll];
    [self.player resetRowColumn:NO];
    [self.player active:NO];
    
    self.player.view.translatesAutoresizingMaskIntoConstraints = YES;
    [self.componentManagers removeAllObjects];
    
}

-(void)initPlayer{
    _player = [MultiPreviewPlayer new];
    _player.view.frame = CGRectMake(0, 64, kWidth, kWidth*9/16);
    _player.multiPreviewEvents  = self;
    _player.previewEvents       = self;
    [self.view addSubview:_player.view];
}

- (UIView*) getPlayerView {
    return _player.view;
}

-(void)initChannelUI{
    _componentManagers = [NSMutableArray new];
    for (int index = 0; index < 4; index++) {
        PreviewComponentManager *manager = [[PreviewComponentManager alloc] initWithSuperview:self.player.view index:index fitscreenButton:nil bottomBar:nil];
        
        X_WeakSelf
        manager.onTimeout = ^(int index) {
            dispatch_async(dispatch_get_main_queue(), ^{
                X_StrongSelf
                [strongSelf stopRecrod:YES];
            });
        };
        manager.onButtonClicked = ^(int index, PreviewComponent component) {
            dispatch_async(dispatch_get_main_queue(), ^{
                X_StrongSelf
                                
                
                int deviceIndex = [strongSelf getDeviceIndexWithPanoIndex:index onPano:strongSelf.isOnPano];
                NSMutableDictionary *info   = strongSelf.deviceInfos[deviceIndex];
                NVDevice *device            = (NVDevice *)info[kNVDevice];
                BOOL isHD                   = nil != info[kHD] && [info[kHD] boolValue];
                BOOL isMute                 = nil != info[kMute] && [info[kMute] boolValue];
                
                if(component == PreviewComponentEmptyPassword){
                    // empty password
                    
                }
                else if(component == PreviewComponentIncorrect){
                    NVDevice *device = strongSelf.deviceInfos[deviceIndex][kNVDevice];
                    //wrong password
                }
                else if(component == PreviewComponentConnectFaliure){
                    [strongSelf startWithDeviceIndex:deviceIndex mute:isMute hd:isHD];
                }
                else if(component == PreviewComponentPlay){
                    [strongSelf startWithDeviceIndex:deviceIndex mute:isMute hd:isHD];
                }else{
                        
                }
            });
        };
        [_componentManagers addObject:manager];
    }
}

-(void)initToolButton{
    UIStackView *stack = [[UIStackView alloc] init];
    stack.backgroundColor = [UIColor lightGrayColor];
    [stack setTranslatesAutoresizingMaskIntoConstraints:NO];
    stack.alignment = UIStackViewAlignmentFill;
    stack.distribution = UIStackViewDistributionEqualCentering;
    [self.view addSubview:stack];
    [stack.topAnchor constraintEqualToAnchor:self.player.view.bottomAnchor].active = YES;
    [stack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0].active = YES;
    [stack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0].active = YES;
    [stack.heightAnchor constraintEqualToConstant:50].active = YES;

  
    [stack addArrangedSubview:[self creatBtn:@"preview_btn_sd" selectImage:@"preview_btn_hd" tag:1000]];
    [stack addArrangedSubview:[self creatBtn:@"preview_btn_openvoice_white" selectImage:@"preview_btn_closevoice_white" tag:1001]];
    [stack addArrangedSubview:[self creatBtn:@"preview_btn_fourscreens" selectImage:@"preview_btn_singlescreen" tag:1002]];

    [stack addArrangedSubview:[self creatBtn:@"preview_btn_replay_gray" selectImage:@"preview_btn_replay_gray" tag:1003]];

}

-(void)initBottomButton{
    UIStackView *stack = [[UIStackView alloc] init];
    stack.backgroundColor = [UIColor lightGrayColor];
    [stack setTranslatesAutoresizingMaskIntoConstraints:NO];
    stack.alignment = UIStackViewAlignmentFill;
    stack.distribution = UIStackViewDistributionEqualCentering;
    [self.view addSubview:stack];
    [stack.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [stack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0].active = YES;
    [stack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0].active = YES;
    [stack.heightAnchor constraintEqualToConstant:100].active = YES;

  
    [stack addArrangedSubview:[self creatBtn:@"preview_btn_screenshot_gray" selectImage:@"preview_btn_screenshot_gray" tag:1004]];
    [stack addArrangedSubview:[self creatBtn:@"preview_btn_record_gray" selectImage:@"preview_btn_recording" tag:1005]];
//    [stack addArrangedSubview:[self creatBtn:@"preview_btn_intercom2_gray" selectImage:@"preview_btn_intercom2_gray" tag:1005]];
    //对讲
        [stack addArrangedSubview:self.talkSmallButtonPortrait];

    
    [stack addArrangedSubview:[self creatBtn:@"preview_btn_preset_gray" selectImage:@"preview_btn_preset_gray" tag:1006]];

    [stack addArrangedSubview:[self creatBtn:@"preview_preset_btn_edit_gray" selectImage:@"preview_preset_btn_edit_gray" tag:1007]];

}

-(void)toolAction:(UIButton*)sender{
    sender.selected = !sender.selected;
    switch (sender.tag) {
        case 1000:
            self.isHD = sender.selected;
            break;
        case 1001:
            self.isMuted = sender.selected;
            break;
        case 1002:
            [_player pano:!sender.selected];
            break;
        case 1003:
        {
            int panoIndex       = self.player.currentSelected;
            int deviceIndex     = [self getDeviceIndexWithPanoIndex:panoIndex onPano:self.isOnPano];
            NSMutableDictionary *info  = self.deviceInfos[deviceIndex];
            LoginHandle *handle = info[kLoginHandle];
            NVDevice    *device = info[kNVDevice];
            if([device isEqual:[NSNull null]] || device == nil ||
               [handle isEqual:[NSNull null]] || handle == nil ){
                return;
            }
            
            [self stopAll];
            _isFromReplay = YES;
            WeakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                StrongSelf;
                
                [strongSelf.player.view removeFromSuperview];
                strongSelf.player.view.translatesAutoresizingMaskIntoConstraints = YES;
                
                // enter playback
                    NVPanoPlayerNormalViewController *panoNormalPlayerVC = [[NVPanoPlayerNormalViewController alloc]init];
                    panoNormalPlayerVC.hidesBottomBarWhenPushed = YES;
                    panoNormalPlayerVC.device                   = device;
                    panoNormalPlayerVC.loginResult              = handle;
                    panoNormalPlayerVC.currentRecordType        = RecordTypeSD;
                    panoNormalPlayerVC.isFromMultiPreview               = YES;
                    [strongSelf.navigationController pushViewController:panoNormalPlayerVC animated:YES];
                strongSelf.player.previewEvents         = nil;
                strongSelf.player.multiPreviewEvents    = nil;
                NSLog(@"[####] [%@] enterReplayViewController", NSStringFromClass(self.class));
            });
        }
            break;
           //screenshot
        case 1004:
        {
            /// TODO:screenshot
            int panoIndex = self.player.currentSelected;
            UIImage *image = [self.player srceenShot:panoIndex];
            if (image) {

            }
            else{
                dispatch_after(1.f, dispatch_get_main_queue(), ^{
//                    iToast *toast = [iToast makeToast:@"Screenshot failed"];
//                    [toast setToastPosition:kToastPositionCenter];
//                    [toast setToastDuration:kToastDurationShort];
//                    [toast show];
                });
            }
        }
            break;
            //record
        case 1005:
        {
            /// TODO: Video
            if(!self.isOnPano){
// iToast *toast = [iToast makeToast:@"Please switch to single screen mode to use this function"];
// [toast setToastPosition:kToastPositionCenter];
// [toast setToastDuration:kToastDurationShort];
// [toast show];
// self.recordButtonPortrait.selected = NO;
// self.recordButtonLandscape.selected = NO;
            }
            else{
                if(sender.selected){
                    if(![self startRecord]){
// self.recordButtonPortrait.selected = NO;
// self.recordButtonLandscape.selected = NO;
                        
// iToast *toast = [iToast makeToast:@"This function is not currently supported"];
//                        [toast setToastPosition:kToastPositionCenter];
//                        [toast setToastDuration:kToastDurationShort];
//                        [toast show];
                    }
                }
                else{
                    [self stopRecrod:YES];
                }
            }
        }
;
            break;
            //preset
        case 1006:
        {
            
            int panoIndex = self.player.currentSelected;
            int deviceIndex = [self getDeviceIndexWithPanoIndex:panoIndex onPano:self.isOnPano];
            LoginHandle *handle = self.deviceInfos[deviceIndex][kLoginHandle];
            int deviceID = handle.nDevID;
            int ptzxCount = handle.nPTZXCount;

            NSArray *pics =  [self getPTZXImageWithDeviceID:deviceID];
            [self.presetViewPortrait reset:panoIndex deviceID:deviceID ptzxCount:ptzxCount ptzxs:pics];
            self.presetViewPortrait.hidden = NO;

        }
            break;
           //Album video
        case 1007:
        {
           
        }
            break;
        default:
            break;
    }

    
}

-(UIButton*)creatBtn:(NSString*)image selectImage:(NSString*)selectImage tag:(int)tag{
    UIButton *btn = [[UIButton alloc]init];
    [btn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:selectImage] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(toolAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = tag;
    return btn;
}

#pragma mark - Basic control interface such as start, stop, mute, record, etc.
-(void)startWithDeviceIndex:(int)deviceIndex{
    NSMutableDictionary *info = self.deviceInfos[deviceIndex];
    BOOL isHD   = nil != info[kHD] && [info[kHD] boolValue];
    BOOL isMute = nil != info[kMute] && [info[kMute] boolValue];
    [self startWithDeviceIndex:deviceIndex mute:isMute hd:isHD];
}
-(void)startWithDeviceIndex:(int)deviceIndex mute:(BOOL)mute hd:(BOOL)hd{
    if(nil == _deviceInfos || deviceIndex >= _deviceInfos.count){
        return;
    }
    
    NSMutableDictionary *info = _deviceInfos[deviceIndex];
    NVDevice *device = info[kNVDevice];
    info[kMute] = @(mute);
    info[kHD] = @(hd);
    
    LoginHandle *handle = info[kLoginHandle];
    BOOL isStretch = nil != handle && CAM_TYPE_NORMAL == handle.nCamType;
    int indexOfGroup = [info[kIndexOfGroup] intValue];
    int userID =0;
    NSString *method = @"login_local";
    NSString *password = device.strPassword;
    if (password.length>28) {
        password = [[device.strPassword MD5_EX] base64Encode];
    }
    [_player start:indexOfGroup
             lanIP:device.strServer
            netIPs:[GlobleVar getPanoIPs]
              port:device.nPort
          deviceID:device.NDevID
          username:nil==device.strUsername?@"":device.strUsername
          password:nil==password?@"":password
           channel: 0 // LAN can only be 0, Internet 1: HD, 0: SD (automatically controlled by the bottom layer)
        streamType:hd?STREAM_TYPE_HD:STREAM_TYPE_SMOOTH
              mute:mute || [self getCurrentDeviceIndex]!=deviceIndex // It is not the currently selected item, it must be muted, but you cannot start calling mute to add this judgment, because the value of info will be modified
           stretch:isStretch
          userInfo:@(deviceIndex)
     method:method
         accountId:userID];
    
}
-(void)startWithPanoIndex:(int)panoIndex mute:(BOOL)mute hd:(BOOL)hd{
    int deviceIndex = [self getDeviceIndexWithPanoIndex:panoIndex onPano:self.isOnPano];
    [self startWithDeviceIndex:deviceIndex mute:mute hd:hd];
    
}
-(BOOL)stopWithDeviceIndex:(int)deviceIndex{
    if(nil == _deviceInfos || deviceIndex >= _deviceInfos.count){
        return NO;
    }
    else{
        NSLog(@"[MultiPreviewVC] deviceIndex:%d,Execution is about to stop", deviceIndex);
    }

    NSMutableDictionary *info = _deviceInfos[deviceIndex];
    int indexOfGroup = [info[kIndexOfGroup] intValue];
    BOOL isPlaying = nil != info[kPlaying] && [info[kPlaying] boolValue];
    if(isPlaying){
        LoginHandle *loginHandle = info[kLoginHandle];
        UIImage *image = [self.player srceenShot:indexOfGroup];
        if (image && nil != loginHandle) {
   
        }
    }
    
   return [_player stop:indexOfGroup];
}
-(BOOL)stopWithPanoIndex:(int)panoIndex{
    
    int deviceIndex = [self getDeviceIndexWithPanoIndex:panoIndex onPano:self.isOnPano];
    return [self stopWithDeviceIndex:deviceIndex];
}

-(void)stopAll{
    [self stopWithPanoIndex:0];
    [self stopWithPanoIndex:1];
    [self stopWithPanoIndex:2];
    [self stopWithPanoIndex:3];

}
-(void)restartPlayerUserInfo:(id)userInfo atIndex:(int)index{
    int deviceIndex = [userInfo intValue];
    /// Calculate the actual number of device information
    if(deviceIndex < 0 || deviceIndex >= _deviceInfos.count){
        return;
    }
    NSMutableDictionary *info   = _deviceInfos[deviceIndex];
    int HD = [info[kHD] intValue];
    
    if(self.isRecording){
        [self stopRecrod:YES];
        int panoIndex = self.player.currentSelected;
        [self stopWithPanoIndex:panoIndex];
        [self startWithPanoIndex:panoIndex mute:self.isMuted hd:HD];
    }
    else{
        int panoIndex = index;
        [self stopWithPanoIndex:panoIndex];
        [self startWithPanoIndex:panoIndex mute:self.isMuted hd:HD];
    }
}
-(void)mute:(BOOL)mute atPanoIndex:(int)panoIndex{
    int deviceIndex = [self getDeviceIndexWithPanoIndex:panoIndex onPano:self.isOnPano];
    self.deviceInfos[deviceIndex][kMute] = @(mute);
    [self.player mute:mute atIndex:panoIndex];
}
-(BOOL)startRecord{
    int panoIndex = self.player.currentSelected;
    int deviceIndex = [self getDeviceIndexWithPanoIndex:panoIndex onPano:self.isOnPano];
    NSMutableDictionary *info = self.deviceInfos[deviceIndex];
    NVDevice *device = info[kNVDevice];

    NSDateFormatter *recordDateFormatter = [NSDateFormatter new];
    recordDateFormatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *dateString = [recordDateFormatter stringFromDate:[NSDate date]];
    NSString *videoName = [NSString stringWithFormat:@"%@(%i).mp4",dateString, device.NDevID];
    //Video path Documents/xx/xxx
    NSString *recordFilePath = [KAlbumVideoPath stringByAppendingPathComponent:videoName];

    NSString *imageName = [AlbumListManager genRecordFaceImageName];
    //Thumbnail path Documents/xx/xxx
    NSString *recordImagePath    = [KAlbumVideoFacePath stringByAppendingPathComponent:imageName];
    
    
    BOOL ret = [self.player startRecord:panoIndex videoPath:recordFilePath imagePath:recordImagePath];
    if(ret){
        info[kRecording] = @(YES);
        self.isRecording = YES;
    }
    return ret;
}
-(void)stopRecrod:(BOOL)save{
    int panoIndex = self.player.currentSelected;
    int deviceIndex = [self getDeviceIndexWithPanoIndex:panoIndex onPano:self.isOnPano];
    NSMutableDictionary *info = self.deviceInfos[deviceIndex];
    
    info[kRecording] = @(NO);
    self.isRecording = NO;
    
    BOOL saveSucceed = [self.player stopRecord:YES atIndex:panoIndex];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(saveSucceed){
// iToast *toast = [iToast makeToast: @"The video has been saved to the album"];
// [toast setToastPosition:kToastPositionCenter];
// [toast setToastDuration:kToastDurationShort];
// [toast show];
        }
        else{
            NSString *msg = [NSString stringWithFormat:@"%@:%@",@"Save the video failed",@"Failed to save"];
//            iToast *toast = [iToast makeToast:msg];
//            [toast setToastPosition:kToastPositionCenter];
//            [toast setToastDuration:kToastDurationShort];
//            [toast show];
        }
    });
}

-(void)updatePageWithDeviceIndex:(int)deviceIndex onPano:(BOOL)pano{
    if(pano){
        self.pageCount = (int)(self.deviceInfos.count);
        self.currentPage = deviceIndex + 1;
    }
    else{
        self.pageCount = (int)(self.deviceInfos.count / 4 + (self.deviceInfos.count % 4 > 0 ? 1 : 0));
        self.currentPage = deviceIndex / 4 + 1;
    }
}
-(int)getCurrentDeviceIndex{
    return [self getDeviceIndexWithPanoIndex:self.player.currentSelected onPano:self.isOnPano];
}
-(int)getDeviceIndexWithPanoIndex:(int)panoIndex onPano:(BOOL)pano{
    int deviceIndex = pano ? (self.currentPage-1)/4*4+panoIndex : (self.currentPage-1) * 4 + panoIndex;
    if(deviceIndex >= _deviceInfos.count){
        return -1;
    }
    return deviceIndex;
}

- (void)setIsHD:(BOOL)isHD{
    if(_isHD == isHD) return;
    _isHD = isHD;

    int panoIndex = self.player.currentSelected;
    [self stopWithPanoIndex:panoIndex];
    [self startWithPanoIndex:panoIndex mute:self.isMuted hd:isHD];
}

- (void)setIsMuted:(BOOL)isMuting{
    if(_isMuted == isMuting) return;
    _isMuted = isMuting;
    
    int panoIndex = self.player.currentSelected;
    int deviceIndex = [self getDeviceIndexWithPanoIndex:panoIndex onPano:self.isOnPano];
    self.deviceInfos[deviceIndex][kMute] = @(isMuting);
    [self.player mute:isMuting atIndex:panoIndex];
}
#pragma mark - Protocol function: <PreviewEvents>
- (void) previewIdle:(BOOL)isIdle userInfo:(nullable id)userInfo atIndex:(int)index{
    int deviceIndex = [userInfo intValue];
    
    if(isIdle){
        [_componentManagers[index] hidden:NO control:PreviewComponentConnectingGif];
    }
}
- (void) previewCameraType:(int)cameraType timestamp:(int64_t)timestamp userInfo:(nullable id)userInfo atIndex:(int)index{
    
    int deviceIndex             = [userInfo intValue];
    NSMutableDictionary *info   = self.deviceInfos[deviceIndex];
    
    BOOL isPlaying              = nil != info[kPlaying] && [info[kPlaying] boolValue];
    if(!isPlaying){
        NSLog(@"[MultiPreviewVC] [⚠️] index:%d stop failed", index);
    }
}
- (void) previewLoginHandle:(LoginHandle*)handle loginError:(NSError*)error userInfo:(nullable id)userInfo atIndex:(int)index{
    int deviceIndex = [userInfo intValue];
    NSLog(@"[MultiPreviewVC] previewIndex:%d deviceIndex:%d loginError:%@ (%@) (%@)", index, deviceIndex, error, self, [NSThread currentThread]);
    /// Calculate the actual number of the device information
    if(deviceIndex < 0 || deviceIndex >= _deviceInfos.count){
        return;
    }
    NSMutableDictionary *info   = _deviceInfos[deviceIndex];
    info[kLogining]             = @(NO);
    info[kIsWaitFirstFrame]     = @(NO);
    NVDevice *device = info[kNVDevice];
    
    if(error && MultiPlayerErrorWeakPassword != error.code && MultiPlayerErrorEmptyPassword != error.code){
        
        // hide the connecting icon
        [_componentManagers[index] hidden:YES control:PreviewComponentConnectingGif];
        
        if(MultiPlayerErrorEmptyPassword == error.code){

                /// change Password
                [_componentManagers[index] hidden:NO control:PreviewComponentEmptyPassword];
                info[kIsEmptyPassword] = @(YES);

        }
        else if(MultiPlayerErrorUsernameOrPasswordIncorrect == error.code){
            /// Please re-enter password
            [_componentManagers[index] hidden:NO control:PreviewComponentIncorrect];
            info[kIsErrorPassword] = @(YES);
        }
        else if(MultiPlayerErrorLoginFailure == error.code){
            /// Login failed
            NVDevice *device = self.deviceInfos[deviceIndex][kNVDevice];
            
            if(ONLINE_STAT_OFF == device.nOnlineStatus){
                if(self.player.currentSelected == index) self.isOffline = YES;
                [_componentManagers[index] hidden:NO control:PreviewComponentOffline];
            }
            else{
                [_componentManagers[index] hidden:NO control:PreviewComponentConnectFaliure];
                
            }
        }
        else{
            /// Unknown error code
            return;
        }
        
        /// FIXME: If it is currently selected, update the state of the panel control, but if there is a page-cutting function, the current login return may be invalid, and additional judgment is required
        if(index == self.player.currentSelected){
    
        }
    }
    else{

        /// Save the login handle, if it is not a normal lens type (360 or 180 lens), you need to use HD
        info[kLoginHandle]      = handle;
        info[kIsErrorPassword]  = @(NO);
        info[kIsErrorPassword]  = @(NO);
        info[kIsWaitFirstFrame] = @(YES);
        
        int cameraType = handle.nCamType;
        if(cameraType != CAM_TYPE_NORMAL){
            info[kHD] = @(YES);
        }
                        
       /// Update the panel state
        if(self.player.currentSelected == index){
            /// Update mute
            self.isMuted = nil != info[kMute] && [info[kMute] boolValue];
            /// Update the gimbal
            if(nil == handle || 0 == handle.bPTZ_PRI){
//                self.ptzType = PTZTypeNone;
            }
            else{
                if(3 == (handle.ptzType&0x03)){
                    //self.ptzType = PTZTypeVertical;
                }
                else if(2 == (handle.ptzType&0x02)){
                    //self.ptzType = PTZTypeHorizontal;
                }
                else if(1 == (handle.ptzType&0x01)){
                    //self.ptzType = PTZTypeFull;
                }else{
                    //self.ptzType = PTZTypeFull;
                }
                
                if(4 == (handle.ptzType&0x04)){
                   //Support gimbal calibration
                }
               
            }
            ///Update the standard HD status
            self.isHD = nil!=info[kHD] && [info[kHD] boolValue];

        }else{
      
        }
        
        X_WeakSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            X_StrongSelf
            
            /// If it is an ordinary lens, it needs to be stretched or adapted
            BOOL isStetch = CAM_TYPE_NORMAL == cameraType ;
            [strongSelf.player stretch:isStetch atIndex:index];
        });
    }
}
- (void) previewOldState:(MultiPlayerState)oldState newState:(MultiPlayerState)newState userInfo:(nullable id)userInfo atIndex:(int)index{
   
    int deviceIndex = [userInfo intValue];
    NSLog(@"[#] [MultiPreviewVC] previewIndex:%d deviceIndex:%d oldState:%d --> newState:%d (%@)", index, deviceIndex, (int)oldState, (int)newState, self);

    if(oldState == MultiPlayerState_Connecting){
        [_componentManagers[index] hidden:YES control:PreviewComponentConnectingGif];
    }
    else if(oldState == MultiPlayerState_Buffering){
        [_componentManagers[index] hidden:YES control:PreviewComponentConnectingGif];
    }
    else if(oldState == MultiPlayerState_Playing){
        
    }
    else if(oldState == MultiPlayerState_Paused){
        
    }
    else if(oldState == MultiPlayerState_Stopped){
        [_componentManagers[index] hidden:YES control:PreviewComponentPlay];
        [_componentManagers[index] hidden:YES control:PreviewComponentIncorrect];
        [_componentManagers[index] hidden:YES control:PreviewComponentEmptyPassword];
        [_componentManagers[index] hidden:YES control:PreviewComponentConnectFaliure];
        [_componentManagers[index] hidden:YES control:PreviewComponentOffline];
    }
    else{
        
    }
    
    if(newState == MultiPlayerState_Connecting){
        [_componentManagers[index] hidden:NO control:PreviewComponentConnectingGif];
        self.deviceInfos[deviceIndex][kLogining] = @(YES);
        if(index == self.player.currentSelected){
            
        }
    }
    else if(newState == MultiPlayerState_Buffering){
        [_componentManagers[index] hidden:NO control:PreviewComponentConnectingGif];
        self.deviceInfos[deviceIndex][kLogining] = @(NO);
        if(index == self.player.currentSelected){
            
        }
    }
    else if(newState == MultiPlayerState_Playing){
        NSMutableDictionary *info = self.deviceInfos[deviceIndex];
        info[kIsWaitFirstFrame] = @(NO);
        if(nil == info[kPlaying] || ![info[kPlaying] boolValue]){
            info[kPlaying] = @(YES);
            if(self.player.currentSelected == index){
                /// set to play
                self.isPlaying = YES;
                LoginHandle *handle = info[kLoginHandle];

            }
        }
    }
    else if(newState == MultiPlayerState_Paused){

    }
    else if(newState == MultiPlayerState_Stopped){
        // reset the channel property state
        NSMutableDictionary *info = self.deviceInfos[deviceIndex];
        info[kPlaying] = @(NO);
        info[kLogining] = @(NO);
        info[kIsWaitFirstFrame] = @(NO);

        // Reset the display state of the channel control
        PreviewComponentManager *manager = self.componentManagers[index];
        [manager hidden:YES control:PreviewComponentTimestamp];
        [manager hidden:NO control:PreviewComponentPlay];

        
        // Hide the channel control interface popup and disable other controls
        if(index == self.player.currentSelected){
          
            self.isPlaying = NO;
            
//            if(self.isPushToTalk){
//                [self onTalkEnd:nil];
//            }
        }
    }
    else{
        
    }
}


#pragma mark - 协议函数: <MultiPreviewEvents>
- (BOOL) multiPreviewCanSelectedAtIndex:(int)index{
 
    int deviceIndex = [self getDeviceIndexWithPanoIndex:index onPano:self.isOnPano];
    if(deviceIndex >= self.deviceInfos.count){
        return NO;
    }
    
    if(_isRecording){
        NSString *messgae = NSLocalizedString(@"noticeMsgStopAndbackButRecording", nil);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:messgae preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"btnCancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
        X_WeakSelf
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"btnOK", @"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            X_StrongSelf
            [strongSelf stopRecrod:YES];
            strongSelf.player.currentSelected = index;
        }];
        
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    else{
        return YES;
    }
}
- (BOOL) multiPreviewCanPanoONAtIndex:(int)index{

    int deviceIndex = [self getDeviceIndexWithPanoIndex:index onPano:self.isOnPano];
    if(deviceIndex >= self.deviceInfos.count){
        return NO;
    }
    return YES;
}
- (BOOL) multiPreviewCanPanoOFFAtIndex:(int)index{

    return NO;
}
- (void) multiPreviewCurrentSelected:(int)current previousSelected:(int)previous{
   
    if(previous>=0){
        [self.player mute:YES atIndex:previous];
        
//        if(self.isPushToTalk){
//            [self onTalkEnd:nil];
//        }
        [self.player stopTalk:previous];
    }
    
    if(current>=0){
        int deviceIndex = [self getDeviceIndexWithPanoIndex:current onPano:self.isOnPano];
        NSMutableDictionary *info = self.deviceInfos[deviceIndex];
        
        BOOL isMute = nil != info[kMute] && [info[kMute] boolValue];
        [self.player mute:isMute atIndex:current];
        
        LoginHandle *handle         = info[kLoginHandle];
        BOOL isPlaying      = nil != info[kPlaying] && [info[kPlaying] boolValue];
        BOOL isHD           = nil != info[kHD] && [info[kHD] boolValue];
        BOOL isRecording    = nil != info[kRecording] && [info[kRecording] boolValue];
        BOOL isNormalCamera = handle.nCamType == CAM_TYPE_NORMAL;
        BOOL isOffline      = [info[kNVDevice] nOnlineStatus] == ONLINE_STAT_OFF;
        BOOL isLogining     = nil != info[kLogining] && [info[kLogining] boolValue];
        BOOL isWaitFirstFrame = nil != info[kIsWaitFirstFrame] && [info[kIsWaitFirstFrame] boolValue];
        self.isPlaying = isPlaying;
        
        if(isPlaying){
            // update stream state
            self.isHD = isHD;
            // update mute state
            self.isMuted = isMute;
            // update the recording status
            self.isRecording = isRecording;
            // update gimbal
//            if(nil == handle || 0 == handle.bPTZ_PRI){
//                self.ptzType = PTZTypeNone;
//            }
//            else{
//                if(3 == (handle.ptzType&0x03)){
//                    self.ptzType = PTZTypeVertical;
//                }
//                else if(2 == (handle.ptzType&0x02)){
//                    self.ptzType = PTZTypeHorizontal;
//                }
//                else if(1 == (handle.ptzType&0x01)){
//                    self.ptzType = PTZTypeFull;
//                }else{
//                    self.ptzType = PTZTypeFull;
//                }
//
//                if(4 == (handle.ptzType&0x04)){
//                    //支持云台校准
//                    _isSupportPTZinit = YES;
//                }
//
//            }
        
           // If it is playing, cancel the offline state
            self.isOffline = NO;
           
        }
        else{
            // Standard HD
            self.isHD = isHD;
            // mute
            self.isMuted = isMute;
            // offline state
            self.isOffline = isOffline;
           
            
            BOOL isEmptyPassword = nil != info[kIsEmptyPassword] && [info[kIsEmptyPassword] boolValue];
            BOOL isErrorPassword = nil != info[kIsErrorPassword] && [info[kIsErrorPassword] boolValue];
            if(isLogining || isWaitFirstFrame){
               
            }
            else if(isEmptyPassword || isErrorPassword){
              
            }
            else{
            }
        }
        
        // 云台
//        if(nil == handle || 0 == handle.bPTZ_PRI){
//            self.ptzType = PTZTypeNone;
//        }
//        else{
//            if(3 == (handle.ptzType&0x03)){
//                self.ptzType = PTZTypeVertical;
//            }
//            else if(2 == (handle.ptzType&0x02)){
//                self.ptzType = PTZTypeHorizontal;
//            }
//            else if(1 == (handle.ptzType&0x01)){
//                self.ptzType = PTZTypeFull;
//            }else{
//                self.ptzType = PTZTypeFull;
//            }
//
//            if(4 == (handle.ptzType&0x04)){
//                //支持云台校准
//            }
//        }
       
        // Update navbar title
        NVDevice *device = info[kNVDevice];
        NSString *deviceName = nil == device.strName || 0 == device.strName.length ? [NSString stringWithFormat:@"%d", device.NDevID] : device.strName;
        self.title = deviceName;
        
    }
}
#pragma mark - 私有函数: 对讲
-(void)onTalkBegin:(id)sender{

    self.isPushToTalk = YES;
    [PermissionManager checkRecordPermission:^(BOOL isPermission) { //add by xys 20201229 Access to unified management rights
        if (isPermission && self.isPushToTalk == YES) {
       
            [self.talkSmallButtonPortrait setImage:[UIImage imageNamed:@"preview_btn_intercoming2_gray"] forState:UIControlStateNormal];
            
            NSError *error = [self.player startTalk:self.player.currentSelected];
            if(error && error.code == -1002){
                self.isPushToTalk = NO;
// iToast *toast = [iToast makeToast:@"This function is not currently supported"];
//                [toast setToastPosition:kToastPositionCenter];
//                [toast setToastDuration:kToastDurationShort];
//                [toast show];
                return;
            }
        }
    }];
    
    
}
-(void)onTalkEnd:(id)sender{
    NSLog(@"[MultiPreviewVC] onTalkEnd");
    self.isPushToTalk = NO;
    [self.talkSmallButtonPortrait setImage:[UIImage imageNamed:@"preview_btn_intercom2_gray"] forState:UIControlStateNormal];
    [self.player stopTalk:self.player.currentSelected];
}


#pragma mark - 私有函数: 预置位
-(void)setPTZXIndex:(int)index ptzxID:(int)ptzxID deviceID:(int)deviceID image:(UIImage*)image{
    WeakSelf
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{//note for temp
        StrongSelf
        int bResult = [strongSelf.player resetPTZX:ptzxID atIndex:index action:NV_PRESET_ACTION_RESET];
        if (bResult) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf updatePTZXImage:ptzxID deviceID:deviceID image:image];
                [strongSelf.presetViewPortrait reset:image atIndex:ptzxID];
                
//                iToast *toast = [iToast makeToast:@"set successfully"];
//                [toast setToastPosition:kToastPositionCenter];
//                [toast setToastDuration:kToastDurationShort];
//                [toast show];
            });
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
//                iToast *toast = [iToast makeToast:NSLocalizedString(@"lblLocationFail", @"Position setting fail")];
//                [toast setToastPosition:kToastPositionCenter];
//                [toast setToastDuration:kToastDurationShort];
//                [toast show];
            });
        }
    });
}

-(BOOL)updatePTZXImage:(int)ptzxID deviceID:(int)deviceID image:(UIImage *)image{
    NSData *data = UIImageJPEGRepresentation(image, 0.6);
    if (data) {
        if ([self.databaseManager isPTZXPicExist:deviceID ID:ptzxID]) {
            [self.databaseManager updatePTZXPic:ptzxID devid:deviceID data:data];
        }else{
            [self.databaseManager addPTZXPicture:ptzxID devid:deviceID data:data];
        }
    }
    return YES;
}

-(NSArray<PTZXPicture*>*)getPTZXImageWithDeviceID:(int)deviceID{
    return [self.databaseManager getPTZXPicByDevID:deviceID];
}





- (void) multiPreviewPanoON:(BOOL)on atIndex:(int)index{
    
    NSLog(@"[MultiPreviewVC] index:%d switch to %@ (%@)%d", index, on?@"Single screen":@"Multi-screen", self,self.isMultiPreview);
    int deviceIndex;
    BOOL isPanoSwap = NO;
    if(_isOnPano == on){
        isPanoSwap = YES;
        deviceIndex = [self getDeviceIndexWithPanoIndex:index onPano:on];
                
        self.isMultiPreview = !on;

    }
    else{
        _isOnPano = on;
        deviceIndex = [self getDeviceIndexWithPanoIndex:index onPano:!on];
        if(deviceIndex < 0){
            return;
        }
        [self updatePageWithDeviceIndex:deviceIndex onPano:on];
        
        self.isMultiPreview = !on;
        
    }
        
    for (int i = 0; i < 4; i++) {
        PreviewComponentManager *manager = _componentManagers[i];
        [manager updateConstraints:on];
        NSLog(@"[MultiPreviewVC] [###] update channel constraint index:%d (%@)", i, self);

        int targetDeviceIndex = [self getDeviceIndexWithPanoIndex:i onPano:on];
        if(targetDeviceIndex < 0){
            break;
        }
        NSDictionary *deviceInfo = self.deviceInfos[targetDeviceIndex];
        
        if(on && index == i){
          
        }
        else{
            [manager hidden:YES control:PreviewComponentWifi];
            [manager hidden:YES control:PreviewComponentBattery];
        }
        
    }
    
    if(on){
        NSMutableDictionary *info = [self.deviceInfos objectAtIndex:deviceIndex];
        LoginHandle *handle = info[kLoginHandle];
        if(nil != handle){
            [self.player panoType:0 atIndex:index];
            [self.player panoMode:13 atIndex:index];
        }
        
        BOOL isPlaying = nil != info[kPlaying] && [info[kPlaying] boolValue];
        if(!isPlaying){
            X_WeakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                X_StrongSelf;
                [strongSelf.player repaint];
            });
        }
    
    }
    else{
  
    }
    
    int currentPanoIndex = index;
    for (int panoIndex = 0; panoIndex < 4 && !isPanoSwap; panoIndex++) {
        if(currentPanoIndex == panoIndex){
            NSLog(@"[MultiPreviewVC] The current index is: %d, no action is required", index);
            continue;
        }
        
        int indexOffset = panoIndex - currentPanoIndex;
        int targetDeviceIndex = deviceIndex + indexOffset;
        
        if(on){
            NSLog(@"[MultiPreviewVC] The current index is: %d The target index is: %d The target deviceIndex is: %d Execute the preview", index, panoIndex, targetDeviceIndex);
            [self stopWithDeviceIndex:targetDeviceIndex];
        }
        else{
            if(targetDeviceIndex >= self.deviceInfos.count){
                NSLog(@"[MultiPreviewVC] current index is: %d target index is: %d target deviceIndex is: %d is an invalid device", index, panoIndex, targetDeviceIndex);
                //self.componentManagers[panoIndex].shamHiddenAll = YES;
            }
            else{
                NSLog(@"[MultiPreviewVC] current index is:%d target index is:%d target deviceIndex is:%d execution stop preview", index, panoIndex, targetDeviceIndex);
                [self startWithDeviceIndex:targetDeviceIndex mute:YES hd:NO];
            }
        }
    }
}

-(void)initPresetPortrait{
    _presetViewPortrait = [[NSBundle mainBundle] loadNibNamed:@"PresetViewPortrait" owner:nil options:nil].lastObject;
    _presetViewPortrait.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_presetViewPortrait];
    
    ShowingLayouts(_presetViewPortrait);
    HiddenLayouts(_presetViewPortrait);
    _presetViewPortrait.showingLayouts = showingLayouts;
    _presetViewPortrait.hiddenLayouts = hiddenLayouts;
    _presetViewPortrait.viewController = self;
    _presetViewPortrait.hidden = YES;
    
    WeakSelf
    _presetViewPortrait.onChanged = ^(int panoIndex, int deviceID, int ptzxID, PresetAction action) {
        StrongSelf
        if(PresetActionReset == action){
            UIImage *image = [strongSelf.player srceenShot:panoIndex];
            [strongSelf setPTZXIndex:panoIndex ptzxID:ptzxID deviceID:deviceID image:image];
        }
        else if(PresetActionCall == action){
            [strongSelf.player callPTZX:ptzxID action:NV_PRESET_ACTION_LOCATION atIndex:panoIndex];
            //add by qin 20201214 View the preset position and restore the locally enlarged page
            [strongSelf.player panoRectResetZoom];
        }
        else if(PresetActionDelete == action){
            [strongSelf.databaseManager removePTZXPic:ptzxID devid:deviceID];
        }
        else{
            
        }
    };
}

-(void)initPtz
{
    
//    [self.view addSubview:self.ptzViewPortrait];
    self.ptzViewPortrait.frame = CGRectMake((kWidth-200)/2, 64+(kWidth*9/16)+100, 200, 200);
    
    self.ptzViewPortrait.images = @[[UIImage imageNamed:@"preview_btn_yt_nor"],
                                    [UIImage imageNamed:@"preview_btn_yt_up"],
                                    [UIImage imageNamed:@"preview_btn_yt_left"],
                                    [UIImage imageNamed:@"preview_btn_yt_down"],
                                    [UIImage imageNamed:@"preview_btn_yt_right"],
                                    [UIImage imageNamed:@"preview_btn_yt_dis"]];
    WeakSelf
    self.ptzViewPortrait.onUpdateDirection = ^(PTZDirection direction) {
        StrongSelf
        [strongSelf.player ptzWithUp:direction==PTZDirectionUp
                                left:direction==PTZDirectionLeft
                                down:direction==PTZDirectionDown
                               right:direction==PTZDirectionRight
                             atIndex:strongSelf.player.currentSelected];
    };
    
    self.ptzViewPortrait.backgroundColor = [UIColor orangeColor];
    
    [self.view addSubview:self.axisPtzViewPortrait];
    self.axisPtzViewPortrait.frame = CGRectMake((kWidth-200)/2, 64+(kWidth*9/16)+70, 200, 200);
    // X/Y轴云台
    self.axisPtzViewPortrait.backgroundColor = [UIColor whiteColor];
    self.axisPtzViewPortrait.upImages = @[@"preview_btn_yt2_up_nor",@"preview_btn_yt2_up_sel",@"preview_btn_yt2_up_dis"];
    self.axisPtzViewPortrait.leftImages = @[@"preview_btn_yt2_left_nor",@"preview_btn_yt2_left_sel",@"preview_btn_yt2_left_dis"];
    self.axisPtzViewPortrait.downImages = @[@"preview_btn_yt2_down_nor",@"preview_btn_yt2_down_sel",@"preview_btn_yt2_down_dis"];
    self.axisPtzViewPortrait.rightImages = @[@"preview_btn_yt2_right_nor",@"preview_btn_yt2_right_sel",@"preview_btn_yt2_right_dis"];
    
    self.axisPtzViewPortrait.onUpdateDirection = ^(PTZDirection direction) {
        StrongSelf
        [strongSelf.player ptzWithUp:direction==PTZDirectionUp
                                left:direction==PTZDirectionLeft
                                down:direction==PTZDirectionDown
                               right:direction==PTZDirectionRight
                             atIndex:strongSelf.player.currentSelected];
    };
    self.axisPtzViewPortrait.enabled = YES;

}

-(UIButton*)talkSmallButtonPortrait
{
    if (_talkSmallButtonPortrait==nil) {
        _talkSmallButtonPortrait  = [[UIButton alloc]init];
        [_talkSmallButtonPortrait setImage:[UIImage imageNamed:@"preview_btn_intercom2_gray"] forState:UIControlStateNormal];
        [_talkSmallButtonPortrait addTarget:self action:@selector(onTalkBegin:) forControlEvents:UIControlEventTouchDown];
        [_talkSmallButtonPortrait addTarget:self action:@selector(onTalkEnd:) forControlEvents:UIControlEventTouchUpInside];
        [_talkSmallButtonPortrait addTarget:self action:@selector(onTalkEnd:) forControlEvents:UIControlEventTouchUpOutside];
        [_talkSmallButtonPortrait addTarget:self action:@selector(onTalkBegin:) forControlEvents:UIControlEventTouchDown];
        [_talkSmallButtonPortrait addTarget:self action:@selector(onTalkEnd:) forControlEvents:UIControlEventTouchUpInside];
        [_talkSmallButtonPortrait addTarget:self action:@selector(onTalkEnd:) forControlEvents:UIControlEventTouchUpOutside];

    }
    return  _talkSmallButtonPortrait;
}
-(HVPTZView *)axisPtzViewPortrait
{
    if (_axisPtzViewPortrait == nil) {
        _axisPtzViewPortrait = [[HVPTZView alloc]init];
    }
    return _axisPtzViewPortrait;
}

-(PTZViewForMulti *)ptzViewPortrait
{
    if (_ptzViewPortrait == nil) {
        _ptzViewPortrait = [[PTZViewForMulti alloc]init];
    }
    return _ptzViewPortrait;
}
@end
