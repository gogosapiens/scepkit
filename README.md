# SCEPKit Configuration Guide

This guide provides instructions on how to configure the Swift Package using Firebase Remote Config. The configuration is stored in the `scepkit_config` key, and the current version is specified in the `scepkit_config_var` key.

## Configuration Overview

Below is the JSON configuration for the Swift Package. Please note that API keys, font names, and certain localization data have been replaced with placeholders or limited to English and French for clarity.

```json
{
  "v1": {
    "app": {
      "appleAppId": "YOUR_APPLE_APP_ID",
      "adaptyApiKey": "YOUR_ADAPTY_API_KEY",
      "amplitudeApiKey": "YOUR_AMPLITUDE_API_KEY",
      "adStartDelay": 0,
      "adInterstitialInterval": 40,
      "requestTracking": true,
      "adAppId": "YOUR_AD_APP_ID",
      "adInterstitialId": "YOUR_AD_INTERSTITIAL_ID",
      "adAppOpenId": "YOUR_AD_APP_OPEN_ID",
      "adBannerId": "YOUR_AD_BANNER_ID",
      "adRewardedId": "YOUR_AD_REWARDED_ID",
      "termsURL": "https://yourwebsite.com/terms",
      "privacyURL": "https://yourwebsite.com/privacy",
      "feedbackURL": "https://yourwebsite.com/feedback",
      "productsIds": {
        "short": "com.yourapp.subscription.short",
        "shortTrial": "com.yourapp.subscription.short.trial",
        "long": "com.yourapp.subscription.long"
      },
      "style": "yourStyle",
      "fontNames": {
        "semibold": "YOUR_SEMIBOLD_FONT_NAME",
        "bold": "YOUR_BOLD_FONT_NAME",
        "medium": "YOUR_MEDIUM_FONT_NAME"
      }
    },
    "onboarding": {
      "slides": [
        {
          "title": {
            "en": "Welcome to Our App",
            "fr": "Bienvenue dans Notre Application"
          },
          "imageURL": "https://yourcdn.com/onboarding-slide-1.png"
        },
        {
          "title": {
            "en": "Discover New Features",
            "fr": "Découvrez de Nouvelles Fonctionnalités"
          },
          "imageURL": "https://yourcdn.com/onboarding-slide-2.png"
        },
        {
          "title": {
            "en": "Stay Connected",
            "fr": "Restez Connecté"
          },
          "imageURL": "https://yourcdn.com/onboarding-slide-3.png"
        }
      ]
    },
    "settings": {
      "title": {
        "en": "App PRO",
        "fr": "Application PRO"
      },
      "subtitle": {
        "en": "Get full access with a subscription",
        "fr": "Accédez à tout avec un abonnement"
      },
      "features": [
        {
          "en": "All Premium Features",
          "fr": "Toutes les Fonctionnalités Premium"
        },
        {
          "en": "Ad-Free Experience",
          "fr": "Expérience Sans Publicités"
        }
      ],
      "imageURL": "https://yourcdn.com/settings-image.png"
    },
    "paywalls": {
      "main": {
        "single": {
          "config": {
            "imageURL": "https://yourcdn.com/paywall-single.png",
            "title": {
              "en": "Unlimited Access to All Features",
              "fr": "Accès Illimité à Toutes les Fonctionnalités"
            },
            "features": [
              {
                "en": "Unlimited Messages",
                "fr": "Messages Illimités"
              },
              {
                "en": "Premium Support",
                "fr": "Support Premium"
              }
            ],
            "laurel": {
              "en": "BEST AI MODELS INSIDE",
              "fr": "LES MEILLEURS MODÈLES AI"
            }
          }
        },
        "adapty": {
          "placementId": "YOUR_ADAPTY_PLACEMENT_ID"
        }
      },
      "onboarding": {
        "vertical": {
          "config": {
            "imageURL": "https://yourcdn.com/paywall-vertical.png",
            "title": {
              "en": "Get Full Access with App PRO",
              "fr": "Accédez à Tout avec l'Application PRO"
            },
            "features": [
              {
                "en": "Unlimited Chat Messages",
                "fr": "Messages de Chat Illimités"
              },
              {
                "en": "Fastest AI Model",
                "fr": "Modèle AI le Plus Rapide"
              }
            ]
          }
        }
      }
    }
  }
}
```

## Firebase Remote Config Keys

- **Configuration Key**: `scepkit_config`
- **Version Key**: `scepkit_config_var`

Ensure you update both keys in Firebase Remote Config to apply the new configuration.

## Product Identifiers

The `productsIds` object contains identifiers for in-app purchase subscriptions:

- **short**: Short period subscription (e.g., weekly or monthly).
- **shortTrial**: Short period subscription with a trial period. Optional. If not specified, the trial switch will be hidden in the paywalls.
- **long**: Long period subscription (e.g., yearly).

### Example

```json
"productsIds": {
  "short": "com.yourapp.subscription.short",
  "shortTrial": "com.yourapp.subscription.short.trial",
  "long": "com.yourapp.subscription.long"
}
```

## Paywalls Configuration

The `paywalls` object defines how paywalls are displayed in the app. There are two main placements:

- **main**: Shown throughout the app.
- **onboarding**: Shown during the onboarding process.

### Paywall Types

There are three types of paywalls:

1. **Single Paywall** (`single`): Displays only one product, which is the short subscription or short trial if available.

2. **Vertical Paywall** (`vertical`): Displays two products—short and long subscriptions. If `shortTrial` exists, it will also be included.

3. **Adapty Paywall** (`adapty`): This paywall is controlled by the Adapty SDK and requires a `placementId` to display.

### Single Paywall Example

Shown in the `main` placement.

```json
"main": {
  "single": {
    "config": {
      "imageURL": "https://yourcdn.com/paywall-single.png",
      "title": {
        "en": "Unlimited Access to All Features",
        "fr": "Accès Illimité à Toutes les Fonctionnalités"
      },
      "features": [
        {
          "en": "Unlimited Messages",
          "fr": "Messages Illimités"
        },
        {
          "en": "Premium Support",
          "fr": "Support Premium"
        }
      ],
      "laurel": {
        "en": "BEST AI MODELS INSIDE",
        "fr": "LES MEILLEURS MODÈLES AI"
      }
    }
  }
}
```

### Vertical Paywall Example

Shown in the `onboarding` placement.

```json
"onboarding": {
  "vertical": {
    "config": {
      "imageURL": "https://yourcdn.com/paywall-vertical.png",
      "title": {
        "en": "Get Full Access with App PRO",
        "fr": "Accédez à Tout avec l'Application PRO"
      },
      "features": [
        {
          "en": "Unlimited Chat Messages",
          "fr": "Messages de Chat Illimités"
        },
        {
          "en": "Fastest AI Model",
          "fr": "Modèle AI le Plus Rapide"
        }
      ]
    }
  }
}
```

### Adapty Paywall Example

The Adapty paywall is controlled by the Adapty SDK and requires a placement ID. This is used for displaying dynamic paywalls based on the user's interaction.

```json
"main": {
  "adapty": {
    "placementId": "YOUR_ADAPTY_PLACEMENT_ID"
  }
}
```

## Localization

For brevity, only English (`en`) and French (`fr`) localizations are shown in the configuration. You can add more languages as needed by extending the localization objects.

## Notes

- **API Keys and Font Names**: Replace placeholders like `YOUR_APPLE_APP_ID`, `YOUR_ADAPTY_API_KEY`, and `YOUR_SEMIBOLD_FONT_NAME` with your actual values.
- **Image URLs**: Update `imageURL` fields with the correct paths to your assets.
- **Terms and Privacy URLs**: Ensure `termsURL`, `privacyURL`, and `feedbackURL` point to your actual web pages.
- **Product Identifiers**: Confirm that `productsIds` match the identifiers set up in your in-app purchase configurations.

## Conclusion

By following this guide, you should be able to configure the Swift Package to suit your app's needs. Make sure to update all placeholders with your actual data and test the configuration thoroughly before deploying it to production.
