#import "CPLastLoginPreferences.h"
#import <MobileGestalt/MobileGestalt.h>

@interface LastLoginListController: PSListController
@property (nonatomic, strong) NSMutableArray *lockscreenSpecs;
@property (nonatomic, strong) NSMutableArray *passcodeSpecs;
@end

@implementation LastLoginListController

- (instancetype)init {
  if(self = [super init]) {
    [self createDynamicSpecs];
  }
  return self;
}

-(id)specifiers {
  if(_specifiers == nil) {

    NSMutableArray *specs = [NSMutableArray new];
    PSSpecifier *spec;

    spec = [PSSpecifier emptyGroupSpecifier];
    [specs addObject:spec];

    spec = switchCellWithName(@"Count TouchID Attempts");
    [spec setProperty:@"trackMesa" forKey:@"key"];
    [spec setProperty:@NO forKey:@"default"];
    [specs addObject:spec];

    spec = [PSSpecifier emptyGroupSpecifier];
    [spec setProperty:@"Enabling this option will show the LastLogin text instead of 'Press Home To Unlock'" forKey:@"footerText"];
    [specs addObject:spec];

    spec = switchCellWithName(@"Display on Action Label");
    [spec setProperty:@"displaysActionLabel" forKey:@"key"];
    [spec setProperty:@NO forKey:@"default"];
    [specs addObject:spec];

    BOOL displaysActionLabel = [[self readPreferenceValue:spec] boolValue];

    if(displaysActionLabel) {
      for(PSSpecifier *sp in _lockscreenSpecs) {
        [specs addObject:sp];
      }
    }

    spec = [PSSpecifier emptyGroupSpecifier];
    [spec setProperty:@"Enabling this option will show the LastLogin text instead of 'Enter Passcode'" forKey:@"footerText"];
    [specs addObject:spec];

    spec = switchCellWithName(@"Display on Passcode Screen");
    [spec setProperty:@"displaysPasscodeLabel" forKey:@"key"];
    [spec setProperty:@NO forKey:@"default"];
    [specs addObject:spec];

    BOOL displaysPasscodeLabel = [[self readPreferenceValue:spec] boolValue];

    if(displaysPasscodeLabel) {
      for(PSSpecifier *sp in _passcodeSpecs) {
        [specs addObject:sp];
      }
    }

    spec = [PSSpecifier emptyGroupSpecifier];
    [spec setProperty:@"If you're having trouble configuring your date formatter, check out this site for information" forKey:@"footerText"];
    [specs addObject:spec];

    spec = buttonCellWithName(@"Date Formatters: How To");
    spec->action = @selector(handleOpeningPageWithSpecifier:);
    [spec setProperty:@"http://nsdateformatter.com" forKey:@"pageLink"];
    [specs addObject:spec];

    spec = [PSSpecifier emptyGroupSpecifier];
    [specs addObject:spec];

    spec = buttonCellWithName(@"Follow on Twitter");
    spec->action = @selector(handleOpeningPageWithSpecifier:);
    [spec setProperty:@"https://twitter.com/CPDigDarkroom" forKey:@"pageLink"];
    [specs addObject:spec];

    spec = buttonCellWithName(@"View Source");
    spec->action = @selector(handleOpeningPageWithSpecifier:);
    [spec setProperty:@"https://github.com/CPDigitalDarkroom/LastLogin" forKey:@"pageLink"];
    [specs addObject:spec];

    _specifiers = [specs copy];
  }
  return _specifiers;
}

- (void)handleOpeningPageWithSpecifier:(PSSpecifier *)spec {
    NSString *siteLink = spec.properties[@"pageLink"];
    if([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:siteLink] options:@{} completionHandler:nil];
    } else {
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:siteLink]];
    }
}

- (void)createDynamicSpecs {
  _lockscreenSpecs = [NSMutableArray new];
  _passcodeSpecs = [NSMutableArray new];
  PSSpecifier *spec;

  spec = [PSSpecifier emptyGroupSpecifier];
  [spec setProperty:@"Enter the string you'd like displayed on the LockScreen 'Press Home to Unlock' label. Use LLCount and LLDate as placeholders. They will be replaced during presentation." forKey:@"footerText"];
  [_lockscreenSpecs addObject:spec];

  spec = textEditCellWithName(@"Date Format:");
  [spec setProperty:@"lsDateFormat" forKey:@"key"];
  [spec setProperty:@"M/dd h:mm" forKey:@"default"];
  [_lockscreenSpecs addObject:spec];

  spec = textEditCellWithName(@"Text:");
  [spec setProperty:@"lsString" forKey:@"key"];
  [spec setProperty:@"LLCount Login Attempts Since LLDate" forKey:@"default"];
  [_lockscreenSpecs addObject:spec];

  spec = [PSSpecifier emptyGroupSpecifier];
  [spec setProperty:@"Enter the string you'd like displayed on the passcode screen 'Enter Passcode' label. Use LLCount and LLDate as placeholders. They will be replaced during presentation." forKey:@"footerText"];
  [_passcodeSpecs addObject:spec];

  spec = textEditCellWithName(@"Date Format:");
  [spec setProperty:@"psDateFormat" forKey:@"key"];
  [spec setProperty:@"M/dd h:mm" forKey:@"default"];
  [_passcodeSpecs addObject:spec];

  spec = textEditCellWithName(@"Text:");
  [spec setProperty:@"psString" forKey:@"key"];
  [spec setProperty:@"LLCount Login Attempts Since LLDate" forKey:@"default"];
  [_passcodeSpecs addObject:spec];
}

-(void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {

  NSDictionary *properties = specifier.properties;
  NSString *key = properties[@"key"];

  CFPreferencesSetAppValue((CFStringRef)key, (CFPropertyListRef)value, CFSTR("com.cpdigitaldarkroom.lastlogin"));

  if([key isEqualToString:@"displaysActionLabel"] || [key isEqualToString:@"displaysPasscodeLabel"]) {
    [self updateSpecifiersWithValue:[value boolValue] andKey:key];
  }

  CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.cpdigitaldarkroom.lastlogin.settings"), NULL, NULL, true);
}

-(id)readPreferenceValue:(PSSpecifier*)specifier {
  NSString *key = specifier.properties[@"key"];
  return (id)CFPreferencesCopyAppValue((CFStringRef)key, CFSTR("com.cpdigitaldarkroom.lastlogin"));
}

- (void)updateSpecifiersWithValue:(BOOL)value andKey:(NSString *)key {

  if([key isEqualToString:@"displaysActionLabel"]) {
    if(value) {
      [self insertContiguousSpecifiers:_lockscreenSpecs afterSpecifierID:@"displaysActionLabel" animated:YES];
    } else {
      [self removeContiguousSpecifiers:_lockscreenSpecs animated:YES];
    }
  } else if([key isEqualToString:@"displaysPasscodeLabel"]) {
    if(value) {
      [self insertContiguousSpecifiers:_passcodeSpecs afterSpecifierID:@"displaysPasscodeLabel" animated:YES];
    } else {
      [self removeContiguousSpecifiers:_passcodeSpecs animated:YES];
    }
  }
}

-(void)viewDidLoad {

  UIImage *icon = [[UIImage alloc] initWithContentsOfFile:HEADER_ICON];
  icon = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
  self.navigationItem.titleView = iconView;
  self.navigationItem.titleView.alpha = 0;

  [super viewDidLoad];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window];

  [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(increaseAlpha) userInfo:nil repeats:NO];
}

- (void)keyboardWillShow:(NSNotification *)n {
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
}

- (void)keyboardWillHide:(NSNotification *)n {
  self.navigationItem.rightBarButtonItem = nil;
}

- (void)save {
  [self.view endEditing:YES];
}

- (void)increaseAlpha {
  [UIView animateWithDuration:0.5 animations:^{
    self.navigationItem.titleView.alpha = 1;
  } completion:nil];
}

@end
