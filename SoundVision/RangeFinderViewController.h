/*
 This file is part of the Structure SDK.
 Copyright © 2013 Occipital, Inc. All rights reserved.
 http://structure.io
 */

#import <UIKit/UIKit.h>
#import "Novocaine.h"

#define HAS_STDCXX
#import <Structure/Structure.h>

@interface RangeFinderViewController : UIViewController <STSensorControllerDelegate, AVAudioPlayerDelegate>
@property (nonatomic, strong) Novocaine *audioManager;
@end
