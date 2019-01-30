#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "EMAppLanguage.h"
#import "EMDebugManager.h"
#import "EMDebugKit.h"
#import "EMFactoryManager.h"
#import "EMLogManager.h"
#import "NSBundle+DebugKit.h"

FOUNDATION_EXPORT double Emax_DebugKitVersionNumber;
FOUNDATION_EXPORT const unsigned char Emax_DebugKitVersionString[];

