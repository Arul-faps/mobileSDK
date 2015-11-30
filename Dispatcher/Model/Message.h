//
//  Message.h
//  Created by Gal Blank on 9/21/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum{
    MESSAGEROUTE_INTERNAL,
    MESSAGEROUTE_API,
    MESSAGEROUTE_OTHER
}messageRoute;

typedef enum{
    MESSAGETYPE_GET_CONFIG = 0,
    NotSet,
    Auth,
    Sale,
    Query,
    Credit,
    CreditRetailOnly,
    Void,
    VoidPartial,
    Settle,
    TipAdjust,
    ReAuth,
    ReSale,
    ReDebit,
    CloseBatch,
    
    //Ach
    AchCredit,
    AchDebit,
    AchGetCategories,
    AchCreateCategory,
    AchUpdateCategory,
    AchDeleteCategory,
    AchSetupStore,
    AchVoid,
    
    //Vault
    VaultCreateContainer,
    VaultCreateAchRecord,
    VaultCreateCreditCardRecord,
    VaultCreateShippingRecord,
    VaultDeleteContainerAndAllAsscData,
    VaultDeleteAchRecord,
    VaultDeleteCreditCardRecord,
    VaultDeleteShippingRecord,
    VaultUpdateContainer,
    VaultUpdateAchRecord,
    VaultUpdateCreditCardRecord,
    VaultUpdateShippingRecord,
    
    VaultQueryVault,
    VaultQueryVaultCreditCard,
    VaultQueryVaultAch,
    VaultQueryVaultShippingAddr,
    
    //Misc
    TokenToCreditCard,
    CreditCardToToken,
    TokenForTransaction,
    TokenForTransactionRequest,
    
    IngenicoMessage
}messageType;

typedef enum {
    FLOATINGBUTTON_TYPE_MENU = 1,
    FLOATINGBUTTON_TYPE_BACK
}FLOATINGBUTTONTYPE;

#define DEFAULT_TTL 5.0
#define TTL_NOW 0.5;
#define CLEANUP_TIMER 10.0


@interface Message : NSObject

@property(nonatomic)messageRoute mesRoute;
@property(nonatomic)messageType mesType;
@property(nonatomic,strong)id params;
@property(nonatomic)float ttl;

@end
