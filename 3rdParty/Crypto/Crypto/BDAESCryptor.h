//
//  Created by Patrick Hogan on 10/12/12.
//


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Super class
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#import "BDCryptor.h"


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Forward Declarations
////////////////////////////////////////////////////////////////////////////////////////////////////////////
@class BDError;


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface BDAESCryptor : BDCryptor

/**
 @return The maximum length of plaintext that can be encrypted with AES cipher for this and derived classes.
 */
- (NSInteger)maximumBlockSize;

- (NSInteger)keySize;

- (BOOL)serializedObjectSatisfiesLengthConstraint:(NSObject *)object
                                            error:(BDError *)error;

- (BOOL)stringSatisfiesLengthConstraint:(NSObject *)object
                                  error:(BDError *)error;

/**
 @return Password based key derivation
 */
- (NSData *)PBKDF2WithKey:(NSString *)key
                     salt:(NSData *)saltDataObject;


@end