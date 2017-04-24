//
//
//    LastLogin+Authentication.xm
//    Track Authentication Attempts
//    Created by Juan Carlos Perez <carlos@jcarlosperez.me> 04/24/2017
//    © CP Digital Darkroom <admin@cpdigitaldarkroom.com>. All rights reserved.
//
//

#import "LastLoginTracker.h"
#import <version.h>

%group iOS_10

#define kTouchIDMatched 	3
#define kTouchIDNotMatched 	10

%hook SBFUserAuthenticationController

/*!
  @brief Called after a successful passcode authentication

  @discussion After a user enters a passcode in the passcode entry view it's delegate gets notified and eventually it reaches here.
              The only con is mesa attempts will never call this so a different method of tracking mesa unlocks is required

              Since this is only called on successful login attempts, the only thing I'll do is save the date. (Clearing the login count
              will be handled by the tracker since setting a new login date always clears the tracker state)
!*/

-(void)_handleSuccessfulAuthentication:(id)arg1 responder:(id)arg2 {
  %orig;
  [LastLoginTracker sharedInstance].lastLoginDate = [NSDate date];
}

/*!
  @brief Same as above but called for failed authentication requests
!*/

-(void)_handleFailedAuthentication:(id)arg1 error:(id)arg2 responder:(id)arg3 {
  %orig;
  [LastLoginTracker sharedInstance].loginAttempts++;
}
%end

%hook SBDashBoardMesaUnlockBehavior

/*!
  @brief handleBiometricEvent is called for every biometric event, perfect!

  @discussion This is called as soon as a user finger is touched to the sensor.
              For LastLogin this is the perfect place to catch a successful and invalid mesa login match.

              Thanks to evilgoldfish and sticktron for their work on LockGlyphX and figuring out the event values for iOS 10
              https://github.com/evilgoldfish/LockGlyphX/blob/master/LockGlyphX.xm#L29

              By checking against the biometric event, we can determine when a successful match occurs as well as when a failure occurs.
              By doing this we can save the date for the last login and handle adding/removing from the login count.
!*/

-(void)handleBiometricEvent:(unsigned long long)event {
  %orig;

  if(event == kTouchIDMatched) {
    [LastLoginTracker sharedInstance].lastLoginDate = [NSDate date];
  } else if(event == kTouchIDNotMatched) {
    if([LastLoginTracker sharedInstance].tracksMesaAttempts) {
      [LastLoginTracker sharedInstance].loginAttempts++;
    }
  }
}
%end
%end

%group iOS_9
%hook SBLockScreenManager

-(BOOL)_attemptUnlockWithPasscode:(id)arg1 finishUIUnlock:(BOOL)arg2 {

	[LastLoginTracker sharedInstance].loginAttempts++;
	return %orig;
}

-(void)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2 {

	%orig;
  [LastLoginTracker sharedInstance].lastLoginDate = [NSDate date];

}

%end
%end

static void updateSettings(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  [[LastLoginTracker sharedInstance] syncPrefs];
}

%ctor {
  if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"]) {

    %init;
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, updateSettings, CFSTR("com.cpdigitaldarkroom.lastlogin.settings"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

    if(IS_IOS_OR_NEWER(iOS_10_0)) {
      %init(iOS_10);
    } else {
      %init(iOS_9);
    }
  }
}
