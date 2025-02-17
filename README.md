# SCEPKit SDK Documentation

## Описание
SCEPKit — это фреймворк для iOS, который включает в себя:
- Сплэш-скрин с загрузкой **Firebase Remote Config** и других SDK
- Онбординг
- Экраны подписки и/или покупки кредитов
- Показ рекламы
- Экран настроек с **Terms of Use** и **Privacy Policy**
- Аналитику
- Глобальные шрифты и цвета приложения

## Интеграция в Xcode
В Xcode-проекте уже интегрированы:
- **SCEPKit Framework**
- **Шрифт приложения** (`SCEPKit/Fonts`)
- **Цвета и изображения** (`SCEPKit/SCEPKitAssets.xcassets`)
- **Firebase Remote Config** (`SCEPKit/GoogleService-Info.plist`)
- **Кэш Remote Config** (`SCEPKit/RemoteConfig-Info.plist`)
- **Сплэш-скрин** (`SCEPKit/LaunchScreen.storyboard`)
- **Настройки проекта** (`AppName.xcodeproj` и `Info.plist`)
- **Инициализация MainController** в `AppDelegate.swift`

> ⚠️ **Важно!** Не изменяйте название проекта, папки проекта, путь к `Info.plist` и `SCEPKit`, чтобы избежать ошибок при сборке.

---

## Принцип работы
При запуске приложение загружает **Firebase Remote Config**, содержащий тексты, изображения онбординга, экраны подписки и настроек. Если за 7 секунд не удалось загрузить конфигурацию, используется закешированная версия из `SCEPKit/RemoteConfig-Info.plist`.

### Основной цикл работы:
1. **Сплэш-скрин** → загрузка конфигурации.
2. **Онбординг** → три экрана с информацией (изображения могут загружаться продюсером через сервер).
3. **Экран подписки или покупки кредитов** → монетизация.
4. **MainController** → основной экран приложения.

В момент загрузки `MainController` может отображаться реклама или маркетинговый попап. Чтобы определить, когда приложение полностью готово, используйте:
- `SCEPKit.isApplicationReady`
- `SCEPKit.applicationDidBecomeReadyNotification`

После получения `SCEPKit.applicationDidBecomeReadyNotification` приложение работает как обычное iOS-приложение, за исключением следующих подсистем:
- Подписки
- Кредиты
- Реклама
- Экран настроек
- Глобальные шрифты и цвета
- Аналитика

> 🔗 **Примеры кода**: [SCEPKit Demo](https://github.com/gogosapiens/scepkit-demo)

---

## Монетизация
### Поддерживаемые модели
SCEPKit поддерживает три модели монетизации:
#### 1. **Subscription** (Подписка)
Разделяет пользователей на **premium** и **не-premium**:
- Доступ к premium-контенту через `SCEPKit.isPremium`
- `SCEPKit.premiumUpdatedNotification` для обновления UI при подписке.
- Доступ к premium-контенту, включая логику проверки статуса юзера:
  ```swift
  SCEPKit.accessPremiumContent(from: controller, placement: "feature_name") {
      // Код отображения premium-контента
  }
  ```
- Прямой вызов экрана подписки:
  ```swift
  SCEPKit.showPaywallController(from: controller, placement: "feature_name") {
      // Код после успешной подписки
  }
  ```

#### 2. **Credits** (Кредиты)
- Пользователи покупают кредиты за разовые платежи.
- Проверка количества кредитов:
  ```swift
  SCEPKit.hasCredits(5) // true/false
  ```
- Доступ к платному контенту, включая логику проверки количества кредитов:
  ```swift
  SCEPKit.accessCreditsContent(amount: 5, controller: self, placement: "feature_name") { handler in
      // Код отображения контента
  }
  ```
- Прямой вызов экрана кредитов:
  ```swift
  SCEPKit.showPaywallController(from: controller, placement: "feature_name") {
      // Код после успешной подписки
  }


#### 3. **Subscription + Credits** (Подписка + Кредиты)
- Подписка даёт кредиты каждую неделю.
- Покупка дополнительных кредитов доступна только подписчикам.
- Работа аналогична модели **Credits**, но подписка необходима для их покупки.
- Доступ к платному контенту, включая логику проверки статуса подписки и количества кредитов:
  ```swift
  SCEPKit.accessCreditsContent(amount: 5, controller: self, placement: "feature_name") { handler in
      // Код отображения контента
  }
  ```

---

## Реклама
SCEPKit поддерживает несколько типов рекламы:
### 1. **App Open Ad** (Запуск)
- Автоматически показывается при запуске или возвращении из фона.
- Определить, загружено ли приложение: `SCEPKit.isApplicationReady`, `SCEPKit.applicationDidBecomeReadyNotification`.


### 2. **Banner Ad** (Баннер)
```swift
SCEPKit.getBannerView(placement: "chat_screen") { banner in
    // Добавить баннер в UI
} dismissHandler: { banner in
    // Удалить баннер из UI
}
```

### 3. **Interstitial Ad** (Полноэкранная)
```swift
let shown = SCEPKit.showInterstitialAd(from: self, placement: "game_end") {
    // Действие после закрытия рекламы
}
```

### 4. **Rewarded Ad** (С бонусом)
```swift
SCEPKit.showRewardedAd(from: self, placement: "free_coins") { rewarded in
    if rewarded {
        // Выдать награду пользователю
    }
}
```

---

## Экран настроек
Для показа экрана настроек вызовите:
```swift
SCEPKit.showSettingsController(from: self, customActions: [])
```

На экране настроек уже есть ссылки на **Privacy Policy** и **Terms of Use**.
В тестовых билдах отображаются дополнительные опции для QA.

---

## Дополнительные возможности
### Аналитика, Remote Config, Шрифты, Цвета и Локализация
- Примеры использования смотрите в [SCEPKit Demo](https://github.com/gogosapiens/scepkit-demo).


---
## Прочее
| Git Branch & SCEPEnvironment | Ad ids prefix | Product ids & Adapty key prefix |
| ---- | ----- | ---------------- |
| main | test | test |
| testflight | test | test |
| camouflage | test | test |
| prodtest | test | prod |
| appstore | prod | prod |
