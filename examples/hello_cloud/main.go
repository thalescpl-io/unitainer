package main

import (
	"crypto/cipher"
	"fmt"
	"github.com/ThalesIgnite/crypto11"
	"github.com/ThalesIgnite/gose"
	"github.com/ThalesIgnite/gose/jose"
	"io"
)

var aeskey1 *crypto11.SecretKey
var aead cipher.AEAD
var aeskey1ID = "caa862b2-6129-4209-9355-a929658b7901"
var aeskey1Label = "aeskey1"

func main() {

	cfg := &crypto11.Config{
		Path:       "/dpod/client/libs/64/libCryptoki2.so",
		TokenLabel: "demo",
		Pin:        "1234",
	}
	ctx11, err := crypto11.Configure(cfg)
	// Connecting to the HSM
	if err != nil {
		panic(err)
	}
	if aeskey1, err = ctx11.GenerateSecretKeyWithLabel([]byte(aeskey1ID), []byte(aeskey1Label), 256, crypto11.CipherAES); err != nil {
		panic(err)
	}

	// we should have a key handle now... let's try it out...
	if aead, err = aeskey1.NewGCM(); err != nil {
		panic(err)
	}

	// end config
	var rng io.Reader
	if rng, err = ctx11.NewRandomReader(); err != nil {
		return
	}
	var hsmAEAD gose.AuthenticatedEncryptionKey
	if hsmAEAD, err = gose.NewAesGcmCryptor(aead, rng, aeskey1ID, jose.AlgA256GCM, []jose.KeyOps{jose.KeyOpsEncrypt, jose.KeyOpsDecrypt}); err != nil {
		return
	}
	jwe := gose.NewJweDirectEncryptorImpl(hsmAEAD)
	var encryptedData string
	if encryptedData, err = jwe.Encrypt([]byte("Hello, Cloud!"), nil); err != nil {
		return
	}
	fmt.Printf("From the HSM: %s", encryptedData)
}
