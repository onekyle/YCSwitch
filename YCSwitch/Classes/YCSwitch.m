//
//  YCSwitch.m
//  CCTest
//
//  Created by Durand on 26/8/16.
//  Copyright © 2016年 com.Durand. All rights reserved.
//

#import "YCSwitch.h"

@interface YCSwitch ()
{
    float thumbOnPosition;
    float thumbOffPosition;
    float bounceOffset;
}

@property (copy, nonatomic) void (^handlerBlock)(BOOL isOn);
@property (copy, nonatomic) void (^willBePressedHandlerBlock)(BOOL isOn);

@end

@implementation YCSwitch
- (id)initWithFrame:(CGRect)frame thumbSize:(CGSize)thumbSize trackThickHeight:(CGFloat)trackThickHeight
{
    _trackOnTintColor = [UIColor purpleColor];
    _trackOffTintColor = [UIColor cyanColor];
    _thumbOnImage = [UIImage imageNamed:@"录音_switch"];
    _thumbOffImage = [UIImage imageNamed:@"录音_switch"];
    self.isEnabled = YES;
    self.isBounceEnabled = YES;
    bounceOffset = 3.0;
    
    CGRect trackFrame = CGRectZero;
    CGRect thumbFrame = CGRectZero;
    
    trackFrame.size.width = frame.size.width;
    trackFrame.size.height = trackThickHeight;
    trackFrame.origin.x = 0.0;
    trackFrame.origin.y = (frame.size.height-trackThickHeight)/2;
    thumbFrame.size = thumbSize;
    thumbFrame.origin.x = 0.0;
    thumbFrame.origin.y = (frame.size.height-thumbSize.height)/2;
    
    self = [super initWithFrame:frame];
    self.track = [[UIView alloc] initWithFrame:trackFrame];
    self.track.backgroundColor = [UIColor grayColor];
    self.track.layer.cornerRadius = MIN(self.track.frame.size.height, self.track.frame.size.width)/2;
    [self addSubview:self.track];

    self.switchThumb = [[UIButton alloc] initWithFrame:thumbFrame];
//    self.switchThumb.backgroundColor = [UIColor whiteColor];
//    self.switchThumb.layer.cornerRadius = self.switchThumb.frame.size.height/2;
//    self.switchThumb.layer.shadowOpacity = 0.5;
//    self.switchThumb.layer.shadowOffset = CGSizeMake(0.0, 1.0);
//    self.switchThumb.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.switchThumb.layer.shadowRadius = 2.0f;
    // Add events for user action
    [self.switchThumb addTarget:self action:@selector(onTouchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
    [self.switchThumb addTarget:self action:@selector(onTouchUpOutsideOrCanceled:withEvent:) forControlEvents:UIControlEventTouchUpOutside];
    [self.switchThumb addTarget:self action:@selector(switchThumbTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.switchThumb addTarget:self action:@selector(onTouchDragInside:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [self.switchThumb addTarget:self action:@selector(onTouchUpOutsideOrCanceled:withEvent:) forControlEvents:UIControlEventTouchCancel];
    
    
    [self addSubview:self.switchThumb];
    
    thumbOnPosition = self.frame.size.width - self.switchThumb.frame.size.width;
    thumbOffPosition = self.switchThumb.frame.origin.x;
    
    self.isOn = NO;
    [self.switchThumb setImage:_thumbOffImage forState:UIControlStateNormal];
    [self.switchThumb setImage:_thumbOnImage forState:UIControlStateSelected];
    
    UITapGestureRecognizer *singleTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(switchAreaTapped:)];
    [self addGestureRecognizer:singleTap];
    
    return self;

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
    [UIView animateWithDuration:0.15f
                          delay:0.05f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect thumbFrame = self.switchThumb.frame;
                         thumbFrame.origin.x = thumbOnPosition+bounceOffset;
                         self.switchThumb.frame = thumbFrame;
                         //                         if (self.isEnabled == YES) {
                         self.switchThumb.selected = YES;
                         self.track.backgroundColor = self.trackOnTintColor;
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
                         [UIView animateWithDuration:0.15f
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
    [UIView animateWithDuration:0.15f
                          delay:0.05f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect thumbFrame = self.switchThumb.frame;
                         thumbFrame.origin.x = thumbOffPosition-bounceOffset;
                         self.switchThumb.frame = thumbFrame;
                         //                         if (self.isEnabled == YES) {
                         self.switchThumb.selected = NO;
                         self.track.backgroundColor = self.trackOffTintColor;
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
                         [UIView animateWithDuration:0.15f
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
    self.track.backgroundColor = self.trackOnTintColor;
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
    self.track.backgroundColor = self.trackOffTintColor;
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
