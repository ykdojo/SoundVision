#import "FirstViewController.h"

@interface FirstViewController ()
@end

@implementation FirstViewController

float t = 0;
int x = 64; // set x = y = 64 when using Peter's strings.
int y = 64;
float *matrix_to_play = new float[x*y];
float *phases = new float[y];
int state = 0; // TODO: Fix this to an enum.

// something

// Peter's house and car drawing, 64 x 64 pixels,
// 'a' represents black (far) wheras 'p' represents white (near)
NSArray *peterStrings = @[  /* N x N pixels, 16 grey levels a,...,p */
    @"aaaaaaaaaaaaaaaaaaaaaaaaaaapapaaaaaapaaapaapaaaaaaaaaaaaaaaaaaaa",
    @"aaaaaaaaaaaaaaaaaaaaaaaaaaaapaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaaaaaaaaaaaaaaaaaaaaaaapaaaapappaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaaaaaaaaaaaaaaaaaaaaaaapappappaaaaapaaaaaaapaaaaaaaaaaaaaaaaa",
    @"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaapaaaaaaaaapaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaaaaaaaaaaaaaaaaaaaaaaaaaapaaaaaaaaaaaappppaaaaaaaaaaaaaaaaaa",
    @"aaaaaaaaaaaaaaaaaaaaaaaaaaappaaaapaaappaaaapaaapaaapaaaaaaaaaaaa",
    @"aaaaaaaaaaaaaaaaaaaaaaaaaapaapaaapaapaapaaaaapaaaaaaaaaaaaaaaaaa",
    @"aaaaaaaaaaaaaaaaaaaaaaaaapaappaaapappaaaapaaaaaapaaaaaaaaaaaaaaa",
    @"aaaaaaaaaaaaaaaaaaaaaaaaaapppaaapaaaaaaaaaaaapaappaappaaaaaaaaaa",
    @"aaaaaaaaaaaaaaaaaaaaaaaaapappappaaapapaaaaapaaapaaaaaaaaaaaaaaaa",
    @"aaaaaaaaaaaaaaaaaaaaaaaaaaaaapappaaapapaaaaaaappappaaaaaaaaaaaaa",
    @"aaaaaaaaaaaaaaaaaaaapaaaaaapaaaaaaaaaaaaaaaaapaaaaapaaaaaaaaaaaa",
    @"aaaaaaaaaaaaaaaaaaapppaaaaaaaaaaapaaaaaaaaaaaaappapaaaaaaaaaaaaa",
    @"aaaaaaaaaaaaaaaaaappappaaaapppapaaaaaaapaapaaaaaaaaapaaaaaaaaaaa",
    @"aaaaaaaaaaaaaaaaappaaappaaapppaaaapapaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaaaaaaaaaaaaappaaaaappaapppaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaaaaaaaaaaaappaaaaaaappapppaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaaaaaaaaaaappaaaaaaaaapppppaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaaaaaaaaaappaaaaaaaaaaappppaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaaaaaaaaappaaaaaaaaaaaaapppaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaaaaaaaappaaaaaaaaaaaaaaappaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaaaaaaappaaaaaaaaaaaaaaaaappaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaaaaaappaaaaaaaaaaaaaaaaaaappaaaaaaaaaaaaaaaaapppaapppaapppaa",
    @"aaaaaaaappaaaaaaaaaaaaaaaaaaaaappaaaaaaaaaaaaaaaapppaapppaapppaa",
    @"aaaaaaappaaaaaaaaaaaaaaaaaaaaaaappaaaaaaaaaaaaaaapppaapppaapppaa",
    @"aaaaaappaaaaaaaaaaaaaaaaaaaaaaaaappaaaaaaaaaaaaaapppaapppaapppaa",
    @"aaaaappaaaaaaaaaaaaaaaaaaaaaaaaaaappaaaaaaaaaaaaapppaapppaapppaa",
    @"aaaaapppppppppppppppppppppppppppppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaapppppppppppppppppppppppppppppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaapppppppppppppppppppppppppppppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaapppppppppppppppppppppppppppppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaapppppaaaaaaappppppaaaaaaappppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaapppppaaaaaaappppppaaaaaaappppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaapppppaaaaaaappppppaaaaaaappppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    
    @"aaaaapppppaaaaaaappppppaaaaaaappppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaapppppaaaaaaappppppaaaaaaappppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaapppppaaaaaaappppppaaaaaaappppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaapppppppppppppppppppppppppppppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaapppppppppppppppppppppppppppppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaapppppppppppppppppppppppppppppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaapppppppppppppppppppppppppppppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaapppppppppppppppppppppppppppppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaapppppppppppppppppppppppppppppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaapppppaaaaaappppppaaaaaaaappppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaapppppaaaaaappppppaaaaaaaappppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaapppppaaaaaappppppaaaaaaaappppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaapppppaaaaaappppppaaaaaaaappppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaapppppaaaaaappppppaaaaaaaappppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaapppppaaaaaappppppaaaaaaaappppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaapppppaaaaaappppppppppppppppppppaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaapppppaaaaaappppppppppppppppppppaaaaaaaaaapppppppaaaaaaaaaaa",
    @"aaaaapppppaaaaaappppppppppppppppppppaaaaaaaaapaapaaaapaaaaaaaaaa",
    @"aaaaapppppaaaaaappppppppppppppppppppaaaaaaaapaaapaaaapaaaaaaaaaa",
    @"aaaaapppppppppppppppppppppppppppppppaaaaapppaaaapaaaaapppppaaaaa",
    @"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaappppppppppppppppppppaaaa",
    @"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaappppppppppppppppppppaaaa",
    @"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaappappapppppppappapppaaaa",
    @"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaapaaaaaaappppaaaaaaappppaaaaaaa",
    @"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaappaaaaaaaappppaaaaaaappppaaaaaaa",
    @"aaaaaaaaaaaaaaaaaaaaaaaaaaaaapppaaaaaaaaaaappaaaaaaaaappaaaaaaaa",
    @"aaaaaaaaaaaaaaaaaaaaaaaapppppaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aaaaaaaaaaaaaaaappppppppaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    @"aappppppppppppppaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"];


float *frequencies = new float[y];
float frequency_max = 5000.0;
float frequency_min = 500.0;
const float T = 1.0; // time length of one cycle
const float amplitude = 0.05; // the maximum amplitude we can use seems to be like 0.05.  I'm not 100% sure on this though.



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (IBAction)togglePlay:(UIButton *)selectedButton
{
    if (state == 0){
        [self playMatrix:matrix_to_play x_length: x y_length: y];
        [selectedButton setTitle:NSLocalizedString(@"Stop Sound Vision", nil) forState:0];
        state = 1;
    } else {
        [self.audioManager pause];
        [selectedButton setTitle:NSLocalizedString(@"Start Sound Vision", nil) forState:0];
        state = 0;
    }
}


// this function converts the matrix into sound
- (void)playMatrix: (float*) matrix
          x_length: (int) x_len
          y_length: (int) y_len
{
    __weak FirstViewController * wself = self;
    for (int i = 0; i < y_len; i++){
        phases[i] = 0.0;
    }
    t = 0;

    [self.audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         //         NSLog(@"Time: %f", t);
         float samplingRate = wself.audioManager.samplingRate;
         
         if (t + 2.0 / samplingRate > T){
             [wself.audioManager pause];
             //             free(matrix);
             //             free(frequencies);
             //             free(phases);
             // TODO: fix this later.
             state = 0;
             [wself.playButton setTitle:NSLocalizedString(@"Start Sound Vision", nil) forState:0];
         }
         
         for (int i=0; i < numFrames; ++i)
         {
             
             int x_ind = int( (t / T) * x_len ); // x index
             float tmp = 0;
             for (int y_ind = 0; y_ind < y_len; y_ind++){
                 float theta = phases[y_ind] * M_PI * 2;
                 
                 // make sure the index doesn't exceed the limit
                 if (x_ind + y_ind*x_len < y_len*x_len) {
                     tmp += sin(theta) * matrix[x_ind + y_ind*x_len];
                 }
             }
             
             // copying the same data for both channels (left and right speakers)
             for (int iChannel = 0; iChannel < numChannels; ++iChannel)
             {
                 data[i*numChannels + iChannel] = tmp * amplitude;
             }
             for (int i = 0; i < y_len; i++){
                 phases[i] += 1.0 / (samplingRate / frequencies[i]);
                 if (phases[i] > 1.0) phases[i] = -1;
             }
             t += 1.0 / samplingRate;
         }
     }];
    [self.audioManager play];

}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.audioManager = [Novocaine audioManager];
    frequencies[0] = frequency_max;
    float mult_rate = pow( frequency_min / frequency_max, 1/float(y));
    for (int i = 1; i < y; i++) {
        // exponential scale
        frequencies[i] = frequencies[i - 1] * mult_rate;
        
        // linear scale
        //        frequencies[i] = frequency_max - i * frequency_diff / (y - 1);
    }
    
//    // IDENTITY
//    for (int i = 0; i < x*y; i++){
//        matrix_to_play[i] = 0.0;
//    }
//    for (int i = 0; i < y; i++){
//        matrix_to_play[x * i + i] = 1.0;
//    }
    
    // Peter's strings (it's the B&W drawing here: https://www.seeingwithsound.com/im2sound.htm)
    for( int x_ind = 0 ; x_ind < x ; x_ind++ ){
        for( int y_ind = 0 ; y_ind < y ; y_ind++ ){
            // this way, we get 'p' = 15 and 'a' = 0.
            float char_converted = (float)([peterStrings[y_ind] characterAtIndex:x_ind] - 'a') / 15.0;
            matrix_to_play[x_ind + y_ind * x] = char_converted;
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
