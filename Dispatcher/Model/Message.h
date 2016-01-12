//
//  Message.h
//  Created by Gal Blank on 9/21/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import <Foundation/Foundation.h>

<<<<<<< HEAD
typedef NS_ENUM(NSInteger, MessageRoute) {
    MessageRouteMessageInternal = 1,
    MessageRouteMessageApiGet = 2,
    MessageRouteMessageApiPost = 3,
    MessageRouteMessageApiPut = 4,
    MessageRouteMessageApiDelete = 5,
    MessageRouteMessageApiExternal = 6,
    MessageRouteMessageApiOther = 7
};


typedef NS_ENUM(NSInteger, messageType){
    messageTypeMESSAGETYPE_GET_CONFIG = 0,
    messageTypeNotSet,
    messageTypeAuth,
    messageTypeSale,
    messageTypeQuery,
    messageTypeCredit,
    messageTypeCreditRetailOnly,
    messageTypeVoid,
    messageTypeVoidPartial,
    messageTypeSettle,
    messageTypeTipAdjust,
    messageTypeReAuth,
    messageTypeReSale,
    messageTypeReDebit,
    messageTypeCloseBatch,
    
    //Ach
    messageTypeAchCredit,
    messageTypeAchDebit,
    messageTypeAchGetCategories,
    messageTypeAchCreateCategory,
    messageTypeAchUpdateCategory,
    messageTypeAchDeleteCategory,
    messageTypeAchSetupStore,
    messageTypeAchVoid,
    
    //Vault
    messageTypeVaultCreateContainer,
    messageTypeVaultCreateAchRecord,
    messageTypeVaultCreateCreditCardRecord,
    messageTypeVaultCreateShippingRecord,
    messageTypeVaultDeleteContainerAndAllAsscData,
    messageTypeVaultDeleteAchRecord,
    messageTypeVaultDeleteCreditCardRecord,
    messageTypeVaultDeleteShippingRecord,
    messageTypeVaultUpdateContainer,
    messageTypeVaultUpdateAchRecord,
    messageTypeVaultUpdateCreditCardRecord,
    messageTypeVaultUpdateShippingRecord,
    
    messageTypeVaultQueryVault,
    messageTypeVaultQueryVaultCreditCard,
    messageTypeVaultQueryVaultAch,
    messageTypeVaultQueryVaultShippingAddr,
    
    //Misc
    messageTypeTokenToCreditCard,
    messageTypeCreditCardToToken,
    messageTypeTokenForTransaction,
    messageTypeTokenForTransactionRequest,
    
    messageTypeIngenicoMessage,
    
    messageTypeStartScanners,
    messageTypeStopScanners,
    messageTypeUserInitializeHardware,
    
    messageTypeProductScanned,
    
    messageTypeOnHoldOrderSync,
    messageTypeOnHoldOrdersBatchSync,

    messageTypeGotoPortal,
    messageTypeComebackFromPortal

};

typedef enum {
    FLOATINGBUTTON_TYPE_MENU = 1,
    FLOATINGBUTTON_TYPE_BACK
}FLOATINGBUTTONTYPE;

=======
>>>>>>> a48ee7ba9c2880518082747d8c1aacba9abdbe8e
#define DEFAULT_TTL 5.0
#define TTL_NOW 0.1;
#define CLEANUP_TIMER 10.0

#define PRINTERS @"printers"
#define SCANNERS @"scanners"
#define RECEIPT_PRINTERS @"receipt"
#define ITEMS_PRINTERS   @"items"

@interface Message : NSObject

@property(nonatomic,strong)NSString *routingKey;
@property(nonatomic,strong)NSString *httpMethod;
@property(nonatomic,strong)id params;
@property(nonatomic)float ttl;
@property(nonatomic,strong)NSString *messageApiEndPoint;

-(NSString*)routeFromRoutingKey;
-(NSString*)messageFromRoutingKey;
@end
