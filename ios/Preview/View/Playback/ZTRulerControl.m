//
//  ZTRulerControl.m
//  iCamSee
//
//  Created by hs_mac on 2018/1/2.
//  Copyright © 2018年 macrovideo. All rights reserved.
//

#import "ZTRulerControl.h"
#import "RecordVideoInfo.h"
#import "CloudDiskPlayBackFileModel.h"

typedef NS_ENUM(NSInteger, rulerStyle) {
    
    rulerStyleDefault = 0, // default (portrait)
    rulerStyleLanscape // landscape mode
    
};

@interface ZTRulerControl()

@property(nonatomic, assign) rulerStyle style;
@property (nonatomic, assign) BOOL isCloudDisk; //add by xie yongsheng 20190316 Adapt to cloud disk

@end

#define kMinorScaleDefaultSpacing 20 // Minor scale spacing
#define kMajorScaleDefaultLength 25.0 //Main scale height
#define kMiddleScaleDefaultLength 17.0 //Middle scale height
#define kMinorScaleDefaultLength 10.0 //Minor scale height
#define kRulerDefaultBackgroundColor ([UIColor clearColor]) //The background color of the scale
#define kScaleDefaultColor ([UIColor lightGrayColor]) //scale color
#define kScaleDefaultFontColor ([UIColor darkGrayColor]) //scale font color
#define kScaleDefaultFontSize 10.0 //Scale font
#define kIndicatorDefaultColor ([UIColor blueColor]) //Indicator default color
#define kIndicatorDefaultLength 80 //Indicator height

//#define kRulerPrecisionMax 6
//#define kRulerPrecisionMin 0
#define kRulerPrecisionQuality 60



@implementation ZTRulerControl{
    UIScrollView *_scrollView;
    UIImageView *_rulerImageView;
    UIImageView *_indicatorView;
    CGFloat realScale;
    BOOL isNeedReloadRuler;
    BOOL isScrolling;
    int lastRecEndTime;
}

#pragma mark - Constructor
+(instancetype) rulerStyleDefault:(CGRect)frame{
    
    ZTRulerControl *ruler = [[ZTRulerControl alloc] initWithFrame:frame];
    ruler.style = rulerStyleDefault;
    return ruler;
}
+(instancetype) rulerStyleLanscape:(CGRect)frame{
   
    ZTRulerControl *ruler = [[ZTRulerControl alloc] initWithFrame:frame];
    ruler.style = rulerStyleLanscape;
    return ruler;
}

+(instancetype)rulerStyleCloudDisk:(CGRect)frame{  //add by xie yongsheng 20190316Adapt to cloud disk
    ZTRulerControl *ruler = [[ZTRulerControl alloc] initWithFrame:frame];
    ruler.style = rulerStyleDefault;
    ruler.isCloudDisk = YES;
    return ruler;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_rulerImageView.image == nil || isNeedReloadRuler) {
        isNeedReloadRuler = NO;
        [self reloadRuler];
    }
    CGSize size = self.bounds.size;
    _indicatorView.frame = CGRectMake(size.width * 0.5 - 8/ 2.0, size.height - self.indicatorLength, 8, self.indicatorLength);
    
   // Set the scroll view content spacing
    CGSize textSize = [self maxValueTextSize];
    CGFloat offset = size.width * 0.5 - textSize.width;
    _scrollView.contentInset = UIEdgeInsetsMake(0, offset, 0, offset);
    if(self.style == rulerStyleDefault){
        
        _scrollView.layer.borderWidth = 0.5;
        _scrollView.layer.borderColor = [UIColor orangeColor].CGColor;
        
    }else{
        _scrollView.layer.borderWidth = 0;
        
    }
}

#pragma mark - set properties
// indicator color
- (void)setIndicatorColor:(UIColor *)indicatorColor {
    _indicatorView.backgroundColor = indicatorColor;
}

////选中的数值
- (void)setSelectedValue:(CGFloat)selectedValue {
    if (selectedValue < _minValue || selectedValue > _maxValue || _valueStep <= 0) {
        return;
    }
    
    _selectedValue = selectedValue;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    CGFloat spacing = self.minorScaleSpacing;
    CGSize size = self.bounds.size;
    CGSize textSize = [self maxValueTextSize];
    CGFloat offset = 0;
    
    // Calculate the offset
    CGFloat steps = [self stepsWithValue:selectedValue];
    offset = size.width * 0.5 - textSize.width - steps * spacing;
    _scrollView.contentOffset = CGPointMake(-offset, 0);
}



#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//    CGFloat spacing = self.minorScaleSpacing;
//    CGSize size = self.bounds.size;
//    CGSize textSize = [self maxValueTextSize];
//    CGFloat offset = targetContentOffset->x + size.width * 0.5 - textSize.width;
    
//    CGFloat steps = (CGFloat)(offset / spacing );
    //CGFloat value = _minValue + steps * _valueStep / (_midCount * _smallCount);
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    CGFloat spacing = self.minorScaleSpacing;
    CGSize size = self.bounds.size;
    CGSize textSize = [self maxValueTextSize];
    CGFloat offset = 0;
    offset = scrollView.contentOffset.x + size.width * 0.5 - textSize.width;
    CGFloat steps = (CGFloat)(offset / spacing );
    CGFloat value = _minValue + steps * _valueStep/(_midCount*_smallCount);
    if(decelerate == YES){
        isScrolling = YES;
    }
    
    if ((value >= _minValue && value <= _maxValue && isScrolling == NO)) {

        if([self.delegate respondsToSelector:@selector(rulerScrollDidEndResult:)]){
            [self.delegate rulerScrollDidEndResult:value];
    }
    }
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    isScrolling = NO;
    CGFloat spacing = self.minorScaleSpacing;
    CGSize size = self.bounds.size;
    CGSize textSize = [self maxValueTextSize];
    CGFloat offset = 0;
    offset = scrollView.contentOffset.x + size.width * 0.5 - textSize.width;
    CGFloat steps = (CGFloat)(offset / spacing );
    CGFloat value = _minValue + steps * _valueStep/(_midCount*_smallCount);
    
    if(value > _maxValue) value = _maxValue-1;
    if(value < _minValue) value = _minValue;
    
    if ( (value >= _minValue && value <= _maxValue)) {
        
        //[self sendActionsForControlEvents:UIcontrolevent];
        if([self.delegate respondsToSelector:@selector(rulerScrollDidEndResult:)]){
            [self.delegate rulerScrollDidEndResult:value];
        }
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!(scrollView.isDragging || scrollView.isTracking || scrollView.isDecelerating)) {
        return;
    }
    if (scrollView.isTracking && !scrollView.isDragging) {
        return;
    }
    
    CGFloat spacing = self.minorScaleSpacing;
    CGSize size = self.bounds.size;
    CGSize textSize = [self maxValueTextSize];
    CGFloat offset = 0;
    offset = scrollView.contentOffset.x + size.width * 0.5 - textSize.width;
    //NSInteger steps = (NSInteger)(offset / spacing + 0.5);
    CGFloat steps = (CGFloat)(offset / spacing );
    CGFloat value = _minValue + steps * _valueStep/(_midCount*_smallCount);
    
    if (value != _selectedValue && (value >= _minValue && value <= _maxValue)) {
        _selectedValue = value;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    if([self.delegate respondsToSelector:@selector(rulerDidScroll:)]){
        [self.delegate rulerDidScroll:value];
    }
}

#pragma mark - Drawing ruler related methods
- (void)reloadRuler {
    UIImage *image = [self rulerImage];
    if (image == nil) {
        return;
    }
    _rulerImageView.image = image;
    _rulerImageView.backgroundColor = self.rulerBackgroundColor;
    [_rulerImageView sizeToFit];
    _scrollView.contentSize = _rulerImageView.image.size;

    // Align the horizontal ruler down
    CGRect rect = _rulerImageView.frame;
    rect.origin.y = _scrollView.bounds.size.height - _rulerImageView.image.size.height;
    _rulerImageView.frame = rect;
    
    // update initial value
    self.selectedValue = _selectedValue;
}

- (UIImage *)rulerImage {
    // 1. Constant calculation
    CGFloat steps = [self stepsWithValue:_maxValue]; //steps number of small cells
    if (steps == 0) {
        return nil;
    }
    
    // The size of the image to be drawn horizontally
    CGSize textSize = [self maxValueTextSize];
//    CGFloat height = _scrollView.frame.size.height-_rulerImageView.frame.size.height ;
    CGFloat height = _scrollView.frame.size.height;
    CGFloat startX = textSize.width;
    CGRect rect = CGRectMake(0, 0, steps * self.minorScaleSpacing + 2 * startX, height);
    
    // 2. 绘制图像
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    //
   // 1> draw tick marks
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (NSInteger i = _minValue; i <= _maxValue; i += _valueStep) {
        // draw the main scale
        CGFloat x = (i - _minValue) / _valueStep * self.minorScaleSpacing * (_midCount*_smallCount) + startX;
        
        if(self.style == rulerStyleDefault){
            [path moveToPoint:CGPointMake(x, height)];
            [path addLineToPoint:CGPointMake(x, height - self.majorScaleLength)];
            
            // draw on the main scale
            [path moveToPoint:CGPointMake(x, 0)];
            [path addLineToPoint:CGPointMake(x,self.majorScaleLength)];
        }else{
            // draw major ticks
            CGFloat gap = (height  - self.majorScaleLength)/2.0;
            [path moveToPoint:CGPointMake(x,gap)];
            [path addLineToPoint:CGPointMake(x, height - gap)];
        }
        
        if (i == _maxValue) {
            break;
        }
        if(self.style == rulerStyleDefault){
           // draw small tick marks
            for (NSInteger j = 1; j < (_midCount*_smallCount); j++) {
                
                CGFloat scaleX = x + j * self.minorScaleSpacing;
                [path moveToPoint:CGPointMake(scaleX, height)];
                CGFloat scaleY = height - ((j%_smallCount == 0) ? self.middleScaleLength : self.minorScaleLength);
                [path addLineToPoint:CGPointMake(scaleX, scaleY)];
            }
            
            // draw minor tick lines
            for (NSInteger j = 1; j < (_midCount*_smallCount); j++) {
                CGFloat scaleX = x + j * self.minorScaleSpacing;
                
                //superior
                [path moveToPoint:CGPointMake(scaleX, 0)];
                CGFloat scaleY =((j%_smallCount == 0) ? self.middleScaleLength : self.minorScaleLength);
                
                //superior
                [path addLineToPoint:CGPointMake(scaleX, scaleY)];
            }
        }else{
            // draw small scale
            for (NSInteger j = 1; j < (_midCount*_smallCount); j++) {
                CGFloat scaleX = x + j * self.minorScaleSpacing;
                CGFloat scaleY =((j%_smallCount == 0) ? self.middleScaleLength : self.minorScaleLength);
                CGFloat gap = (height  - scaleY)/2.0;
                [path moveToPoint:CGPointMake(scaleX, gap)];
                [path addLineToPoint:CGPointMake(scaleX, height - gap)];
            }
            
        }
    }
    [self.scaleColor set];
    [path stroke];

    // 2> draw the tick values
    NSDictionary *strAttributes = [self scaleTextAttributes];

    for (NSInteger i = _minValue; i <= _maxValue; i += _valueStep) {
        // Convert seconds to hours and minutes
        NSString *str = [self timeFormatted:i];

        CGRect strRect = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:strAttributes
                                           context:nil];
        
        strRect.origin.x = (i - _minValue) / _valueStep * self.minorScaleSpacing *( _midCount*_smallCount) + startX - strRect.size.width * 0.5;
        if(self.style == rulerStyleDefault){
        
            strRect.origin.y =_scrollView.frame.size.height*0.5-textSize.height*0.5;
        }else{
            CGFloat gap = (height  - self.majorScaleLength)/2.0;
            strRect.origin.y = height - gap - 1;
        }
        [str drawInRect:strRect withAttributes:strAttributes];
    }
    // draw the file area
    lastRecEndTime = 0;
    
    for (int i = 0; i < _recFileList.count; i++) {
        //update by xie yongsheng 20190316 for cloud disk
        id info = _recFileList[i];
        
        //Start seconds of the video (from zero of the day)
        int startSeconds;
        int fileStartSeconds = 0;
        if (self.isCloudDisk == NO) {
            startSeconds = [self nSecondsInTheDay:((RecordVideoInfo *)info).nStartTime];
        }else{
            startSeconds = [self nSecondsInTheDay:((CloudDiskPlayBackFileModel *)info).recTimeStamp];
            fileStartSeconds = [self nSecondsInTheDay:((CloudDiskPlayBackFileModel *)info).recTimeStamp];

        }

        if(startSeconds < lastRecEndTime){
            startSeconds = lastRecEndTime;
        }
        
        // end seconds of the video
        int endSeconds;
        if (self.isCloudDisk == NO) {
            endSeconds = [self nSecondsInTheDay:((RecordVideoInfo *)info).nEndTime];
        }else{
    
            /// modify by GWX 2020.05.07, because the file may be spanned across days, the end seconds are abnormally obtained, and now it is changed to end time = start time + duration
            //endSeconds = [self nSecondsInTheDay:(int)[((CloudDiskPlayBackFileModel *)info) getEndTime]];
            endSeconds = fileStartSeconds + ((CloudDiskPlayBackFileModel *)info).recTimeLength;
            if(endSeconds > 86400){
                endSeconds = 86400;
            }
            /// end modify by GWX
            
            /**
                  TODO:
                  After the device cloud disk is reconstructed, the video file connection is at the millisecond level, while the app timeline connection is at the second level, which causes the timeline to display "silk intervals" when the video is perfectly connected. For example, the videos are 0-300s and 301-600s respectively, then the time axis will display a white gap between 300s-301s, so when drawing, it is judged that the two files are drawn within 2s of the difference.
                  add by yang 20200423
                  */
            if (fileStartSeconds-lastRecEndTime <= 2 && fileStartSeconds-lastRecEndTime > 0) {
                startSeconds = lastRecEndTime;
            }
        }
        
        
        //add by qin 20180720
        if(endSeconds < lastRecEndTime){//prevent overlapping
            // NSLog(@"endSeconds=%d,lastRecEndTime=%d,starttime=%@",endSeconds,lastRecEndTime,((CloudDiskPlayBackFileModel *)info).recTime);
            //The last file may be across the sky, which will cause accidental entry here
            if(i != _recFileList.count-1){
                continue;
            }
        }
        //end
        lastRecEndTime = endSeconds;
        
        if (self.isCloudDisk == NO) {
            if(((RecordVideoInfo *)info).nfileType == FILE_TYPE_ALARM){
                // alarm recording
                [[UIColor orangeColor] setFill];
            }
        }else{ //Cloud disk
            if(((CloudDiskPlayBackFileModel *)info).recType == FILE_TYPE_ALARM){
                // alarm recording
                [[UIColor orangeColor] setFill];
            }
            else if(((CloudDiskPlayBackFileModel *)info).recType == FILE_TYPE_NORMAL){
                // non-alarm recording
                [[UIColor orangeColor] setFill];
            }
            else if(((CloudDiskPlayBackFileModel *)info).recType == FILE_TYPE_EPITOME){
                /// Miniature video
                [[UIColor orangeColor] setFill];
            }
            else{
                
            }
        }
        //update end by xie yongsheng 20190316 for cloud disk
        
        
        // Calculate start x
        CGFloat x = (CGFloat)(startSeconds - _minValue) / _valueStep * self.minorScaleSpacing * (_midCount*_smallCount) + startX;
        // Calculate the width
        CGFloat startX = x;
        CGFloat startY = 0;
        
        //modify by qin 20180704
        CGFloat width = 0;
        if(endSeconds-startSeconds<0){
           width  = (CGFloat)(86400 - startSeconds)/_valueStep * self.minorScaleSpacing * (_midCount*_smallCount);
//            NSLog(@"relerframe<0 = %f   (%d -- %d) (%d-%d)",width,endSeconds,startSeconds,info.nStartTime,info.nEndTime);
        }else{
           width = (CGFloat)(endSeconds - startSeconds)/_valueStep * self.minorScaleSpacing * (_midCount*_smallCount);
        }

        if(width != 0 && width < 6000){
        CGFloat height = _scrollView.frame.size.height;
        CGRect frame = CGRectMake(startX, startY, width, height);
        UIBezierPath *pathRect = [UIBezierPath bezierPathWithRect:frame]; //bezierPathWithRect
        pathRect.lineWidth = 0;
        [pathRect fillWithBlendMode:kCGBlendModeNormal alpha:1];
        }
        //end
    }

    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
    
}


- (NSString *)timeFormatted:(int)totalSeconds{
    
    //int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d",hours, minutes];
    
}


-(int) nSecondsInTheDay:(int) nTime{  //1525887429
    
    int nseconds = 0;
//    if (!self.isCloudDisk) {
        nTime = nTime - [self secondsToGMTZone];
//    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:nTime];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond;
    NSDateComponents *nTimeComponent = [calendar components:unitFlags fromDate:date];
    short nHour = [nTimeComponent hour];
    short nMinute = [nTimeComponent minute];
    short nSecond = [nTimeComponent second];
    
    nseconds = nHour * 60 * 60  + nMinute * 60 + nSecond;
    
    return nseconds;
}

//Get the interval in seconds between the current time zone and time zone 0
-(NSInteger)secondsToGMTZone{
    NSTimeZone *localZone = [NSTimeZone localTimeZone];
    NSInteger seconds= [localZone secondsFromGMT];
    return seconds;
}
- (CGFloat)stepsWithValue:(CGFloat)value {
    if (_minValue >= value || _valueStep <= 0) {
        return 0;
    }
    return (value - _minValue) / _valueStep * ( _midCount * _smallCount); //Calculate the grid
}

- (CGSize)maxValueTextSize {
    // Convert seconds to hours
    NSString *scaleText = @(self.maxValue/60/60).description;
    scaleText = [scaleText stringByAppendingString:@":00"];  //20180102
    CGSize size = [scaleText boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:[self scaleTextAttributes]
                                          context:nil].size;
    
    return CGSizeMake(floor(size.width), floor(size.height));
}

- (NSDictionary *)scaleTextAttributes {
    CGFloat fontSize = self.scaleFontSize * [UIScreen mainScreen].scale * 0.6;
    
    return @{NSForegroundColorAttributeName: self.scaleFontColor,
             NSFontAttributeName: [UIFont boldSystemFontOfSize:fontSize]};
}

#pragma mark - settings interface
- (void)setupUI {
    
    // scroll view
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    [self addSubview:_scrollView];
    
    // ruler image
    _rulerImageView = [[UIImageView alloc] init];
    [_scrollView addSubview:_rulerImageView];
    
    // indicator view
    _indicatorView = [[UIImageView alloc] init];
    [_indicatorView setImage:[UIImage imageNamed:@"icon_sjz_axis"]];
    [self addSubview:_indicatorView];
    
    // zoom in gesture
    UIPinchGestureRecognizer *pinchGestture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchGesture:)];
    [_scrollView addGestureRecognizer:pinchGestture];
    
}


#pragma mark - pinch gesture
-(void)pinchGesture:(UIPinchGestureRecognizer *)pinch{
    
    if(fabs(realScale - pinch.scale) < 0.02){
        //Prevent too fast, intercept
        return;
    }
    realScale = pinch.scale;

    if(pinch.scale < 1.0){
        //Reduce the gesture, the precision is reduced, the interval difference becomes larger, the maximum is 6
        if(_minorScaleSpacing > 20){
            // two small scale pixels
            [UIView animateWithDuration:0.5 animations:^{
                self->_minorScaleSpacing = self->_minorScaleSpacing - 1;
                self->isNeedReloadRuler = YES;
                [self layoutSubviews];
            } completion:^(BOOL finished) {
                
            }];
  
        }else{
            if(self.valueStep >= kRulerPrecisionQuality * 60 * 6){ //Six minutes
                //The precision has been minimized, and the interval difference has become larger
                return;
            }else{
                //Until the minimum, continue to reduce the precision
                if(self.valueStep == kRulerPrecisionQuality * 60){
                    //The current interval is 60 minutes, it becomes 6 * 60
                    self.valueStep = kRulerPrecisionQuality * 60 * 6;
                }else if(self.valueStep == kRulerPrecisionQuality * 6 ){
                    //The current interval is 6 minutes
                    self.valueStep = kRulerPrecisionQuality * 60;
                }
                isNeedReloadRuler = YES;
                _minorScaleSpacing = 40;
                [self layoutSubviews];
            }
        }
    }
    if(pinch.scale > 1.0){
        //Enlarge the gesture, the accuracy is improved, the interval difference becomes smaller, the minimum is 0
        if(_minorScaleSpacing >= 40){
            //change the precision
            if(self.valueStep <= kRulerPrecisionQuality * 6){ //6 1
                return;
            }else{
                //Until the maximum, continue to improve the precision and reduce the interval value
                if(self.valueStep == kRulerPrecisionQuality * 60){
                    //The current interval is 60 minutes, then it becomes 6
                    self.valueStep = kRulerPrecisionQuality * 6;
                }else if(self.valueStep == kRulerPrecisionQuality * 6 * 60 ){
                    //The current interval is 360 minutes
                    self.valueStep = kRulerPrecisionQuality * 60;
                    
                }
                
                isNeedReloadRuler = YES;
                _minorScaleSpacing = 20;
                [self layoutSubviews];
            }
            
        }else{
            // first make the interval larger
            [UIView animateWithDuration:0.5 animations:^{
                self->_minorScaleSpacing += 1;
                self->isNeedReloadRuler = YES;
                [self layoutSubviews];
            } completion:^(BOOL finished) {
                
            }];

        }
    }

    
}

#pragma mark -

#pragma mark - property default value
// Minor tick spacing
- (CGFloat)minorScaleSpacing {
    if (_minorScaleSpacing <= 0) {
        _minorScaleSpacing = kMinorScaleDefaultSpacing;
    }
    return _minorScaleSpacing;
}

// main tick length
- (CGFloat)majorScaleLength {
    if (_majorScaleLength <= 0) {
        _majorScaleLength = kMajorScaleDefaultLength;
    }
    return _majorScaleLength;
}

//Intermediate tick length
- (CGFloat)middleScaleLength {
    if (_middleScaleLength <= 0) {
        _middleScaleLength = kMiddleScaleDefaultLength;
    }
    return _middleScaleLength;
}

// minor tick length
- (CGFloat)minorScaleLength {
    if (_minorScaleLength <= 0) {
        _minorScaleLength = kMinorScaleDefaultLength;
    }
    return _minorScaleLength;
}

// scale background color
- (UIColor *)rulerBackgroundColor {
    if (_rulerBackgroundColor == nil) {
        _rulerBackgroundColor = kRulerDefaultBackgroundColor;
    }
    return _rulerBackgroundColor;
}

// scale color
- (UIColor *)scaleColor {
    if (_scaleColor == nil) {
        _scaleColor = kScaleDefaultColor;
    }
    return _scaleColor;
}

// scale font color
- (UIColor *)scaleFontColor {
    if (_scaleFontColor == nil) {
        if(self.isCloudDisk == YES){
            _scaleFontColor = kScaleDefaultColor;
        }else if(self.style == rulerStyleDefault){
            
            _scaleFontColor = kScaleDefaultColor;
            //_scaleFontColor = kScaleDefaultFontColor;
            
        }else {
            
            _scaleFontColor = [UIColor whiteColor];
        }
        
    }
    return _scaleFontColor;
}

// scale font size
- (CGFloat)scaleFontSize {
    if (_scaleFontSize <= 0) {
        _scaleFontSize = kScaleDefaultFontSize;
    }
    return _scaleFontSize;
}

// indicator color
- (UIColor *)indicatorColor {
    if (_indicatorView.backgroundColor == nil) {
        _indicatorView.backgroundColor = kIndicatorDefaultColor;
    }
    return _indicatorView.backgroundColor;
}

// indicator length
- (CGFloat)indicatorLength {
    if (_indicatorLength <= 0) {
//        if(_style == rulerStyleDefault){
//
//            _indicatorLength = kIndicatorDefaultLength;
//        }else{
//
            _indicatorLength = self.bounds.size.height - 2;
//        }
    }
    return _indicatorLength;
}


-(void)setRecFileList:(NSArray *)recFileList{

    _recFileList = recFileList;
    [self reloadRuler];
    
    
}

//Invert the input array and save it later
-(void)setReverseFileList:(NSArray *)fileList{
    _recFileList = [[fileList reverseObjectEnumerator] allObjects];
    [self reloadRuler];
}

- (BOOL)isEditing{
    return _scrollView.isDragging || _scrollView.isTracking || _scrollView.isDecelerating;
}
@end
