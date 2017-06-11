//
//  YCSwitch.m
//  CCTest
//
//  Created by Durand on 26/8/16.
//  Copyright © 2016年 com.Durand. All rights reserved.
//

#import "YCSwitch.h"

@interface YCTrackGradient : CAGradientLayer
@property (nonatomic,strong) NSArray *onColors;
@property (nonatomic,strong) NSArray *offColors;
@property (nonatomic,strong) CAShapeLayer *shadowLayer;
-(void) changeTrackStatus:(BOOL)isOn;
@end

@implementation YCTrackGradient

- (instancetype)init
{
    self = [super init];
    if (self) {
        _onColors = @[(id)[UIColor colorWithRed:208/255.0 green:62/255.0 blue:159/255.0 alpha:1.0].CGColor,(id)[UIColor colorWithRed:186/255.0 green:83/255.0 blue:233/255.0 alpha:1.0].CGColor];
        _offColors = @[(id)[UIColor colorWithRed:97/255.0 green:101/255.0 blue:178/255.0 alpha:1.0].CGColor,(id)[UIColor colorWithRed:18/255.0 green:147/255.0 blue:178/255.0 alpha:1.0].CGColor];
        self.colors = _offColors;
        self.startPoint = CGPointMake(0, 0);
        self.endPoint = CGPointMake(0, 1);
        //        _trackGradient.cornerRadius = MIN(self.track.frame.size.height, self.track.frame.size.width)/2;
        self.masksToBounds = YES;
        
        _shadowLayer = [CAShapeLayer layer];
        
        // Standard shadow stuff
        _shadowLayer.shadowColor = [UIColor colorWithWhite:0 alpha:1].CGColor;
        _shadowLayer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        _shadowLayer.shadowOpacity = 1.0f;
        _shadowLayer.shadowRadius = 5;
        
        // Causes the inner region in this example to NOT be filled.
        _shadowLayer.fillRule = kCAFillRuleEvenOdd;
        //    [_shadowLayer addSublayer:_trackGradient];
        [self addSublayer:_shadowLayer];
    }
    return self;
}

-(void)layoutSublayers
{
    [super layoutSublayers];
    self.cornerRadius = MIN(self.frame.size.height, self.frame.size.width)/2;
    CGFloat transulantRadius = 5;
    CGRect largerRect = CGRectMake(self.bounds.origin.x - transulantRadius,
                                   self.bounds.origin.y - transulantRadius,
                                   self.bounds.size.width + transulantRadius + transulantRadius,
                                   self.bounds.size.height + transulantRadius + transulantRadius);
    
    // Create the larger rectangle path.
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, largerRect);
    
    // Add the inner path so it's subtracted from the outer path.
    // someInnerPath could be a simple bounds rect, or maybe
    // a rounded one for some extra fanciness.
    CGFloat cornerRadius = self.cornerRadius;
    UIBezierPath *bezier;
    if (cornerRadius) {
        bezier = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:cornerRadius];
    } else {
        bezier = [UIBezierPath bezierPathWithRect:self.bounds];
    }
    CGPathAddPath(path, NULL, bezier.CGPath);
    CGPathCloseSubpath(path);
    
    _shadowLayer.path = path;
    
    CGPathRelease(path);
    
}

-(void) changeTrackStatus:(BOOL)isOn
{
    self.colors = isOn ? _onColors : _offColors;
}

@end

@interface YCSwitch ()
{
    float thumbOnPosition;
    float thumbOffPosition;
    float bounceOffset;
    YCTrackGradient *_trackGradient;
}

@property (copy, nonatomic) void (^handlerBlock)(BOOL isOn);
@property (copy, nonatomic) void (^willBePressedHandlerBlock)(BOOL isOn);

@end

@implementation YCSwitch

- (instancetype)initWithFrame:(CGRect)frame thumbSize:(CGSize)thumbSize trackThickHeight:(CGFloat)trackThickHeight
{
    if (self = [super init]) {
        [self setupSwitch];
        self.frame = frame;
        self.thumbSize = thumbSize;
        self.trackThickHeight = trackThickHeight;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupSwitch];
    }
    return self;
}

-(void) setupSwitch
{
    _trackOnTintColor = [UIColor purpleColor];
    _trackOffTintColor = [UIColor cyanColor];
    _thumbOnImage = [UIImage imageNamed:@"录音_switch"];
    _thumbOffImage = [UIImage imageNamed:@"录音_switch"];
    self.isEnabled = YES;
    self.isBounceEnabled = YES;
    bounceOffset = 3.0;
    
    
    self.track = [[UIView alloc] init]; //WithFrame:trackFrame];
    
    _trackGradient = [YCTrackGradient layer];
    
    [self.track.layer addSublayer:_trackGradient];
    

    [self addSubview:self.track];
    
    self.switchThumb = [[UIButton alloc] init ];// WithFrame:thumbFrame];

    [self.switchThumb addTarget:self action:@selector(onTouchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
    [self.switchThumb addTarget:self action:@selector(onTouchUpOutsideOrCanceled:withEvent:) forControlEvents:UIControlEventTouchUpOutside];
    [self.switchThumb addTarget:self action:@selector(switchThumbTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.switchThumb addTarget:self action:@selector(onTouchDragInside:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [self.switchThumb addTarget:self action:@selector(onTouchUpOutsideOrCanceled:withEvent:) forControlEvents:UIControlEventTouchCancel];
    
    
    [self addSubview:self.switchThumb];
    
    
    
    self.isOn = NO;
    [self.switchThumb setImage:_thumbOffImage forState:UIControlStateNormal];
    [self.switchThumb setImage:_thumbOnImage forState:UIControlStateSelected];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchAreaTapped:)];
    [self.track addGestureRecognizer:singleTap];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.frame;
    CGRect trackFrame = CGRectZero;
    CGRect thumbFrame = CGRectZero;
    
    trackFrame.size.width = frame.size.width;
    trackFrame.size.height = _trackThickHeight;
    trackFrame.origin.x = 0.0;
    trackFrame.origin.y = (frame.size.height-_trackThickHeight)/2;
    thumbFrame.size = _thumbSize;
    thumbFrame.origin.x = 0.0;
    thumbFrame.origin.y = (frame.size.height-_thumbSize.height)/2;
    self.track.frame = trackFrame;
    _trackGradient.frame = self.track.bounds;
    self.switchThumb.frame = thumbFrame;
    //    self.track.layer.cornerRadius = MIN(self.track.frame.size.height, self.track.frame.size.width)/2;
    thumbOnPosition = self.frame.size.width - self.switchThumb.frame.size.width;
    thumbOffPosition = self.switchThumb.frame.origin.x;
}

-(void)setPressedHandler:(void (^)(BOOL))handler
{
    _handlerBlock = handler;
}

-(void)setWillBePressedHandler:(void (^)(BOOL))handler
{
    _willBePressedHandlerBlock = handler;
}
//-(void)setSwitchThumbStatus:(BOOL)on
//{
//    UIImage *img = on ? _thumbOnImage : _thumbOffImage;
//    [self.switchThumb setImage:img forState:UIControlStateNormal];
//}

// Change switch state if necessary, with the animated option parameter
- (void)setOn:(BOOL)on animated:(BOOL)animated
{
    if (on == YES) {
        if (animated == YES) {
            // set on with animation
            [self changeThumbStateONwithAnimation];
        }
        else {
            // set on without animation
            [self changeThumbStateONwithoutAnimation];
        }
    }
    else {
        if (animated == YES) {
            // set off with animation
            [self changeThumbStateOFFwithAnimation];
        }
        else {
            // set off without animation
            [self changeThumbStateOFFwithoutAnimation];
        }
    }
}


- (void)onTouchDown:(UIButton*)btn withEvent:(UIEvent*)event
{
    // will pressed
    if (_willBePressedHandlerBlock) {
        BOOL isOn = self.isOn;
        _willBePressedHandlerBlock(isOn);
    }
}

//The event handling method
- (void)switchAreaTapped:(UITapGestureRecognizer *)recognizer
{
    // Delegate method
    if (_willBePressedHandlerBlock) {
        BOOL isOn = self.isOn;
        _willBePressedHandlerBlock(isOn);
    }
    [self changeThumbState];
}


- (void)changeThumbState
{
    // NSLog(@"thumb origin pos: %@", NSStringFromCGRect(self.switchThumb.frame));
    if (self.isOn == YES) {
        [self changeThumbStateOFFwithAnimation];
    }
    else {
        [self changeThumbStateONwithAnimation];
    }
}

// Change thumb state when touchUPInside action is detected
- (void)switchThumbTapped: (id)sender
{
    [self changeThumbState];
    // diid pressed
}


// Change thumb state when touchUPOutside action is detected
- (void)onTouchUpOutsideOrCanceled:(UIButton*)btn withEvent:(UIEvent*)event
{
    // NSLog(@"Touch released at ouside");
    UITouch *touch = [[event touchesForView:btn] anyObject];
    CGPoint prevPos = [touch previousLocationInView:btn];
    CGPoint pos = [touch locationInView:btn];
    float dX = pos.x-prevPos.x;
    
    //Get the new origin after this motion
    float newXOrigin = btn.frame.origin.x + dX;
    //NSLog(@"Released tap X pos: %f", newXOrigin);
    
    if (newXOrigin > (self.frame.size.width - self.switchThumb.frame.size.width)/2) {
        //NSLog(@"thumb pos should be set *ON*");
        [self changeThumbStateONwithAnimation];
    }
    else {
        //NSLog(@"thumb pos should be set *OFF*");
        [self changeThumbStateOFFwithAnimation];
    }
    
}

// Drag the switch thumb
- (void)onTouchDragInside:(UIButton*)btn withEvent:(UIEvent*)event
{
    //This code can go awry if there is more than one finger on the screen
    UITouch *touch = [[event touchesForView:btn] anyObject];
    CGPoint prevPos = [touch previousLocationInView:btn];
    CGPoint pos = [touch locationInView:btn];
    float dX = pos.x-prevPos.x;
    
    //Get the original position of the thumb
    CGRect thumbFrame = btn.frame;
    
    thumbFrame.origin.x += dX;
    //Make sure it's within two bounds
    thumbFrame.origin.x = MIN(thumbFrame.origin.x,thumbOnPosition);
    thumbFrame.origin.x = MAX(thumbFrame.origin.x,thumbOffPosition);
    
    //Set the thumb's new frame if need to
    if(thumbFrame.origin.x != btn.frame.origin.x) {
        btn.frame = thumbFrame;
    }
}

#pragma Action
- (void)changeThumbStateONwithAnimation
{
    // switch movement animation
    [UIView animateWithDuration:0.25f
                          delay:0.05f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect thumbFrame = self.switchThumb.frame;
                         thumbFrame.origin.x = thumbOnPosition+bounceOffset;
                         self.switchThumb.frame = thumbFrame;
                         //                         if (self.isEnabled == YES) {
                         self.switchThumb.selected = YES;
                         [_trackGradient changeTrackStatus:YES];
                         //                         self.track.backgroundColor = self.trackOnTintColor;
                         //                         }
                         //                         else {
                         //                             self.switchThumb.backgroundColor = self.thumbDisabledTintColor;
                         //                             self.track.backgroundColor = self.trackDisabledTintColor;
                         //                         }
                         self.userInteractionEnabled = NO;
                     }
                     completion:^(BOOL finished){
                         // change state to ON
                         if (self.isOn == NO) {
                             self.isOn = YES; // Expressly put this code here to change surely and send action correctly
                             [self sendActionsForControlEvents:UIControlEventValueChanged];
                         }
                         self.isOn = YES;
                         // NSLog(@"now isOn: %d", self.isOn);
                         // NSLog(@"thumb end pos: %@", NSStringFromCGRect(self.switchThumb.frame));
                         // Bouncing effect: Move thumb a bit, for better UX
                         [UIView animateWithDuration:0.25f
                                          animations:^{
                                              // Bounce to the position
                                              CGRect thumbFrame = self.switchThumb.frame;
                                              thumbFrame.origin.x = thumbOnPosition;
                                              self.switchThumb.frame = thumbFrame;
                                          }
                                          completion:^(BOOL finished){
                                              self.userInteractionEnabled = YES;
                                              if (_handlerBlock) {
                                                  BOOL isOn = self.isOn;
                                                  _handlerBlock(isOn);
                                              }
                                          }];
                     }];
}

- (void)changeThumbStateOFFwithAnimation
{
    // switch movement animation
    [UIView animateWithDuration:0.25f
                          delay:0.05f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect thumbFrame = self.switchThumb.frame;
                         thumbFrame.origin.x = thumbOffPosition-bounceOffset;
                         self.switchThumb.frame = thumbFrame;
                         //                         if (self.isEnabled == YES) {
                         self.switchThumb.selected = NO;
                         [_trackGradient changeTrackStatus:NO];
                         //                         self.track.backgroundColor = self.trackOffTintColor;
                         //                         }
                         //                         else {
                         //                             self.switchThumb.backgroundColor = self.thumbDisabledTintColor;
                         //                             self.track.backgroundColor = self.trackDisabledTintColor;
                         //                         }
                         self.userInteractionEnabled = NO;
                     }
                     completion:^(BOOL finished){
                         // change state to OFF
                         if (self.isOn == YES) {
                             self.isOn = NO; // Expressly put this code here to change surely and send action correctly
                             [self sendActionsForControlEvents:UIControlEventValueChanged];
                         }
                         self.isOn = NO;
                         // NSLog(@"now isOn: %d", self.isOn);
                         // NSLog(@"thumb end pos: %@", NSStringFromCGRect(self.switchThumb.frame));
                         // Bouncing effect: Move thumb a bit, for better UX
                         [UIView animateWithDuration:0.25f
                                          animations:^{
                                              // Bounce to the position
                                              CGRect thumbFrame = self.switchThumb.frame;
                                              thumbFrame.origin.x = thumbOffPosition;
                                              self.switchThumb.frame = thumbFrame;
                                          }
                                          completion:^(BOOL finished){
                                              self.userInteractionEnabled = YES;
                                              if (_handlerBlock) {
                                                  BOOL isOn = self.isOn;
                                                  _handlerBlock(isOn);
                                              }
                                              
                                          }];
                     }];
}

// Without animation
- (void)changeThumbStateONwithoutAnimation
{
    CGRect thumbFrame = self.switchThumb.frame;
    thumbFrame.origin.x = thumbOnPosition;
    self.switchThumb.frame = thumbFrame;
    //    if (self.isEnabled == YES) {
    self.switchThumb.selected = YES;
    [_trackGradient changeTrackStatus:YES];
    //    self.track.backgroundColor = self.trackOnTintColor;
    //    }
    //    else {
    //        self.switchThumb.backgroundColor = self.thumbDisabledTintColor;
    //        self.track.backgroundColor = self.trackDisabledTintColor;
    //    }
    
    if (self.isOn == NO) {
        self.isOn = YES;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    self.isOn = YES;
    if (_handlerBlock) {
        BOOL isOn = self.isOn;
        _handlerBlock(isOn);
    }
    
}

// Without animation
- (void)changeThumbStateOFFwithoutAnimation
{
    CGRect thumbFrame = self.switchThumb.frame;
    thumbFrame.origin.x = thumbOffPosition;
    self.switchThumb.frame = thumbFrame;
    //    if (self.isEnabled == YES) {
    self.switchThumb.selected = NO;
    [_trackGradient changeTrackStatus:NO];
    //    self.track.backgroundColor = self.trackOffTintColor;
    //    }
    //    else {
    //        self.switchThumb.backgroundColor = self.thumbDisabledTintColor;
    //        self.track.backgroundColor = self.trackDisabledTintColor;
    //    }
    
    if (self.isOn == YES) {
        self.isOn = NO;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    self.isOn = NO;
    if (_handlerBlock) {
        BOOL isOn = self.isOn;
        _handlerBlock(isOn);
    }
}

@end
