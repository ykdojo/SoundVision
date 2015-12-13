//
//  FirstViewController.h
//  SoundVision
//
//  Created by Yosuke Sugishita on 11/11/15.
//  Copyright (c) 2015 Yosuke Sugishita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Novocaine.h"

@interface FirstViewController : UIViewController {
    IBOutlet UILabel *frequencyMax;
    IBOutlet UILabel *frequencyMin;
    IBOutlet UILabel *tValue;
}

@property (nonatomic, strong) Novocaine *audioManager;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
- (IBAction)togglePlay:(UIButton *)selectedButton;

- (IBAction)frequencyMaxSet:(UISlider *)sender;
- (IBAction)frequencyMinSet:(UISlider *)sender;
- (IBAction)tSet:(UISlider *)sender;

@end
