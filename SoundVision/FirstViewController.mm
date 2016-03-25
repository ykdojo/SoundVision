#import "FirstViewController.h"

@interface FirstViewController ()
@end

@implementation FirstViewController

float t = 0;
long current_frame = 0;
int x = 128; // set x = y = 64 when using Peter's strings.
int y = 64;
float *phases = new float[y]; // random phases
float *matrix_to_play = new float[x*y];
int state = 0; // TODO: Fix this to an enum.

float *frequencies = new float[y];
float frequency_max;
float frequency_min;
const float T = 1.05; // time length of one cycle
const float amplitude = 0.05; // the maximum amplitude we can use seems to be like 0.05.  I'm not 100% sure on this though.


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





- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    frequency_min = self.minFrequencySlider.value = 500.0;
    self.minFrequencyVal.text = [NSString stringWithFormat:@"%i Hertz", (int)roundf(frequency_min)];
    
    frequency_max = self.maxFrequencySlider.value = 4000.0;
    self.maxFrequencyVal.text = [NSString stringWithFormat:@"%i Hertz", (int)roundf(frequency_max)];
    
    t = self.speedSlider.value;
    self.speedVal.text = [NSString stringWithFormat:@"%.1f s", t];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (IBAction)minFrequencySet:(id)sender {
    frequency_min = self.minFrequencySlider.value;
    
    self.minFrequencyVal.text = [NSString stringWithFormat:@"%i Hertz", (int)roundf(frequency_min)];
}


- (IBAction)maxFrequencySet:(id)sender {
    frequency_max = self.maxFrequencySlider.value;
    
    self.maxFrequencyVal.text = [NSString stringWithFormat:@"%i Hertz", (int)roundf(frequency_max)];
}


- (IBAction)speedSet:(id)sender {
    t = self.speedSlider.value;
    
    self.speedVal.text = [NSString stringWithFormat:@"%.1f s", t];
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


// convert the x index so that if it's -1 (too much on the left), it becomes (xMax - 1) (on the right most column)
// and if we have xMax (too much on the right), it becomes 0 (on the left most column)
- (int) convertIndex: (int) xIndex
           x_length: (int) x_len
{
    if (xIndex == -1) {
        return x_len - 1;
    }
    else if (xIndex == x_len){
        return 0;
    }
    else {
        return xIndex;
    }
}



// this function converts the matrix into sound
- (void)playMatrix: (float*) A
          x_length: (int) x_len
          y_length: (int) y_len
{

    __weak FirstViewController * wself = self;
    t = 0;
    current_frame = 0;
    for (int i = 0; i < y_len; i++){
        phases[i] = (float)rand() / RAND_MAX * 2 * M_PI;
    }
    

    [self.audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         float samplingRate = wself.audioManager.samplingRate;

         for (int i=0; i < numFrames; ++i)
         {
             // numFramesTotal = # number of frames for all the columns
             int NF = (int)(samplingRate * T); // number of frames total
             // I want numFramesTotal to be divisible by sampling Rate
             int numFramesTotal = NF - NF % (int)samplingRate;
             
             // m = # frames per column
             long m = (long) (numFramesTotal / x_len);
             
             int x_i = current_frame / m;
             if (x_i >= x_len){
                 x_i = x_len - 1;
             }
             float q = 1.0 * (current_frame % m) / (m - 1);
             float q2 = 0.5*q*q;

             float s = 0;
             for (int y_i = 0; y_i < y_len; y_i++){
                     float tmp_amplitude;
                     int x_ind_left = [self convertIndex:(x_i - 1) x_length:x_len];
                     int x_ind_right = [self convertIndex:(x_i + 1) x_length:x_len];
                 
                    // TODO: test if this part is correct!
                   // I should always get the same result for this one for the same y_i
                    // -> TEST IT!!!  (WORKING ON THIS NOW)
                     tmp_amplitude =
                        (q2 - q +0.5) * A[x_ind_left + y_i*x_len]
                     + (0.5+q-q*q) * A[x_i + y_i*x_len]
                     + q2 * A[x_ind_right + y_i*x_len];
                 
                     float theta = frequencies[y_i] * M_PI * 2 * t;

                     s += tmp_amplitude * sin(theta + phases[y_i]);
             }
             
             // copying the same data for both channels (left and right speakers)
             for (int iChannel = 0; iChannel < numChannels; ++iChannel)
             {
                data[i*numChannels + iChannel] = s * amplitude;
             }
             
             // go back to the beginning right before current_frame
             //  reaches numFramesTotal
             // (that's what the % is for here yo)
             current_frame = (current_frame + 1) % numFramesTotal;
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
    float mult_rate = pow( frequency_min / frequency_max, 1/float(y-1));
    for (int i = 1; i < y; i++) {
        // exponential scale
        frequencies[i] = frequencies[i - 1] * mult_rate;
        
        // linear scale
        //        frequencies[i] = frequency_max - i * frequency_diff / (y - 1);
    }
    
    // IDENTITY
    for (int i = 0; i < x*y; i++){
        matrix_to_play[i] = 0.0;
    }
    for (int i = 0; i < y; i++){
        matrix_to_play[x * i + i] = 1.0;
        matrix_to_play[x * (63 - i) + (i + 64)] = 1.0;
    }

    
//    //   A single horizontal line
//    for (int i = 0; i < x*y; i++){
//        matrix_to_play[i] = 0.0;
//    }
//    for (int i = 0; i < x; i++){
//        matrix_to_play[i + (y*3/4) * x] = 1.0;
//    }

    
    
    
////     Peter's strings (it's the B&W drawing here: https://www.seeingwithsound.com/im2sound.htm)
//    for( int x_i = 0 ; x_i < x ; x_i++ ){
//        for( int y_i = 0 ; y_i < y ; y_i++ ){
//            // this way, we get 'p' = 15 and 'a' = 0.
//            float char_converted = (float)([peterStrings[y_i] characterAtIndex:x_i] - 'a') / 15.0;
//            matrix_to_play[x_i + y_i * x] = char_converted;
//        }
//    }
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
