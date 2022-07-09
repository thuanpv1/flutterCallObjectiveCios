//
//  NVPanoPlayerNormalViewController.m
//  iCamSee
//
//  Created by MacroVideo on 2018/2/8.
//  Copyright © 2018年 Macrovideo. All rights reserved.
//

#import "NVPanoPlayerNormalViewController.h"
#import "NVPanoPlayer.h"
#import "UIImage+TUCAssetsHelper.h"
#import "GestureRecognizer.h"
#import <Photos/Photos.h>
#import "UIImage+GIF.h"
#import "RecordVideoHelper.h"
#import "RecordVideoInfo.h"
#import "ZTRecFileSetView.h"
#import "RecordVideoDownloader.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import <Photos/Photos.h>
#import "ZTPlaySlider.h"
#import "ZTCalendar.h"
#import "SelectTimeView.h"

#import "NVCryptor.h"
#import "DataBaseManager.h"
#import "NSDate+Formatter.h"
#import "NSString+Formatter.h"

//#define CAFFE_BATTERY_VOLUME //Conditional compilation directive

//#define CAFFE_USE_PANO_SHARE //Open use singleton mode

#define MJPEG_Supported // Enable support for MJPEG
#define KAlbumVideoPath [KAlbumRootPath stringByAppendingPathComponent:@"Photo_Album_List_Video_Dir"]
#define KAlbumPhotoPath [KAlbumRootPath stringByAppendingPathComponent:@"Photo_Album_List_Photo_Dir"]
#define KAlbumRootPath [@"Documents" stringByAppendingPathComponent: @"Album_Root"]

@interface NVPanoPlayerNormalViewController ()<RecFileSearchDelegate,RecordVideoDownloadDelegate,PlaybackDelegate,SelectTimeViewDelegate>{
    int nStep;
    int SCErrorCount;
    int lastCMD;
    BOOL isSpeechRecognnizing;
    CGFloat ZTScale;
    int nSearchThreadID; // Video file search ID
    recShowType currentRecShowType; // Display mode of current video viewing
    PlayerMode currentPlayMode;
    int currentRecIndex; // currently playing video file
    BOOL isPlayingBack; // Whether it is playing back
    BOOL isPlayBackPause; // playback paused
    CGFloat nProgressValue; // current playback progress
    
    // 录像下载
    NSMutableDictionary *usingDownloaders;
    NSMutableArray      *reuseDownloaders;
    NSMutableDictionary *VideoPaths;
    int                 timercount;
    NSString            *current_download_path;
    BOOL                isDownloading;
    BOOL                isEditingSlider;
    int                 nPlayIndexId;
    CGFloat             currentRulerValue;
    UIAlertController   *alert;
    
    BOOL                _onBack;
}
#ifdef CAFFE_USE_PANO_SHARE
@property(nonatomic,strong)ZTPanoPlayView *panoPlayer;
#else
@property(nonatomic,strong)NVPanoPlayer *panoPlayer;
#endif
@property(nonatomic,strong)DataBaseManager *databaseManager;
@property (assign, nonatomic) BOOL m_bSoundEnable; //Whether to enable sound
@property (assign, nonatomic) BOOL isPlaying; //Whether live preview

// Landscape bottom view
@property (strong, nonatomic) UIView *panoPlayLaunchBottomView;
@property (assign, nonatomic) BOOL isShowBottomView; //Whether the horizontal screen displays the bottom and other views
// playback
@property (strong, nonatomic) UIView *playBackBgView;//Playback view
@property (strong, nonatomic) LoginHandle *loginHandle;
@property (strong, nonatomic) NSMutableArray *recFileList; // record file list
@property (strong, nonatomic) NSMutableArray *recFileListSelect; // record file list

@property (strong, nonatomic) ZTRecFileSetView *recFileSetView; //event set
@property (strong, nonatomic) UIActivityIndicatorView *recActivityView;
@property (strong, nonatomic) NSCondition *recListLock;
@property (strong, nonatomic) UIButton *weakShowtypeBtn;
@property (strong, nonatomic) UIButton *weakSoundBtn;
@property (strong, nonatomic) UIButton *weakScreenShotBtn;
@property (strong, nonatomic) UIButton *weakFullScreenBtn;
@property (strong, nonatomic) UIButton *weakClarityBtn;//Clarity
@property (strong, nonatomic) UIButton *weakSDBtn; //SD card recording
@property (strong, nonatomic) UIButton *weakOSSBtn; //Cloud storage video
@property (strong, nonatomic) UIButton *weakDownloadBtn;//Playback download
@property (nonatomic, strong)        ZTCalendar *calendar;

// Play back the bottom toolbar
@property (strong, nonatomic) ZTPlaySlider *playbackSlider;
@property (strong, nonatomic) UIView *playbackBottomToolView;
@property (strong, nonatomic) UILabel *playbackTimeStartLbl;
@property (strong, nonatomic) UILabel *playbackTimeEndLbl;

@property (strong, nonatomic) UIButton *playbackPlayAndStop; // landscape, play/pause/playback button
@property (strong, nonatomic) UIButton *playbackScreenshot; // landscape screenshot button
@property (strong, nonatomic) UIButton *playbackSound; // landscape mute button
@property (strong, nonatomic) UIButton *playbackFullScreen; // back button for landscape screen

@property (strong, nonatomic) UIButton *playBackToPlay; // after pause
@property(nonatomic,strong) UIButton *btnBacktoPortrait; // Return to portrait in landscape

@property (nonatomic, strong) NSDate *currentSelectDate;// Current video search time
@property (nonatomic, strong) UIButton *weakDateBtn;//Date selection button

@property(nonatomic,strong) UIAlertController *alertVC;

@property(nonatomic,strong) UIPanGestureRecognizer *panGestureRecognizer;
@property(nonatomic,strong) UIView *moveTrackdView;
@property(nonatomic,strong) UIButton *moveTrackdImgBtn;
@property(nonatomic,assign) BOOL moveTrackSwitch;
@property(nonatomic,assign) int fileCurrentTime;
@property(nonatomic,strong) UIImageView *recordImg;
@property(nonatomic,strong) UILabel *recordLabel;
@property (nonatomic, strong) UIButton *weakDateTimeBtn;//Time selection button
@property (nonatomic, strong)         UIImageView *weakDateTimeImg;

@property(nonatomic,strong)NSMutableArray *arraySDCardFileList;
@property(nonatomic,strong)NSMutableArray *arrayCloudServiceFileList;
@property(nonatomic,assign)NSInteger nDisplayFileType;


@property (nonatomic, strong) UIView *noPlayBackTipsBgView; //Background view of cloud service promotion prompt when playback cannot be performed (no card, no cloud service)
@property (nonatomic, strong) UIImageView *noPlayBackTipsImageView; //The cloud service promotion prompt picture when it cannot be played back (no card, no cloud service)
@property (nonatomic, strong) UILabel *noPlayBackTipsLabel; // Cloud service promotion prompt when playback cannot be performed (no card, no cloud service) label
@property (nonatomic, strong) UIButton *noPlayBackTipsBtn; //Cloud service promotion prompt button when playback cannot be performed (no card, no cloud service)

@property(nonatomic, assign) BOOL needAutoPlay; //Whether autoplay is required
@property (nonatomic,assign) BOOL isNeedResetContext;
@end


@implementation NVPanoPlayerNormalViewController

-(NSMutableArray *)recFileList{
    
    if(_recFileList == nil){
        
        _recFileList = [NSMutableArray array];
        
    }
    return _recFileList;
    
}
-(NSCondition *)recListLock{
    
    if(_recListLock == nil){
        
        _recListLock = [[NSCondition alloc] init];
    }
    return _recListLock;
    
}

#pragma mark -- 回放视图
// add by zhantian 20180307
-(UIView *)playBackBgView{
    
    if (!_playBackBgView) {
        
        _playBackBgView = [[UIView alloc]init];
        _playBackBgView.backgroundColor = [UIColor whiteColor];
        _playBackBgView.frame = CGRectMake(0,kHeight, kWidth, 300);
        
        int btnCount = 3;
        CGFloat btnWidth              = 45;
        CGFloat btnHeight             = 45;
        CGFloat btnY = 0;
        CGFloat btnSpacing            = (kWidth - btnWidth * btnCount ) / btnCount;
        for (int i = 0 ; i < btnCount; i++) {
            UIButton *btn = [[UIButton alloc]init];
            btn.frame = CGRectMake(btnSpacing / 2.0 + btnSpacing *i + btnWidth *i, btnY, btnWidth, btnHeight);
            [_playBackBgView addSubview:btn];
            btn.tag = i;
            if (i == 0) {
                if (self.m_bSoundEnable) {
                    [btn setImage:[UIImage imageNamed:@"btn_voice_open"] forState:UIControlStateNormal];
                }else{
                    [btn setImage:[UIImage imageNamed:@"btn_voice_close"] forState:UIControlStateNormal];
                }
                _weakSoundBtn = btn;
            }else if (i == 1){
                _weakDownloadBtn = btn;
                [btn setImage:[UIImage imageNamed:@"btn_load"] forState:UIControlStateNormal];
            }else if (i == 2){
                [btn setImage:[UIImage imageNamed:@"btn_jietu"] forState:UIControlStateNormal];
                _weakScreenShotBtn = btn;
            }else if (i == 3){
                [btn setImage:[UIImage imageNamed:@"btn_fd"] forState:UIControlStateNormal];
                _weakFullScreenBtn = btn;
            }
            [btn addTarget:self action:@selector(playBackButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        for (int i =0 ; i < btnCount - 1; i++) {
            UIView *line = [[UIView alloc]init];
            line.frame = CGRectMake(btnSpacing / 2.0 + btnSpacing *i + btnWidth *(i+1) +(btnSpacing-1)/2.0, 8, 1, 29);
            line.backgroundColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:239/255.0 alpha:1.0];
            [_playBackBgView addSubview:line];
        }
        
        UIView *lineView = [[UIView alloc]init];
        lineView.frame = CGRectMake(0, 45, kWidth, 1);
        lineView.backgroundColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:239/255.0 alpha:1.0];
        [_playBackBgView addSubview:lineView];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isShouldShowSomeGoodThings"]) {
            btnCount = 3;
        }else{
            btnCount = 2;
        }
        
        if(self.isFromMultiPreview == YES) btnCount--;
        
        for (int i = 0 ; i < btnCount ; i++) {
            UIButton *btn = [[UIButton alloc]init];
            btn.frame = CGRectMake(kWidth/btnCount *i, CGRectGetMaxY(lineView.frame) + 5, kWidth/btnCount, 40);
            btn.tag = i;
            btn.titleLabel.adjustsFontSizeToFitWidth = YES;
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            btn.titleLabel.numberOfLines = 0;
            [_playBackBgView addSubview:btn];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0.0,10.0, 0.0,0.0)];
            [btn addTarget:self action:@selector(recordType:) forControlEvents:UIControlEventTouchUpInside];
            if (i == 0) {
                [btn setTitle:@"microSD card" forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:@"btn_sdcard"] forState:UIControlStateNormal];
                _weakSDBtn = btn;
            }
            
            if (btnCount == 3) {
                if (i == 1){
               
                        [btn setTitle:NSLocalizedString(@"Cloud Disk", @"Cloud Disk") forState:UIControlStateNormal];
                    [btn setImage:[UIImage imageNamed:@"btn_ycc"] forState:UIControlStateNormal];
                    _weakOSSBtn = btn;
                }else if (i == 2){
                    [btn setTitle:NSLocalizedString(@"return preview", nil) forState:UIControlStateNormal];
                    [btn setImage:[UIImage imageNamed:@"btn_ycc"] forState:UIControlStateNormal];
                }
            }else if (btnCount == 2){
                if (i == 1){
                    if(self.isFromMultiPreview == NO){
                        [btn setTitle:NSLocalizedString(@"return preview", nil) forState:UIControlStateNormal];
                        [btn setImage:[UIImage imageNamed:@"btn_yl_default"] forState:UIControlStateNormal];
                    }else{
           
                            [btn setTitle:NSLocalizedString(@"Cloud Disk", @"Cloud Disk") forState:UIControlStateNormal];
                            [btn setImage:[UIImage imageNamed:@"btn_ycc"] forState:UIControlStateNormal];
                        _weakOSSBtn = btn;
                    }
                }
            }
            //add by qin 20181013
            if ([NSLocalizedString(@"cn", nil) isEqualToString:@"fa"] || [NSLocalizedString(@"cn", nil) isEqualToString:@"ar"]) {
                btn.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
                btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
            }
            //end by qin 20181013
        }
        //end by qin 20190417
        
        UIView *lineView2 = [[UIView alloc]init];
        lineView2.frame = CGRectMake(0, CGRectGetMaxY(lineView.frame) + 50, kWidth, 1);
        lineView2.backgroundColor = [UIColor grayColor];
        [_playBackBgView addSubview:lineView2];
        
        //日期选择按钮
        UIButton *dateBtn = [[UIButton alloc]init];
        dateBtn.frame = CGRectMake(8, CGRectGetMaxY(lineView2.frame) + 8, 130, 40);
        [dateBtn setImage:[UIImage imageNamed:@"btn_date"] forState:UIControlStateNormal];
        [dateBtn setTitle:[[[NSDate alloc]init] dateString] forState:UIControlStateNormal];
        [dateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        dateBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [dateBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0,8.0, 0.0,0.0)];
        if ([NSLocalizedString(@"cn", nil) isEqualToString:@"fa"] || [NSLocalizedString(@"cn", nil) isEqualToString:@"ar"]) {
            [dateBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0,0.0, 0.0,8.0)];
        }
        [dateBtn addTarget:self action:@selector(dateSelectedAction:) forControlEvents:UIControlEventTouchUpInside];
        _weakDateBtn = dateBtn;
        [_playBackBgView addSubview:dateBtn];
        
        UIImageView *rightImg = [[UIImageView alloc]init];
        rightImg.frame = CGRectMake(CGRectGetMaxX(dateBtn.frame) + 2,  CGRectGetMaxY(lineView2.frame) + 21, 8, 14);
        CGPoint center = dateBtn.center;
        center.x = rightImg.center.x;
        rightImg.center = center;
        rightImg.image = [UIImage imageNamed:@"btn_more_right"];
        [_playBackBgView addSubview:rightImg];
        
        //具体时间选择按钮（24小时）
        UIButton *timeBtn = [[UIButton alloc]init];
        //        timeBtn.frame = CGRectMake(CGRectGetMaxX(rightImg.frame), CGRectGetMaxY(lineView2.frame) + 8, 50, 40);
        [timeBtn setTitle:NSLocalizedString(@"Please select the video playback time period", nil) forState:UIControlStateNormal];
        [timeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        timeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [timeBtn addTarget:self action:@selector(timeSelectedAction:) forControlEvents:UIControlEventTouchUpInside];
        [_playBackBgView addSubview:timeBtn];
        _weakDateTimeBtn = timeBtn;
        NSString *content = timeBtn.titleLabel.text;
        UIFont *font = timeBtn.titleLabel.font;
        CGSize size = CGSizeMake(MAXFLOAT, 30.0f);
        CGSize buttonSize = [content boundingRectWithSize:size
                                                  options:NSStringDrawingTruncatesLastVisibleLine  | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               attributes:@{ NSFontAttributeName:font}
                                                  context:nil].size;
        timeBtn.frame = CGRectMake(CGRectGetMaxX(rightImg.frame)+5, CGRectGetMaxY(lineView2.frame) + 8,buttonSize.width,40);
        
        UIImageView *rightImg1 = [[UIImageView alloc]init];
        rightImg1.frame = CGRectMake(CGRectGetMaxX(timeBtn.frame)+3,  CGRectGetMaxY(lineView2.frame) + 21, 8, 14);
        rightImg1.image = [UIImage imageNamed:@"btn_more_right"];
        [_playBackBgView addSubview:rightImg1];
        _weakDateTimeImg = rightImg1;
        
        //图片跟文字分离在不同语言下button更好做UI适配
        //modify by qin 20190425
        UIImageView *rightImg2 = [[UIImageView alloc]init];
        rightImg2.frame = CGRectMake(kWidth - 8 - 8,  CGRectGetMaxY(lineView2.frame) + 21, 8, 14);
        rightImg2.image = [UIImage imageNamed:@"btn_more_right"];
        [_playBackBgView addSubview:rightImg2];
        
        UIButton *showTypeBtn = [[UIButton alloc]init];
        showTypeBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        showTypeBtn.titleLabel.numberOfLines = 0;
        showTypeBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        showTypeBtn.frame = CGRectMake(kWidth - 80 - 20, CGRectGetMaxY(lineView2.frame) + 8, 80, 40);
            [showTypeBtn setTitle:NSLocalizedString(@"event set", nil) forState:UIControlStateNormal];
        [showTypeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        showTypeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        
        showTypeBtn.contentHorizontalAlignment = NSTextAlignmentRight;
        //end by qin 20190425
        _weakShowtypeBtn = showTypeBtn;
        [_playBackBgView addSubview:showTypeBtn];

        [self.view addSubview:_playBackBgView];
        currentRecShowType = recShowTypeFileset;

        [self changeShowType];
        // 事件集
        _recFileSetView = [[ZTRecFileSetView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(dateBtn.frame) + 20, kWidth, 80)];
        __weak typeof(self) weakSelf = self;
        _recFileSetView.selectItemAction = ^(NSIndexPath *indexPath) {
            
            [weakSelf recItemAction:indexPath];
            
        };
        [_playBackBgView addSubview:_recFileSetView];
        
        // 菊花
        self.recActivityView.frame = _recFileSetView.frame;
        [_playBackBgView addSubview:_recActivityView];
            

        
        if (self.noPlayBackTipsBgView == nil) {
            self.noPlayBackTipsBgView = [[UIView alloc] initWithFrame:self.panoPlayer.frame];
    //        self.noPlayBackTipsBgView.backgroundColor = UIColor.redColor;
            self.noPlayBackTipsBgView.hidden = YES;
            
            [self.view addSubview:self.noPlayBackTipsBgView];
            
            CGFloat frameW = 55 * kScaleX;
            CGFloat frameH = 36 * kScaleY;
            CGFloat frameX = (self.noPlayBackTipsBgView.frame.size.width - frameW) / 2;
            CGFloat frameY = 0;
            self.noPlayBackTipsImageView = [[UIImageView alloc] initWithFrame:(CGRect){frameX,frameY,frameW,frameH}];
            self.noPlayBackTipsImageView.image = [UIImage imageNamed:@""];
            [self.noPlayBackTipsBgView addSubview:self.noPlayBackTipsImageView];
            
            frameX = 50;
            frameW = self.noPlayBackTipsBgView.frame.size.width - frameX * 2;
            frameH = 20;
            frameY = CGRectGetMaxY(self.noPlayBackTipsImageView.frame) + 5;
            self.noPlayBackTipsLabel = [[UILabel alloc] initWithFrame:(CGRect){frameX,frameY,frameW,frameH}];
            self.noPlayBackTipsLabel.text = @"";
            self.noPlayBackTipsLabel.textAlignment = NSTextAlignmentCenter;
            self.noPlayBackTipsLabel.textColor = [UIColor whiteColor];
            [self.noPlayBackTipsBgView addSubview:self.noPlayBackTipsLabel];
            
            
            frameW = self.noPlayBackTipsBgView.frame.size.width;
            frameX = 0;
            frameY = CGRectGetMaxY(self.noPlayBackTipsLabel.frame) + 5;
            frameH = 30;
            self.noPlayBackTipsBtn = [[UIButton alloc] initWithFrame:(CGRect){frameX,frameY,frameW,frameH}];
            [self.noPlayBackTipsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.noPlayBackTipsBtn setBackgroundColor:[UIColor orangeColor]];
            [self.noPlayBackTipsBtn addTarget:self action:@selector(noPlayBackTipsBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [self.noPlayBackTipsBgView addSubview:self.noPlayBackTipsBtn];
            self.noPlayBackTipsBtn.titleLabel.numberOfLines = 0;
            self.noPlayBackTipsBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.noPlayBackTipsBtn.layer.cornerRadius = 15;
        }
        
    }
    return _playBackBgView;
}



-(UIActivityIndicatorView *)recActivityView{
    
    if(_recActivityView == nil){
    //load chrysanthemum
        // _recActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _recActivityView = [[UIActivityIndicatorView alloc] init];
        //Change the size of the chrysanthemum by deformation
        CGAffineTransform transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        _recActivityView.transform = transform;
        _recActivityView.hidden = YES;
        _recActivityView.hidesWhenStopped = YES;
        
        if(@available(iOS 13.0,*)){
            
        }
        else{
            _recActivityView.color = UIColor.grayColor;
        }
    }
    
    return _recActivityView;
}


-(void)noPlayBackTipsBtnClick{

}

//Display the prompt that there is no TF card
-(void)showNoTFTips{

    
    UIImage *image = [UIImage imageNamed:@"replay_icon_notfcard"];
    self.noPlayBackTipsImageView.image = image;
    
    self.noPlayBackTipsLabel.text = NSLocalizedString(@"No TF card inserted", @"No TF card inserted");
    [self.noPlayBackTipsBtn setTitle:NSLocalizedString(@"What is the difference between cloud service and TF card?", @"What is the difference between cloud service and TF card?") forState:UIControlStateNormal];
    CGRect frame = self.noPlayBackTipsImageView.frame;
    frame.size.width = image.size.width;
    frame.size.height = image.size.height;
    self.noPlayBackTipsImageView.frame = frame;
    
    frame = self.noPlayBackTipsLabel.frame;
    frame.origin.y = CGRectGetMaxY(self.noPlayBackTipsImageView.frame) + 5;
    frame.size.height = [self.noPlayBackTipsLabel.text stringHeightWithFont:self.noPlayBackTipsLabel.font containSize:(CGSize){frame.size.width,MAXFLOAT}] + 5;
    self.noPlayBackTipsLabel.frame = frame;
    
    frame = self.noPlayBackTipsBtn.frame;
    frame.origin.y = CGRectGetMaxY(self.noPlayBackTipsLabel.frame) + 5;
    frame.size.width = [self.noPlayBackTipsBtn.titleLabel.text stringWidthWithFont:self.noPlayBackTipsBtn.titleLabel.font containSize:(CGSize){self.noPlayBackTipsBgView.frame.size.width - frame.origin.x * 2,MAXFLOAT}] + 10;
    frame.size.height = [self.noPlayBackTipsBtn.titleLabel.text stringHeightWithFont:self.noPlayBackTipsBtn.titleLabel.font containSize:(CGSize){frame.size.width,MAXFLOAT}] + 10;
    frame.origin.x = (self.noPlayBackTipsBgView.frame.size.width - frame.size.width) / 2;
    self.noPlayBackTipsBtn.frame = frame;
    self.noPlayBackTipsBtn.layer.cornerRadius = frame.size.height / 2;
    
    frame = self.noPlayBackTipsBgView.frame;
    frame.size.height = CGRectGetMaxY(self.noPlayBackTipsBtn.frame);
    frame.origin.y = (self.panoPlayer.frame.size.height - frame.size.height) / 2 + self.panoPlayer.frame.origin.y;
    self.noPlayBackTipsBgView.frame = frame;
    self.noPlayBackTipsBgView.hidden = NO;
    [self.view bringSubviewToFront:self.noPlayBackTipsBgView];
        
}




- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    nSearchThreadID = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidBecomeActiveHandle:) name:@"ON_BECOME_ACTIVE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationWillResignActiveHandle:) name:@"ON_RESIGN_ACTIVE" object:nil];
    _onBack = NO;
    UIImage *originalImage = [[UIImage imageNamed:@"common_btn_back_gray"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithImage:originalImage style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = backButton;
    
if (self.device) {
        if (self.device.strName.length > 0) {
            self.navigationItem.title = [NSString stringWithFormat:@"Playback"];
        }else{
            self.navigationItem.title = [NSString stringWithFormat:@"Playback"];
        }
    }

    if (self.loginResult.nMoveTrack ==1) {
        self.moveTrackSwitch = YES;
    }else if(self.loginResult.nMoveTrack ==2){
        self.moveTrackSwitch = NO;
    }
    
    _currentSelectDate = [self latestDate];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    if (_onBack) {
        return;
    }
    [self allowRotation:YES];
    [self GetSettings];
    [self setupPlayerView];
    //[NSThread sleepForTimeInterval:0.5];
    
    //@Author: Caffe 2019.12.03
    {//@Begin
       if(self.isFromMultiPreview == YES){
            //clear the screen
            //[self.panoPlayer clearsurface];

            //time display label
            [self.panoPlayer setLblTimeOSD:nil];
// self.view.backgroundColor = [UIColor blackColor];
            //playback event
            self.needAutoPlay = YES;
            [self.panoPlayer clearsurface]; //Clear the screen
            [self playBackAction]; //Enter playback
        }else{
           
        }
    }//@End
    //@Author: Caffe
    self.isNeedResetContext = YES;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self allowRotation:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self allowRotation:NO];
    //        [self.panoPlayer removeGestureRecognizer:self.tapGestureRecognizer];
    //        [self.panoPlayer removeGestureRecognizer:self.panGestureRecognizer];
}
-(void)backAction{
    _onBack = YES;

    
    //@Author: Caffe 2019.12.09
    {//@Begin
        
        NSString *messgae = NSLocalizedString(@"End playback?", nil);
        if (isDownloading) {
            messgae = NSLocalizedString(@"Cancel the file being downloaded?", nil);
        }

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:messgae preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"btnCancel", @"取消") style:UIAlertActionStyleCancel handler:nil];
        X_WeakSelf;
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            X_StrongSelf;
            strongSelf->_onBack = NO;
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            X_StrongSelf;
            [strongSelf.panoPlayer setIsOnback:YES];
            [strongSelf stopAllPlay];
//            if(strongSelf.isFromMultiPreview) [strongSelf.panoPlayer releaseAction];
            [strongSelf.navigationController popViewControllerAnimated:YES];
        }];
        
        [action1 setValue:[UIColor grayColor] forKey:@"titleTextColor"];
        [action2 setValue:[UIColor blueColor] forKey:@"titleTextColor"];
        [alert addAction:action1];
        [alert addAction:action2];
        self.alertVC = alert;
        if(isDownloading){
            //Only prompt when downloading or recording
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            [self.panoPlayer setIsOnback:YES];
            [self stopAllPlay];
            if(self.isFromMultiPreview) [self.panoPlayer releaseAction];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        
    }//@End
    //@Author: Caffe
}

-(void)stopAllPlay{
    if(self->isDownloading){
        // stop all downloads
        [self StopAllDownload];
    }
 
    
    if(self->isPlayingBack || self->isPlayBackPause){
        [self stopPlayBack];
    }else {
        if (self.isPlaying) {
            [self stopPlay:YES];
           
        }
    }
    [self allowRotation:NO];
    [self.panoPlayer removeGestureRecognizer:self.panGestureRecognizer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ON_BECOME_ACTIVE" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ON_RESIGN_ACTIVE" object:nil];
}

-(void)checkDeviceUpdate:(int)thread{

}

//end by qin 20181024

#pragma mark - 结束播放
-(void)stopPlay:(BOOL)isShotCut{
    //GWXLog(@"[Playback] Stop playback");
    self.isPlaying = NO;

    [self.panoPlayer stopPlayBack];
}



#pragma mark - 初始化播放视图
-(void)setupPlayerView{
    
    [self.view addSubview:self.panoPlayer];
   
}

// recursively get subviews
- (void)getSub:(UIView *)view enable:(BOOL)enable{
    NSArray *subviews = [view subviews];
    
    // if there are no subviews, return directly
    if ([subviews count] == 0) return;
    
    for (UIView *subview in subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton*)subview;
            btn.enabled = enable;
            if (subview.tag ==11 || subview.tag == 21||subview.tag == 105 ||subview.tag ==23) {
                btn.enabled = YES;
            }
        }
        // Recursively get the subviews of this view
        [self getSub:subview enable:enable];
    }
}

//#pragma mark ======================================= Video playbacks === ===================
//FIXME: - playback
-(void) playBackAction{
    
    _currentRecordType = 0;
    [self setupPlayBackView]; //Create a playback page weibin
    [self updatePlayBackView];
    _currentSelectDate = [self latestDate];
    [self.weakDateBtn setTitle:[_currentSelectDate dateString] forState:UIControlStateNormal];//add by qin 20181017 After the playback returns to the preview, enter the playback to ensure that the displayed search date is correct
    [self recordType:_weakSDBtn];
   
    currentPlayMode = PlayerModePlayBack; // The current mode is playback mode
}

#pragma mark - 时间处理函数

- (NSDate *)zeroOfDate:(NSDate *)date{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:date];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [calendar dateFromComponents:components];
    
}
//Get the 23:59:59 time of the current date
- (NSDate *)lastOfDate:(NSDate *)date{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:date];
    components.hour = 23;
    components.minute = 59;
    components.second = 59;
    return [calendar dateFromComponents:components];
    
}


//Get the latest NSDate in the current time zone
-(NSDate *) latestDate{
    
    NSDate *date        = [NSDate date];
    NSTimeZone *zone    = [NSTimeZone timeZoneWithName:@"UTC"];
    NSInteger interval  = [zone secondsFromGMTForDate:date];
    NSDate *localDate   = [date dateByAddingTimeInterval:interval];
    return localDate;
    
}


#pragma mark -


#pragma mark - Playback view
-(void)setupPlayBackView{
    
    self.playBackBgView.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        
        CGRect frame = self.playBackBgView.frame;
        frame.origin.y = CGRectGetMaxY(self.panoPlayer.frame);
        frame.size.height = self.view.bounds.size.height - frame.origin.y;
        self.playBackBgView.frame = frame;
        
    }];
    
    // Play the progress bar
    self.playbackBottomToolView.frame = CGRectMake(self.panoPlayer.frame.origin.x ,CGRectGetMaxY(self.panoPlayer.frame) - 40, self.panoPlayer.frame.size.width, 40);
    [self.view addSubview:_playbackBottomToolView];
    _playbackBottomToolView.hidden = YES;
    
}

-(void)updatePlayBackView{
    
    if (self.m_bSoundEnable) {
        
        [_weakSoundBtn setImage:[UIImage imageNamed:@"btn_voice_open"] forState:UIControlStateNormal];
        
    }else{
        
        [_weakSoundBtn setImage:[UIImage imageNamed:@"btn_voice_close"] forState:UIControlStateNormal];
    }
    
}

#pragma mark - 回放数据请求
-(void) startSearchRecFile:(RecordType)recordType{
    //GWXLog(@"[Playback] Start searching for files");
    if(isDownloading){
        // stop all downloads f
        [self StopAllDownload];
    }
    
    if(isPlayingBack || isPlayBackPause){
        nProgressValue = 0;
        [self stopPlayBack];
    }
    
    //add by weibin 20181008
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setToolBtnEnable:NO];
        self.weakDateTimeBtn.enabled = NO;
        [self reloadRecFileSetView];
        //        NSLog(@"20181008 === no , %s", __func__);
    });
    [RecordVideoHelper cancelOperation];
    //add end by weibin 20181008
    
    [self.recListLock lock];
    [_recFileList removeAllObjects];
    [self.recFileListSelect removeAllObjects];
    _recFileSetView.fileSetList = _recFileList;
    currentRecIndex = -1;
    [self.recListLock unlock];
    
    int searchID = ++nSearchThreadID;
    if(recordType == RecordTypeSD){ //Request TF card data
        // SD card video search
        self.nDisplayFileType = FILE_TYPE_ALL;//add by weibin 20181009
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             //GWXLog(@"[Playback] Start searching for file thread");
            [self recSDFileSearchThreadFunc:self.device searchID:searchID];
            
        });
    }else if(recordType == RecordTypeOSS){
        // Cloud storage video search
        self.nDisplayFileType = FILE_TYPE_ALARM;//add by weibin 20181009
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //GWXLog(@"[Playback] Start searching for file thread");
            [self recCloudFileSearchThreadFunc:self.device searchID:searchID];
        });
        
    }
    
}

#pragma mark  SDCard (new/old agreement)
- (void)recSDFileSearchThreadFunc:(NVDevice *)device searchID:(int)nSearchID{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setToolBtnEnable:NO];

        [self.recFileSetView dismissTipsView];
        [self.recFileSetView setNoCloudFileTipsView:YES];//add by qin 20190221
        self.recActivityView.hidden = NO;
        [self.recActivityView startAnimating];
        [self.recActivityView.superview bringSubviewToFront:self.recActivityView];
        
    });
    
#pragma mark ================================= Troubleshooting the problem of unsuccessful SD card search======== ===========================
    // Get LoginHandle
    
    LoginHandle *loginHandel = self.loginResult;//[RecordVideoHelper getRecordOPHandle:self.device withConnectType:1];
    
    NSLog(@"recSDFileSearchThreadFunc lhandle= %ld version = %d",loginHandel.lHandle,loginHandel.nVersion);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.recFileSetView.hidden = NO;//add by qin 20190509
    });
    if(nSearchID != nSearchThreadID){
        // request to be superseded
        
        [RecordVideoHelper cancelOperation];//add by weibin 20181009
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.currentRecordType == RecordTypeSD) {
                [self.recActivityView stopAnimating];
                [self.recFileSetView showNoFileTips];
            }
            return;
        });
        
    }
    
    //login result
    if (loginHandel && [loginHandel nResult] != RESULT_CODE_SUCCESS) {
        // login unsuccessful
        NSString *strNotice = nil;
        switch ([loginHandel nResult]) {
        case RESULT_CODE_FAIL_USER_NOEXIST:
                strNotice = [NSString stringWithFormat:@"%@", NSLocalizedString(@"User does not exist", @"User does not exist")];
                break;
            case NV_RESULT_DESC_PWD_ERR: case NV_RESULT_DESC_NO_USER:
                strNotice = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Incorrect username or password", @"Incorrect username or password")];
                break;
            case RESULT_CODE_FAIL_VERIFY_FAIL:
                strNotice = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Insufficient permissions", @"Insufficient permissions")];
                break;
                
            default:
                strNotice = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Connection failed", @"Connection failed")];
                break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.currentRecordType == RecordTypeSD) {
                [self.recActivityView stopAnimating];
//                iToast *toast = [iToast makeToast:strNotice];
//                toast.toastPosition = kToastPositionBottom;
//                [toast show];
                [self.recFileSetView showNoFileTips];
            }
        });
        
        return;
    }
    //login successful
    self.loginHandle = _loginHandle;
    int nResult = RESULT_CODE_FAIL_SERVER_CONNECT_FAIL;
    RecordFileParam *param = [[RecordFileParam alloc]init];
    if(loginHandel.nVersion >2){
        // 6.0 new video search protocol
        NSDate *currentDate = _currentSelectDate;
        NSDate *beginDate = [self zeroOfDate:currentDate];
        NSDate *endDate = [self lastOfDate:currentDate];
        
        param.nSearchChn = 0;
        param.nSearchType = FILE_TYPE_ALL;
        param.beginDate = beginDate;
        param.endDate = endDate;
        nResult = [RecordVideoHelper getRecordVideoInTFCard:loginHandel receiver:self fileParam:param];
        //        nResult = [RecordVideoHelper getRecordFilesV60:loginHandel deviceId:self.device.NDevID receiver:self chn:0 type:FILE_TYPE_ALL timeBegin:beginDate timeEnd:endDate];
        //XLog(@"TF card search result == %d",nResult);
        
    }else{
        NSLog(@"Old protocol search playback file");
    // old search protocol
        NSDate *beginDate = [self zeroOfDate:_currentSelectDate];
        NSDate *endDate = [self lastOfDate:_currentSelectDate];
        
        //        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        //        NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond;
        //
        //        NSDateComponents *beginDateComponent = [calendar components:unitFlags fromDate:beginDate];
        //        short nStartYear = [beginDateComponent year];
        //        short nStartMonth = [beginDateComponent month];
        //        short nStartDay = [beginDateComponent day] ;
        //        short nStartHour = [beginDateComponent hour];
        //        short nStartMinute = [beginDateComponent minute];
        //        short nStartSecond = [beginDateComponent second];
        //
        //        NSDateComponents *endDateComponent = [calendar components:unitFlags fromDate:endDate];
        //        short nEndHour = [endDateComponent hour];
        //        short nEndMinute = [endDateComponent minute];
        //        short nEndSecond = [endDateComponent second];
        
        param.nSearchChn = 0;
        param.nSearchType = FILE_TYPE_ALL;
        param.beginDate = beginDate;
        param.endDate = endDate;
        nResult = [RecordVideoHelper getRecordVideoInTFCard:loginHandel receiver:self fileParam:param];
        //        nResult = [RecordVideoHelper getRecordFiles:loginHandel receiver:self chn:0 type:FILE_TYPE_ALL year:nStartYear month:nStartMonth day:nStartDay SH:nStartHour SM:nStartMinute SS:nStartSecond EH:nEndHour EM:nEndMinute ES:nEndSecond];
        
    }
    

    
    if(nSearchID != nSearchThreadID){
        
        [RecordVideoHelper cancelOperation];//add by weibin 20181009
        dispatch_async(dispatch_get_main_queue(), ^{
        // request is replaced
            if (self.currentRecordType == RecordTypeSD) {
                [self.recActivityView stopAnimating];
                if (nResult == -2) { //-2 means no SD card
                    
                    [self showNoTFTips];
                    
                }else{
                    [self.recFileSetView showNoFileTips];
                }
            }
            return;
        });
    }
    //    nSearchThreadID ++;  delete by weibin 20181009
    if(nResult <= 0 ){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.currentRecordType == RecordTypeSD) {
        if (nResult == -2) { //-2 means no SD card
                   
                    [self showNoTFTips];
                    
                }else{
                    [self.recFileSetView showNoFileTips];
                }
                // iToast *toast = [iToast makeToast: NSLocalizedString(@"strNoFilesFound", @"No file found")];
                // [toast show]; //delete by xie yongsheng 20181126 Deleted a redundant prompt that frequent switching would cause crashes
                //set event set
                [self.recActivityView stopAnimating];
            }
            
        });
        
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(nSearchID != self->nSearchThreadID){
                // request is replaced
                if (self.currentRecordType == RecordTypeSD) {
                    [RecordVideoHelper cancelOperation];//add by weibin 20181009
                    [self.recActivityView stopAnimating];
                    if (nResult == -2) { //-2 means no SD card
                       
                            [self showNoTFTips];
                        
                    }else{
                        [self.recFileSetView showNoFileTips];
                    }
                }
                return;
            }
            
            //set event set
            if (self.currentRecordType == RecordTypeSD) {
                [self.recActivityView stopAnimating];
            }
            NSArray *ary = [NSArray arrayWithArray:self.recFileList];
            self.recFileSetView.fileSetList = ary;
            if (self.recFileList.count==0) {
                if (nResult == -2) { //-2 means no SD card
                   
                        [self showNoTFTips];
                    
                }else{
                    [self.recFileSetView showNoFileTips];
                }
            }
        });
    }
    
    //add by weibin 20181008
    [self reloadRecFileSetView];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.weakDateTimeBtn.enabled = YES;
        //add by qin 20190506
        NSArray *ary = [NSArray arrayWithArray:self.recFileList];
        self.recFileSetView.fileSetList = ary;
        if (self.recFileList.count == 0) {
            self.weakShowtypeBtn.enabled = NO;
            if(self.currentRecordType == RecordTypeSD)
                [self allowRotation:NO];
        }else{
            if(self.currentRecordType == RecordTypeSD)
                [self allowRotation:YES];
        }
        //end by qin 20190506
        /* The timeline slides to the start time of the first file add by yang 20190828 */
        NSString *timeDate = [NSString stringWithFormat:@"%@ 00:00:00",self.weakDateBtn.titleLabel.text];
        int timeStemp = (int)[self timeSwitchTimestamp:timeDate];
        RecordVideoInfo *info = ary.lastObject;
        self->currentRulerValue = info.nStartTime - timeStemp;
        
        if (self.currentRecordType == RecordTypeSD) {
    
                [self.recFileSetView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.recFileList.count - 1 inSection:0]];
                [self.recFileSetView selectCellAtIndexPath:[NSIndexPath indexPathForRow:self.recFileList.count - 1 inSection:0]];
                self.weakShowtypeBtn.enabled = YES;
            if (self.recFileList.count > 0) {
                [self allowRotation:YES];
            }
        }
    });
    //add end by weibin 20181008
    
}


#pragma mark - 云存储录像搜索
-(void)checkCloudStorageEnable:(NVDevice *)device searchID:(int)nsearchID{
    
}

-(void)recCloudFileSearchThreadFunc:(NVDevice*)device searchID:(int)nSearchID{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->currentRecShowType == recShowTypeRuler) {
            self.weakDateTimeBtn.hidden = NO;
            self.weakDateTimeImg.hidden = NO;
            [self.weakShowtypeBtn setTitle:NSLocalizedString(@"event set", nil) forState:UIControlStateNormal];
        }
        self.recActivityView.hidden = NO;
        [self.recActivityView startAnimating];
        [self.recActivityView.superview bringSubviewToFront:self.recActivityView];
        [self.recFileSetView dismissTipsView];
        [self.recFileSetView setNoCloudFileTipsView:YES];//add by qin 20190221
    });

    
    //add by weibin 20181008
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self.weakDateTimeBtn.enabled = YES;
        //        NSLog(@"20181008 === yes , %s", __func__);
    });
    //add end by weibin 20181008
    
}

#pragma mark - 回放数据接收(代理回调)
//接收到数据
-(void)onReceiveFile:(int)nRecvTotalCount size:(int)nFileCount list:(NSArray *)fileList{
    
    //    if(fileList.count > 0){
    //        NSLog(@"20181011 =%s= count:%lu",__func__,(unsigned long)fileList.count);
    //    }
    
    //add by weibin 20181009
    if (self.nDisplayFileType != FILE_TYPE_ALL) {
        
        return ;
    }
    //add end weibin 20181009
    
    
    if(fileList.count > 0){
        [_recFileSetView dismissTipsView];
        [self setToolBtnEnable:YES];
        
        [self.recFileList addObjectsFromArray:fileList]; //Add into the array
        
        //[self sortRecList:_recFileList]; //Resort
        if (_recFileList && _recFileList.count > 0) {
            NSArray *tempArr = [self sortRecList:_recFileList];
            [_recFileList removeAllObjects];
            [_recFileList addObjectsFromArray: tempArr];
        }
        
        [self.recFileListSelect addObjectsFromArray:fileList]; //add to the array
        //[self sortRecList:self.recFileListSelect];
        if (self.recFileListSelect && self.recFileListSelect.count > 0){
            NSArray *tempArr = [self sortRecList: self.recFileListSelect];
            [self.recFileListSelect removeAllObjects];
            [self.recFileListSelect addObjectsFromArray: tempArr];
        }
        
        if (_currentRecordType == RecordTypeSD) {
            if (self.loginHandle.nVersion > 2 && self->currentRecShowType == recShowTypeRuler) {
                [_weakShowtypeBtn setTitle:NSLocalizedString(@"事件集", nil) forState:UIControlStateNormal];
                _playbackBottomToolView.hidden = YES;
                // switch the ruler
                _weakDateTimeBtn.hidden = YES;
                _weakDateTimeImg.hidden = YES;
                currentRecShowType = recShowTypeRuler;
                _recFileSetView.hidden = YES;
//                [self rulerScrollDidEndResult:0];
            }else{
//                still can't select
//                [self.recFileSetView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//                [self.recFileSetView selectCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            }
        }
        
//        if (self.loginHandle.nVersion > 2 &&_currentRecordType == RecordTypeSD) {
//
//        }
        
        //@Author: Caffe 2019.12.10
        {//@Begin
            //if(self.needAutoPlay == YES){
//            if(_currentRecordType == RecordTypeSD){
//                [self rulerScrollDidEndResult:0];
//            }
            //    self.needAutoPlay = NO;
            //}
        }//@End
        //@Author: Caffe
    }else {
        [_recFileSetView showNoFileTips];
//        iToast *toast = [iToast makeToast: NSLocalizedString(@"No video file found", @"No video file found")];
//        [toast show];
        
    }
}


- (NSArray* _Nullable) sortRecList:(NSArray* _Nullable) fileList {
    
    if (fileList == nil || [fileList count] <= 0) {
        return nil;
    }
    NSSet *recFileSet = [NSSet setWithArray:fileList];
    NSArray *tempArray = [NSMutableArray arrayWithArray:[recFileSet allObjects]];
    
    NSArray *sortedArray = [tempArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
        
        RecordVideoInfo * info1=obj1;
        RecordVideoInfo * info2=obj2;
        
        if (info1.nStartTime < info2.nStartTime) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        if (info1.nStartTime > info2.nStartTime) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    return sortedArray;
}


//Because the cloud storage video file does not have a start time nStartTime = 0, it can be sorted only according to the file ID
- (NSArray* _Nullable) sortCloudList:(NSArray *_Nullable)fileList{
    
    if (fileList == nil || [fileList count] <= 0) {
        return nil;
    }
    NSSet *recFileSet = [NSSet setWithArray:fileList];
    NSArray *tempArray = [NSMutableArray arrayWithArray:[recFileSet allObjects]];
    
    NSArray *sortedArray = [tempArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
        
        RecordVideoInfo * info1=obj1;
        RecordVideoInfo * info2=obj2;
        
        if (info1.nFileID < info2.nFileID) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        if (info1.nFileID > info2.nFileID) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    return sortedArray;
}

#pragma mark - Video file click to play

-(void) recItemAction:(NSIndexPath *)indexPath{
    
    RecordVideoInfo *fileInfo = _recFileListSelect[indexPath.row];
    currentRecIndex = (int) indexPath.row;
    _fileCurrentTime = fileInfo.nStartTime;
    _playbackSlider.value = 0.0;
    nProgressValue = 0;
    self.playBackToPlay.hidden = YES;
    // start playback
    //GWXLog(@"[Playback] LINE:%d", __LINE__);
    [self startPlayBack:self.loginResult file:fileInfo];
    
    
}

-(void)onProgressChange:(int) nProgress timeIndexID:(int)nTimeIndexID{
    
    nProgressValue = nProgress;
    RecordVideoInfo *info =nil;
    if (currentRecShowType == recShowTypeRuler) {
        info =_recFileList[currentRecIndex];
    }else{
        info =_recFileListSelect[currentRecIndex];
    }
    int fileTotalTime = info.nEndTime - info.nStartTime;
    int currentSec = fileTotalTime*(nProgressValue*0.01);
    _fileCurrentTime = info.nStartTime + currentSec;
    if (_playbackSlider && !isEditingSlider /*&& nPlayIndexId==nTimeIndexID*/) {
        
        [_playbackSlider setValue:nProgress];
        //        NSLog(@"20180930 ==nProgress== %d", nProgress);
        if (nProgress >= (self.loginResult.nVersion > 2 ? 100:99)) {
            
            _playbackSlider.value = 0.0;
            nProgressValue = 0.0;
            
            if (currentRecShowType == recShowTypeRuler) {
                if (currentRecIndex < _recFileList.count-1) {
                    currentRecIndex++;
                    NSLog(@"Triggered time positioning currentRecIndex = %d",currentRecIndex);
                    RecordVideoInfo *info =_recFileList[currentRecIndex];
                    _fileCurrentTime = info.nStartTime;
                    //GWXLog(@"[Playback] LINE:%d", __LINE__);
                    [self startPlayBack:_loginHandle file:_recFileList[currentRecIndex]];
                }else{
                    [self stopPlayBack];
                    isPlayingBack = NO;
                    self.playBackToPlay.hidden = NO;
                }
                
            }else{
                [self stopPlayBack];
                if(kWidth > kHeight){
                    
                    isPlayingBack = NO;
                    self.playBackToPlay.hidden = NO;
                    [self.playbackPlayAndStop setImage:[UIImage imageNamed:@"btn_play_white"] forState:UIControlStateNormal];
                    
                }else{
                    isPlayingBack = NO;
                    self.playBackToPlay.hidden = NO;
                }
            }
        }
    }
    
}
-(void)lblTimeOSDChange:(int)timeStr{
    
    RecordVideoInfo *info = nil;
    if (currentRecShowType == recShowTypeFileset) {
        if (currentRecIndex < self.recFileListSelect.count && self.recFileListSelect.count > 0) {
            info = self.recFileListSelect[currentRecIndex];
        }
        
    }else{
        if (currentRecIndex < self.recFileList.count && self.recFileList.count > 0) {
            info = self.recFileList[currentRecIndex];
        }
    }
    if (info == nil || _onBack) {
        return;
    }
    if (self.loginHandle.nVersion >2 && _currentRecordType == RecordTypeSD) {
//        _playbackTimeStartLbl.text = [NSString stringWithDuration:timeStr-info.nStartTime];
        NSString *timeDate = [NSString stringWithFormat:@"%@ 00:00:00",self.weakDateBtn.titleLabel.text];
        int timeStemp = (int)[self timeSwitchTimestamp:timeDate];
        currentRulerValue = timeStr - timeStemp;

    }else{
        
    }
    if(self.isNeedResetContext){
        self.isNeedResetContext = NO;
        [self.panoPlayer resetPanoBuffer];
    }
}
- (NSString *)timeFormatted:(int)totalSeconds{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

-(void) startPlayBack:(LoginHandle *)loginHandle file:(RecordVideoInfo *)fileInfo{
    if(_onBack){
        return;
    }
    [self stopPlay:NO]; // stop preview
    if(isPlayingBack){
        //stop the previous one
        [self stopPlayBack];
        
    }
    self.playBackToPlay.hidden = YES;
    // start playback
    [self.panoPlayer resetPause];
    [self.panoPlayer setCamType:loginHandle.nCamType];
    [self.panoPlayer setMode:13];
    [self.panoPlayer setNeedsLayout];
    [self.panoPlayer layoutIfNeeded];
    [self.panoPlayer setNeedsDisplay];
    if (_currentRecordType == RecordTypeOSS) {
////        CLDUser *user = [[CLDDatabaseManager defaultManager] userInfo];
//        [self.panoPlayer startCloudPlayBack:user.userID.intValue devID:self.device.NDevID pToken:user.accessToken sToken:user.accessToken ecsip:user.ecsIP ecsport:user.ecsPort.intValue file:fileInfo loginhandle:loginHandle];
    }else{
        if (loginHandle.nVersion>2) {
            //[self.panoPlayer StartPlayBackV30:loginHandle file:fileInfo currentTime:_fileCurrentTime];
            fileInfo.nCurrentTime = _fileCurrentTime;
            [self.panoPlayer startPlayBack:loginHandle file:fileInfo];
            
            [self.panoPlayer setCamType:loginHandle.nCamType];
            [self.panoPlayer setMode:13];
            [self.panoPlayer setNeedsLayout];
            [self.panoPlayer layoutIfNeeded];
            [self.panoPlayer setNeedsDisplay];
        }else{
            //[self.panoPlayer StartPlayBack:loginHandle file:fileInfo];
            [self.panoPlayer startPlayBack:loginHandle file:fileInfo];
        }
        self.weakShowtypeBtn.enabled = YES;
    }
    [self.panoPlayer setMode:13];
    [self.panoPlayer setPlaybackDelegate:self];
    [_playbackSlider setUserInteractionEnabled:YES];
    _playbackTimeStartLbl.text = @"00:00:00";
    _playbackTimeEndLbl.text = [self timeFormatted:fileInfo.nFileTimeLen];
    [_playbackPlayAndStop setImage:[UIImage imageNamed:@"btn_stop_white"] forState:UIControlStateNormal]; // add by GWX 20190417
    [_playBackToPlay setImage:[UIImage imageNamed:@"hs_btn_stop2"] forState:UIControlStateNormal];
    // modify by GWX 20190417, Increase the non-horizontal screen judgment of the timeline
    if(currentRecShowType == recShowTypeRuler && (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))){
        _playbackBottomToolView.hidden = YES;
    }else{
        
        _playbackBottomToolView.hidden = NO;
    }
    // end modify by GWX 20190417
    isPlayingBack = YES;
    isPlayBackPause = NO;

}

-(void) stopPlayBack{
    
    if(isPlayBackPause){
    // if it was pausing at the time
        self.playBackToPlay.hidden = YES;
    }
    // stop playback
    [self.panoPlayer resetPause];
    if (_currentRecordType == RecordTypeOSS) {
        
    }else{
        
        if (self.loginHandle.nVersion > 2) {
            //[self.panoPlayer stopPlayBackV30];
            [self.panoPlayer stopPlayBack];
        }else{
            //[self.panoPlayer StopPlayBack];
            [self.panoPlayer stopPlayBack];
        }
        
    }
    isPlayingBack = NO;
    [self.panoPlayer setPlaybackDelegate:nil];
    _playbackBottomToolView.hidden = YES;
    //[_playbackSlider setValue:0];
    [_playbackSlider setUserInteractionEnabled:NO];
    isPlayBackPause = NO;
    [_playBackToPlay setImage:[UIImage imageNamed:@"hs_btn_play2"] forState:UIControlStateNormal];
    // add by GWX 20190416
    if(kWidth > kHeight)    // horizontal screen
        _playbackBottomToolView.hidden = NO;
    else
        _playbackBottomToolView.hidden = YES;
    // end add by GWX 20190416
}
#pragma mark -


#pragma mark - Playback Action - Determine the click event based on the button's tag
-(void)recordType:(id)sender{
    UIButton *btn = sender;
    switch (btn.tag) {
        case 0:
            if (self.currentRecordType != RecordTypeSD) {
                [self allowRotation:NO];
            }
            break;
        case 1:
            if (self.currentRecordType != RecordTypeOSS) {
                [self allowRotation:NO];
            }
            break;
        default:
            break;
    }
    //modify by weibin 20181124
    UIButton *senderBtn = (UIButton*)sender;
    BOOL bIsSameBtn = (self.currentRecordType == RecordTypeSD && senderBtn.tag == 0 )||(self.currentRecordType == RecordTypeOSS && senderBtn.tag == 1);
    if (usingDownloaders.count >0 || (isPlayingBack && !bIsSameBtn)) {
        X_WeakSelf;
        UIAlertController *alert;
        
        if (usingDownloaders.count >0) {
            alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"There is currently a download task", @"There is a download task currently") message:NSLocalizedString(@"Whether to cancel the download", @"Whether to cancel the download") preferredStyle:UIAlertControllerStyleAlert];
        } else {
            alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Stop playing?", @"Stop playing?") preferredStyle:UIAlertControllerStyleAlert];
        }
        //modify end by weibin 20181124
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            X_StrongSelf;
            NSLog(@"isdownlog %d" ,strongSelf->isDownloading);
            [self allowRotation:YES];
        }];
        
        // confirm button
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            X_StrongSelf;
            
            if (self.playbackBottomToolView.frame.size.width == kWidth){
                [strongSelf btnBacktoPortraitClick:nil];
            }
            
            RecordVideoDownloader *rec = [strongSelf->usingDownloaders objectForKey:@(strongSelf->currentRecIndex)];
            if (rec) {
                [strongSelf StopAllDownload];
                NSLog(@"stop download");
                [strongSelf.weakDownloadBtn setImage:[UIImage imageNamed:@"btn_load"] forState:UIControlStateNormal];
            }
            [strongSelf changeRecordType:sender];
        }];
        [cancelAction setValue:[UIColor grayColor] forKey:@"titleTextColor"];
        [confirmAction setValue:[UIColor blueColor] forKey:@"titleTextColor"];
        [alert addAction:cancelAction];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        if (!bIsSameBtn) {
            [self changeRecordType:sender];
        }
        
        
    }
}


-(void)changeRecordType:(UIButton *)btn{  //add by xie yongsheng 20181215 Encapsulated to reduce code duplication and facilitate maintenance
    nSearchThreadID++;
    switch (btn.tag) {
        case 0:
            // add by GWX 20200324 (The original enabled=no is written to the first line of this function. If the file type is clicked repeatedly, the timeline/event set cannot be switched, so it is necessary to judge whether it is a repeated click before enabled=no)
            if(_currentRecordType == RecordTypeSD) return;
            _weakShowtypeBtn.enabled = NO;
            // end add by GWX 20200324
//            [self allowRotation:YES];
            [self changeToSDCardPlayback];
            break;
        case 1:
            // add by GWX 20200324 (The original enabled=no is written to the first line of this function. If the file type is clicked repeatedly, the timeline/event set cannot be switched, so it is necessary to judge whether it is a repeated click before enabled=no )
            if(_currentRecordType == RecordTypeOSS) return;
            _weakShowtypeBtn.enabled = NO;
            // end add by GWX 20200324
//            [self allowRotation:YES];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isShouldShowSomeGoodThings"]) {
//                [self changeToCloudFilePlayBack];
            }else{
            }
            
            //modify by qin 20190417
            //            if (_weakOSSBtn == nil) {
            //                [_recActivityView stopAnimating];
            //                [self backToRealTimePlaying];
            //            }else{
//            [self changeToCloudFilePlayBack];
            //            }
            //end by qin 20190417
            break;
        case 2:
            // return to preview
            [_recActivityView stopAnimating];
            break;
        default:
            break;
    }
}


-(void)changeToSDCardPlayback{
    if(_currentRecordType == RecordTypeSD){
        return;
    }

    [self.weakDateTimeBtn setEnabled:YES];
    [self.recFileSetView setNoCloudFileTipsView:YES];
    
    //Open TF card video search
    _currentRecordType = RecordTypeSD;
    [_weakSDBtn setImage:[UIImage imageNamed:@"btn_sdcard_select"] forState:UIControlStateNormal];
    [_weakOSSBtn setImage:[UIImage imageNamed:@"btn_ycc"] forState:UIControlStateNormal];
    [_weakDateTimeBtn setTitle:@"Please select the video playback time period" forState:UIControlStateNormal];
    
    NSTimeInterval timeBetween = [_currentSelectDate timeIntervalSinceDate:[self latestDate]];
    self.recFileSetView.hidden = NO;
    if (timeBetween<=0) {
        [self startSearchRecFile:RecordTypeSD];
    }else{
        [_recFileSetView showNoFileTips];
    }
}



-(BOOL)matchingDevice:(NSArray *)array{
    for (NSDictionary *dic in array) {
        if ([dic[@"device_id"] intValue] == self.device.NDevID) {
            return YES;
        }
    }
    return NO;
}

-(void)setToolBtnEnable:(BOOL)enable{
    if (enable) {
        //XLog(@"Set the toolbar button to be clickable");
    }else{
        //XLog(@"Set the toolbar button to be unclickable");
    }
    self.weakSoundBtn.enabled = enable;
    self.weakDownloadBtn.enabled = enable;
    self.weakScreenShotBtn.enabled = enable;
    self.weakFullScreenBtn.enabled = enable;
}

#pragma mark - Playback tool button
-(void)playBackButtonAction:(id)sender{
    
    UIButton *btn = sender;
    
    switch(btn.tag) {
            
        case 0:
            // playback sound
            self.m_bSoundEnable = !_m_bSoundEnable;
            if (self.m_bSoundEnable) {
                
                [sender setImage:[UIImage imageNamed:@"btn_voice_open"] forState:UIControlStateNormal];
                
            }else{
                
                [sender setImage:[UIImage imageNamed:@"btn_voice_close"] forState:UIControlStateNormal];
            }
            
            break;
        case 1:
// download
            if(currentRecIndex >= 0){
#ifdef MJPEG_Supported
                [self DownOneRecfile:btn];
#else
                if(self.panoPlayer.frametype == FRAMETYPE_JPEG){
// iToast *toast = [iToast makeToast:NSLocalizedString(@"This function is not currently supported", nil)];
// [toast setToastPosition:kToastPositionCenter];
// [toast setToastDuration:kToastDurationShort];
// [toast show];
                }
                else{
                    [self DownOneRecfile:btn];
                }
#endif
            }else{
                
// iToast *toast = [[iToast alloc] initWithText:NSLocalizedString(@"Please select the video file first", nil)];
//                toast.toastPosition = kToastPositionCenter;
//                toast.toastDuration = kToastDurationNormal;
//                [toast show];
            }
            
            break;
        case 2:
            // 截图
            if(currentRecIndex >= 0 || isPlayingBack == YES){
                
                [self screenshotAction:sender];
                
            }else{
                
                return;
            }
            
            break;
        case 3:
            // landscape
            if(currentRecIndex >= 0 || isPlayingBack == YES){

                [self btnLanscapeClick:nil];

            }else{

                return;
            }
            break;
        default:
            break;
    }
    
}

-(void) btnBacktoPortraitClick:(id)sender{
    // switch from horizontal to vertical
    NSNumber * value = [NSNumber numberWithInt:UIDeviceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
}

-(void) btnLanscapeClick:(id)sender{
    // switch from portrait to landscape
    NSNumber * value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
}

-(void)dateSelectedAction:(id)sender{ // update by xie yongsheng 20181022 When adding a download, a pop-up prompt will pop up whether to cancel the download. Click OK to select the date
// if (self.device.serviceID.integerValue ==0 &&_currentRecordType ==RecordTypeOSS) {
// return;
// }
    
if (usingDownloaders.count >0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"There is a download task currently", @"There is a download task currently") message:NSLocalizedString(@"Whether to cancel the download", @"Whether to cancel the download") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"isdownlog %d" ,self->isDownloading);
        }];
// confirm button
        X_WeakSelf;
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            X_StrongSelf;
            // stop the download first
            NSLog(@"stop download");
            [strongSelf StopAllDownload];
            [strongSelf.weakDownloadBtn setImage:[UIImage imageNamed:@"btn_load"] forState:UIControlStateNormal];
            
            strongSelf->nSearchThreadID++;
            [strongSelf selectCalendar];
        }];
        
        [cancelAction setValue:[UIColor grayColor] forKey:@"titleTextColor"];
        [confirmAction setValue:[UIColor blueColor] forKey:@"titleTextColor"];
        [alert addAction:cancelAction];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        [self selectCalendar];
    }
}
-(void)selectCalendar{ //add by xie yongsheng Wrap it up to reduce code duplication
    //Playback date selection
    if(_calendar == nil){
        
        __weak typeof(self) weakSelf = self;
        _calendar = [[ZTCalendar alloc] initWithFrame:self.playBackBgView.frame];
        _calendar.itemClickAction = ^(NSDate *date) {
            X_StrongSelf;
            
            // add by GWX 20200330, switch the date to stop playing
            [strongSelf stopAllPlay];
            // end add by GWX 20200330
            [strongSelf allowRotation:YES];
            strongSelf.currentSelectDate = date;
            //modify by qin 20181017 Select future date UI changes
            NSTimeInterval timeBetween = [date timeIntervalSinceDate:[strongSelf latestDate]];
            if (timeBetween<=0) {
                if(strongSelf.currentRecordType == RecordTypeSD){
                    // TFCard search
                    [strongSelf startSearchRecFile:RecordTypeSD];
                }else if(strongSelf.currentRecordType == RecordTypeOSS){
                    // yun
                    [strongSelf startSearchRecFile:RecordTypeOSS];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    X_StrongSelf;
                    [strongSelf.weakDateBtn setTitle:[date dateString] forState:UIControlStateNormal];
                    [strongSelf.weakDateTimeBtn setTitle:NSLocalizedString(@"all day", nil) forState:UIControlStateNormal];
                });
            }else{
                [strongSelf.recFileList removeAllObjects];
                strongSelf->currentRecIndex = -1;
                
                [strongSelf.recActivityView stopAnimating];
                if(strongSelf.currentRecordType == RecordTypeSD){
                    strongSelf.recFileSetView.fileSetList = nil;
                    strongSelf.recFileSetView.hidden = NO;
                    [strongSelf.recFileSetView showNoFileTips];
                }else if(strongSelf.currentRecordType == RecordTypeOSS){
                   
                }
                
                [strongSelf setToolBtnEnable:NO];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    X_StrongSelf;
                    [strongSelf.weakDateBtn setTitle:[date dateString] forState:UIControlStateNormal];
                    [strongSelf.weakDateTimeBtn setTitle:NSLocalizedString(@"all day", nil) forState:UIControlStateNormal];
                });
            }
            //end by qin 20181017
            strongSelf->currentRecIndex = 0;
        };
    }
    
    [self.view addSubview:_calendar];
}


-(void)timeSelectedAction:(UIButton*)sender{
if (usingDownloaders.count >0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"There is a download task currently", @"There is a download task currently") message:NSLocalizedString(@"Whether to cancel the download", @"Whether to cancel the download") preferredStyle:UIAlertControllerStyleAlert];
        X_WeakSelf;
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            X_StrongSelf;
            NSLog(@"isdownlog %d" ,strongSelf->isDownloading);
        }];
        // confirm button
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            X_StrongSelf;
            // stop all downloads first
            [strongSelf StopAllDownload];
            [strongSelf.weakDownloadBtn setImage:[UIImage imageNamed:@"btn_load"] forState:UIControlStateNormal];
            
            SelectTimeView *view = [[SelectTimeView alloc]initWithFrame:[UIScreen mainScreen].bounds];
            view.delegate = strongSelf;
            [view show];
        }];
        
        [cancelAction setValue:[UIColor grayColor] forKey:@"titleTextColor"];
        [confirmAction setValue:[UIColor blueColor] forKey:@"titleTextColor"];
        [alert addAction:cancelAction];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        SelectTimeView *view = [[SelectTimeView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        view.delegate = self;
        [view show];
    }
}

//Playback the selected time period
-(void)selectedTimeBlock:(NSString *)str{
    
    if (usingDownloaders.count >0) {
        // stop the download first
        NSLog(@"stop download");
        [self StopAllDownload];
        [_weakDownloadBtn setImage:[UIImage imageNamed:@"btn_load"] forState:UIControlStateNormal];
    }
    
    if(isPlayingBack || isPlayBackPause){
        nProgressValue = 0;
        _playBackToPlay.hidden = YES;
        [self stopPlayBack];
    }
    [_weakDateTimeBtn setTitle:str forState:UIControlStateNormal];
    [self.recFileListSelect removeAllObjects];
    NSMutableArray *newArr = [NSMutableArray array];
    if (_recFileList.count > 0) {
       if ([str isEqualToString:NSLocalizedString(@"all day", nil)]) {
            [newArr addObjectsFromArray:_recFileList];
            NSArray *tempArr = nil;
            if(_currentRecordType == RecordTypeSD){
                tempArr = [self sortRecList:newArr];
            }else if(_currentRecordType == RecordTypeOSS){
                tempArr = [self sortCloudList:newArr];
            }
            [newArr removeAllObjects];
            [newArr addObjectsFromArray:tempArr];
            [self.recFileListSelect addObjectsFromArray:newArr];
            _recFileSetView.fileSetList = newArr;
            [self setToolBtnEnable:YES];
        }else{
            if (self.loginHandle.nVersion > 2 && _currentRecordType==RecordTypeSD) {
                NSString *timeDate = [NSString stringWithFormat:@"%@ %@:00:00",self.weakDateBtn.titleLabel.text,str];
                int timeStemp = (int)[self timeSwitchTimestamp:timeDate];
                for (RecordVideoInfo *info in _recFileList) {
                    if (timeStemp <= info.nStartTime && info.nStartTime < timeStemp+60*60) {
                        [newArr addObject:info];
                    }
                }
            }else{
                for (RecordVideoInfo *info in _recFileList) {
                    if ([str intValue] <= info.nStartHour && info.nStartHour < [str intValue]+1) {
                        [newArr addObject:info];
                    }
                }
            }
            
            if (newArr.count > 0) {
                NSArray *tempArr = nil;
                if(_currentRecordType == RecordTypeSD){
                    tempArr = [self sortRecList:newArr];
                }else if(_currentRecordType == RecordTypeOSS){
                    tempArr = [self sortCloudList:newArr];
                }
                [newArr removeAllObjects];
                [newArr addObjectsFromArray:tempArr];
                [self.recFileListSelect addObjectsFromArray:newArr];
                _recFileSetView.fileSetList = newArr;
                [self setToolBtnEnable:YES];
            }else{
                _recFileSetView.fileSetList = newArr;
            
                [self setToolBtnEnable:NO];
            }
        }
    }else{
        [self setToolBtnEnable:NO];
     
    }

    [self reloadRecFileSetView];//add by weibin 20181009
//    if(self.currentRecordType == RecordTypeSD){
//        currentRecIndex = (int)self.recFileList.count - 1;
//    }else{
//        currentRecIndex = 0;
//    }
    currentRecIndex = -1;

}



-(void)showTypeAction:(id)sender{
    
    if(currentRecShowType == recShowTypeFileset ){
if (self.loginResult.nVersion<3) {//modify by qin 20181101 loginHandle->loginResult The case of unsuccessful login during search is not handled, the loginHandle may be empty, resulting in no timeline after the beginning
// iToast *toast = [iToast makeToast:NSLocalizedString(@"This device does not support timeline mode, please upgrade to the latest hardware version!", @"")];
//            [toast setToastPosition:kToastPositionCenter];
//            [toast setToastDuration:kToastDurationShort];
//            [toast show];
            return;
        }
    }
    
if (usingDownloaders.count >0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"There is a download task currently", @"There is a download task currently") message:NSLocalizedString(@"Whether to cancel the download", @"Whether to cancel the download") preferredStyle:UIAlertControllerStyleAlert];
        X_WeakSelf;
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            X_StrongSelf;
            NSLog(@"isdownlog %d" ,strongSelf->isDownloading);
        }];
        
       // confirm button
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            X_StrongSelf;
            // stop the download first
            NSLog(@"stop download");
            [strongSelf StopAllDownload];
            [strongSelf.weakDownloadBtn setImage:[UIImage imageNamed:@"btn_load"] forState:UIControlStateNormal];
            
            [strongSelf changeShowType]; //update by xie yongsheng 20190301
        }];
        
        [cancelAction setValue:[UIColor grayColor] forKey:@"titleTextColor"];
        [confirmAction setValue:[UIColor blueColor] forKey:@"titleTextColor"];
        [alert addAction:cancelAction];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        [self changeShowType];  //update by xie yongsheng 20190301
    }
}


-(void)changeShowType{ //add by xie yongsheng 20190301 Extract this part of the repetitive code for reuse
    
        if (isPlayingBack == YES) {
            _playbackBottomToolView.hidden = NO;
        }else{
            _playbackBottomToolView.hidden = YES;
        }
        _weakDateTimeBtn.hidden = NO;
        _weakDateTimeImg.hidden = NO;
// toggle event set
        currentRecShowType = recShowTypeFileset;
        [_weakShowtypeBtn setTitle:NSLocalizedString(@"event set", nil) forState:UIControlStateNormal];
        _recFileSetView.hidden = NO;
        if (currentRecIndex < _recFileList.count && currentRecIndex >= 0) {
            [_recFileSetView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentRecIndex inSection:0]];
        }
        if (_recFileSetView.fileSetList.count > 0) {
            [self setToolBtnEnable:YES];
        }else{
            [self setToolBtnEnable:NO];
        }
[self selectedTimeBlock:NSLocalizedString(@"all day", nil)];
//    }
}





#pragma mark - 录像下载

//download callback
-(void)onDownloadProcess:(id)downloader flag:(int)nFlag process:(int) nProcess{
    
    RecordVideoDownloader *recDownloader = downloader;
    int downloaderIndex = recDownloader.nTag;
    int tempstatu = 0;//Record the last callback status
    RecordVideoInfo *recinfo = nil;
    if (currentRecShowType == recShowTypeRuler) {
        recinfo = [_recFileList objectAtIndex:downloaderIndex];
    }else{
        NSAssert(downloaderIndex < _recFileListSelect.count, @"download callback out of bounds == event set");
        if(downloaderIndex < _recFileListSelect.count){
            recinfo = [_recFileListSelect objectAtIndex:downloaderIndex];
        }else{
            [self StopAllDownload];
            return;
        }
    }
    tempstatu = recinfo.nDownloadStatus; //Last callback status
    NSLog(@"tag %d nFlag ------ %d nProcess%d ",downloaderIndex, nFlag, nProcess);
    
if (nFlag == DOWNLOAD_PROC_FINISH) {//Download successful
        dispatch_async(dispatch_get_main_queue(), ^{
// iToast *toast = [iToast makeToast:NSLocalizedString(@"download complete", @"download complete")];
//            [toast setToastPosition:kToastPositionCenter];
//            [toast setToastDuration:kToastDurationShort];
//            [toast show];
            [self.weakDownloadBtn setImage:[UIImage imageNamed:@"btn_load"] forState:UIControlStateNormal];
        });
        recinfo.nDownloadStatus = DOWNLOAD_PROC_FINISH;
        [self StopOneDownloader:recDownloader];
        isDownloading = NO;
        
}else if (nFlag == DOWNLOAD_PROC_CONNECTING && tempstatu !=DOWNLOAD_PROC_NET_ERR && tempstatu != DOWNLOAD_PROC_CLOSE ){//connecting
        // NSLog(@"Connecting");
        
        isDownloading = YES;
        recinfo.nDownloadStatus = DOWNLOAD_PROC_CONNECTING;
        
}else if (nFlag == DOWNLOAD_PROC_DOWNLOADING && tempstatu != DOWNLOAD_PROC_FINISH && tempstatu != DOWNLOAD_PROC_CLOSE && tempstatu !=DOWNLOAD_PROC_NET_ERR){//Downloading
        
        recinfo.nDownloadStatus = DOWNLOAD_PROC_DOWNLOADING;
        isDownloading = YES;
        timercount = 99999;//Reset download timeout
        recinfo.nDownloadProcess = nProcess * 0.01;
        if (currentRecShowType == recShowTypeRuler) {
            [_recFileList replaceObjectAtIndex:downloaderIndex withObject:recinfo];
        }else{
            [_recFileListSelect replaceObjectAtIndex:downloaderIndex withObject:recinfo];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.recFileSetView updateItemWithIndexPath:[NSIndexPath indexPathForItem:downloaderIndex inSection:0]];
        });
        
    }else if((nFlag == DOWNLOAD_PROC_NET_ERR || nFlag == DOWNLOAD_PROC_CLOSE) && (tempstatu != DOWNLOAD_PROC_FINISH)){//Return directly to failure
        NSLog(@"Error %d",downloaderIndex);
        isDownloading = NO;
        [self StopOneDownloader:recDownloader];
        [VideoPaths removeObjectForKey:@(downloaderIndex)];
        recinfo.nDownloadProcess = 0;
        if (currentRecShowType == recShowTypeRuler) {
            [_recFileList replaceObjectAtIndex:downloaderIndex withObject:recinfo];
        }else{
            [_recFileListSelect replaceObjectAtIndex:downloaderIndex withObject:recinfo];
        }
        if (current_download_path) {
            [NSThread sleepForTimeInterval:0.5];
            unlink([current_download_path UTF8String]);
            current_download_path = nil;
        }
    }
    
    if (tempstatu != nFlag) {
        //download status change
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self->currentRecShowType == recShowTypeRuler) {
                [self.recFileList replaceObjectAtIndex:downloaderIndex withObject:recinfo];
            }else{
                [self.recFileListSelect replaceObjectAtIndex:downloaderIndex withObject:recinfo];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.recFileSetView updateItemWithIndexPath:[NSIndexPath indexPathForItem:downloaderIndex inSection:0]];
            });
            
        });
    }
    
}

//Single task download main method -- click to download
- (void)DownOneRecfile:(UIButton*)sender{
    
    if (currentRecShowType == recShowTypeRuler) {
// iToast *toast = [iToast makeToast:NSLocalizedString(@"Please select the event set video to download", @"")];
//        [toast setToastPosition:kToastPositionCenter];
//        [toast setToastDuration:kToastDurationShort];
//        [toast show];
        
        return;
    }
    
    if(_recFileList.count <= 0){
        return;
    }
    
    if(!usingDownloaders){
        
        usingDownloaders = [NSMutableDictionary dictionary];
    }
    
    if (!reuseDownloaders){
        
        reuseDownloaders =[NSMutableArray array];
    }
    
    if (!VideoPaths) {
        VideoPaths = [NSMutableDictionary dictionary];
    }
    
    if (usingDownloaders.count <=0) {
//There are currently no tasks being downloaded
        [sender setImage:[UIImage imageNamed:@"btn_loading"] forState:UIControlStateNormal];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self StartDownloadOneRecfileWithIndex:(int)self->currentRecIndex];
        });
        
    }
else {//There is currently a download task to stop the download first
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"There is a download task currently", @"There is a download task currently") message:NSLocalizedString(@"Whether to cancel the download", @"Whether to cancel the download") preferredStyle:UIAlertControllerStyleAlert];
            X_WeakSelf;
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                X_StrongSelf;
                NSLog(@"isdownlog %d" ,strongSelf->isDownloading);
            }];
            
// confirm button
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                X_StrongSelf;
                [strongSelf downloadRecFile];     //update by xie yongsheng 20190301
            }];
            
            [cancelAction setValue:[UIColor grayColor] forKey:@"titleTextColor"];
            [confirmAction setValue:[UIColor blueColor] forKey:@"titleTextColor"];
            [alert addAction:cancelAction];
            [alert addAction:confirmAction];
            [self presentViewController:alert animated:YES completion:nil];
        
        
    }
}

-(void)downloadRecFile{ //add by xie yongsheng 20190301 Extract this part of the repetitive code for reuse
    if(usingDownloaders.count > 0){
        [_weakDownloadBtn setImage:[UIImage imageNamed:@"btn_load"] forState:UIControlStateNormal];
        [self StopAllDownload];
        NSLog(@"stop download");
    }else{
        [self StartDownloadOneRecfileWithIndex:(int)currentRecIndex];
    }
}

//Start downloading the selected video file
-(void) StartDownloadOneRecfileWithIndex:(int)Index{
    
    if (currentRecShowType == recShowTypeRuler) {
        if(self.recFileList == nil || self.recFileList.count <= Index){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.weakDownloadBtn setImage:[UIImage imageNamed:@"btn_load"] forState:UIControlStateNormal];
            });
            return;
        }
    }else{
        if(self.recFileListSelect == nil || self.recFileListSelect.count <= Index){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.weakDownloadBtn setImage:[UIImage imageNamed:@"btn_load"] forState:UIControlStateNormal];
            });
            return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
// iToast *toast = [iToast makeToast:NSLocalizedString(@"Downloading video", @"")];
//        [toast setToastPosition:kToastPositionCenter];
//        [toast setToastDuration:kToastDurationShort];
//        [toast show];
    });
    RecordVideoDownloader *recDownloader = [reuseDownloaders lastObject];//Reuse pool fetch
    
    if (!recDownloader) {
        
        recDownloader = [[RecordVideoDownloader alloc]init];
        recDownloader.nTag = Index;
        recDownloader.downloadDelegate = self;
        // add to available queue
        [usingDownloaders setObject:recDownloader forKey:@(Index)];
        
    }else {
        
        recDownloader.nTag = Index;
        recDownloader.downloadDelegate = self;
        
        // handle the reuse pool
        [reuseDownloaders removeObject:recDownloader]; //Remove from reuse pool
        [usingDownloaders setObject:recDownloader forKey:@(Index)]; //Add to the available queue
    }
    
    RecordVideoInfo *rec = nil;
    if (currentRecShowType == recShowTypeRuler) {
        rec = [_recFileList objectAtIndex:Index];
    }else{
        rec = [_recFileListSelect objectAtIndex:Index];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *strVideoName=[NSString stringWithFormat:@"rec_%@(%i).mp4",currentDateStr, [_loginHandle nDevID]];
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//    NSString *strMP4FilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",filePath]];// 保存文件的名称
    NSString *strMP4FilePath = [KAlbumVideoPath stringByAppendingPathComponent:strVideoName];

    current_download_path = strMP4FilePath;
    
    rec.nDownloadStatus = DOWNLOAD_PROC_CONNECTING;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self->currentRecShowType == recShowTypeRuler) {
            [self.recFileList replaceObjectAtIndex:Index withObject:rec];
        }else{
            [self.recFileListSelect replaceObjectAtIndex:Index withObject:rec];
        }
        
        [self.recFileSetView updateItemWithIndexPath:[NSIndexPath indexPathForItem:Index inSection:0]];
        
    });
    
    
    if (_currentRecordType ==RecordTypeOSS ) {
//        strVideoName=[NSString stringWithFormat:@"%@(%i).mp4",[rec strFileName],self.device.NDevID];
//        strMP4FilePath = [KAlbumVideoPath stringByAppendingPathComponent:strVideoName];
//         current_download_path = strMP4FilePath;
//        CLDUser *user = [[CLDDatabaseManager defaultManager] userInfo];
//        [recDownloader startDownloadCloudVideo:strMP4FilePath handle:self.loginResult rec:rec accessToken:user.accessToken ecsIP:user.ecsIP ecsPort:user.ecsPort nDevID:self.device.NDevID nAccountID:user.userID.intValue];
//        //        [recDownloader StartDownLoadCloudFile:strMP4FilePath handle:self.loginResult rec:rec accessToken:user.accessToken ecsIP:user.ecsIP ecsPort:user.ecsPort nDevID:self.device.NDevID nAccountID:user.userID.intValue];
    }else{
        [recDownloader startDownloadRecordVideo:strMP4FilePath handle:self.loginResult rec:rec];
        //        [recDownloader StartDownLoadRecFile:strMP4FilePath handle:self.loginResult  rec:rec];
    }
    
    isDownloading = YES;
    
    if (isDownloading) [VideoPaths setObject:strMP4FilePath forKey:@(Index)];
    
}
//stop downloading a video file
-(void)StopOneDownloader:(RecordVideoDownloader*)downloader{
    
    int downloaderIndex = downloader.nTag;
    [downloader stopDownLoadVideo];
    [usingDownloaders removeObjectForKey:@(downloaderIndex)];
    [reuseDownloaders addObject:downloader];
    
    
}
//stop all downloads
-(void)StopAllDownload{
    if (usingDownloaders.count>0) {
        [usingDownloaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            RecordVideoDownloader *recDownloader = obj;
            int downloaderIndex = recDownloader.nTag;
            RecordVideoInfo *rec = nil;
            if (self->currentRecShowType == recShowTypeRuler) {
                rec = [self.recFileList objectAtIndex:downloaderIndex];
            }else{
                rec = [self.recFileListSelect objectAtIndex:downloaderIndex];
            }
            //1. Stop downloading
            [recDownloader stopDownLoadVideo];
            self->isDownloading = NO;
            // handle the reuse pool
            [self->usingDownloaders removeObjectForKey:@(downloaderIndex)];//Remove in progress
            [self->reuseDownloaders addObject:recDownloader];//Reuse pool recycling
            [self->VideoPaths removeObjectForKey:@(downloaderIndex)];
            rec.nDownloadStatus = DOWNLOAD_PROC_BREAK;
            rec.nDownloadProcess = 0;
            if (self->currentRecShowType == recShowTypeRuler) {
                [self.recFileList replaceObjectAtIndex:downloaderIndex withObject:rec];
            }else{
                [self.recFileListSelect replaceObjectAtIndex:downloaderIndex withObject:rec];
            }
            [self.recFileSetView updateItemWithIndexPath:[NSIndexPath indexPathForItem:downloaderIndex inSection:0]];
        }];
    }
    
    if (current_download_path) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [NSThread sleepForTimeInterval:0.5];
            unlink([self->current_download_path UTF8String]);
            self->current_download_path = nil;
        });
    }
}

#pragma mark - Video playback progress bar event

-(void)recProgressTouchDown:(ZTPlaySlider *)slider{
    
    isEditingSlider=YES;
    
}
-(void)recProgressTouchUpInside:(ZTPlaySlider *)slider{
    
    if (isEditingSlider) {
        
        if (self.loginResult.nVersion > 2 && _currentRecordType ==RecordTypeSD) {
            int value = slider.value;
            RecordVideoInfo *info =_recFileListSelect[currentRecIndex];
            int fileTotalTime = info.nEndTime - info.nStartTime;
            int currentSec = fileTotalTime*(value*0.01);
            _fileCurrentTime = info.nStartTime + currentSec;
            if (slider.value > 99) {
                _playbackSlider.value = 0.0;
                nProgressValue = 0.0;
                if(kWidth > kHeight){
                    isPlayBackPause = YES;
                    isPlayingBack = NO;
                    [self.playbackPlayAndStop setImage:[UIImage imageNamed:@"btn_play_white"] forState:UIControlStateNormal];
                    
                }else{
                    isPlayBackPause = YES;
                    isPlayingBack = NO;
                }
                self.playBackToPlay.hidden = NO;
                isEditingSlider = NO;
                if (currentRecIndex < _recFileListSelect.count-1) {
                    currentRecIndex++;
                    RecordVideoInfo *info =_recFileListSelect[currentRecIndex];
                    _fileCurrentTime = info.nStartTime ;
                }else{
                    
                }
            }
            
//GWXLog(@"[Playback] LINE:%d", __LINE__);
            [self startPlayBack:_loginHandle file:_recFileListSelect[currentRecIndex]];
            
        }else{
            if (slider.value > 99) {
                
                _playbackSlider.value = 0.0;
                nProgressValue = 0.0;
                //GWXLog(@"[Playback] LINE:%d", __LINE__);
                [self startPlayBack:_loginHandle file:_recFileListSelect[currentRecIndex]];
                [_panoPlayer timeIndexWhenPause:nProgressValue];
                if(kWidth > kHeight){
                    isPlayBackPause = YES;
                    isPlayingBack = NO;
                    [self.playbackPlayAndStop setImage:[UIImage imageNamed:@"btn_play_white"] forState:UIControlStateNormal];
                    
                }else{
                    isPlayBackPause = YES;
                    isPlayingBack = NO;
                }
                self.playBackToPlay.hidden = NO;
                isEditingSlider = NO;
                return;
                
            }
            if (slider.value == 0) {
//GWXLog(@"[Playback] LINE:%d", __LINE__);
                [self startPlayBack:_loginHandle file:_recFileListSelect[currentRecIndex]];
            }
            
            nPlayIndexId = [_panoPlayer setPlayProgress:slider.value];
        }
        
    }
    
    isEditingSlider=NO;
    
}

-(void)recProgressTouchCancel:(ZTPlaySlider *)slider{
    
    isEditingSlider = NO;
    
}

-(void)recProgressTouchUpOutside:(ZTPlaySlider *)slider{//add by luo 20180726
    
    isEditingSlider = NO;
    
}

-(void)recProgressTouchOutside:(ZTPlaySlider*)slider{
    if (isEditingSlider) {
        
        if (self.loginResult.nVersion > 2 && _currentRecordType ==RecordTypeSD) {
            int value = slider.value;
            RecordVideoInfo *info =_recFileListSelect[currentRecIndex];
            int fileTotalTime = info.nEndTime - info.nStartTime;
            int currentSec = fileTotalTime*(value*0.01);
            _fileCurrentTime = info.nStartTime + currentSec;
            if (slider.value > 99) {
                _playbackSlider.value = 0.0;
                nProgressValue = 0.0;
                if(kWidth > kHeight){
                    isPlayBackPause = YES;
                    isPlayingBack = NO;
                    [self.playbackPlayAndStop setImage:[UIImage imageNamed:@"btn_play_white"] forState:UIControlStateNormal];
                    
                }else{
                    isPlayBackPause = YES;
                    isPlayingBack = NO;
                }
                isEditingSlider = NO;
                self.playBackToPlay.hidden = NO;
                if (currentRecIndex < _recFileListSelect.count-1) {
                    currentRecIndex++;
                    RecordVideoInfo *info =_recFileListSelect[currentRecIndex];
                    _fileCurrentTime = info.nStartTime ;
                }else{
                    
                }
            }
            
//GWXLog(@"[Playback] LINE:%d", __LINE__);
            [self startPlayBack:_loginHandle file:_recFileListSelect[currentRecIndex]];
            
        }else{
            if (slider.value > 99) {
                
                _playbackSlider.value = 0.0;
                nProgressValue = 0.0;
                //GWXLog(@"[Playback] LINE:%d", __LINE__);
                [self startPlayBack:_loginHandle file:_recFileListSelect[currentRecIndex]];
                [_panoPlayer timeIndexWhenPause:nProgressValue];
                if(kWidth > kHeight){
                    isPlayBackPause = YES;
                    isPlayingBack = NO;
                    [self.playbackPlayAndStop setImage:[UIImage imageNamed:@"btn_play_white"] forState:UIControlStateNormal];
                    
                }else{
                    
                    isPlayBackPause = YES;
                    isPlayingBack = NO;
                }
                self.playBackToPlay.hidden = NO;
                isEditingSlider = NO;
                return;
                
            }
            if (slider.value == 0) {
                
//GWXLog(@"[Playback] LINE:%d", __LINE__);
                [self startPlayBack:_loginHandle file:_recFileListSelect[currentRecIndex]];
            }
            
            nPlayIndexId = [_panoPlayer setPlayProgress:slider.value];
        }
        
    }
    isEditingSlider = NO;
}

-(void)reloadRecFileSetView{
    if (self.currentRecordType == RecordTypeSD) {
        self.recFileSetView.isReverse = YES;
    }else{
        self.recFileSetView.isReverse = NO;
    }
    [self.recFileSetView reloadDataForCollectionView];//add by weibin 20181009
}
#pragma mark -



#pragma mark -

#pragma mark - 回放横屏事件
-(void) playbackLanscapeBtnClick:(UIButton *)sender{
    
    switch (sender.tag) {
        case 0:
            
            if(self.recFileList == nil || self.recFileList.count <= 0) {
               //If there is no video file, click is not allowed
                return;
            }
            
            // Pause playback
            if(isPlayingBack){
                
                // Currently playing, pause
                if (self.loginResult.nVersion > 2) {
                    //[self.panoPlayer stopPlayBackV30];
                    if (self.currentRecordType == RecordTypeOSS) {
                        [self.panoPlayer timeIndexWhenPause:nProgressValue];
                    }else{
                        [self.panoPlayer stopPlayBack];
                    }
                }else{
                    [self.panoPlayer timeIndexWhenPause:nProgressValue];
                }
                isPlayBackPause = YES;
                isPlayingBack = NO;
                self.playBackToPlay.hidden = NO; // add by GWX 20190417
                [sender setImage:[UIImage imageNamed:@"btn_play_white"] forState:UIControlStateNormal];
                [self.playBackToPlay setImage:[UIImage imageNamed:@"hs_btn_play2"] forState:UIControlStateNormal];
            }else if(isPlayBackPause){
               // currently paused
                if (self.loginResult.nVersion > 2) {
                    if (currentRecShowType == recShowTypeRuler) {
                        //GWXLog(@"[Playback] LINE:%d", __LINE__);
                        [self startPlayBack:_loginHandle file:_recFileList[currentRecIndex]];
                    }else{
                        if (self.currentRecordType == RecordTypeOSS) {
                            [self.panoPlayer timeIndexWhenPause:nProgressValue];
                        }else{
                            //GWXLog(@"[Playback] LINE:%d", __LINE__);
                            [self startPlayBack:_loginHandle file:_recFileListSelect[currentRecIndex]];
                        }
                    }
                }else{
                    [self.panoPlayer timeIndexWhenPause:nProgressValue];
                }
                isPlayingBack = YES;
                isPlayBackPause = NO;
                self.playBackToPlay.hidden = YES;
                [sender setImage:[UIImage imageNamed:@"btn_stop_white"] forState:UIControlStateNormal];
                [self.playBackToPlay setImage:[UIImage imageNamed:@"hs_btn_stop2"] forState:UIControlStateNormal];
            }else{
// add by GWX 20190416, click the play button to replay after the playback is complete
                // currently stopping
                RecordVideoInfo *fileInfo = nil;
                if (currentRecShowType == recShowTypeRuler) {
                    if(self.recFileList && self.recFileList.count > currentRecIndex){
                        fileInfo = self.recFileList[currentRecIndex];
                    }else{
                        return;
                    }
                }else{
                    if(self.recFileListSelect && self.recFileListSelect.count > currentRecIndex){
                        fileInfo = self.recFileListSelect[currentRecIndex];
                    }else{
                        return;
                    }
                }
                
                _fileCurrentTime = fileInfo.nStartTime;
                _playbackSlider.value = 0.0;
                nProgressValue = 0;
                self.playBackToPlay.hidden = YES;
//GWXLog(@"[Playback] LINE:%d", __LINE__);
                [self startPlayBack:self.loginHandle file:fileInfo];
                [sender setImage:[UIImage imageNamed:@"btn_stop_white"] forState:UIControlStateNormal];
                // end add by GWX 20190416
            }
            
            break;
        case 1:
// screenshot
            if(isPlayingBack || isPlayBackPause){
                [self screenshotAction:sender];
            }
            
            break;
        case 2:
            // sound
            self.m_bSoundEnable = !_m_bSoundEnable;
            if (self.m_bSoundEnable) {
                [sender setImage:[UIImage imageNamed:@"btn_voice_open_white"] forState:UIControlStateNormal];
            }else{
                [sender setImage:[UIImage imageNamed:@"btn_voice_close_white"] forState:UIControlStateNormal];
            }
            
            break;
        case 3:
            // zoom out
            [self btnBacktoPortraitClick:nil];
            break;
            
        default:
            break;
    }
    
}

#pragma mark -


#pragma mark - ====================================== 录像回放 e ================
//
- (void)screenshotAction:(UIButton *)sender{
   
    if (![self photoAuthorStatus]) {
        return;
    }
//    [ZTProgressHUD showWithStatus:NSLocalizedString(@"noticeScreenShot", @"")];
    [sender setEnabled:NO];
        
        UIImage *bResult = [self.panoPlayer screenShot];
        if(bResult){
                dispatch_after(1.f, dispatch_get_main_queue(), ^{
// iToast *toast = [iToast makeToast:@"The image has been saved, please view it in the album"];
// [toast setToastPosition:kToastPositionCenter];
// [toast setToastDuration:kToastDurationShort];
// [toast show];
                [sender setEnabled:YES];
            });
            
        }else{
            dispatch_after(1.f, dispatch_get_main_queue(), ^{
// iToast *toast = [iToast makeToast:@"Screenshot failed"];
//                [toast setToastPosition:kToastPositionCenter];
//                [toast setToastDuration:kToastDurationShort];
//                [toast show];
                
                [sender setEnabled:YES];
            });
            
        }
    //end of dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
    
}



-(BOOL)photoAuthorStatus{
    __block BOOL success = NO;
    PHAuthorizationStatus photoAuthorStatus = [PHPhotoLibrary authorizationStatus];
    switch (photoAuthorStatus) {
        case PHAuthorizationStatusAuthorized:
            success = YES;
            break;
        case PHAuthorizationStatusDenied:
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Please allow access to albums in \"Settings-Privacy\" on iPhone.", @"") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Go to Settings", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication]canOpenURL:url]) {
                    [[UIApplication sharedApplication]openURL:url];
                }
            }];
            
            
            [action1 setValue:[UIColor grayColor] forKey:@"titleTextColor"];
            [action2 setValue:[UIColor blueColor] forKey:@"titleTextColor"];
            [alert addAction:action1];
            [alert addAction:action2];
            [self presentViewController:alert animated:YES completion:nil];
        }
            break;
        case PHAuthorizationStatusNotDetermined:{
            NSLog(@"not Determined");
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized)
                {
                    success = YES;
                }
                else{ NSLog(@"Denied or Restricted");
                } }];
        }
            break;
            
        default:
            break;
    }
    return success;
}



//time to timestamp
-(NSInteger)timeSwitchTimestamp:(NSString *)formatTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    [formatter setTimeZone:timeZone];
    NSDate* date = [formatter dateFromString:formatTime];
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
    return timeSp;
}


// Support device auto-rotation
- (BOOL)shouldAutorotate{
    
    return YES;
}

-(void)onPlayAreaClick{
    if (_recFileList.count == 0) {
        return;
    }
    if (currentRecShowType == recShowTypeFileset && _recFileListSelect.count == 0) {
        return;
    }
    if(currentPlayMode == PlayerModePlayBack){
        if (currentRecIndex == -1) {
            return;
        }
        
        if(kWidth > kHeight){
// playback horizontal screen
            if(CGAffineTransformIsIdentity(_playbackBottomToolView.layer.affineTransform)){
                
                [self bottomViewHideAnimation];
                
            }else{
                
                [self bottomViewEndHideAnimation];
            }
            
        }else {
            // playback vertical screen
//            if (!isPlayBackPause && !isPlayingBack) {
//                return;
//            }
            
            [UIView animateWithDuration:0.25 animations:^{
                self.playBackToPlay.hidden = !self.playBackToPlay.hidden;
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if(self.playBackToPlay.hidden == NO){
                    [UIView animateWithDuration:0.25 animations:^{
                        self.playBackToPlay.hidden = YES;
                    }];
                }
            });
        }
        return;
    }
    if (!UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        if (self.isShowBottomView) {
            self.isShowBottomView = NO;
            self.panoPlayLaunchBottomView.hidden = YES;
            
            
        }else{
            self.isShowBottomView = YES;
            self.panoPlayLaunchBottomView.hidden = NO;
            
        }
        
    }else{
     
    }
}

-(void)playbackReplayAction:(UIButton*)sender{
    if (_recFileList.count == 0) {
        return;
    }
    if (currentRecShowType == recShowTypeFileset && _recFileListSelect.count == 0) {
        return;
    }
    if(isPlayingBack){
        
        // Currently playing, pause
        if (self.loginResult.nVersion > 2) {
            if (self.currentRecordType == RecordTypeOSS) {
                [self.panoPlayer timeIndexWhenPause:nProgressValue];
            }else{
                [self.panoPlayer stopPlayBack];
            }
        }else{
            [self.panoPlayer timeIndexWhenPause:nProgressValue];
        }
        isPlayBackPause = YES;
        isPlayingBack = NO;
        self.playBackToPlay.hidden = NO; // add by GWX 201904117
        [_playBackToPlay setImage:[UIImage imageNamed:@"hs_btn_play2"] forState:UIControlStateNormal];
    }else if(isPlayBackPause){
        
        // currently paused
        if (self.loginResult.nVersion > 2) {
            if (currentRecShowType == recShowTypeRuler) {
                //GWXLog(@"[Playback] LINE:%d", __LINE__);
                [self startPlayBack:_loginHandle file:_recFileList[currentRecIndex]];
            }else{
                if (self.currentRecordType == RecordTypeOSS) {
                    [self.panoPlayer timeIndexWhenPause:(int)_playbackSlider.value];
                }else{
                    //GWXLog(@"[Playback] LINE:%d", __LINE__);
                    if(_recFileListSelect.count > currentRecIndex){
                        [self startPlayBack:_loginHandle file:_recFileListSelect[currentRecIndex]];
                    }else{
                        [self stopPlayBack];
                    }
                }
            }
        }else{
            [self.panoPlayer timeIndexWhenPause:nProgressValue];
        }
        isPlayingBack = YES;
        isPlayBackPause = NO;
        self.playBackToPlay.hidden = YES;
        [_playBackToPlay setImage:[UIImage imageNamed:@"hs_btn_stop2"] forState:UIControlStateNormal];
    }else if (currentRecIndex >= 0){ //If the first two ifs do not hold, either the playback has not started yet, or the playback is completed. If the index of the currently selected file is greater than or equal to 0, it means that the playback is completed.
        [self recItemAction:[NSIndexPath indexPathForRow:currentRecIndex inSection:0]];
    }
}

#pragma mark ----------------- (Animation of bottom View) ----------------------

-(void)bottomViewHideAnimation{
    
    [UIView animateWithDuration:0.25 animations:^{
        CGAffineTransform transform1 = CGAffineTransformMakeTranslation(0,self.playbackBottomToolView.frame.size.height);
        self.playbackBottomToolView.layer.affineTransform = transform1;
        
        CGAffineTransform transform2 = CGAffineTransformMakeTranslation(0,-(self.btnBacktoPortrait.frame.size.height + self.btnBacktoPortrait.frame.origin.y));
        self.btnBacktoPortrait.layer.affineTransform = transform2;
        
    } completion:^(BOOL finished) {
    }];
    
}

-(void)bottomViewEndHideAnimation{
    
    [UIView animateWithDuration:0.25 animations:^{
        self.playbackBottomToolView.layer.affineTransform = CGAffineTransformIdentity;
        self.btnBacktoPortrait.layer.affineTransform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark -

#pragma mark - APP切到后台及返回
- (void)onApplicationDidBecomeActiveHandle:(NSNotification *)notification{
   
    [self.panoPlayer onApplicationDidBecomeActive];

    
}

- (void)onApplicationWillResignActiveHandle:(NSNotification *)notification{
    

    [self.panoPlayer onApplicationWillResignActive];
    
}

- (void)SaveSettings{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (userDefault) {
        [userDefault setValue:[NSNumber numberWithBool:self.m_bSoundEnable] forKey:@"sound_enable"];
        [userDefault synchronize];
    }
}
- (void)GetSettings{
/* Currently only video playback function: audio can be enabled by default, no need to obtain from local
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    self.m_bSoundEnable=YES;
    if (userDefault) {
        NSNumber *value=[userDefault valueForKey:@"sound_enable"];
        if (value !=nil) {
            self.m_bSoundEnable=[value boolValue];
        }
        
    }
    */
    
//@Author: Caffe 2020.01.09
    {//@Begin
        //Currently only video playback, so the default is to turn on the sound
        self.m_bSoundEnable = YES;
    }//@End
    //@Author: Caffe
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//Set whether to allow screen rotation
-(void)allowRotation:(BOOL)allow{
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    appDelegate.allowRotation = allow;
}

-(NVPanoPlayer *)panoPlayer{
    
    if (!_panoPlayer) {
        #ifdef CAFFE_USE_PANO_SHARE
                _panoPlayer = [ZTPanoPlayView shareInstance];
        #else
                _panoPlayer = [[NVPanoPlayer alloc] init];
        #endif
        _panoPlayer.notReleasePanoWhenDealloc = YES;
        _panoPlayer.singleDelegate = self;
        _panoPlayer.frame = CGRectMake(0, 64, kWidth, kWidth*9/16);
        
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handelPan:)];
        [_panoPlayer addGestureRecognizer:_panGestureRecognizer];
        
        //@Author: Caffe 2020.01.04
        {//@Begin
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPlayAreaClick)];
            [self.panoPlayer addGestureRecognizer:tap];
        }//@End
        //@Author: Caffe

        [_panoPlayer setMode:13];
        [_panoPlayer addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    [_panoPlayer setMode:13];
    [_panoPlayer setActive:YES];
    return _panoPlayer;
}

-(DataBaseManager *)databaseManager{
    if (!_databaseManager) {
        _databaseManager = [[DataBaseManager alloc]init];
    }
    return _databaseManager;
}

-(UIView *)panoPlayLaunchBottomView{
    if (!_panoPlayLaunchBottomView) {
        _panoPlayLaunchBottomView = [[UIView alloc]init];
        _panoPlayLaunchBottomView.frame = CGRectMake(0, kHeight - 44, kWidth, 44);

        _panoPlayLaunchBottomView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    }
    return _panoPlayLaunchBottomView;
}



-(UIButton *)btnBacktoPortrait{
    
    if(_btnBacktoPortrait == nil){
        
        _btnBacktoPortrait = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnBacktoPortrait setImage:[UIImage imageNamed:@"btn_back_white"] forState:UIControlStateNormal];
        [_btnBacktoPortrait addTarget:self action:@selector(btnBacktoPortraitClick:) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect frame;
        frame.size.width = 44 ;
        frame.size.height = frame.size.width;
        frame.origin.x = 10 ;
        frame.origin.y = 15 ;
        _btnBacktoPortrait.frame = frame;
    }
    
    return _btnBacktoPortrait;
}

-(UIButton *)playBackToPlay{
    
    if(_playBackToPlay == nil){
        
        _playBackToPlay = [[UIButton alloc] init];
        CGRect frame = _playBackToPlay.frame;
        frame.size.width = MIN(self.panoPlayer.frame.size.width, self.panoPlayer.frame.size.height) * 0.2;
        frame.size.height = frame.size.width;
        frame.origin.x = (self.panoPlayer.frame.size.width - frame.size.width) / 2.0;
        frame.origin.y = (self.panoPlayer.frame.size.height - frame.size.height) / 2.0;
        _playBackToPlay.frame = frame;
        _playBackToPlay.center = self.panoPlayer.center;
        [_playBackToPlay setImage:[UIImage imageNamed:@"hs_btn_stop2"] forState:UIControlStateNormal];
        [_playBackToPlay addTarget:self action:@selector(playbackReplayAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_playBackToPlay];
        _playBackToPlay.hidden = YES;
    }
    
    return _playBackToPlay;
}

// Play back the bottom toolbar
-(UIView *)playbackBottomToolView{
    
    if(_playbackBottomToolView == nil){
        
        _playbackBottomToolView = [[UIView alloc] init];
        _playbackBottomToolView.backgroundColor = [UIColor blackColor];//[[UIColor blackColor] colorWithAlphaComponent:0.3];
        [_playbackBottomToolView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        
        _playbackTimeStartLbl = [[UILabel alloc] init];
        _playbackTimeStartLbl.textAlignment = NSTextAlignmentRight;
        _playbackTimeStartLbl.textColor = [UIColor whiteColor];
        _playbackTimeStartLbl.adjustsFontSizeToFitWidth = YES;
        //        [_playbackBottomToolView addSubview:_playbackTimeStartLbl];// hide time
        
        _playbackSlider = [[ZTPlaySlider alloc] init];
        CGAffineTransform transform = CGAffineTransformMakeScale(0.7f, 0.7f);
        [_playbackSlider addTarget:self action:@selector(recProgressTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_playbackSlider addTarget:self action:@selector(recProgressTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_playbackSlider addTarget:self action:@selector(recProgressTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [_playbackSlider addTarget:self action:@selector(recProgressTouchCancel:) forControlEvents:UIControlEventTouchCancel];
        [_playbackSlider addTarget:self action:@selector(recProgressTouchOutside:) forControlEvents:UIControlEventTouchUpOutside];
        
        _playbackSlider.transform = transform;
        [_playbackSlider setMinimumValue:0.f];
        [_playbackSlider setMaximumValue:100.f];
        [_playbackSlider setUserInteractionEnabled:NO];
        [_playbackBottomToolView addSubview:_playbackSlider];
        
        _playbackTimeEndLbl = [[UILabel alloc] init];
        _playbackTimeEndLbl.textAlignment = NSTextAlignmentRight;
        _playbackTimeEndLbl.textColor = [UIColor whiteColor];
        _playbackTimeEndLbl.adjustsFontSizeToFitWidth = YES;
        //        [_playbackBottomToolView addSubview:_playbackTimeEndLbl];// hide time
        
    }
    return _playbackBottomToolView;
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if(object == _playbackBottomToolView && [keyPath isEqualToString:@"frame"]){
        
        if(kWidth > kHeight){
            // landscape
            //@Author: Caffe 2020.01.10
            {//@Begin
                self.playBackBgView.hidden = YES;
                [self updatePlaybackBottomToolViewToLanscape];
            }//@End
            //@Author: Caffe
        }else{
            // vertical screen
            //@Author: Caffe 2020.01.10
            {//@Begin
                self.playBackBgView.hidden = NO;
                [self updatePlaybackBottomToolViewToPortrait];
            }//@End
            //@Author: Caffe
        }
    }
    
    if(object == _panoPlayer && [keyPath isEqualToString:@"frame"] ){
// playback mode
        // pause button
        CGRect frame = _playBackToPlay.frame;
        frame.size.width = MIN(self.panoPlayer.frame.size.width, self.panoPlayer.frame.size.height) * 0.15;
        frame.size.height = frame.size.width;
        frame.origin.x = (self.panoPlayer.frame.size.width - frame.size.width) / 2.0;
        frame.origin.y = (self.panoPlayer.frame.size.height - frame.size.height) / 2.0;
        _playBackToPlay.frame = frame;
        _playBackToPlay.center = self.panoPlayer.center;
        if(currentPlayMode == PlayerModePlayBack){
            
            if(kWidth > kHeight){
                // Landscape mode
                _playbackBottomToolView.frame = CGRectMake(self.panoPlayer.frame.origin.x ,CGRectGetMaxY(self.panoPlayer.frame) - 40, self.panoPlayer.frame.size.width, 40);
            }else{
                // vertical screen
                _playbackBottomToolView.frame = CGRectMake(self.panoPlayer.frame.origin.x ,CGRectGetMaxY(self.panoPlayer.frame) - 40, self.panoPlayer.frame.size.width, 40);
            }
        }
    }
    
}
// Play back the horizontal screen, follow the new playback toolbar
-(void) updatePlaybackBottomToolViewToLanscape{
    
    // landscape
    CGRect frame = _playbackBottomToolView.frame;
    frame.size.width = kWidth; //add by xys 20200219 Reason for modification: _playbackBottomToolView.frame.width is also 375 in the horizontal screen state before the picture is displayed. It needs to be corrected to the real width, otherwise the UI width of the timeline is abnormal.
    
    int btnCount = 4;
    int btnHW = 40;
    for (int i = 0; i <= btnCount - 1; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        [btn addTarget:self action:@selector(playbackLanscapeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        switch (i) {
            case 0:
                // Pause playback
                if (_playbackPlayAndStop) {
                    [_playbackPlayAndStop removeFromSuperview];
                }
                _playbackPlayAndStop = btn;
                if(isPlayingBack){
                    
                    [btn setImage:[UIImage imageNamed:@"btn_stop_white"] forState:UIControlStateNormal];

                }else{
                    
                    [btn setImage:[UIImage imageNamed:@"btn_play_white"] forState:UIControlStateNormal];
                    
                }
                btn.frame = CGRectMake(10, (frame.size.height - btnHW)/2.0, btnHW, btnHW);
                // layout child controls
                _playbackTimeStartLbl.frame = CGRectMake(CGRectGetMaxX(btn.frame) + 10, 0, 60, frame.size.height);
                _playbackSlider.frame = CGRectMake(CGRectGetMaxX(btn.frame) + 10 , (frame.size.height - 20)/2.0, frame.size.width - btnHW * btnCount - 10 * 2 - 10 *2-10, 20);
                _playbackTimeEndLbl.frame = CGRectMake(CGRectGetMaxX(_playbackSlider.frame), 0, 60, frame.size.height);
                if(currentRecShowType == recShowTypeFileset){
                    
                    _playbackTimeStartLbl.hidden = NO;
                    _playbackSlider.hidden = NO;
                    _playbackTimeEndLbl.hidden = NO;
                    
                }else{

                   //Video playback file list
                    _playbackTimeStartLbl.hidden = YES;
                    _playbackSlider.hidden = YES;
                    _playbackTimeEndLbl.hidden = YES;
                    
                }
                break;
            case 1:
                // screenshot
                [btn setImage:[UIImage imageNamed:@"btn_jietu_white"] forState:UIControlStateNormal];
                btn.frame = CGRectMake(CGRectGetMaxX(_playbackSlider.frame) + 10, (frame.size.height - btnHW)/2.0, btnHW, btnHW);
                
                if (_playbackScreenshot) {
                    [_playbackScreenshot removeFromSuperview];
                }
                _playbackScreenshot = btn;
                break;
            case 2:
                // sound
                if (self.m_bSoundEnable){
                    [btn setImage:[UIImage imageNamed:@"btn_voice_open_white"] forState:UIControlStateNormal];
                }else{
                    [btn setImage:[UIImage imageNamed:@"btn_voice_close_white"] forState:UIControlStateNormal];
                }
                btn.frame = CGRectMake(CGRectGetMaxX(_playbackSlider.frame) + 10 + 10 + btnHW, (frame.size.height - btnHW)/2.0, btnHW, btnHW);
                
                if (_playbackSound) {
                    [_playbackSound removeFromSuperview];
                }
                _playbackSound = btn;
                break;
            case 3:
                // zoom out
                [btn setImage:[UIImage imageNamed:@"hs_btn_exitfullscreen"] forState:UIControlStateNormal];
                btn.frame = CGRectMake(CGRectGetMaxX(_playbackSlider.frame) + 10 + 10 * 2 + btnHW * 2, (frame.size.height - btnHW)/2.0, btnHW, btnHW);
                
                if (_playbackFullScreen) {
                    [_playbackFullScreen removeFromSuperview];
                }
                _playbackFullScreen = btn;
                break;
            default:
                break;
        }
        
        [_playbackBottomToolView addSubview:btn];
    }
    
}
// Playback vertical screen, follow the new playback toolbar
-(void) updatePlaybackBottomToolViewToPortrait{
    
    CGRect frame = _playbackBottomToolView.frame;
    //Remove the button in landscape
    for (UIView *view in _playbackBottomToolView.subviews) {
        
        if([view isKindOfClass:[UIButton class]]){
            
            [view removeFromSuperview];
        }
    }
    _playbackTimeStartLbl.hidden = NO;
    _playbackSlider.hidden = NO;
    _playbackTimeEndLbl.hidden = NO;
    _playbackTimeStartLbl.frame = CGRectMake(10, 0, 60, frame.size.height);
    _playbackSlider.frame = CGRectMake(10 , (frame.size.height - 20)/2.0, frame.size.width - 20, 20);
    _playbackTimeEndLbl.frame = CGRectMake(frame.size.width - 70, 0, 60, frame.size.height);
    
}


-(NSMutableArray *)recFileListSelect{
    if (!_recFileListSelect) {
        _recFileListSelect = [NSMutableArray array];
    }
    return _recFileListSelect;
}


#pragma mark - Login expired popup
-(void)showAlarView{
    _onBack = YES;
}

#pragma mark - lazy loading by weibin - 20181009
- (NSMutableArray *)arraySDCardFileList{
    if (_arraySDCardFileList == nil) {
        _arraySDCardFileList = [NSMutableArray array];
    }
    return _arraySDCardFileList;
}

- (NSMutableArray *)arrayCloudServiceFileList{
    if (_arrayCloudServiceFileList == nil) {
        _arrayCloudServiceFileList = [NSMutableArray array];
    }
    return _arrayCloudServiceFileList;
}


#pragma mark - dealloc
-(void)dealloc{
    if(!_onBack){
        self.panoPlayer.notReleasePanoWhenDealloc = NO;
    }
    //NSLog(@"caffe ============================NVPanoPlayerNormalViewController=====================dealloc=====================");
    [_playbackBottomToolView removeObserver:self forKeyPath:@"frame"];
    [_panoPlayer removeObserver:self forKeyPath:@"frame"];
}

@end
