#import "FirstViewController.h"

@interface FirstViewController ()
@end

@implementation FirstViewController

float currentTime = 0;
long current_frame = 0;
int x = 64; // set x = y = 64 when using Peter's strings.
int y = 64;
float *phases = new float[y]; // random phases
float *matrix_to_play = new float[x*y];
int state = 0; // TODO: Fix this to an enum.

float *rowFrequencies = new float[y];
float frequency_max;
float frequency_min;
const float lengthOfTimeMatrixIsPlaying = 1.05; // time length of one cycle
const float AMPLITUDE = 0.05; // the maximum amplitude we can use seems to be like 0.05.  I'm not 100% sure on this though.

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
    
    frequency_max = self.maxFrequencySlider.value = 5000.0;
    self.maxFrequencyVal.text = [NSString stringWithFormat:@"%i Hertz", (int)roundf(frequency_max)];
    
    currentTime = self.speedSlider.value;
    self.speedVal.text = [NSString stringWithFormat:@"%.1f s", currentTime];
    
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
    currentTime = self.speedSlider.value;
    
    self.speedVal.text = [NSString stringWithFormat:@"%.1f s", currentTime];
}



- (IBAction)togglePlay:(UIButton *)selectedButton
{
    if (state == 0){
        [self playMatrix:matrix_to_play x_length: x y_length: y];
        [selectedButton setTitle:NSLocalizedString(@"Stop Sound Vision", nil) forState:0];
        state = 1;
    } else {
//        [self.audioManager pause];
//        [selectedButton setTitle:NSLocalizedString(@"Start Sound Vision", nil) forState:0];
//        state = 0;
    }
}


// this function converts the matrix into sound
- (void)playMatrix: (float*) matrixToPlay
          x_length: (int) totalNumberOfColumns
          y_length: (int) totalNumberOfRows
{

    __weak FirstViewController * wself = self;
    // we need this because we cannot access self directly from the output block

    currentTime = 0;
    current_frame = 0;
    for (int i = 0; i < totalNumberOfRows; i++){
        // Randomizing phase start for each frequency
        phases[i] = (float)rand() / RAND_MAX * 2 * M_PI;
    }
    

    // Note:
    //   numFrames = 512
    //   numChannels = 2 (stereo)
    [self.audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         float samplingRate = wself.audioManager.samplingRate;

         
         //TODO: put this into a pause() function
         // +3.0 helps us get rid of the noise that we don't want at the end.
         if (currentTime + 4.0 / samplingRate * numFrames >= lengthOfTimeMatrixIsPlaying){
             [wself.audioManager pause];
             state = 0;
             [wself.playButton setTitle:NSLocalizedString(@"Start Sound Vision", nil) forState:0];
         }

         for (int i=0; i < numFrames; ++i)
         {
             long totalNumberOfFrames = samplingRate * lengthOfTimeMatrixIsPlaying;
             long numberOfFramesPerColumn = (long) (totalNumberOfFrames / totalNumberOfColumns);
             int currentColumn = current_frame / numberOfFramesPerColumn;
             current_frame += 1;
             float totalAmplitudeOfCurrentFrame = 0;
             
             for (int rowIndex = 0; rowIndex < totalNumberOfRows; rowIndex++){
                 // make sure the index doesn't exceed the limit with the if condition
                 if (currentColumn < totalNumberOfColumns){
                     float theta = rowFrequencies[rowIndex] * M_PI * 2 * currentTime;
                     int oneDimentionArrayIndex = currentColumn + rowIndex*totalNumberOfColumns;
                     float amplitudeFromDepthCell = matrixToPlay[oneDimentionArrayIndex];
                     totalAmplitudeOfCurrentFrame += amplitudeFromDepthCell * sin(theta + phases[rowIndex]);
                 }
             }
         
             // copying the same data for both channels (left and right speakers)
             for (int iChannel = 0; iChannel < numChannels; ++iChannel)
             {
                data[i*numChannels + iChannel] = totalAmplitudeOfCurrentFrame * AMPLITUDE;
             }
             currentTime += 1.0 / samplingRate;
         }
     }]; // [self.audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
    [self.audioManager play];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.audioManager = [Novocaine audioManager];
    rowFrequencies[0] = frequency_max; // each frequency corresponds to each row
    float mult_rate = pow( frequency_min / frequency_max, 1/float(y-1));
    for (int i = 1; i < y; i++) {
        // exponential scale
        rowFrequencies[i] = rowFrequencies[i - 1] * mult_rate;
        // this is written so that rowFrequencies[y] = frequency_min
        
        // linear scale
        //        frequencies[i] = frequency_max - i * frequency_diff / (y - 1);
    }
    
//  IDENTITY (meaning, 1's on the digonal and 0's everywhere else)
    for (int i = 0; i < x*y; i++){
        matrix_to_play[i] = 0.0;
    }
    for (int i = 0; i < y; i++){
        matrix_to_play[x * i + i] = 1.0;
    }
    // matrix_to_play[x_index * y_index + y_index] tod
    
    [self playMatrix:matrix_to_play x_length: x y_length: y];
    
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
