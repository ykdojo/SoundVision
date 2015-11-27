#import "FirstViewController.h"

@interface FirstViewController ()
@end

@implementation FirstViewController

float t = 0;
int x = 100;
int y = 100;
float *phases = new float[y];
int state = 0; // TODO: Fix this to an enum.

// something


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
        for (int i = 0; i < y; i++){
            phases[i] = 0.0;
        }
        t = 0;
        [self.audioManager play];
        [selectedButton setTitle:NSLocalizedString(@"Stop Sound Vision", nil) forState:0];
        state = 1;
    } else {
        [self.audioManager pause];
        for (int i = 0; i < y; i++){
            phases[i] = 0.0;
        }
        t = 0;
        [selectedButton setTitle:NSLocalizedString(@"Start Sound Vision", nil) forState:0];
        state = 0;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    __weak FirstViewController * wself = self;
    
    self.audioManager = [Novocaine audioManager];
    
    
    // SIGNAL GENERATOR!
    const float T = 3.0; // time length of one cycle
    const float amplitude = 1;
    
    float *frequencies = new float[y];
    float frequency_max = 4500.0;
    float frequency_min = 1500.0;
    frequencies[0] = frequency_max;
    float mult_rate = pow( frequency_min / frequency_max, 1/float(y));
    for (int i = 1; i < y; i++) {
        frequencies[i] = frequencies[i - 1] * mult_rate;
        //        frequencies[i] = frequency_max - i * frequency_diff / (y - 1);
    }
    
    float *matrix = new float[x*y];
    for (int i = 0; i < x*y; i++){
        matrix[i] = 0.0;
    }
    for (int i = 0; i < y; i++){
        matrix[x * i + i] = 1.0;
    }
    
    
    [self.audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         //         NSLog(@"Time: %f", t);
         if (t > T){
             [wself.audioManager pause];
             //             free(matrix);
             //             free(frequencies);
             //             free(phases);
             // TODO: fix this later.
             state = 0;
             [wself.playButton setTitle:NSLocalizedString(@"Start Sound Vision", nil) forState:0];
         }
         
         int length = x;
         float samplingRate = wself.audioManager.samplingRate;
         for (int i=0; i < numFrames; ++i)
         {
             
             int x_ind = int( (t / T) * length ); // x index
             float tmp = 0;
             for (int y_ind = 0; y_ind < y; y_ind++){
                 float theta = phases[y_ind] * M_PI * 2;
                 
                 tmp += sin(theta) * matrix[x_ind + y_ind*x];
                 
                 // The following code was just for an experimentation, maybe delete it later
                 //                 float freq = frequencies[y_ind];
                 //                 int tmp_2 = int(t * freq);
                 //                 float left = tmp_2 / freq;
                 //                 float right = left + 1 / freq;
                 //                 int x_left = int( (left / T) * length );
                 //                 int x_right = int( (right / T) * length );
                 //                 if (x_left == x_right || x_right >= x) {
                 //                     tmp += sin(theta) * matrix[x_left + y_ind*x];
                 //                 }
                 //                 else{
                 //                     tmp += sin(theta) * (0.5 * matrix[x_left + y_ind*x] + 0.5 * matrix[x_right + y_ind*x]);
                 //                 }
             }
             
             // copying the same data for both channels (left and right speakers)
             for (int iChannel = 0; iChannel < numChannels; ++iChannel)
             {
                 data[i*numChannels + iChannel] = tmp * amplitude;
             }
             for (int i = 0; i < y; i++){
                 phases[i] += 1.0 / (samplingRate / frequencies[i]);
                 if (phases[i] > 1.0) phases[i] = -1;
             }
             t += 1.0 / samplingRate;
         }
     }];
    
//    [self.audioManager play];
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
