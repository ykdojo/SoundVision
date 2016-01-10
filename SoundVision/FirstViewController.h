//
//  FirstViewController.h
//  SoundVision
//
//  Created by Yosuke Sugishita on 11/11/15.
//  Copyright (c) 2015 Yosuke Sugishita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Novocaine.h"

@interface FirstViewController : UIViewController

@property (nonatomic, strong) Novocaine *audioManager;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
- (IBAction)togglePlay:(UIButton *)selectedButton;

@property (weak, nonatomic) IBOutlet UISlider *minFrequencySlider;
@property (weak, nonatomic) IBOutlet UILabel *minFrequencyVal;

@property (weak, nonatomic) IBOutlet UISlider *maxFrequencySlider;
@property (weak, nonatomic) IBOutlet UILabel *maxFrequencyVal;

@property (weak, nonatomic) IBOutlet UISlider *speedSlider;
@property (weak, nonatomic) IBOutlet UILabel *speedVal;

@end
