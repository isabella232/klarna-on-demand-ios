#import "KODCrypto.h"
#import "BDRSACryptor.h"
#import "BDRSACryptorKeyPair.h"
#import "BDError.h"
#import "BDLog.h"
#import <Security/SecBase.h>
#include <CommonCrypto/CommonDigest.h>
#import "NSData+Base64.h"
#import "NSString+Base64.h"

@implementation KODCrypto

NSString *const KodTag = @"kod";

+ (id)sharedKODCrypto {
  static KODCrypto *sharedKODCrypto = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedKODCrypto = [[self alloc] init];
  });
  return sharedKODCrypto;
}

- (id)init {
  if (self = [super init]) {
    BDRSACryptor *RSACryptor = [[BDRSACryptor alloc] init];
    
    NSString *publicKeyTag = [RSACryptor publicKeyIdentifierWithTag:KodTag];
    NSString *privateKeyTag = [RSACryptor privateKeyIdentifierWithTag:KodTag];
    
    SecKeyRef publicKeyRef = [RSACryptor keyRefWithTag:publicKeyTag error:nil];
    SecKeyRef privateKeyRef = [RSACryptor keyRefWithTag:privateKeyTag error:nil];
    if (publicKeyRef && privateKeyRef)
    {
      NSString *publicKeyStr = [RSACryptor X509FormattedPublicKey:publicKeyTag error:nil];
      _publicKeyBase64Str = [publicKeyStr base64EncodedString];
    }
    else
    {
      BDError *error = [[BDError alloc] init];
      BDRSACryptorKeyPair *RSAKeyPair = [RSACryptor generateKeyPairWithKeyIdentifier:KodTag error:error];
      NSAssert(RSAKeyPair, @"Failed to create rsa key-pair");
      
      _publicKeyBase64Str = [RSAKeyPair.publicKey base64EncodedString];
    }
  }
  return self;
}


- (NSString *)signWithData:(NSData *)plainData {
  
  BDRSACryptor *RSACryptor = [[BDRSACryptor alloc] init];
  BDError *error = [[BDError alloc] init];
  
  NSString *privateKeyTag = [RSACryptor privateKeyIdentifierWithTag:KodTag];
  SecKeyRef privateKey = [RSACryptor keyRefWithTag:privateKeyTag error:error];
  
  size_t signedHashBytesSize = SecKeyGetBlockSize(privateKey);
  uint8_t* signedHashBytes = malloc(signedHashBytesSize);
  memset(signedHashBytes, 0x0, signedHashBytesSize);
  
  size_t hashBytesSize = CC_SHA256_DIGEST_LENGTH;
  uint8_t* hashBytes = malloc(hashBytesSize);
  if (!CC_SHA256([plainData bytes], (CC_LONG)[plainData length], hashBytes)) {
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
  
  if (hashBytes) {
    free(hashBytes);
  }
    
  if (signedHashBytes) {
    free(signedHashBytes);
  }
  
  return [signedHash base64EncodedString];
}

@end
