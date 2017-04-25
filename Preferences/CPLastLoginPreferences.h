#import <Preferences/Preferences.h>
#import <UIKit/UIImage+Private.h>

#define MAIN_ICON_PATH               @"/Library/PreferenceBundles/LastLogin.bundle/images/LastLogin.png"
#define HEADER_ICON               @"/Library/PreferenceBundles/LastLogin.bundle/images/headerLogo.png"

#define buttonCellWithName(name) [PSSpecifier preferenceSpecifierNamed:name target:self set:NULL get:NULL detail:NULL cell:PSButtonCell edit:Nil]
#define switchCellWithName(name) [PSSpecifier preferenceSpecifierNamed:name target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NULL cell:PSSwitchCell edit:Nil]
#define textEditCellWithName(name) [PSSpecifier preferenceSpecifierNamed:name target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NULL cell:PSEditTextCell edit:Nil]
