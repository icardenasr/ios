//
//  NubeLoginViewController.h
//  Owncloud iOs Client
//
//  Created by Israel Cardenas on 14/6/16.
//
//

#import <UIKit/UIKit.h>
#import "CheckAccessToServer.h"
#import "SSOViewController.h"
#import "CheckSSOServer.h"

@interface NubeLoginViewController : UIViewController <UITextFieldDelegate, CheckAccessToServerDelegate, SSODelegate, CheckSSOServerDelegate> {

    // Valores introducidos para elementos del interfaz
    NSString *user;
    NSString *password;
    
    // Flags
    BOOL isUserTextUp;
    BOOL isPasswordTextUp;
    BOOL isConnectionToServer;
    BOOL isNeedToCheckAgain;
    BOOL isHttps;
    BOOL isHttpsSecure;
    BOOL isCheckingTheServerRightNow;
    BOOL isSSLAccepted;
    BOOL isErrorOnCredentials;
    BOOL isError500;
    BOOL isLoginButtonEnabled;
    BOOL urlEditable;
    BOOL userNameEditable;
    BOOL hasInvalidAuth;

}

// Propiedades para elementos del interfaz
@property (nonatomic, retain) NSString *nombre;
@property (nonatomic, retain) NSString *direccion;
@property (nonatomic, retain) IBOutlet UILabel *appNameLabel;
@property (nonatomic, retain) IBOutlet UITextField *userTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *aiview;
@property (nonatomic, retain) IBOutlet UIButton *connectButton;
@property (nonatomic, retain) IBOutlet UIButton *termsButton;

// Propiedades de valores introducidos para elementos del interfaz
@property (nonatomic, retain) NSString *user;
@property (nonatomic, retain) NSString *password;

// Propiedades para variables importantes de conexion
@property (nonatomic, strong) NSString *connectString;

// Metodo de accion para autenticarse
- (IBAction)connectWithServer:(id)sender;

// Metodo de accion para abrir los terminos de uso
- (IBAction)showTerms:(id)sender;

@end
