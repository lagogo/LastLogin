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
@property (nonatomic, strong) NSUserDefaults *userDefaults;
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

    _loginAttempts = 0;
    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.cpdigitaldarkroom.lastlogin"];

    _lastLoginDate = [_userDefaults objectForKey:@"lastLoginDate"];

    [_userDefaults registerDefaults:@{
      @"displaysActionLabel": @NO,
      @"displaysActionLabel": @NO,
      @"trackMesa": @NO,
      @"lsString": kDefaultLS,
      @"psString":kDefaultPS,
      @"lsDateFormat" : kDefaultDateLS,
      @"psDateFormat" : kDefaultDatePS
    }];

    [self syncPrefs];
  }
  return self;
}

- (void)syncPrefs {
  _displayOnLS = [_userDefaults boolForKey:@"displaysActionLabel"];
  _displayOnPS = [_userDefaults boolForKey:@"displaysActionLabel"];
  _tracksMesaAttempts = [_userDefaults boolForKey:@"trackMesa"];

  [self updateLabelStrings];
}

- (void)setLastLoginDate:(NSDate *)date {

  _lastLoginDate = date;
  _loginAttempts = 0;

  [_userDefaults setObject:date forKey:@"lastLoginDate"];
  [self updateLabelStrings];
}

- (void)setLoginAttempts:(int)attempts {
  _loginAttempts = attempts;
  [self updateLabelStrings];
}

- (void)updateLabelStrings {

  _lockscreenString = nil;
  _passcodeString = nil;

  _lockscreenString = [_userDefaults objectForKey:@"lsString"];
  _passcodeString = [_userDefaults objectForKey:@"psString"];

  if([_lockscreenString containsString:@"LLCount"]) {
    _lockscreenString = [_lockscreenString stringByReplacingOccurrencesOfString:@"LLCount" withString:[NSString stringWithFormat:@"%d", _loginAttempts]];
  }

  if([_lockscreenString containsString:@"LLDate"]) {
    NSString *dateFormat = [_userDefaults objectForKey:@"lsDateFormat"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    _lockscreenString = [_lockscreenString stringByReplacingOccurrencesOfString:@"LLDate" withString:_lastLoginDate ? [dateFormatter stringFromDate:_lastLoginDate] : @"never"];
  }

  if([_passcodeString containsString:@"LLCount"]) {
    _passcodeString = [_passcodeString stringByReplacingOccurrencesOfString:@"LLCount" withString:[NSString stringWithFormat:@"%d", _loginAttempts]];
  }

  if([_passcodeString containsString:@"LLDate"]) {
    NSString *dateFormat = [_userDefaults objectForKey:@"pCsDateFormat"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    _passcodeString = [_passcodeString stringByReplacingOccurrencesOfString:@"LLDate" withString:_lastLoginDate ? [dateFormatter stringFromDate:_lastLoginDate] : @"never"];
  }

}
@end
