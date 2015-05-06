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

#import <UIKit/UIKit.h>

#include <iostream>
#include <string>

using namespace Demo;

// Various delivery mode constants
#define DeliveryModeTwoway  0
#define DeliveryModeTwowaySecure 1
#define DeliveryModeOneway 2
#define DeliveryModeOnewayBatch  3
#define DeliveryModeOnewaySecure 4
#define DeliveryModeOnewaySecureBatch 5
#define DeliveryModeDatagram 6
#define DeliveryModeDatagramBatch 7

using namespace std;

namespace
{

class Dispatcher : public Ice::Dispatcher
{
public:

    virtual void 
    dispatch(const Ice::DispatcherCallPtr& call, const Ice::ConnectionPtr&)
    {
        dispatch_sync(dispatch_get_main_queue(), ^ { 
                @autoreleasepool
                {
                    call->run(); 
                }
            });
    }

private:
};

class HelloClient : public IceUtil::Shared
{
public:
    
    HelloClient(HelloController* controller) :
        _controller(controller),
        _pending(0)
    {
        Ice::InitializationData initData;
        initData.properties = Ice::createProperties();        
        initData.properties->setProperty("IceSSL.CheckCertName", "0");
        initData.properties->setProperty("IceSSL.CertAuthFile", "cacert.der");
        initData.properties->setProperty("IceSSL.CertFile", "c_rsa1024.pfx");
        initData.properties->setProperty("IceSSL.Password", "password");
        initData.dispatcher = new Dispatcher();
        _communicator = Ice::initialize(initData);
    }
    
    Demo::HelloPrx createProxy(const string& hostname, int deliveryMode, int timeout)
    {
        _deliveryMode = deliveryMode;
        ostringstream os;
        os << "hello:tcp -h \"" << hostname << "\" -p 10000:ssl -h \"" << hostname << "\" -p 10001";
        os << ":udp -h \"" << hostname << "\" -p 10000";
        
        Ice::ObjectPrx prx = _communicator->stringToProxy(os.str());
        
        switch(deliveryMode)
        {
            case DeliveryModeTwoway:
                prx = prx->ice_twoway();
                break;
            case DeliveryModeTwowaySecure:
                prx = prx->ice_twoway()->ice_secure(true);
                break;
            case DeliveryModeOneway:
                prx = prx->ice_oneway();
                break;
            case DeliveryModeOnewayBatch:
                prx = prx->ice_batchOneway();
                break;
            case DeliveryModeOnewaySecure:
                prx = prx->ice_oneway()->ice_secure(true);
                break;
            case DeliveryModeOnewaySecureBatch:
                prx = prx->ice_batchOneway()->ice_secure(true);
                break;
            case DeliveryModeDatagram:
                prx = prx->ice_datagram();
                break;
            case DeliveryModeDatagramBatch:
                prx = prx->ice_batchDatagram();
                break;
        }
        
        if(timeout != 0)
        {
            prx = prx->ice_timeout(timeout);
        }
        
        return Demo::HelloPrx::uncheckedCast(prx);
    }
    
    void sayHello(const string& hostname, int deliveryMode, int timeout, int delay)
    {
        try
        {
            _pending++;

            Demo::HelloPrx hello = createProxy(hostname, deliveryMode, timeout);
            if(deliveryMode != DeliveryModeOnewayBatch &&
               deliveryMode != DeliveryModeOnewaySecureBatch &&
               deliveryMode != DeliveryModeDatagramBatch)
            {
                Ice::AsyncResultPtr result = 
                    hello->begin_sayHello(delay, newCallback_Hello_sayHello(this,
                                                                            &HelloClient::response,
                                                                            &HelloClient::exception,
                                                                            &HelloClient::sent));
                
                if(!result->sentSynchronously())
                {
                    [_controller sendingRequest];
                }
                else if(_pending == 0)
                {
                    [_controller ready];
                }
            }
            else
            {
                hello->sayHello(delay);
                [_controller queuedRequest];
            }
        }
        catch(const Ice::LocalException& ex)
        {
            exception(ex);
        }
    }
    
    void response()
    {
        if(--_pending == 0)
        {
            [_controller ready];
        }
    }
    
    void sent(bool sentSynchronously)
    {
        if(_pending == 0)
        {
            return; // Response was received already.
        }
        
        if(_deliveryMode == DeliveryModeTwoway || _deliveryMode == DeliveryModeTwowaySecure)
        {
            [_controller waitingForResponse];
        }
        else if(!sentSynchronously)
        {
            [_controller requestSend];
        }
    }
    
    void exception(const Ice::Exception& ex)
    {
        _pending--;
        ostringstream os;
        os << ex;
        const string s = os.str();
        NSString* err = [NSString stringWithUTF8String:s.c_str()];
        [_controller exception:err];
    }
    
    void shutdown(const string& hostname, int deliveryMode, int timeout)
    {
        try
        {
            _pending++;
            Demo::HelloPrx hello = createProxy(hostname, deliveryMode, timeout);
            if(deliveryMode != DeliveryModeOnewayBatch &&
               deliveryMode != DeliveryModeOnewaySecureBatch &&
               deliveryMode != DeliveryModeDatagramBatch)
            {
                Ice::AsyncResultPtr result = hello->begin_shutdown(newCallback_Hello_shutdown(this, 
                                                                                              &HelloClient::response, 
                                                                                              &HelloClient::exception));
                
                if(!result->sentSynchronously())
                {
                    [_controller sendingRequest];
                }
                else 
                {
                    [_controller requestSend];
                }
            }
            else
            {
                hello->shutdown();
                [_controller queuedRequest];
            }
        }
        catch(const Ice::LocalException& ex)
        {
            exception(ex);
        }
    }
    
    void flushBatchSend(bool)
    {
        [_controller flushBatchSend];
    }
    
    void flushBatch()
    {
        try
        {
            Ice::AsyncResultPtr result = _communicator->begin_flushBatchRequests(
                Ice::newCallback_Communicator_flushBatchRequests(this, 
                                                                 &HelloClient::exception, 
                                                                 &HelloClient::flushBatchSend));
        }
        catch(const Ice::LocalException& ex)
        {
            exception(ex);
        }
    }
                                          
    void destroy()
    {
        if(_communicator)
        {
            _communicator->destroy();
            _communicator = 0;
        }
    }
                                    
private:

    IceUtil::Mutex _mutex;
    HelloController* _controller;
    Ice::CommunicatorPtr _communicator;
    int _pending;
    int _deliveryMode;
};

typedef IceUtil::Handle<HelloClient> HelloClientPtr;
HelloClientPtr client;

}
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
    if(client)
    {
        client->destroy();
    }
}

-(void)viewDidLoad
{	
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
    
    client = new HelloClient(self);
    
    showAlert = NO;
}

-(void)waitingForResponse
{
    statusLabel.text = @"Waiting for response";
    [activity startAnimating];
}

-(void)sendingRequest
{
    statusLabel.text = @"Sending request";
    [activity startAnimating];
}

-(void)ready
{
    statusLabel.text = @"Ready";
    [activity stopAnimating];
}

-(void)requestSend
{
    NSInteger deliveryMode = [modePicker selectedRowInComponent:0];
    if(deliveryMode != DeliveryModeTwoway && deliveryMode != DeliveryModeTwowaySecure)
    {
        statusLabel.text = @"Ready";
        [activity stopAnimating];
    }
}

-(void)queuedRequest
{
    flushButton.enabled = YES;
    [flushButton setAlpha:1.0];
    statusLabel.text = @"Queued hello request";
}

-(void)flushBatchSend
{
    flushButton.enabled = NO;
    [flushButton setAlpha:0.5];
    statusLabel.text = @"Flushed batch requests";
}


-(void)sayHello:(id)sender
{
    client->sayHello([hostnameTextField.text cStringUsingEncoding:[NSString defaultCStringEncoding]], 
                     (int)[modePicker selectedRowInComponent:0],
                     (int)(timeoutSlider.value * 1000.0f),     // Convert to ms.
                     (int)(delaySlider.value * 1000.0f));  // Convert to ms.
    
}

-(void)flushBatch:(id)sender
{
    client->flushBatch();    
}

-(void)shutdown:(id)sender
{
    client->shutdown([hostnameTextField.text cStringUsingEncoding:[NSString defaultCStringEncoding]], 
                     (int)[modePicker selectedRowInComponent:0],
                     (int)(delaySlider.value * 1000.0f));  // Convert to ms.
    
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

-(void)dealloc
{
    [flushButton release];
    [hostnameTextField release];
    [statusLabel release];
    [timeoutSlider release];
    [delaySlider release];
    [activity release];
    [modePicker release];
    [super dealloc];
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

-(void)exception:(NSString*)s
{
    [activity stopAnimating];       
    
    statusLabel.text = @"Ready";
    
    // open an alert with just an OK button
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error"
                                                     message:s
                                                        delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil] autorelease];
    [alert show];
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


