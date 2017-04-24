//
//
//    LastLogin+Labels.xm
//    Change Labels
//    Created by Juan Carlos Perez <carlos@jcarlosperez.me> 04/24/2017
//    © CP Digital Darkroom <admin@cpdigitaldarkroom.com>. All rights reserved.
//
//

#import "LastLogin.h"
#import "LastLoginTracker.h"
#import <version.h>


%hook SBUIPasscodeLockViewWithKeypad // This hook should work back to iOS 8.0

/*!
  @brief Used to set the keypad entry view string

  @discussion For LastLogin I'm only worried about the main status text since the only times when the subtitle is used is when the passcode
              entry view is displaying feedback about authentication. LastLogin will only replace the "Enter Passcode" status to allow the
              other visual cues to behave as normal.

              As an extra feature LastLogin will check when the "Try Again" status is being set and update the status back to the LastLogin
              string. By default once "Try Again" is displayed it doesn't leave.
!*/

-(void)updateStatusText:(NSString *)status subtitle:(NSString *)subtitle animated:(BOOL)animated {

  if(status) {

    /*!
      @discussion There are two ways to handle this and one of the two is wrong. One of the things Apple does is localize everything. Take advantage
                  of it!

                  If you were to use [status isEqualToString:@"Enter Passcode"], it would be effectively limiting LastLogin to only work with English.
                  By finding the localization strings to check against, we can ensure LastLogin will work with all the supported iOS languages
    !*/

    NSBundle *SBUISBundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/SpringBoardUIServices.framework"];

    if([status isEqualToString:[SBUISBundle localizedStringForKey:@"PASSCODE_ENTRY_PROMPT" value:@"" table:@"SpringBoardUIServices"]] ||
      [status isEqualToString:[SBUISBundle localizedStringForKey:@"PASSCODE_MESA_ENTRY_PROMPT" value:@"" table:@"SpringBoardUIServices"]]) {

      status = [LastLoginTracker sharedInstance].passcodeString;

    } else if([status isEqualToString:[SBUISBundle localizedStringForKey:@"PASSCODE_ENTRY_PROMPT_RETRY" value:@"" table:@"SpringBoardUIServices"]]) {

      /*!
        @discussion By default iOS doesn't update the status string after "Try Again" is set unless the user interacts with it again. I wanted
                    LastLogin to update this string again after a couple seconds just because.

                    It's worth mentioning what I'm doing here.

                    This same method I'm currently in takes three arguments. Unfortunately performSelector:withObject:withObject only takes two
                    arguments. Instead by using a NSInvocation with the target, selector and arguments set I can do what I wanted.

        @remark NSInvocation automatically sets self and _cmd to index 0 and 1 respectively. Start at 2 when adding arguments
      !*/

      BOOL animate = YES;
      NSString *statusString = [LastLoginTracker sharedInstance].passcodeString;
      NSString *subtitleString = @"";

      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(updateStatusText:subtitle:animated:)]];
      [invocation setSelector:@selector(updateStatusText:subtitle:animated:)];
      [invocation setTarget:self];
      [invocation setArgument:&statusString atIndex:2];
      [invocation setArgument:&subtitleString atIndex:3];
      [invocation setArgument:&animate atIndex:4];

      [invocation performSelector:@selector(invoke) withObject:nil afterDelay:1.6];
    }
  }

  %orig(status, subtitle, animated);
}

%end

%group iOS_10
%hook SBDashBoardMainPageView
/*!
  @brief Pretty straight forward. If user wants "Press Home To Unlock" to show LastLogin then show it.
!*/
- (void)_layoutCallToActionLabel {

	%orig;

  if([LastLoginTracker sharedInstance].lockscreenString) {
    [self.callToActionLabel setText:[LastLoginTracker sharedInstance].lockscreenString];
    [self.callToActionLabel sizeToFit];
  }
}
%end
%end

%group iOS_9
%hook SBLockScreenView
/*!
  @brief Same concept as for iOS 10
!*/
- (NSString *)_defaultSlideToUnlockText {
  return [LastLoginTracker sharedInstance].lockscreenString;
}
%end
%end

%ctor {

  if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
    %init;
    if(IS_IOS_OR_NEWER(iOS_10_0)) {
      %init(iOS_10);
    } else {
      %init(iOS_9);
    }
  }
}
