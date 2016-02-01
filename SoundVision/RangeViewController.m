/*
 This file is part of the Structure SDK.
 Copyright © 2013 Occipital, Inc. All rights reserved.
 http://structure.io
 */


#import "RangeViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Structure/StructureSLAM.h>

#define CONNECT_TEXT @"Please Connect Structure Sensor"
#define CHARGE_TEXT @"Please Charge Structure Sensor"



@interface ViewController () <AVCaptureVideoDataOutputSampleBufferDelegate> {
    
    STSensorController *_sensorController;
    
    AVCaptureSession *_session;
    
    UIImageView *_depthImageView;
    
    UILabel* _statusLabel;
    
    STFloatDepthFrame *floatDepthFrame;
}

- (bool)connectAndStartStreaming;
- (void)renderDepthFrame:(STDepthFrame*) depthFrame;
- (void)startAVCaptureSession;

@end

@implementation ViewController


double lastTimePlayed = 0; // the last time the sound was played

float t = 0;
long current_frame = 0;
int x = 176;
int y = 64;
char* rgba = (char*)malloc(x*y*4);
float *matrix_to_play = new float[x*y];
float *phases = new float[y]; // random phases
int state = 0; // TODO: Fix this to an enum.

float *frequencies = new float[y];
float frequency_max = 5000.0;
float frequency_min = 500.0;
const float T = 1.05; // time length of one cycle
const float amplitude = 0.0001; // TODO: try a lower number.


// this function converts the matrix into sound
- (void)playMatrix: (float*) A
          x_length: (int) x_len
          y_length: (int) y_len
{
    
    __weak ViewController * wself = self;
    t = 0;
    current_frame = 0;
    for (int i = 0; i < y_len; i++){
        phases[i] = (float)rand() / RAND_MAX * 2 * M_PI;
    }
    
    
    [self.audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         float samplingRate = wself.audioManager.samplingRate;
         
         // +4.0 helps us get rid of the noise that we don't want at the end.
         if (t + 4.0 / samplingRate * numFrames >= T){
             [wself.audioManager pause];
             state = 0;
         }
         
         for (int i=0; i < numFrames; ++i)
         {
             long m = (long) (samplingRate * T / x_len);
             float r = 1.0 * current_frame / (floor (T*samplingRate) - 1);
             float theta_2 = (r - 0.5) * 2 * M_PI / 3;
             float head_size = 0.2; // in meters, I think
             float x_distance = 0.5 * head_size * (theta_2 + sin(theta_2));
             float v = 340; // speed of sound, 340 m/s
             float tl = t;
             float tr = t;
             tr += x_distance / v;
             
             int x_i = current_frame / m;
             float q = 1.0 * (current_frame % m) / (m - 1);
             float q2 = 0.5*q*q;
             current_frame += 1;
             
             float sl = 0;
             float sr = 0;
             for (int y_i = 0; y_i < y_len; y_i++){
                 // make sure the index doesn't exceed the limit
                 if (x_i < x_len){
                     float tmp_amplitude;
                     if (x_i == 0){
                         tmp_amplitude =
                         (1.0 - q2) * A[x_i + y_i*x_len]
                         + q2 * A[(x_i + 1) + y_i*x_len];
                     }
                     else if (x_i == x_len - 1) {
                         tmp_amplitude =
                         (q2 - q +0.5) * A[(x_i - 1) + y_i*x_len]
                         + (0.5 + q - q2) * A[x_i + y_i*x_len];
                     }
                     else {
                         tmp_amplitude =
                         (q2 - q +0.5) * A[(x_i - 1) + y_i*x_len]
                         + (0.5+q-q*q) * A[x_i + y_i*x_len]
                         + q2 * A[(x_i + 1) + y_i*x_len];
                     }
                     
                     float theta_l = frequencies[y_i] * M_PI * 2 * tl;
                     float theta_r = frequencies[y_i] * M_PI * 2 * tr;
                     
                     float x_abs = fabs(x_distance);
                     float diffraction;
                     if (v / frequencies[y - y_i - 1] > x_abs){
                         diffraction = 1;
                     } else {
                         diffraction = v / (x_abs * frequencies[y - y_i - 1]);
                     }
                     
                     float fade_l = 1;
                     float fade_r = 1;
                     
                     fade_l *= (1.0 - 0.7*r);
                     fade_r *= (0.3 + 0.7*r);
                     
                     sl += fade_l * tmp_amplitude * sin(theta_l + phases[y_i]);
                     sr += fade_r * tmp_amplitude * sin(theta_r + phases[y_i]);
                 }
             }
             
             // copying the same data for both channels (left and right speakers)
             for (int iChannel = 0; iChannel < numChannels; ++iChannel)
             {
                 // left channel
                 if(iChannel == 0) {
                     data[i*numChannels + iChannel] = sl * amplitude;
                 } else { // right channel
                     data[i*numChannels + iChannel] = sr * amplitude;
                 }
             }
             t += 1.0 / samplingRate;
         }
     }];
    [self.audioManager play];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize the audio manager
    self.audioManager = [Novocaine audioManager];
    
    // Setting the frequencies
    frequencies[0] = frequency_max;
    float mult_rate = pow( frequency_min / frequency_max, 1/float(y));
    for (int i = 1; i < y; i++) {
        frequencies[i] = frequencies[i - 1] * mult_rate; // exponential scale
        //        frequencies[i] = frequency_max - i * frequency_diff / (y - 1); // linear scale
    }
    
    
    // status bar hide
    // Make sure the status bar is hidden.
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    _sensorController = [STSensorController sharedController];
    _sensorController.delegate = self;
    
    // Request that we receive depth frames with synchronized color pairs
    [_sensorController setFrameSyncConfig:FRAME_SYNC_OFF];
    
    
    //
    // Create two image views where we will render our frames
    //
    
    CGRect depthFrame = self.view.frame;
    
    _depthImageView = [[UIImageView alloc] initWithFrame:depthFrame];
    _depthImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_depthImageView];
    
    
    floatDepthFrame = [[STFloatDepthFrame alloc] init];
    
    // When the app enters the foreground, we can choose to restart the stream
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
#if !TARGET_IPHONE_SIMULATOR
    [self startAVCaptureSession];
#endif
}


- (void)viewDidAppear:(BOOL)animated
{
    static bool fromLaunch = true;
    if(fromLaunch)
    {
        
        //
        // Create a UILabel in the center of our view to display status messages
        //
        
        // We do this here instead of in viewDidLoad so that we get the correctly size/rotation view bounds
        if (!_statusLabel) {
            
            _statusLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
            _statusLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
            _statusLabel.textAlignment = NSTextAlignmentCenter;
            _statusLabel.font = [UIFont systemFontOfSize:35.0];
            
            [_statusLabel setText:CONNECT_TEXT];
            [_statusLabel setTextColor:[UIColor whiteColor]];
            [self.view addSubview: _statusLabel];
        }
        
        [self connectAndStartStreaming];
        fromLaunch = false;
    }
}


- (void)appWillEnterForeground
{
    
    bool success = [self connectAndStartStreaming];
    
    if(!success)
    {
        // Workaround for direct multitasking between two Structure Apps.
        
        // HACK ALERT! Try once more after a delay if we failed to reconnect on foregrounding.
        // 0.75s was not enough, 0.95s was, but this might depend on the other app using the sensor.
        // We need a better solution to this.
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self
                                       selector:@selector(connectAndStartStreaming) userInfo:nil repeats:NO];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (bool)connectAndStartStreaming
{
    
    STSensorControllerInitStatus result = [_sensorController initializeSensorConnection];
    
    bool didSucceed = (result == STSensorControllerInitStatusSuccess || result == STSensorControllerInitStatusAlreadyInitialized);
    
    
    if (didSucceed)
    {
        //Now that we're about to stream, hide the status label
        [self hideStatusMessage];
        
        //After this call, we will start to receive frames through the delegate methods
        [_sensorController startStreamingWithConfig:CONFIG_VGA_DEPTH];
    }
    else
    {
        if (result == STSensorControllerInitStatusSensorNotFound)
            NSLog(@"[Debug] No Structure Sensor found!");
        else if (result == STSensorControllerInitStatusOpenFailed)
            NSLog(@"[Error] Structure Sensor open failed.");
        else if (result == STSensorControllerInitStatusSensorIsWakingUp)
            NSLog(@"[Debug] Structure Sensor is waking from low power.");
        else if (result != STSensorControllerInitStatusSuccess)
            NSLog(@"[Debug] Structure Sensor failed to init with status %d.", (int)result);
        
        [self showStatusMessage:CONNECT_TEXT];
    }
    
    return didSucceed;
    
}


- (void) showStatusMessage: (NSString*) msg
{
    
    _statusLabel.hidden = false;
    _statusLabel.text = msg;
    
}

- (void) hideStatusMessage
{
    _statusLabel.hidden = true;
}


#pragma mark -
#pragma mark Structure SDK Delegate Methods

- (void) sensorDidDisconnect
{
    NSLog(@"Structure Sensor disconnected!");
    [self showStatusMessage:CONNECT_TEXT];
}

- (void) sensorDidConnect
{
    NSLog(@"Structure Sensor connected!");
    [self connectAndStartStreaming];
}

- (void) sensorDidEnterLowPowerMode
{
    // Notify the user that the sensor needs to be charged.
    [self showStatusMessage:CHARGE_TEXT];
}

- (void) sensorDidLeaveLowPowerMode
{
    
}

- (void) sensorBatteryNeedsCharging
{
    // Notify the user that the sensor needs to be charged.
    [self showStatusMessage:CHARGE_TEXT];
}

- (void) sensorDidStopStreaming:(STSensorControllerDidStopStreamingReason)reason
{
    //If needed, change any UI elements to account for the stopped stream
}

- (void) sensorDidOutputDepthFrame: (STDepthFrame*) depthFrame
{
    
    [floatDepthFrame updateFromDepthFrame:depthFrame];
    
    // we need to wait at least T seconds since the last time played
    double now = [[NSDate date] timeIntervalSince1970];
    if (now > lastTimePlayed + T + 0.05){
        lastTimePlayed = now;
        float depth;
        
        for (int x_ind = 0; x_ind < x; x_ind++){
            for (int y_ind = 0; y_ind < y; y_ind++){
                float sum = 0;
                int count = 0;
                int S = 0; // sample range, start with 0 and make it larger and larger
                while (S < 5) {
                    for (int i = -S; i <= S; i++){
                        for (int j = -S; j <= S; j++){
                            // the only relevant indices are the edges
                            if (abs(i) == S or abs(j) == S){
                                int x_ind_translated = (int)( (x_ind + i + 0.5) * (depthFrame->width / x) );
                                int y_ind_translated = (int)( (y_ind + j + 0.5) * (depthFrame->height / y) );
                                // make sure the indices we are looking at are inside the matrix
                                if (x_ind_translated >= 0
                                    && x_ind_translated < depthFrame -> width
                                    && y_ind_translated >= 0
                                    && y_ind_translated < depthFrame -> height
                                    ) {
                                    // need to devide this by 1000 to get a meter amount
                                    float depth_tmp = floatDepthFrame.depthAsMeters[
                                                                                    x_ind_translated
                                                                                    + y_ind_translated * depthFrame->width
                                                                                    ] / 1000.0;
                                    if(!isnan(depth_tmp)){
                                        count++;
                                        sum += depth_tmp;
                                    }
                                }
                            }
                        }
                    } //  for (int i = -S; i <= S; i++){
                    
                    if(count == 0){
                        depth = NAN;
                        S++;
                    } else {
                        depth = sum / count;
                        break;
                    }
                } // while (S < 5)
                
                
                
                float max_depth = 3.2; // by setting this to 3.2, the effective range becomes 3 meters.
                float min_depth = 0.3;
                
                if(!isnan(depth)) {
                    if (depth > max_depth) depth = max_depth;
                    else if (depth < min_depth) depth = min_depth;
                } else {
                    depth = min_depth;
                }
                
                // The linear scale goes from 0 to 1.
                // 0 means far, 1 means close.
                float linear_scale = 1 - ( (depth - min_depth) / (max_depth - min_depth) );
                // Translate it to an exponential scale.
                float exp_scale;
                
                if (linear_scale < 1/16) {
                    exp_scale = 0;
                } else {
                    exp_scale = powf(10, (linear_scale * 16 - 16) / 10);
                }
                
                matrix_to_play[x_ind + y_ind * x] = exp_scale;
            }
        }
        
        //        NSString *d = [NSString stringWithFormat:@"%f", ratioNaN];
        //        [self showStatusMessage:d];
        
        [self playMatrix:matrix_to_play x_length: x y_length: y];
        [self renderDepthFrame:depthFrame];
        
    }
}

// This synchronized API will only be called when two frames match. Typically, timestamps are within 1ms of each other.
// Two important things have to happen for this method to be called:
// Tell the SDK we want framesync: [_ocSensorController setFrameSyncConfig:FRAME_SYNC_DEPTH_AND_RGB];
// Give the SDK color frames as they come in:     [_ocSensorController frameSyncNewColorImage:sampleBuffer];
- (void) sensorDidOutputSynchronizedDepthFrame: (STDepthFrame*)     depthFrame
                                 andColorFrame: (CMSampleBufferRef) sampleBuffer
{
    
}


#pragma mark -
#pragma mark Rendering

- (void) renderDepthFrame: (STDepthFrame*) depthFrame
{
    
    for(int i=0; i < x*y; ++i) {
        int tmp_color = (int) (matrix_to_play[i] * 255);
        rgba[4*i] = tmp_color;
        rgba[4*i+1] = tmp_color;
        rgba[4*i+2] = tmp_color;
        rgba[4*i+3] = 0;
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(
                                                       rgba,
                                                       x,
                                                       y,
                                                       8, // bitsPerComponent
                                                       4*x, // bytesPerRow
                                                       colorSpace,
                                                       kCGImageAlphaNoneSkipLast);
    
    CFRelease(colorSpace);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    
    CFRelease(colorSpace);
    _depthImageView.image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
}


#pragma mark -  AVFoundation

- (void)startAVCaptureSession
{
    NSString* sessionPreset = AVCaptureSessionPreset640x480;
    
    //-- Setup Capture Session.
    _session = [[AVCaptureSession alloc] init];
    [_session beginConfiguration];
    
    //-- Set preset session size.
    [_session setSessionPreset:sessionPreset];
    
    //-- Creata a video device and input from that Device.  Add the input to the capture session.
    AVCaptureDevice * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if(videoDevice == nil)
        assert(0);
    
    NSError *error;
    [videoDevice lockForConfiguration:&error];
    
    // Auto-focus Auto-exposure, auto-white balance
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)
        [videoDevice setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionFar];
    [videoDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    
    [videoDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    [videoDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
    
    [videoDevice unlockForConfiguration];
    
    //-- Add the device to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if(error)
        assert(0);
    
    [_session addInput:input]; // After this point, captureSession captureOptions are filled.
    
    //-- Create the output for the capture session.
    AVCaptureVideoDataOutput * dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    //-- Set to YUV420.
    [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                             forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
    // Set dispatch to be on the main thread so OpenGL can do things with the data
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    [_session addOutput:dataOutput];
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)
    {
        [videoDevice lockForConfiguration:&error];
        [videoDevice setActiveVideoMaxFrameDuration:CMTimeMake(1, 30)];
        [videoDevice setActiveVideoMinFrameDuration:CMTimeMake(1, 30)];
        [videoDevice unlockForConfiguration];
    }
    else
    {
        AVCaptureConnection *conn = [dataOutput connectionWithMediaType:AVMediaTypeVideo];
        
        // Deprecated use is OK here because we're using the correct APIs on iOS 7 above when available
        // If we're running before iOS 7, we still really want 30 fps!
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        conn.videoMinFrameDuration = CMTimeMake(1, 30);
        conn.videoMaxFrameDuration = CMTimeMake(1, 30);
#pragma clang diagnostic pop
        
    }
    [_session commitConfiguration];
    
    [_session startRunning];
    
}


- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    // Pass into the driver. The sampleBuffer will return later with a synchronized depth or IR pair.
    [_sensorController frameSyncNewColorImage:sampleBuffer];
    
    // If we weren't using framesync, we could just do the following instead:
    // [self renderColorFrame:sampleBuffer];
    
}

#pragma mark - Audio Support

static void interruptionListener(void *inClientData, UInt32 inInterruption)
{
    NSLog(@"Session interrupted: --- %s ---",
          inInterruption == kAudioSessionBeginInterruption ? "Begin Interruption" : "End Interruption");
}



@end
