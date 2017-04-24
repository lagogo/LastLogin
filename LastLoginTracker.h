//
//
//    LastLoginTracker.h
//    Manage LastLogin Stuff
//    Created by Juan Carlos Perez <carlos@jcarlosperez.me> 04/24/2017
//    © CP Digital Darkroom <admin@cpdigitaldarkroom.com>. All rights reserved.
//
//

@interface LastLoginTracker : NSObject

@property (nonatomic, assign) BOOL tracksMesaAttempts;
@property (nonatomic, assign) int loginAttempts;
@property (nonatomic, strong) NSDate *lastLoginDate;

@property (nonatomic, strong) NSString *lockscreenString;
@property (nonatomic, strong) NSString *passcodeString;

+ (instancetype)sharedInstance;

@end
