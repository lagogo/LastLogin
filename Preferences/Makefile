TARGET = :clang
ARCHS = armv7 arm64

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LastLogin
LastLogin_FILES = LastLogin.mm $(wildcard *.m)
LastLogin_INSTALL_PATH = /Library/PreferenceBundles
LastLogin_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/LastLogin.plist$(ECHO_END)
