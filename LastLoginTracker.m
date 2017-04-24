//
//
//    LastLoginTracker.m
//    Manage LastLogin Stuff
//    Created by Juan Carlos Perez <carlos@jcarlosperez.me> 04/24/2017
//    © CP Digital Darkroom <admin@cpdigitaldarkroom.com>. All rights reserved.
//
//

#import "LastLogin.h"
#import "LastLoginTracker.h"

@interface LastLoginTracker ()
- (void)updateLabelStrings;
@end

@implementation LastLoginTracker

+ (instancetype)sharedInstance {
  static LastLoginTracker *sharedInstance = nil;
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
  sharedInstance = [[self alloc] init];
  });

  return sharedInstance;
}

- (instancetype)init {
  if(self = [super init]) {
    _lastLoginDate = !CFPreferencesCopyAppValue(CFSTR("lastLoginDate"), kPrefsID) ? [NSDate date] : CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("lastLoginDate"), kPrefsID));
    _loginAttempts = 0;
    _tracksMesaAttempts = !CFPreferencesCopyAppValue(CFSTR("trackMesa"), kPrefsID) ? YES : [CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("trackMesa"), kPrefsID)) boolValue];
    [self updateLabelStrings];
  }
  return self;
}

- (void)setLastLoginDate:(NSDate *)date {

  _lastLoginDate = date;
  _loginAttempts = 0;

  CFPreferencesSetAppValue((CFStringRef)@"lastLoginDate", (CFPropertyListRef)date, kPrefsID);
  [self updateLabelStrings];
}

- (void)setLoginAttempts:(int)attempts {
  _loginAttempts = attempts;
  [self updateLabelStrings];
}

- (void)updateLabelStrings {

  _lockscreenString = !CFPreferencesCopyAppValue(CFSTR("lsString"), kPrefsID) ? kDefaultLS : CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("lsString"), kPrefsID));
  _passcodeString = !CFPreferencesCopyAppValue(CFSTR("psString"), kPrefsID) ? kDefaultPS : CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("psString"), kPrefsID));

  if([_lockscreenString containsString:@"LLCount"]) {
    _lockscreenString = [_lockscreenString stringByReplacingOccurrencesOfString:@"LLCount" withString:[NSString stringWithFormat:@"%d", _loginAttempts]];
  }

  if([_lockscreenString containsString:@"LLDate"]) {
    NSString *dateFormat = !CFPreferencesCopyAppValue(CFSTR("lsDateFormat"), kPrefsID) ? kDefaultPS : CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("lsDateFormat"), kPrefsID));
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    _lockscreenString = [_lockscreenString stringByReplacingOccurrencesOfString:@"LLDate" withString:[dateFormatter stringFromDate:_lastLoginDate]];
  }

  if([_passcodeString containsString:@"LLCount"]) {
    _passcodeString = [_passcodeString stringByReplacingOccurrencesOfString:@"LLCount" withString:[NSString stringWithFormat:@"%d", _loginAttempts]];
  }

  if([_passcodeString containsString:@"LLDate"]) {
    NSString *dateFormat = !CFPreferencesCopyAppValue(CFSTR("psDateFormat"), kPrefsID) ? kDefaultDatePS : CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("psDateFormat"), kPrefsID));
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    _passcodeString = [_passcodeString stringByReplacingOccurrencesOfString:@"LLDate" withString:[dateFormatter stringFromDate:_lastLoginDate]];
  }

  [_lockscreenString retain];
  [_passcodeString retain];
  
}
@end
