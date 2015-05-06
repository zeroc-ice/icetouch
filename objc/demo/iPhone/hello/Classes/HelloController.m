// **********************************************************************
//
// Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
//
// This copy of Ice Touch is licensed to you under the terms described in the
// ICE_TOUCH_LICENSE file included in this distribution.
//
// **********************************************************************

#import <HelloController.h>
#import <Ice/Ice.h>
#import <Hello.h>

// Various delivery mode constants
#define DeliveryModeTwoway  0
#define DeliveryModeTwowaySecure 1
#define DeliveryModeOneway 2
#define DeliveryModeOnewayBatch  3
#define DeliveryModeOnewaySecure 4
#define DeliveryModeOnewaySecureBatch 5
#define DeliveryModeDatagram 6
#define DeliveryModeDatagramBatch 7

//
// Avoid warning for undocumented UISlider method
//
@interface UISlider(UndocumentedAPI)
-(void)setShowValue:(BOOL)val;
@end

@implementation HelloController

static NSString* hostnameKey = @"hostnameKey";

+(void)initialize
{
    NSDictionary* appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:@"127.0.0.1", hostnameKey, nil];
	
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
}

-(void)applicationWillTerminate
{
    [communicator destroy];
}

-(void)viewDidLoad
{
    ICEInitializationData* initData = [ICEInitializationData initializationData];
    initData.properties = [ICEUtil createProperties];

    [initData.properties setProperty:@"IceSSL.CheckCertName" value:@"0"];
    [initData.properties setProperty:@"IceSSL.CertAuthFile" value:@"cacert.der"];
    [initData.properties setProperty:@"IceSSL.CertFile" value:@"c_rsa1024.pfx"];
    [initData.properties setProperty:@"IceSSL.Password" value:@"password"];
	
    // Dispatch AMI callbacks on the main thread
    initData.dispatcher = ^(id<ICEDispatcherCall> call, id<ICEConnection> con)
    {
        dispatch_sync(dispatch_get_main_queue(), ^ { [call run]; });
    };
	
    communicator = [ICEUtil createCommunicator:initData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate) 
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil]; 
    
    // When the user starts typing, show the clear button in the text field.
    hostnameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    // Defaults for the UI elements.
    hostnameTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:hostnameKey];
    flushButton.enabled = NO;
    [flushButton setAlpha:0.5];
    
    // This generates a compile time warning, but does actually work!
    [delaySlider setShowValue:YES];
    [timeoutSlider setShowValue:YES];
    
    statusLabel.text = @"Ready";
    
    showAlert = NO;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


#pragma mark UIAlertViewDelegate

-(void)didPresentAlertView:(UIAlertView *)alertView
{
    showAlert = YES;
}

-(void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    showAlert = NO;
}

#pragma mark UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    // If we've already showing an invalid hostname alert, then we ignore enter.
    if(showAlert)
    {
        return NO;
    }

    // Close the text field.
    [theTextField resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Dismiss the keyboard when the view outside the text field is touched.
    [hostnameTextField resignFirstResponder];

    [super touchesBegan:touches withEvent:event];
}

#pragma mark AMI Callbacks

-(void)exception:(ICEException*) ex
{
    [activity stopAnimating];       

    statusLabel.text = @"Ready";

    NSString* s = [NSString stringWithFormat:@"%@", ex];
    // open an alert with just an OK button
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                     message:s
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [alert show];
}

#pragma mark UI Element Callbacks

-(id<DemoHelloPrx>)createProxy
{
    NSString* s;
    NSInteger deliveryMode = [modePicker selectedRowInComponent:0];
    
    s = [NSString stringWithFormat:@"hello:tcp -h \"%@\" -p 10000:ssl -h \"%@\" -p 10001:udp -h \"%@\" -p 10000",
                                   hostnameTextField.text, hostnameTextField.text, hostnameTextField.text];
    
    [[NSUserDefaults standardUserDefaults] setObject:hostnameTextField.text forKey:hostnameKey];

    ICEObjectPrx* prx = [communicator stringToProxy:s];
    switch(deliveryMode)
    {
        case DeliveryModeTwoway:
            prx = [prx ice_twoway];
            break;
        case DeliveryModeTwowaySecure:
            prx = [[prx ice_twoway] ice_secure:YES];
            break;
        case DeliveryModeOneway:
            prx = [prx ice_oneway];
            break;
        case DeliveryModeOnewayBatch:
            prx = [prx ice_batchOneway];
            break;
        case DeliveryModeOnewaySecure:
            prx = [[prx ice_oneway] ice_secure:YES];
            break;
        case DeliveryModeOnewaySecureBatch:
            prx = [[prx ice_batchOneway] ice_secure:YES];
            break;
        case DeliveryModeDatagram:
            prx = [prx ice_datagram];
            break;
        case DeliveryModeDatagramBatch:
            prx = [prx ice_batchDatagram];
            break;
    }
    
    int timeout = (int)(timeoutSlider.value * 1000.0f); // Convert to ms.
    if(timeout != 0)
    {
        prx = [prx ice_timeout:timeout];
    }
    
    return [DemoHelloPrx uncheckedCast:prx];
}

-(void)sayHello:(id)sender
{
    @try
    {
        id<DemoHelloPrx> hello = [self createProxy];
        int delay = (int)(delaySlider.value * 1000.0f); // Convert to ms.
        
        NSInteger deliveryMode = [modePicker selectedRowInComponent:0];
        if(deliveryMode != DeliveryModeOnewayBatch &&
           deliveryMode != DeliveryModeOnewaySecureBatch &&
           deliveryMode != DeliveryModeDatagramBatch)
        {
            __block BOOL response = NO;
            id<ICEAsyncResult> result = [hello begin_sayHello:delay 
                                                     response:^ {
                    response = YES;
                    [activity stopAnimating];
                    statusLabel.text = @"Ready";
                }
            exception:^(ICEException* ex) {
                    response = YES;
                    [self exception:ex];
                }
            sent:^(BOOL sentSynchronously) {
                    if(response)
                    {
                        return; // Response was received already.
                    }
                    
                    NSInteger deliveryMode = [modePicker selectedRowInComponent:0];
                    if(deliveryMode == DeliveryModeTwoway || deliveryMode == DeliveryModeTwowaySecure)
                    {
                        statusLabel.text = @"Waiting for response";
                        [activity startAnimating];
                    }
                    else if(!sentSynchronously)
                    {
                        statusLabel.text = @"Ready";
                        [activity stopAnimating];       
                    }
                    
                }];
            if(![result sentSynchronously])
            {
                
                [activity startAnimating];
                statusLabel.text = @"Sending request";
            }
            else 
            {
                NSInteger deliveryMode = [modePicker selectedRowInComponent:0];
                if(deliveryMode != DeliveryModeTwoway && deliveryMode != DeliveryModeTwowaySecure)
                {
                    statusLabel.text = @"Ready";
                }
            }
        }
        else
        {
            [hello sayHello:delay];
            flushButton.enabled = YES;
            [flushButton setAlpha:1.0];
            statusLabel.text = @"Queued hello request";
        }
    }
    @catch(ICELocalException* ex)
    {
        [self exception:ex];
    }
}

-(void)shutdown:(id)sender
{
    @try
    {
        id<DemoHelloPrx> hello = [self createProxy];
        NSInteger deliveryMode = [modePicker selectedRowInComponent:0];
        if(deliveryMode != DeliveryModeOnewayBatch &&
           deliveryMode != DeliveryModeOnewaySecureBatch &&
           deliveryMode != DeliveryModeDatagramBatch)
        {
            [hello begin_shutdown:^ { [activity stopAnimating]; statusLabel.text = @"Ready"; }
                        exception:^(ICEException* ex) { [self exception:ex]; }];
            if(deliveryMode == DeliveryModeTwoway || deliveryMode == DeliveryModeTwowaySecure)
            {
                [activity startAnimating];
                statusLabel.text = @"Waiting for response";
            }
        }
        else
        {
            [hello shutdown];
            flushButton.enabled = YES;
            [flushButton setAlpha:1.0];
            statusLabel.text = @"Queued shutdown request";
        }
    }
    @catch(ICELocalException* ex)
    {
        [self exception:ex];
    }
}

-(void)flushBatch:(id) sender
{
    @try
    {
        [communicator begin_flushBatchRequests:^(ICEException* ex) { [self exception:ex]; }
										  sent:^(BOOL sentSynchronously)
		 {
			 flushButton.enabled = NO;
			 [flushButton setAlpha:0.5];
			 statusLabel.text = @"Flushed batch requests";
		 }];
    }
    @catch(ICELocalException* ex)
    {
		[self exception:ex];
    }
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 8;
}

#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch(row)
    {
        case DeliveryModeTwoway:
            return @"Twoway";
        case DeliveryModeTwowaySecure:
            return @"Twoway secure";
        case DeliveryModeOneway:
            return @"Oneway";
        case DeliveryModeOnewayBatch:
            return @"Oneway batch";
        case DeliveryModeOnewaySecure:
            return @"Oneway secure";
        case DeliveryModeOnewaySecureBatch:
            return @"Oneway secure batch";
        case DeliveryModeDatagram:
            return @"Datagram";
        case DeliveryModeDatagramBatch:
            return @"Datagram batch";
    }
    return @"UNKNOWN";
}

@end


