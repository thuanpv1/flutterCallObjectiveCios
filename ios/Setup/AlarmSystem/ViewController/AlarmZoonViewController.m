//
//  AlarmZoonViewController.m
//  demo
//
//  Created by MacroVideo on 2018/2/3.
//  Copyright © 2018年 Macrovideo. All rights reserved.
//

#import "AlarmZoonViewController.h"
#import "MultiPreviewPlayer.h"
#import "LibContext.h"
#import "GlobleVar.h"
#define STREAM_TYPE_SMOOTH 0
#define STREAM_TYPE_HD 1

//#define CAFFE_USE_PANO_SHARE //Open, use singleton mode

@interface AlarmZoonViewController ()<PreviewEvents,MultiPreviewEvents>{
    BOOL isPanoPlayer;
}
@property (nonatomic,strong) MultiPreviewPlayer *player;
@property(nonatomic,strong) UIView *bgPlayer;//temp player
@property(nonatomic,strong) AlarmAreaView *alarmAreaView;
@property(nonatomic,strong) UIButton *btnSave;//OK/Save
@property(nonatomic,strong) UIView *bottomView;
@property(nonatomic,strong) UIButton *btnresetAlarmArea;//Invert/Clear
//@property(nonatomic,retain) UIButton *selectColor;//(delete unused)
//@property(nonatomic,retain) UIButton *unselectColor;//(delete not used)
@property(nonatomic,strong) UIButton *btnSelectAllArea;//Select all
@property(nonatomic, strong) AlarmConfigInfo *alarmAndPromptInfo;

@property(nonatomic,strong) UILabel *selectColorTips;
@property(nonatomic,strong) UILabel *selectTextTips;
@property(nonatomic,strong) UILabel *titleLab;
@property(nonatomic,strong) UIView *headerView;

@end

@implementation AlarmZoonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [LibContext initResuorce];
    
    _player = [MultiPreviewPlayer new];
    [_player resetRowColumn:NO];
    _player.previewEvents = self;
    _player.multiPreviewEvents = self;
    
    
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.titleLab];
    [self.view addSubview:self.bgPlayer];
    [self.view addSubview:self.bottomView];
    [self.bgPlayer addSubview:self.alarmAreaView];
    [self.bottomView addSubview:self.btnSave];
    [self.bottomView addSubview:self.btnresetAlarmArea];
    [self.bottomView addSubview:self.btnSelectAllArea];
//    [self.bottomView addSubview:self.unselectColor];
//    [self.bottomView addSubview:self.selectColor];
    [self.bottomView addSubview:self.selectColorTips];
    [self.bottomView addSubview:self.selectTextTips];
    self.title = NSLocalizedString(@"Alarm area", nil);
    
    UIImage *leftImage=[[UIImage imageNamed:@"common_btn_back_gray"]imageWithRenderingMode:UIImageRenderingModeAutomatic];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:leftImage style:UIBarButtonItemStyleDone target:self action:@selector(backAndCancel)];
    self.navigationController.navigationBarHidden = YES;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self showSettingViewWithloginparam:self.loginResult];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


-(void)setsubviewframe:(BOOL)isEqualRatio{
    float viewWidth = self.view.bounds.size.width;
    float viewHeight = self.view.bounds.size.height;

    CGRect frame ;

    frame = _titleLab.frame;
    frame.origin.y = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height + 30;
    _titleLab.frame = frame;
    
    // palyer
    frame = _bgPlayer.frame;
    frame.size.width = viewWidth;
    frame.size.height = isEqualRatio ? viewWidth : viewWidth*3/4;//viewHeight* 0.5;
    frame.origin.x = 0;
//    frame.origin.y = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height + 10;
    frame.origin.y = CGRectGetMaxY(_titleLab.frame)+15;
    _bgPlayer.frame = frame; //y gets the height of the navigation bar and the system status bar, plus 10 is the required height, the effect: _player starts to display at 10px below the navigation bar
    
    // alarmareaviw
    _alarmAreaView.frame = _bgPlayer.bounds;
    
    // bottomview
    frame = _bottomView.frame;
    frame.size.width = viewWidth;
    frame.size.height = viewHeight - CGRectGetMaxY(_bgPlayer.frame);
    frame.origin.x = 0;
    frame.origin.y = CGRectGetMaxY(_bgPlayer.frame);
    _bottomView.frame = frame;
    
    frame = _selectColorTips.frame;
    frame.origin.x = 15;
    frame.origin.y = 15;
    _selectColorTips.frame = frame;
    
    frame = _selectTextTips.frame;
    frame.origin.x = CGRectGetMaxX(_selectColorTips.frame) + 10;
    frame.origin.y = 15;
    frame.size.width = kWidth - CGRectGetMaxX(_selectColorTips.frame) - 20;
    _selectTextTips.frame = frame;
    
    CGFloat btnHeight = 100;
    if (btnHeight > _bottomView.frame.size.height - CGRectGetMaxY(_selectTextTips.frame) - 20) {
        btnHeight = _bottomView.frame.size.height - CGRectGetMaxY(_selectTextTips.frame) - 20;
    }
    frame = _btnresetAlarmArea.frame;
    frame.size.width = 100;
    frame.size.height = btnHeight;
    frame.origin.x = (kWidth - 100*3)/4;
    frame.origin.y = _bottomView.frame.size.height - btnHeight - 20;
    _btnresetAlarmArea.frame = frame;
    
    frame = _btnSelectAllArea.frame;
    frame.size.width = 100;
    frame.size.height = btnHeight;
    frame.origin.x = CGRectGetMaxX(_btnresetAlarmArea.frame) + (kWidth - 100*3)/4;
    frame.origin.y = CGRectGetMinY(_btnresetAlarmArea.frame);
    _btnSelectAllArea.frame = frame;
    
    frame = _btnSave.frame;
    frame.size.width = 100;
    frame.size.height = btnHeight;
    frame.origin.x = CGRectGetMaxX(_btnSelectAllArea.frame) + (kWidth - 100*3)/4;
    frame.origin.y = CGRectGetMinY(_btnresetAlarmArea.frame);
    _btnSave.frame = frame;
 
}


-(void)saveClick{
    __block int areaCount = 0;
    [self.alarmAreaView updateAlarmArea:^(AlarmAreaModel *AlarmAreamodel) {
        for (int i = 0; i < AlarmAreamodel.alarmAreaArr.count; i++) {
            int areaSelect = [AlarmAreamodel.alarmAreaArr[i] intValue];
            if (areaSelect == 1) {
                areaCount++;
            }
        }
        if (areaCount > 0) {
            if (self.areaDelegate != nil) {
                [self.areaDelegate setAlarmAreaArr:AlarmAreamodel.alarmAreaArr];
            }
            [self backAndCancel];
        }else {

        }
    }];
}

-(void)selectallArea {
    [self.alarmAreaView selectallArea];
    self.btnSave.enabled = YES;
}

-(void)clearselect {
    [self.alarmAreaView clearselect];
    self.btnSave.enabled = NO;
}

-(void)backAndCancel{
    isPanoPlayer = NO;
    _player.previewEvents = nil;
    _player.multiPreviewEvents = nil;
    [_player stopAll];
    [self.navigationController popViewControllerAnimated:YES];
    
}


-(void) StartPlay:(LoginHandle*) loginParam{
    NSString *password = _device.strPassword;
    if (password.length>28) {
        password = [[_device.strPassword MD5_EX] base64Encode];
    }
    self.player.view.frame = _bgPlayer.bounds;
    [_bgPlayer insertSubview:self.player.view belowSubview:self.alarmAreaView];
    isPanoPlayer = YES;
    [_player start:0
             lanIP:_device.strServer
            netIPs:[GlobleVar getPanoIPs]
              port:_device.nPort
          deviceID:_device.NDevID
          username:_device.strUsername
          password:password
        channel: 0 // LAN can only be 0, Internet 1: HD, 0: SD (automatically controlled by the bottom layer)
        streamType: STREAM_TYPE_SMOOTH
              mute:NO // It is not the currently selected item, it must be muted, but you cannot start calling mute to add this judgment, because the value of info will be modified
           stretch:NO
          userInfo:nil
        method:@"login"
         accountId:0
     ];
}


-(void)showSettingViewWithloginparam:(LoginHandle*) loginParam{
    [self setsubviewframe:loginParam.nCamType==CAM_TYPE_CELL];
    
    if (loginParam != nil) {
        [NSThread sleepForTimeInterval:1];
        if(loginParam.nCamType!=CAM_TYPE_CELL){
            loginParam.nCamType = CAM_TYPE_NORMAL;
        }
        [self StartPlay:loginParam];
        AlarmAreaModel *model = [[AlarmAreaModel alloc] init] ;
        model.row = self.config.alarmAreaRow;
        model.column = self.config.alarmAreaColumn;
        model.alarmAreaArr = self.config.alarmAreaArr;
        self.alarmAreaView.alarmModel= model;
    }
}

#pragma mark - 懒加载



//select all
-(UIButton *)btnSelectAllArea{
    if (!_btnSelectAllArea) {
        _btnSelectAllArea = [UIButton buttonWithType:UIButtonTypeCustom];

        _btnSelectAllArea.frame = CGRectMake(0, 0, 80, 80);
        [_btnSelectAllArea setImage:[UIImage imageNamed:@"set_alarm_icon_selectall"] forState:UIControlStateNormal];
        [_btnSelectAllArea setTitle:NSLocalizedString(@"select all",nil) forState:UIControlStateNormal];
        _btnSelectAllArea.titleLabel.font = [UIFont systemFontOfSize:13];
        [_btnSelectAllArea addTarget:self action:@selector(selectallArea) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _btnSelectAllArea;
}


//invert selection
-(UIButton *)btnresetAlarmArea{
    if (!_btnresetAlarmArea) {
        _btnresetAlarmArea = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _btnresetAlarmArea.frame = CGRectMake(0, 0, 80, 80);
        [_btnresetAlarmArea setImage:[UIImage imageNamed:@"set_alarm_icon_clear"] forState:UIControlStateNormal];
        [_btnresetAlarmArea setTitle:NSLocalizedString(@"clear",nil) forState:UIControlStateNormal];
        _btnresetAlarmArea.titleLabel.font = [UIFont systemFontOfSize:13];
        [_btnresetAlarmArea addTarget:self action:@selector(clearselect) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return _btnresetAlarmArea;
}

-(UIView *)bottomView{
    if (!_bottomView) {
        
        _bottomView = [[UIView alloc]init];
    }
    
    return _bottomView;
}

- (UIButton *)btnSave {
    if (!_btnSave) {
        _btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _btnSave.frame = CGRectMake(0, 0, 80, 80);
        [_btnSave setImage:[UIImage imageNamed:@"set_alarm_icon_comfirm"] forState:UIControlStateNormal];
        [_btnSave setTitle:NSLocalizedString(@"Sure",nil) forState:UIControlStateNormal];
        _btnSave.titleLabel.font = [UIFont systemFontOfSize:13];
        [_btnSave addTarget:self action:@selector(saveClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnSave;
}

-(UILabel *)titleLab{
    if (_titleLab == nil) {
        _titleLab = [[UILabel alloc]init];
        _titleLab.text = NSLocalizedString(@"Please click the grid to set the alarm area",nil);
        _titleLab.font = [UIFont systemFontOfSize:17];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.numberOfLines = 0;
        _titleLab.frame = CGRectMake(15, 0, kWidth - 30, 50);
    }
    return _titleLab;
}

-(UILabel *)selectColorTips{
    if (_selectColorTips == nil) {
        _selectColorTips = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
    }
    return _selectColorTips;
}

-(UILabel *)selectTextTips{
    if (_selectTextTips == nil) {
        _selectTextTips = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 15)];
        _selectTextTips.text = NSLocalizedString(@"Red represents the alarm area", @"Red represents the alarm area");
        _selectTextTips.font = [UIFont systemFontOfSize:14];
        _selectTextTips.textAlignment = NSTextAlignmentLeft;
    }
    return _selectTextTips;
}


-(AlarmAreaView *)alarmAreaView{
    if (!_alarmAreaView) {
        _alarmAreaView = [[AlarmAreaView alloc]init];
        X_WeakSelf;
        _alarmAreaView.updateAreaBlock = ^(NSMutableArray *array) {
            int count = 0;
            for (int i = 0; i < array.count; i++) {
                int areaSelect = [array[i] intValue];
                if (areaSelect == 1) {
                    count++;
                }
            }
            if (count > 0) {
                weakSelf.btnSave.enabled = YES;
            }else {
                weakSelf.btnSave.enabled = NO;
            }
        };
    }
    return _alarmAreaView;
}


-(UIView *)bgPlayer{
    if (!_bgPlayer) {
        _bgPlayer = [[UIView alloc]init];
        _bgPlayer.contentMode = UIViewContentModeScaleAspectFit;
        [_bgPlayer setBackgroundColor:[UIColor blackColor]];
    }
    return _bgPlayer;
}


- (BOOL) shouldAutorotate{
    
    return NO;
}


#pragma mark - 协议函数: <PreviewEvent>
- (void)previewBatteryRemaining:(int)remaining userInfo:(nullable id)userInfo atIndex:(int)index {
    
}
- (void)previewCameraType:(int)cameraType timestamp:(int64_t)timestamp userInfo:(nullable id)userInfo atIndex:(int)index {
    
}
- (void)previewIdle:(BOOL)isIdle userInfo:(nullable id)userInfo atIndex:(int)index {
}
- (void)previewLoginHandle:(nonnull LoginHandle *)handle loginError:(nonnull NSError *)error userInfo:(nullable id)userInfo atIndex:(int)index {
    [_player panoType:0 atIndex:index];
    [_player panoMode:13 atIndex:index];

}
- (void)previewOldState:(MultiPlayerState)oldState newState:(MultiPlayerState)newState userInfo:(nullable id)userInfo atIndex:(int)index {
    switch (newState) {
        case MultiPlayerState_Connecting:
        case MultiPlayerState_Buffering:
            break;
        case MultiPlayerState_Playing:
            break;
        default:
            break;
    }
}
- (void)previewThermalMinTemperature:(int)min maxTemperature:(int)max FTempEnable:(BOOL)FTempEnable userInfo:(nullable id)userInfo atIndex:(int)index {
}
- (void)previewWifiStrength:(int)strength wifiDB:(int)db userInfo:(nullable id)userInfo atIndex:(int)index {
}
- (void)previewPTZXCruiseType:(int)type state:(int)state ptzxid:(int)ptzxid userInfo:(id)userInfo atIndex:(int)index{
    
}

#pragma mark - 协议函数: <MultiPreviewEvent>
- (BOOL)multiPreviewCanPanoOFFAtIndex:(int)index {
    return NO;
}

- (BOOL)multiPreviewCanPanoONAtIndex:(int)index {
    return YES;
}

- (BOOL)multiPreviewCanSelectedAtIndex:(int)index {
    return YES;
}

- (void)multiPreviewCurrentSelected:(int)current previousSelected:(int)previous {
}
- (void)multiPreviewPanoON:(BOOL)on atIndex:(int)index {
}

@end


