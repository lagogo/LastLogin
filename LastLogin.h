//
//
//    LastLogin.h
//    LastLogin Interfaces
//    Created by Juan Carlos Perez <carlos@jcarlosperez.me> 04/24/2017
//    © CP Digital Darkroom <admin@cpdigitaldarkroom.com>. All rights reserved.
//
//

#define kDefaultDateLS        @"M/dd h:mm"
#define kDefaultDatePS        @"M/dd h:mm"

#define kDefaultLS        @"LLCount Login Attempts Since LLDate"
#define kDefaultPS        @"LLCount Login Attempts Since Last Login"

#define kPrefsID          CFSTR("com.cpdigitaldarkroom.lastlogin")
#define kPrefsChanged     CFSTR("com.cpdigitaldarkroom.lastlogin.settings")

@interface SBUICallToActionLabel : UIView
-(void)setText:(NSString *)arg1;
-(void)sizeToFit;
@end

@interface SBFTouchPassThroughView : UIView
@end

@interface SBDashBoardViewBase : SBFTouchPassThroughView
@end

@interface SBDashBoardMainPageView : SBDashBoardViewBase
@property (nonatomic,retain) SBUICallToActionLabel * callToActionLabel;
@end

@interface SBUIPasscodeLockViewBase : UIView
@end

@interface SBUIPasscodeLockViewWithKeypad : SBUIPasscodeLockViewBase
- (void)updateStatusText:(NSString *)status subtitle:(NSString *)subtitle animated:(BOOL)animated;
@end
