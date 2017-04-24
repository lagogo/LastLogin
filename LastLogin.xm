//
//
//    LastLogin.xm
//    Lockscreen Login Attempts
//    Created by CP Digital Darkroom <tweaks@cpdigitaldarkroom.support> 03/13/2016
//    © CP Digital Darkroom <tweaks@cpdigitaldarkroom.support>. All rights reserved.
//
//
//

int kPasswordAttempts;
static UILabel *loginLabel;

%hook SBLockScreenManager

-(BOOL)_attemptUnlockWithPasscode:(id)arg1 finishUIUnlock:(BOOL)arg2 {

	kPasswordAttempts++;
	loginLabel.text = [NSString stringWithFormat:@"%d Login Attempt%@Since Last Login", kPasswordAttempts, (kPasswordAttempts > 1) ? @"s " : @" "];
	return %orig;
}

-(void)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2 {

	kPasswordAttempts = 0;

	%orig;

}

%end


%hook SBUIPasscodeLockViewWithKeypad

- (id)statusTitleView {

	loginLabel = [self valueForKey:@"_statusTitleView"];

	if (kPasswordAttempts > 0) {
        loginLabel.text = [NSString stringWithFormat:@"%d Login Attempts Since Last Login", kPasswordAttempts];
    	return loginLabel;
    }

    return %orig;
}
%end

