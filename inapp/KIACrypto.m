#import "KIACrypto.h"
#import "BDRSACryptor.h"
#import "BDRSACryptorKeyPair.h"
#import "BDError.h"
#import "BDLog.h"
#import <Security/SecBase.h>
#include <CommonCrypto/CommonDigest.h>
#import "NSData+Base64.h"

@interface KIACrypto ()

@property (strong, nonatomic) NSString *publicKeyTag;
@property (strong, nonatomic) NSString *privateKeyTag;

@end

@implementation KIACrypto

#define KIA_TAG @"kia"


+ (id)sharedKIACrypto {
  static KIACrypto *sharedKIACrypto = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedKIACrypto = [[self alloc] init];
  });
  return sharedKIACrypto;
}

- (id)init {
  if (self = [super init]) {
    BDError *error = [[BDError alloc] init];
    BDRSACryptor *RSACryptor = [[BDRSACryptor alloc] init];
    
    _publicKeyTag = [RSACryptor publicKeyIdentifierWithTag:KIA_TAG];
    _privateKeyTag = [RSACryptor publicKeyIdentifierWithTag:KIA_TAG];
    
    SecKeyRef publicKeyRef = [RSACryptor keyRefWithTag:_publicKeyTag error:error];
    SecKeyRef privateKeyRef = [RSACryptor keyRefWithTag:_privateKeyTag error:error];
    
    if (publicKeyRef && privateKeyRef) {
      NSString *publicKeyStr = [RSACryptor X509FormattedPublicKey:_publicKeyTag error:error];
      _publicKeyBase64Str = [[publicKeyStr dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    } else {
      BDRSACryptorKeyPair *RSAKeyPair = [RSACryptor generateKeyPairWithKeyIdentifier:KIA_TAG error:error];
      _publicKeyBase64Str = [[RSAKeyPair.publicKey dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    }
  }
  return self;
}


- (NSString *)getSignatureWithText:(NSData *)plainText {
  
  BDRSACryptor *RSACryptor = [[BDRSACryptor alloc] init];
  BDError *error = [[BDError alloc] init];
  
  SecKeyRef privateKey = [RSACryptor keyRefWithTag:_privateKeyTag error:error];

  
  size_t signedHashBytesSize = SecKeyGetBlockSize(privateKey);
  uint8_t* signedHashBytes = malloc(signedHashBytesSize);
  memset(signedHashBytes, 0x0, signedHashBytesSize);
  
  size_t hashBytesSize = CC_SHA256_DIGEST_LENGTH;
  uint8_t* hashBytes = malloc(hashBytesSize);
  if (!CC_SHA256([plainText bytes], (CC_LONG)[plainText length], hashBytes)) {
    return nil;
  }
  
  SecKeyRawSign(privateKey,
                kSecPaddingPKCS1SHA256,
                hashBytes,
                hashBytesSize,
                signedHashBytes,
                &signedHashBytesSize);
  
  NSData* signedHash = [NSData dataWithBytes:signedHashBytes
                                      length:(NSUInteger)signedHashBytesSize];
  
  if (hashBytes)
    free(hashBytes);
  if (signedHashBytes)
    free(signedHashBytes);
  
  return [signedHash base64EncodedStringWithOptions:0];
}

@end
